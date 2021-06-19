import Foundation
import CoreBluetooth
import SwiftyBeaver

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
    return currentPeripheral?.peripheral != nil
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
    let melomindService = MelomindBluetoothPeripheral.melomindService
    central.scan(services: [melomindService])
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
//    currentPeripheral?.peripheral = newPeripheralResult.peripheral
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










//==============================================================================
// MARK: - MBTPeripheral
//==============================================================================



internal class MBTPeripheral: NSObject {

  //----------------------------------------------------------------------------
  // MARK: - State
  //----------------------------------------------------------------------------

  enum MBTPeripheralState {
    case characteristicDiscovering
    case pairing
    case deviceInformationDiscovering
    case a2dpRequesting
    case ready
  }

  private(set) var state = MBTPeripheralState.characteristicDiscovering

  /// Indicate if the headset is connected or not to BLE and A2DP.
  var isConnected: Bool {
    #warning("TODO: Check A2DP connection?")
    return (peripheral?.state ?? .disconnected) == .connected
  }

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private(set) var peripheral: CBPeripheral? {
    didSet {
      print(peripheral?.identifier)
      updatePeripheral()
    }
  }

  var isPreIndus5: Bool = true

  private var peripheralCommunicator: PeripheralCommunicable?

  private var peripheralValueReceiver: PeripheralValueReceiverProtocol? {
    didSet {
      peripheralValueReceiver?.delegate = self
    }
  }

  private(set) var information: DeviceInformation? {
    didSet {
      guard let information = information else { return }
      delegate?.didConnect(deviceInformation: information)
    }
  }

  var ad2pName: String? {
    return a2dpConnector.a2dpName
  }

  #warning("TODO: To remove")
  private let peripheralManager: CBPeripheralManager

  /// Authorization given to access to bluetooth.
  private(set) var bluetoothAuthorization = BluetoothAuthorization.undetermined
  private(set) var bluetoothState = BluetoothState.undetermined

  /******************** Notifications ********************/

  /// Enable or disable headset EEG notifications.
  var isListeningToEEG = false {
    didSet {
      peripheralCommunicator?.notifyBrainActivityMeasurement(
        value: isListeningToEEG
      )
    }
  }

  /// Enable or disable headset saturation notifications.
  var isListeningToHeadsetStatus = false {
    didSet {
      peripheralCommunicator?.notifyHeadsetStatus(
        value: isListeningToHeadsetStatus
      )
    }
  }

  /******************** Audio ********************/

  private let a2dpConnector = MBTPeripheralA2DPConnector()

  /******************** Attribute discover ********************/

  private let characteristicDiscoverer = CharacteristicDiscoverer()

  private let allIndusServiceCBUUIDs: [CBUUID]

  private let deviceInformationBuilder = DeviceInformationBuilder()

  /******************** Callbacks ********************/

  weak var delegate: PeripheralDelegate?

  var didUpdateBrainData: ((Data) -> Void)?
  var didUpdateBatteryLevel: ((Int) -> Void)?
  var didUpdateSaturationStatus: ((Int) -> Void)?

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(peripheral: CBPeripheral,
       isPreIndus5: Bool,
       delegate: PeripheralDelegate? = nil) {
    peripheralManager = CBPeripheralManager(delegate: nil, queue: nil)
    allIndusServiceCBUUIDs = isPreIndus5 ? MBTService.PostIndus5.allCases.uuids : MBTService.PostIndus5.allCases.uuids
    super.init()

    self.peripheral = peripheral
    self.isPreIndus5 = isPreIndus5
    self.delegate = delegate
    setup()
    updatePeripheral()
  }

  #warning("Remove this init?")
  private override init() {
    peripheralManager = CBPeripheralManager(delegate: nil, queue: nil)
    allIndusServiceCBUUIDs = MBTService.allIndusCBUUIDs

    super.init()
    setup()
  }

  //----------------------------------------------------------------------------
  // MARK: - Setup
  //----------------------------------------------------------------------------

  private func setup() {
    setupPeripheralManager()
    setupDeviceInformationBuilder()
    setupCharacteristicsDiscoverer()
    setupA2DPConnector()
  }

