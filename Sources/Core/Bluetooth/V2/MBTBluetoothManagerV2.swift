import Foundation
import CoreBluetooth

public class MBTBluetoothManagerV2 {

  //----------------------------------------------------------------------------
  // MARK: - properties
  //----------------------------------------------------------------------------

  /******************** Central ********************/

  private let central = BluetoothCentral()

  var authorization: BluetoothAuthorization {
    return central.authorization
  }

  var state: BluetoothState {
    return central.state
  }

  /******************** Device ********************/

  #warning("TODO: Remove optional?")
  private var currentPeripheral: MBTPeripheral?

  public var hasConnectedDevice: Bool {
    return currentPeripheral?.isBleConnected ?? false
  }

  public var hasA2dpConnectedDevice: Bool {
    return currentPeripheral?.isA2dpConnected ?? false
  }

  public var currentDeviceInformation: DeviceInformation? {
    return currentPeripheral?.information
  }

  public var currentDeviceA2DPName: String? {
    return currentPeripheral?.ad2pName
  }

  public var isListeningToEEG: Bool {
    get { return currentPeripheral?.isListeningToEEG ?? false }
    set { currentPeripheral?.isListeningToEEG = newValue }
  }

  public var isListeningToIMS: Bool {
    get { return currentPeripheral?.isListeningToIMS ?? false }
    set { currentPeripheral?.isListeningToIMS = newValue }
  }

  public var isListeningToHeadsetStatus: Bool {
    get { return currentPeripheral?.isListeningToHeadsetStatus ?? false }
    set { currentPeripheral?.isListeningToHeadsetStatus = newValue }
  }

  /******************** Battery ********************/

  private var batteryLevelRefreshTimer: Timer?

  var batteryLevelRefreshInterval: TimeInterval = 180 {
    didSet {
      if batteryLevelRefreshInterval < 1 {
        updateRefreshBatteryLevel(with: nil)
      } else {
        updateRefreshBatteryLevel(with: batteryLevelRefreshInterval)
      }
    }
  }

  private(set) var lastBatteryLevel: Float = -1

  /******************** Delegate ********************/

  weak var bleDelegate: MBTBLEBluetoothDelegate?

  weak var a2dpDelegate: MBTA2DPBluetoothDelegate?

  weak var acquisitionDelegate: MBTBluetoothAcquisitionDelegate?

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  public init() {
    setup()
  }

  private func setup() {
    setupCentral()
    setupPeripheral()
    setupTimers()
  }

  private func setupCentral() {
    central.didDiscoverPeripheral = { [weak self] peripheral in
      self?.handleDiscover(peripheral: peripheral)
    }

    central.didConnectToPeripheral = { [weak self] result in
      self?.handleConnection(to: result)
    }

    central.didConnectionFail = { [weak self] error in
      self?.bleDelegate?.didConnectionFail(error: error)
    }

    central.didDisconnect = { [weak self] peripheral, error in
      self?.bleDelegate?.didDisconnect(error: error)
    }
  }

  private func setupPeripheral() {

  }

  private func setupTimers() {
    setupBatteryLevelRefreshTimer()
  }

  private func setupBatteryLevelRefreshTimer() {
    updateRefreshBatteryLevel(with: batteryLevelRefreshInterval)
  }

  //----------------------------------------------------------------------------
  // MARK: - Central
  //----------------------------------------------------------------------------

  #warning("TODO: Use deviceName or UUID to filter device")
  public func startScanning() {
    //let melomindService = MelomindBluetoothPeripheral.melomindService
    central.scan(services: nil) //[melomindService])
  }

  public func stopScanning() {
    central.stopScanning()
  }

  private func handleDiscover(peripheral: CBPeripheral) {
    print("Central discovered: \(peripheral)")
    central.stopScanning()
    central.connect(to: peripheral)
  }

  private func handleConnection(
    to newPeripheralResult: BluetoothCentral.PeripheralResult
  ) {
    print("Central connected to \(newPeripheralResult.peripheral)")
    bleDelegate?.didConnect()
    currentPeripheral = MBTPeripheral(
      peripheral: newPeripheralResult.peripheral,
      isPreIndus5: newPeripheralResult.isPreIndus5
    )
    currentPeripheral?.delegate = self
  }

  //----------------------------------------------------------------------------
  // MARK: - Connection
  //----------------------------------------------------------------------------

  public func connect() {

  }

  public func disconnect() {
    stopScanning()
    if let peripheral = currentPeripheral?.peripheral {
      central.disconnect(from: peripheral)
    }
    currentPeripheral = nil
  }

  //----------------------------------------------------------------------------
  // MARK: - Command
  //----------------------------------------------------------------------------

  public func requestBatteryLevel() {
    currentPeripheral?.requestBatteryLevel()
  }


  //----------------------------------------------------------------------------
  // MARK: - Timers
  //----------------------------------------------------------------------------

  private func updateRefreshBatteryLevel(with time: TimeInterval?) {
    guard let time = time else {
      batteryLevelRefreshTimer?.invalidate()
      batteryLevelRefreshTimer = nil
      return
    }

    batteryLevelRefreshTimer = Timer.scheduledTimer(
      withTimeInterval: time,
      repeats: true) { [weak self] _ in
      self?.requestBatteryLevel()
    }
  }

}

extension MBTBluetoothManagerV2: PeripheralDelegate {

  func didUpdate(sampleBufferSizeFromMtu: Int) {
    bleDelegate?.didUpdateSampleBufferSize(
      sampleBufferSize: sampleBufferSizeFromMtu
    )
  }

  func didValueUpdate(brainData: Data) {
    acquisitionDelegate?.didUpdateEEGRawData(brainData)
  }

  func didValueUpdate(imsData: Data) {
    acquisitionDelegate?.didUpdateImsData(imsData)
  }

  func didValueUpdate(batteryLevel: Float) {
    lastBatteryLevel = batteryLevel
    acquisitionDelegate?.didUpdateBatteryLevel(batteryLevel)
  }

  func didValueUpdate(saturationStatus: Int) {
    acquisitionDelegate?.didUpdateSaturationStatus(saturationStatus)
  }

  func didRequestA2DPConnection() {
    a2dpDelegate?.didRequestA2DPConnection()
  }

  func didA2DPConnect() {
    a2dpDelegate?.didAudioA2DPConnect()
  }

  func didA2DPDisconnect(error: Error?) {
    a2dpDelegate?.didAudioA2DPDisconnect(error: error)
  }

  func didConnect() {
    #warning("TODO: already done in peripheral closure.")
//    bleDelegate?.didConnect()
  }

  func didConnect(deviceInformation: DeviceInformation) {
    bleDelegate?.didConnect(deviceInformation: deviceInformation)
  }

  func didFail(error: Error) {
    bleDelegate?.didConnectionFail(error: error)
  }


}
