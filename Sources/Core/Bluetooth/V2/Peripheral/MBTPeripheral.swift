import Foundation
import CoreBluetooth

internal class MBTPeripheral: NSObject {

  //----------------------------------------------------------------------------
  // MARK: - State
  //----------------------------------------------------------------------------

  /// Indicate if the headset is connected or not to BLE and A2DP.
  var isBleConnected: Bool {
    #warning("TODO: Check A2DP connection?")
    return peripheral.state == .connected
  }

//  var isA2dpConnected: Bool {
//    guard let information = information else { return false }
//    return a2dpConnector.isConnected(currentDeviceSerialNumber: information.productName)
//  }

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  let peripheral: CBPeripheral

  private(set) var isPreIndus5: Bool

  var information: DeviceInformation? {
    return gateway.information
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
      gateway.peripheralCommunicator?.notifyBrainActivityMeasurement(
        value: isListeningToEEG
      )
    }
  }

  /// Enable or disable headset saturation notifications.
  var isListeningToHeadsetStatus = false {
    didSet {
      gateway.peripheralCommunicator?.notifyHeadsetStatus(
        value: isListeningToHeadsetStatus
      )
    }
  }

  /******************** Audio ********************/

  private let a2dpConnector = MBTPeripheralA2DPConnector()

  /******************** Gateway ********************/

  private let gateway: PeripheralGatewayProtocol

  /******************** Callbacks ********************/

  weak var delegate: PeripheralDelegate? {
    get { return gateway.delegate }
    set { gateway.delegate = newValue }
  }

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

    if isPreIndus5 {
      gateway = PeripheralGatewayPreIndus5(peripheral: peripheral)
    } else {
      gateway = PeripheralGatewayPostIndus5(peripheral: peripheral)
    }

    self.isPreIndus5 = isPreIndus5

    self.peripheral = peripheral

    super.init()

    self.delegate = delegate
    setup()
  }

  //----------------------------------------------------------------------------
  // MARK: - Setup
  //----------------------------------------------------------------------------

  private func setup() {
    setupPeripheralManager()
    setupA2DPConnector()
    setupPeripheral()
  }

  private func setupPeripheral() {
    peripheral.delegate = self
    guard isBleConnected else { return }
    discoverServices()
  }

  private func discoverServices() {
    let allIndusServiceCBUUIDs = gateway.allIndusServiceCBUUIDs
    peripheral.discoverServices(allIndusServiceCBUUIDs)
  }

  private func setupPeripheralManager() {
    peripheralManager.delegate = self
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

  func isVersionUpToDate(oadFirmwareVersion: FormatedVersion) -> Bool {
    guard let peripheralInformation = information else {
      log.error("Device information not found yet.")
      return false
    }
    return peripheralInformation.isVersionUpToDate(
      oadFirmwareVersion: oadFirmwareVersion
    )
  }

  //----------------------------------------------------------------------------
  // MARK: - Services
  //----------------------------------------------------------------------------

  private func handleDiscoverServices(for peripheral: CBPeripheral,
                                      error: Error?) {
    log.verbose("🆕 Did discover services")

    // Check all the services of the connecting peripheral.
    guard isBleConnected, let services = peripheral.services else {
      log.error("BLE peripheral is connected ? \(isBleConnected)")
      log.error("Services peripheral are nil ? \(peripheral.services == nil)")
      return
    }

    guard !services.isEmpty else {
      log.verbose("Empty services")
      return
    }

    // Security check to be sure to work with the right services
    let allowedServices =
      services.filter { gateway.allIndusServiceCBUUIDs.contains($0.uuid) }

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

    guard isBleConnected, let characteristics = service.characteristics else {
      log.error("BLE peripheral is connected ? \(isBleConnected)")
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

      print("Discovered:\n\(characteristic)\n "
              + "from service:\n\(characteristic.service)\n")
      gateway.discover(characteristic: characteristic)
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - IO
  //----------------------------------------------------------------------------

  private func handleValueUpdate(of peripheral: CBPeripheral,
                                 for characteristic: CBCharacteristic,
                                 error: Error?) {
    gateway.handleValueUpdate(for: characteristic, error: error)
  }

  private func handleValueWrite(of peripheral: CBPeripheral,
                                for characteristic: CBCharacteristic,
                                error: Error?) {
    print("Write for: \(characteristic)")

    if let value = characteristic.value {
      print("With value: \(value)")
    }

    gateway.handleValueWrite(for: characteristic, error: error)
  }

  private func handleNotificationStateUpdate(
    of peripheral: CBPeripheral,
    for characteristic: CBCharacteristic,
    error: Error?
  ) {
    print("Notification state update for:")
    print(characteristic)

    gateway.handleNotificationStateUpdate(for: characteristic, error: error)
  }

  //----------------------------------------------------------------------------
  // MARK: - Commands
  //----------------------------------------------------------------------------

  func requestBatteryLevel() {
    guard gateway.isReady else { return }
    gateway.peripheralCommunicator?.readDeviceState()
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


//extension MBTPeripheral: PeripheralValueDelegate {
//
//  func didUpdate(batteryLevel: Int) {
//    print(batteryLevel)
////    didUpdateBatteryLevel?(batteryLevel)
//    delegate?.didValueUpdate(BatteryLevel: batteryLevel)
//  }
//
//  func didUpdate(brainData: Data) {
//    print(brainData)
////    didUpdateBrainData?(brainData)
//    delegate?.didValueUpdate(BrainData: brainData)
//  }
//
//  func didUpdate(saturationStatus: Int) {
//    print(saturationStatus)
////    didUpdateSaturationStatus?(saturationStatus)
//    delegate?.didValueUpdate(SaturationStatus: saturationStatus)
//  }
//
//  func didUpdate(productName: String) {
//    guard state == .deviceInformationDiscovering else { return }
//    deviceInformationBuilder.add(productName: productName)
//  }
//
//  func didUpdate(serialNumber: String) {
//    guard state == .deviceInformationDiscovering else { return }
//    deviceInformationBuilder.add(deviceId: serialNumber)
//  }
//
//  func didUpdate(firmwareVersion: String) {
//    guard state == .deviceInformationDiscovering else { return }
//    deviceInformationBuilder.add(firmwareVersion: firmwareVersion)
//  }
//
//  func didUpdate(hardwareVersion: String) {
//    guard state == .deviceInformationDiscovering else { return }
//    deviceInformationBuilder.add(hardwareVersion: hardwareVersion)
//  }
//
//  func didRequestPairing() {
//    log.verbose("Did resquest pairing")
//    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
//      self.peripheralCommunicator?.requestPairing()
//    }
//  }
//
//  func didPair() {
//    state = .deviceInformationDiscovering
//    peripheralCommunicator?.readDeviceInformation()
//  }
//
//  func didA2DPConnectionRequestSucceed() {
//    guard let information = information else { return }
//    let serialNumber = information.productName
//    let isA2dpConnected =
//      a2dpConnector.isConnected(currentDeviceSerialNumber: serialNumber)
//    guard isA2dpConnected else { return }
//    delegate?.didA2DPConnect()
//  }
//
//  func didFail(with error: Error) {
//    print(error.localizedDescription)
//  }
//
//}









































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