  private func setupPeripheralManager() {
    peripheralManager.delegate = self
  }

  private func setupDeviceInformationBuilder() {
    deviceInformationBuilder.didBuild = { [weak self] deviceInfomration in
      self?.information = deviceInfomration

      self?.state = .a2dpRequesting

      if let information = self?.information {
        print(information)
      }

      self?.peripheralCommunicator?.requestConnectA2DP()
    }

    deviceInformationBuilder.didFail = { [weak self] error in
      // TODO Handle error
    }
  }

  private func setupCharacteristicsDiscoverer() {
    characteristicDiscoverer.didDiscoverAllPreIndus5Characteristics = {
      [weak self] characteristicContainer in
      guard let self = self else { return }

      guard let peripheral = self.peripheral else {
        #warning("TODO: Handle error")
        return
      }

      #warning("TODO: characteristicDiscoverer one callback giving peripheralCommunicator")
      self.peripheralCommunicator = PreIndus5PeripheralCommunicator(
        peripheral: peripheral,
        characteristicContainer: characteristicContainer
      )

      self.peripheralValueReceiver = PreIndus5PeripheralValueReceiver()

      self.state = .pairing
      self.peripheralCommunicator?.requestPairing()
    }

    characteristicDiscoverer.didDiscoverAllPostIndus5Characteristics = {
      [weak self] characteristicContainer in
      guard let self = self else { return }

      guard let peripheral = self.peripheral else {
        #warning("TODO: Handle error")
        return
      }

      self.peripheralCommunicator = PostIndus5PeripheralCommunicator(
        peripheral: peripheral,
        characteristicContainer: characteristicContainer
      )

      self.peripheralValueReceiver = PostIndus5PeripheralValueReceiver()

      self.state = .pairing

      self.peripheralCommunicator?.requestPairing()
    }
  }

