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

  public var isListeningToHeadsetStatus: Bool {
    get { return currentPeripheral?.isListeningToHeadsetStatus ?? false }
    set { currentPeripheral?.isListeningToHeadsetStatus = newValue }
  }

  #warning("TODO: Replace `timeIntervalOnReceiveBattery`")
  var batteryLevelRefreshInterval: TimeInterval = 120

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

}

extension MBTBluetoothManagerV2: PeripheralDelegate {

  func didValueUpdate(BrainData: Data) {
    acquisitionDelegate?.didUpdateEEGRawData(BrainData)
  }

  func didValueUpdate(BatteryLevel: Int) {
    acquisitionDelegate?.didUpdateBatteryLevel(BatteryLevel)
  }

  func didValueUpdate(SaturationStatus: Int) {
    acquisitionDelegate?.didUpdateSaturationStatus(SaturationStatus)
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