  private func setupA2DPConnector() {
    a2dpConnector.didConnectA2DP = { [weak self] in
      print("A2DP is connected.")
      self?.delegate?.didA2DPConnect()
    }

    a2dpConnector.didDisconnectA2DP = { [weak self] in
      print("A2DP is disconnected.")
    }

    a2dpConnector.requestDeviceSerialNumber = { [weak self] in
      return self?.information?.deviceId
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Update
  //----------------------------------------------------------------------------

  func setPeripheral(_ newPeripheral: CBPeripheral, isPreIndus5: Bool) {
    self.isPreIndus5 = isPreIndus5
    peripheral = newPeripheral
  }

  func isVersionUpToDate(oadFirmwareVersion: FormatedVersion) -> Bool {
    guard let peripheralInformation = information else {
      log.error("Device information not found yet.")
      return false
    }
    return peripheralInformation.isVersionUpToDate(
      oadFirmwareVersion: oadFirmwareVersion
    )
  }

  private func updatePeripheral() {
    peripheral?.delegate = self
    guard isConnected else { return }
    updatePeripheralInformation()
  }

  private func updatePeripheralInformation() {
    peripheral?.discoverServices(allIndusServiceCBUUIDs)
  }

  //----------------------------------------------------------------------------
  // MARK: - Services
  //----------------------------------------------------------------------------

  private func handleDiscoverServices(for peripheral: CBPeripheral,
                                      error: Error?) {
    log.verbose("🆕 Did discover services")

    // Check all the services of the connecting peripheral.
    guard isConnected, let services = peripheral.services else {
      log.error("BLE peripheral is connected ? \(isConnected)")
      log.error("Services peripheral are nil ? \(peripheral.services == nil)")
      return
    }

    guard !services.isEmpty else {
      log.verbose("Empty services")
      return
    }

//    let isPreIndus5 =
//      services.contains { $0.uuid == BluetoothService.myBrainService.uuid }
//
//    if isPreIndus5 {
//      print("Is not indus 5")
//    }

    // Security check to be sure to work with the right services
    let allowedServices =
      services.filter { allIndusServiceCBUUIDs.contains($0.uuid) }

    let transparentServiceCBUUID =  MBTService.PostIndus5.transparent.uuid
    isPreIndus5 =
      allowedServices.allSatisfy { $0.uuid != transparentServiceCBUUID }

    for service in allowedServices {
      log.verbose("New service: \(service.uuid)")
      peripheral.discoverCharacteristics(nil, for: service)
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Characteristics
  //----------------------------------------------------------------------------

  private func handleDiscoverCharacteristics(of peripheral: CBPeripheral,
                                             for service: CBService,
                                             error: Error?) {
    log.verbose("🆕 Did discover characteristics")

    guard isConnected, let characteristics = service.characteristics else {
      log.error("BLE peripheral is connected ? \(isConnected)")
      log.error(
        "Characteristics peripheral are nil ? \(service.characteristics == nil)"
      )
      return
    }

    for characteristic in characteristics {
//      if let blCharacteristic = BluetoothService(uuid: characteristic.uuid),
//         BluetoothService.deviceCharacteristics.contains(blCharacteristic),
//         let data = characteristic.value,
//         let dataString = String(data: data, encoding: .ascii) {
//        print("\(blCharacteristic): \(dataString)")
//      }

      print("Discovered:\n\(characteristic)\n from service:\n\(characteristic.service)\n")
      characteristicDiscoverer.discover(characteristic: characteristic)
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - IO
  //----------------------------------------------------------------------------

  private func handleValueUpdate(of peripheral: CBPeripheral,
                                 for characteristic: CBCharacteristic,
                                 error: Error?) {

    if state == .pairing {
      peripheralValueReceiver?.handlePairingValudUpdate(for: characteristic,
                                                        error: error)
    } else {
      peripheralValueReceiver?.handleValueUpdate(for: characteristic,
                                                 error: error)
    }

//    /******************** Quick access ********************/
//
//    let deviceAcquisition = MBTClient.shared.deviceAcquisitionManager
//
//    guard let service = BluetoothService(uuid: characteristic.uuid) else {
//      log.error("unknown service", context: characteristic.uuid)
//      return
//    }
  }

  private func handleValueWrite(of peripheral: CBPeripheral,
                                for characteristic: CBCharacteristic,
                                error: Error?) {
    if let error = error {
      #warning("TODO: Handle error")
      print(error.localizedDescription)
      return
    }

    print("Write for: \(characteristic)")

    // END
    state = .ready
  }

  private func handleNotificationStateUpdate(
    of peripheral: CBPeripheral,
    for characteristic: CBCharacteristic,
    error: Error?) {
    print("Notification activated for:")
    print(characteristic)
    print("With error: \(error?.localizedDescription)")
  }

  //----------------------------------------------------------------------------
  // MARK: - Commands
  //----------------------------------------------------------------------------

  func requestBatteryLevel() {
    guard state == .ready else { return }
    peripheralCommunicator?.readDeviceState()
  }

}

#warning("TODO: Remove and use state of CBCentral")
extension MBTPeripheral: CBPeripheralManagerDelegate {

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    handleUpdateState(of: peripheral)
  }

  private func handleUpdateState(of peripheralManager: CBPeripheralManager) {
    if #available(iOS 13.0, *) {
      bluetoothAuthorization =
        BluetoothAuthorization(authorization: peripheralManager.authorization,
                               state: peripheralManager.state)
    } else {
      bluetoothAuthorization =
        BluetoothAuthorization(state: peripheralManager.state)
    }

    bluetoothState = BluetoothState(state: peripheralManager.state)
  }

}

extension MBTPeripheral: CBPeripheralDelegate {

  /// Check if the service discovered is a valid Service.
  /// Invoked when you discover the peripheral’s available services.
  /// - Parameters:
  ///   - peripheral: The peripheral that the services belong to.
  ///   - error: If an error occurred, the cause of the failure.
  func peripheral(_ peripheral: CBPeripheral,
                  didDiscoverServices error: Error?) {
    handleDiscoverServices(for: peripheral, error: error)
  }

  /// Enable notification and sensor for desired characteristic of valid service.
  /// Invoked when you discover the characteristics of a specified service.
  /// - Parameters:
  ///   - peripheral: The peripheral that the services belong to.
  ///   - service: The service that the characteristics belong to.
  ///   - error: If an error occurred, the cause of the failure.
  func peripheral(_ peripheral: CBPeripheral,
                  didDiscoverCharacteristicsFor service: CBService,
                  error: Error?) {
    handleDiscoverCharacteristics(of: peripheral, for: service, error: error)
  }

  /// Get data values when they are updated.
  /// Invoked when you retrieve a specified characteristic’s value,
  /// or when the peripheral device notifies your app that
  /// the characteristic’s value has changed.
  /// Send them to AcquisitionManager.
  /// - Parameters:
  ///   - peripheral: The peripheral that the services belong to.
  ///   - service: The characteristic whose value has been retrieved.
  ///   - error: If an error occurred, the cause of the failure.
  func peripheral(_ peripheral: CBPeripheral,
                  didUpdateValueFor characteristic: CBCharacteristic,
                  error: Error?) {
    handleValueUpdate(of: peripheral, for: characteristic, error: error)
  }

  /// Check if the notification status changed.
  /// Invoked when the peripheral receives a request to start
  /// or stop providing notifications for a specified characteristic’s value.
  /// - Parameters:
  ///   - peripheral: The peripheral that the services belong to.
  ///   - service: The characteristic whose value has been retrieved.
  ///   - error: If an error occurred, the cause of the failure.
  /// Remark: Absence of this function causes the notifications not to register
  /// anymore.
  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateNotificationStateFor characteristic: CBCharacteristic,
    error: Error?) {
    handleNotificationStateUpdate(of: peripheral,
                                  for: characteristic,
                                  error: error)
  }

  func peripheral(_ peripheral: CBPeripheral,
                  didWriteValueFor characteristic: CBCharacteristic,
                  error: Error?) {
    handleValueWrite(of: peripheral, for: characteristic, error: error)
  }

}


extension MBTPeripheral: PeripheralValueDelegate {

  func didUpdate(batteryLevel: Int) {
    print(batteryLevel)
//    didUpdateBatteryLevel?(batteryLevel)
    delegate?.didValueUpdate(BatteryLevel: batteryLevel)
  }

  func didUpdate(brainData: Data) {
    print(brainData)
//    didUpdateBrainData?(brainData)
    delegate?.didValueUpdate(BrainData: brainData)
  }

  func didUpdate(saturationStatus: Int) {
    print(saturationStatus)
//    didUpdateSaturationStatus?(saturationStatus)
    delegate?.didValueUpdate(SaturationStatus: saturationStatus)
  }

  func didUpdate(productName: String) {
    guard state == .deviceInformationDiscovering else { return }
    deviceInformationBuilder.add(productName: productName)
  }

  func didUpdate(serialNumber: String) {
    guard state == .deviceInformationDiscovering else { return }
    deviceInformationBuilder.add(deviceId: serialNumber)
  }

  func didUpdate(firmwareVersion: String) {
    guard state == .deviceInformationDiscovering else { return }
    deviceInformationBuilder.add(firmwareVersion: firmwareVersion)
  }

  func didUpdate(hardwareVersion: String) {
    guard state == .deviceInformationDiscovering else { return }
    deviceInformationBuilder.add(hardwareVersion: hardwareVersion)
  }

  func didRequestPairing() {
    log.verbose("Did resquest pairing")
    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
      self.peripheralCommunicator?.requestPairing()
    }
  }

  func didPair() {
    state = .deviceInformationDiscovering
    peripheralCommunicator?.readDeviceInformation()
  }

  func didA2DPConnectionRequestSucceed() {
    guard let information = information else { return }
    let serialNumber = information.productName
    let isA2dpConnected =
      a2dpConnector.isConnected(currentDeviceSerialNumber: serialNumber)
    guard isA2dpConnected else { return }
    delegate?.didA2DPConnect()
  }

  func didFail(with error: Error) {
    print(error.localizedDescription)
  }

}
























typealias Bytes = [UInt8]

protocol PeripheralValueDelegate: class {
  func didUpdate(batteryLevel: Int)
  func didUpdate(brainData: Data)
  func didUpdate(saturationStatus: Int)

  func didUpdate(productName: String)
  func didUpdate(serialNumber: String)
  func didUpdate(firmwareVersion: String)
  func didUpdate(hardwareVersion: String)

  func didA2DPConnectionRequestSucceed()

  func didRequestPairing()
  func didPair()

  func didFail(with error: Error)
}

protocol PeripheralValueReceiverProtocol: class {

  var delegate: PeripheralValueDelegate? { get set }

  func handleValueUpdate(for characteristic: CBCharacteristic, error: Error?)
  func handlePairingValudUpdate(for characteristic: CBCharacteristic,
                                error: Error?)
}

class PreIndus5PeripheralValueReceiver: PeripheralValueReceiverProtocol {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Callbacks ********************/

  weak var delegate: PeripheralValueDelegate?

  //----------------------------------------------------------------------------
  // MARK: - Update
  //----------------------------------------------------------------------------

  func handlePairingValudUpdate(for characteristic: CBCharacteristic,
                                error: Error?) {
    let characteristicCBUUID = characteristic.uuid
    guard let mbtCharacteristic =
            MBTCharacteristic.PreIndus5(uuid: characteristicCBUUID) else {
      log.error("Unknown characteristic", context: characteristicCBUUID)
      return
    }

    guard mbtCharacteristic == .deviceBatteryStatus else {
      log.error("Invalid pairing characteristic", context: characteristicCBUUID)
      return
    }

    guard let error = error else {
      delegate?.didPair()
      return
    }

    if (error as NSError).code == CBATTError.readNotPermitted.rawValue {
      print(error.localizedDescription)
      delegate?.didRequestPairing()
      return
    }

    delegate?.didFail(with: error)
  }

  func handleValueUpdate(for characteristic: CBCharacteristic, error: Error?) {
    if let error = error {
      delegate?.didFail(with: error)
      return
    }

    let characteristicCBUUID = characteristic.uuid
    guard let mbtCharacteristic =
            MBTCharacteristic.PreIndus5(uuid: characteristicCBUUID) else {
      log.error("Unknown characteristic", context: characteristicCBUUID)
      return
    }

    guard let data = characteristic.value else {
      #warning("TODO: Handle error")
      return
    }

    switch mbtCharacteristic {
      case .productName: handleProductNameUpdate(for: data)
      case .serialNumber: handleSerialNumberUpdate(for: data)
      case .hardwareRevision: handleHardwareVersionNameUpdate(for: data)
      case .firmwareRevision: handleFirmwareVersionUpdate(for: data)
      case .brainActivityMeasurement: handleBrainUpdate(for: data)
      case .deviceBatteryStatus: handleBatteryUpdate(for: data)
      case .headsetStatus: handleHeadsetStatusUpdate(for: data)
      case .mailBox: handleMailboxUpdate(for: data)

      case .oadTransfert: return
    }

  }

  private func handleProductNameUpdate(for data: Data) {
    guard let valueText = String(data: data, encoding: .ascii) else { return }
    delegate?.didUpdate(productName: valueText)
  }

  private func handleSerialNumberUpdate(for data: Data) {
    guard let valueText = String(data: data, encoding: .ascii) else { return }
    delegate?.didUpdate(serialNumber: valueText)
  }

  private func handleFirmwareVersionUpdate(for data: Data) {
    guard let valueText = String(data: data, encoding: .ascii) else { return }
    delegate?.didUpdate(firmwareVersion: valueText)
  }

  private func handleHardwareVersionNameUpdate(for data: Data) {
    guard let valueText = String(data: data, encoding: .ascii) else { return }
    delegate?.didUpdate(hardwareVersion: valueText)
  }

  private func handleBrainUpdate(for data: Data) {
    delegate?.didUpdate(brainData: data)
  }

  private func handleBatteryUpdate(for data: Data) {
    let bytes = Bytes(data)
    guard bytes.count > 0 else { return }
    let batteryLevel = Int(bytes[0])
    delegate?.didUpdate(batteryLevel: batteryLevel)
  }

  private func handleHeadsetStatusUpdate(for data: Data) {
    let bytes = Bytes(data)
    guard bytes[0] == 1 else { return }
    let saturationStatus = Int(bytes[1])
    delegate?.didUpdate(saturationStatus: saturationStatus)
  }

  private func handleMailboxUpdate(for data: Data) {
    let bytes = Bytes(data)
    guard bytes.count > 0 else { return }
    guard let mailboxCommand = MailboxCommand(rawValue: bytes[0]) else {
      print("Unknown Mailbox command: \(bytes)")
      return
    }

    switch mailboxCommand {
      case .otaModeEvent: handleOtaModeUpdate(for: bytes)
      case .otaIndexResetEvent: handleOtaIndexResetUpdate(for: bytes)
      case .otaStatusEvent: handleOtaStatusUpdate(for: bytes)
      case .a2dpConnection: handleA2dpConnectionUpdate(for: bytes)
      case .setSerialNumber: handleSetSerialNumberUpdate(for: bytes)
      default: log.info("📲 Unknown MBX response")
    }
  }

  private func handleOtaModeUpdate(for bytes: Bytes) {
    #warning("TODO handleOtaModeUpdate")
  }

  private func handleOtaIndexResetUpdate(for bytes: Bytes) {
    #warning("TODO handleOtaIndexResetUpdate")
  }

  private func handleOtaStatusUpdate(for bytes: Bytes) {
    #warning("TODO handleOtaStatusUpdate")
  }

  private func handleA2dpConnectionUpdate(for bytes: Bytes) {
    log.verbose("📲 A2DP connection")

    let bytesResponse = bytes[1]
    let bytesA2DPStatus =
      MailBoxA2DPResponse.getA2DPResponse(from: bytesResponse)

    log.info("📲 A2DP bytes", context: bytes.description)
    log.info("📲 A2DP bits", context: bytesA2DPStatus.description)

    if bytesA2DPStatus.contains(.inProgress) {
      log.info("📲 A2DP in progress")
    }
    guard bytesA2DPStatus.contains(.success) else {
      var error: Error?
      if bytesA2DPStatus.contains(.failedBadAdress) {
        error = OADError.badBDAddr.error
      } else if bytesA2DPStatus.contains(.failedAlreadyConnected) {
        error = AudioError.audioAldreadyConnected.error
      } else if bytesA2DPStatus.contains(.linkKeyInvalid) {
        error = AudioError.audioUnpaired.error
      } else if bytesA2DPStatus.contains(.failedTimeout) {
        error = AudioError.audioConnectionTimeOut.error
      }
      #warning("TODO: Handle unknown error")

      if let error = error {
        log.error("📲 A2DP Transfer failed", context: error)
        delegate?.didFail(with: error)
//        if isOADInProgress {
//          eventDelegate?.onUpdateFailWithError?(error)
//        } else {
//          eventDelegate?.onConnectionFailed?(error)
//        }
//
//        timers.stopA2DPConnectionTimer()
//        disconnect()
      }
      return
    }

    log.info("📲 A2DP connection success")
    delegate?.didA2DPConnectionRequestSucceed()
  }

  private func handleSetSerialNumberUpdate(for bytes: Bytes) {

  }

}


class PostIndus5PeripheralValueReceiver: PeripheralValueReceiverProtocol {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Callbacks ********************/

  weak var delegate: PeripheralValueDelegate?

  //----------------------------------------------------------------------------
  // MARK: - Update
  //----------------------------------------------------------------------------

  func handlePairingValudUpdate(for characteristic: CBCharacteristic,
                                error: Error?) {
    let characteristicCBUUID = characteristic.uuid
    guard let mbtCharacteristic =
            MBTCharacteristic.PostIndus5(uuid: characteristicCBUUID) else {
      log.error("Unknown characteristic", context: characteristicCBUUID)
      return
    }

    guard mbtCharacteristic == .rx else {
      log.error("Invalid pairing characteristic", context: characteristicCBUUID)
      return
    }

    guard let error = error else {
      delegate?.didPair()
      return
    }

    if (error as NSError).code == CBATTError.readNotPermitted.rawValue {
      print(error.localizedDescription)
      delegate?.didRequestPairing()
      return
    }

    delegate?.didFail(with: error)
  }

  func handleValueUpdate(for characteristic: CBCharacteristic, error: Error?) {
    if let error = error {
      delegate?.didFail(with: error)
      return
    }

    let characteristicCBUUID = characteristic.uuid
    guard let mbtCharacteristic =
            MBTCharacteristic.PostIndus5(uuid: characteristicCBUUID) else {
      log.error("Unknown characteristic", context: characteristicCBUUID)
      return
    }

    guard let data = characteristic.value else {
      #warning("TODO: Handle error")
      return
    }

    switch mbtCharacteristic {
      case .tx: handleTxUpdate(for: data)
      case .rx: handleRxUpdate(for: data)
      case .unknown:
        print("unknown characteristic")
        return
//      case .mailBox: handleMailboxUpdate(for: data)
    }

  }

  private func handleTxUpdate(for data: Data) {
    #warning("TODO")
  }

  private func handleRxUpdate(for data: Data) {
    #warning("TODO")
  }

  private func handleMailboxUpdate(for data: Data) {
    let bytes = Bytes(data)
    guard bytes.count > 0 else { return }
    guard let mailboxCommand = MailboxCommand(rawValue: bytes[0]) else {
      print("Unknown Mailbox command: \(bytes)")
      return
    }

    switch mailboxCommand {
      case .otaModeEvent: handleOtaModeUpdate(for: bytes)
      case .otaIndexResetEvent: handleOtaIndexResetUpdate(for: bytes)
      case .otaStatusEvent: handleOtaStatusUpdate(for: bytes)
      case .a2dpConnection: handleA2dpConnectionUpdate(for: bytes)
      case .setSerialNumber: handleSetSerialNumberUpdate(for: bytes)
      default: log.info("📲 Unknown MBX response")
    }
  }

  private func handleOtaModeUpdate(for bytes: Bytes) {
    #warning("TODO handleOtaModeUpdate")
  }

  private func handleOtaIndexResetUpdate(for bytes: Bytes) {
    #warning("TODO handleOtaIndexResetUpdate")
  }

  private func handleOtaStatusUpdate(for bytes: Bytes) {
    #warning("TODO handleOtaStatusUpdate")
  }

  private func handleA2dpConnectionUpdate(for bytes: Bytes) {
    log.verbose("📲 A2DP connection")

    let bytesResponse = bytes[1]
    let bytesA2DPStatus =
      MailBoxA2DPResponse.getA2DPResponse(from: bytesResponse)

    log.info("📲 A2DP bytes", context: bytes.description)
    log.info("📲 A2DP bits", context: bytesA2DPStatus.description)

    if bytesA2DPStatus.contains(.inProgress) {
      log.info("📲 A2DP in progress")
    }
    guard bytesA2DPStatus.contains(.success) else {
      var error: Error?
      if bytesA2DPStatus.contains(.failedBadAdress) {
        error = OADError.badBDAddr.error
      } else if bytesA2DPStatus.contains(.failedAlreadyConnected) {
        error = AudioError.audioAldreadyConnected.error
      } else if bytesA2DPStatus.contains(.linkKeyInvalid) {
        error = AudioError.audioUnpaired.error
      } else if bytesA2DPStatus.contains(.failedTimeout) {
        error = AudioError.audioConnectionTimeOut.error
      }
      #warning("TODO: Handle unknown error")

      if let error = error {
        log.error("📲 A2DP Transfer failed", context: error)
        delegate?.didFail(with: error)
//        if isOADInProgress {
//          eventDelegate?.onUpdateFailWithError?(error)
//        } else {
//          eventDelegate?.onConnectionFailed?(error)
//        }
//
//        timers.stopA2DPConnectionTimer()
//        disconnect()
      }
      return
    }

    log.info("📲 A2DP connection success")
    delegate?.didA2DPConnectionRequestSucceed()
  }

  private func handleSetSerialNumberUpdate(for bytes: Bytes) {

  }

}







class ValueFormatter {

  func formatBatteryLevel(data: Data) -> Int? {
    let bytes = Bytes(data)
    guard bytes.count > 0 else { return nil }
    let batteryLevel = Int(bytes[0])
    return batteryLevel
  }

}










////==============================================================================
//// MARK: - Labo
////==============================================================================
//
//class PeripheralPairingController: NSObject, CBPeripheralDelegate  {
//
//  //----------------------------------------------------------------------------
//  // MARK: - Properties
//  //----------------------------------------------------------------------------
//
//  private let peripheral: CBPeripheral
//
//  private let communicater: PeripheralCommunicable
//
//  private var timer: Timer?
//
//  init(peripheral: CBPeripheral, communicater: PeripheralCommunicable) {
//    self.peripheral = peripheral
//    self.communicater = communicater
//    super.init()
//
//    self.peripheral.delegate = self
//  }
//
//  func startPairing() {
//    communicater.requestPairing()
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Delegate
//  //----------------------------------------------------------------------------
//
//  func peripheral(_ peripheral: CBPeripheral,
//                  didUpdateValueFor characteristic: CBCharacteristic,
//                  error: Error?) {
//
//  }
//
//}



//class PeripheralCharacteristicDiscoverer: NSObject, CBPeripheralDelegate {
//
//  //----------------------------------------------------------------------------
//  // MARK: - Properties
//  //----------------------------------------------------------------------------
//
//  private let peripheral: CBPeripheral
//  private let characteristicDiscoverer = CharacteristicDiscoverer()
//
//  /******************** Callbacks ********************/
//
//  var didComplete: ((Int) -> Void)?
//  var didFail: ((Error) -> Void)?
//
//  //----------------------------------------------------------------------------
//  // MARK: - Initialization
//  //----------------------------------------------------------------------------
//
//  init(peripheral: CBPeripheral) {
//    self.peripheral = peripheral
//    super.init()
//    setup()
//  }
//
//  private func setup() {
//    peripheral.delegate = self
//
//    characteristicDiscoverer.didDiscoverAllPostIndus5Characteristics = {
//      [weak self] container in
//      print(container.tx)
//    }
//  }
//
//  func peripheral(_ peripheral: CBPeripheral,
//                  didDiscoverServices error: Error?) {
//    print("one")
//  }
//
//  func peripheral(_ peripheral: CBPeripheral,
//                  didDiscoverCharacteristicsFor service: CBService,
//                  error: Error?) {
//    print("two")
//
//    guard let characteristics = service.characteristics else { return }
//    for characteristic in characteristics {
//      characteristicDiscoverer.discover(characteristic: characteristic)
//    }
//  }
//}



//==============================================================================
// MARK: - Labo closure
//==============================================================================


//class CBCentralClosure: CBCentralManager {
//
//  var didStateUpdate: ((CBCentralManager) -> Void)?
//
//  var didDiscoverPeripheral: ((CBPeripheral, [String : Any]) -> Void)?
//
//
//  init(stateCompletionHandler: ((CBCentralManager) -> Void)? = nil) {
//    super.init(delegate: nil, queue: nil, options: nil)
//    self.didStateUpdate = stateCompletionHandler
//    delegate = self
//  }
//
//}
//
//extension CBCentralClosure: CBCentralManagerDelegate {
//
//  func centralManagerDidUpdateState(_ central: CBCentralManager) {
//    didStateUpdate?(central)
//  }
//
//  func centralManager(_ central: CBCentralManager,
//                      didDiscover peripheral: CBPeripheral,
//                      advertisementData: [String : Any],
//                      rssi RSSI: NSNumber) {
//    didDiscoverPeripheral?(peripheral, advertisementData)
//    didDiscoverPeripheral = nil
//  }
//
//}
//
//
//public class CentralClosure {
//
//  lazy var cbCentral: CBCentralClosure = {
//    return CBCentralClosure() { [weak self] state in
//      print(state)
//    }
//  }()
//
//  public init() {}
//
//  public func scan(completion: ((CBPeripheral, [String : Any]) -> Void)?) {
//    cbCentral.didDiscoverPeripheral = completion
////    {
////      [weak self] peripheral, advertisementData in
////      print(peripheral)
////      print(advertisementData)
////    }
//
//    cbCentral.scanForPeripherals(withServices: nil, options: nil)
//  }
//
//}
