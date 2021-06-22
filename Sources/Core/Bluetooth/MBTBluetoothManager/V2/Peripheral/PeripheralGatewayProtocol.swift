import Foundation
import CoreBluetooth

protocol PeripheralGatewayProtocol: AnyObject {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  var delegate: PeripheralDelegate? { get set }

  var isReady: Bool { get }
//  var peripheralState: MBTPeripheralState { get }

  #warning("Use interface to hide it.")
  var peripheralCommunicator: PeripheralCommunicable? { get }

//  var peripheralValueReceiver: PeripheralValueReceiverProtocol { get }

  var information: DeviceInformation? { get }

//  var characteristicDiscoverer: CharacteristicDiscoverer { get }

  var allIndusServiceCBUUIDs: [CBUUID] { get }

  var deviceInformationBuilder: DeviceInformationBuilder { get }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(peripheral: CBPeripheral)

  //----------------------------------------------------------------------------
  // MARK: - Discoverer
  //----------------------------------------------------------------------------

  func discover(characteristic: CBCharacteristic)

  //----------------------------------------------------------------------------
  // MARK: - Gateway
  //----------------------------------------------------------------------------

  func handleValueUpdate(for characteristic: CBCharacteristic, error: Error?)

  func handleNotificationStateUpdate(for characteristic: CBCharacteristic,
                                     error: Error?)

  func handleValueWrite(for characteristic: CBCharacteristic, error: Error?)

}

//protocol MBTPeripheralState { }
//
//enum Indus2And3PeripheralState: MBTPeripheralState {
//  case characteristicDiscovering
//  case pairing
//  case deviceInformationDiscovering
//  case a2dpRequesting
//  case ready
//}

class PeripheralGatewayIndus2And3: PeripheralGatewayProtocol {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Peripheral ********************/

  private let peripheral: CBPeripheral

  /******************** State ********************/

  enum Indus2And3PeripheralState {
    case characteristicDiscovering
    case pairing
    case deviceInformationDiscovering
    case a2dpRequesting
    case ready
  }

  private var state = Indus2And3PeripheralState.characteristicDiscovering

  var isReady: Bool {
    return state == .ready
  }

  /******************** PeripheralGatewayProtocol ********************/

  private let peripheralValueReceiver = PreIndus5PeripheralValueReceiver()

  private(set) var peripheralCommunicator: PeripheralCommunicable?

  private(set) var information: DeviceInformation? {
    didSet {
      guard let information = information else { return }
      delegate?.didConnect(deviceInformation: information)
    }
  }

  private let characteristicDiscoverer = CharacteristicDiscoverer()

  var allIndusServiceCBUUIDs: [CBUUID] {
    return MBTService.PreIndus5.allCases.uuids
  }

  let deviceInformationBuilder = DeviceInformationBuilder()

  /******************** Delegate ********************/

  weak var delegate: PeripheralDelegate?

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  required init(peripheral: CBPeripheral) {
    self.peripheral = peripheral
    setup()
  }

  private func setup() {
    setupCharacteristicsDiscoverer()
    setupDeviceInformationBuilder()
    setupPeripheralValueReceiver()
  }

  private func setupCharacteristicsDiscoverer() {
    characteristicDiscoverer.didDiscoverAllPreIndus5Characteristics = {
      [weak self] characteristicContainer in
      guard let self = self else { return }

      #warning("TODO: characteristicDiscoverer one callback giving peripheralCommunicator")
      self.peripheralCommunicator = PreIndus5PeripheralCommunicator(
        peripheral: self.peripheral,
        characteristicContainer: characteristicContainer
      )

      self.state = .pairing
      self.peripheralCommunicator?.requestPairing()
    }
  }

  private func setupDeviceInformationBuilder() {
    deviceInformationBuilder.didBuild = { [weak self] deviceInformation in
      self?.information = deviceInformation

      if let information = self?.information {
        print(information)
      }

      self?.state = .a2dpRequesting
      self?.peripheralCommunicator?.requestConnectA2DP()
    }

    deviceInformationBuilder.didFail = { [weak self] error in
      // TODO Handle error
    }
  }

  private func setupPeripheralValueReceiver() {
    peripheralValueReceiver.delegate = self
  }

  //----------------------------------------------------------------------------
  // MARK: - Discoverer
  //----------------------------------------------------------------------------

  func discover(characteristic: CBCharacteristic) {
    characteristicDiscoverer.discover(characteristic: characteristic)
  }

  //----------------------------------------------------------------------------
  // MARK: - Gateway
  //----------------------------------------------------------------------------

  func handleValueUpdate(for characteristic: CBCharacteristic, error: Error?) {
    if state == .pairing {
      peripheralValueReceiver.handlePairingValudUpdate(for: characteristic,
                                                       error: error)
    } else {
      peripheralValueReceiver.handleValueUpdate(for: characteristic,
                                                error: error)
    }
  }

  func handleNotificationStateUpdate(for characteristic: CBCharacteristic,
                                     error: Error?) {
    peripheralValueReceiver.handleNotificationStateUpdate(for: characteristic,
                                                          error: error)
  }

  func handleValueWrite(for characteristic: CBCharacteristic,
                        error: Error?) {
    peripheralValueReceiver.handleValueWrite(for: characteristic, error: error)

    state = .ready
  }

}


extension PeripheralGatewayIndus2And3: PeripheralValueReceiverDelegate {

  // START: Move to extension for default implementation

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

  // END: Move to extension for default implementation

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
    #warning("Move to Gateway level")
    state = .deviceInformationDiscovering
    peripheralCommunicator?.readDeviceInformation()
  }

  func didA2DPConnectionRequestSucceed() {
    print("Move to MBTPeripheral")
//    guard let information = information else { return }
//    let serialNumber = information.productName
//    let isA2dpConnected =
//      a2dpConnector.isConnected(currentDeviceSerialNumber: serialNumber)
//    guard isA2dpConnected else { return }
//    delegate?.didA2DPConnect()
  }

  func didFail(with error: Error) {
    print(error.localizedDescription)
  }

}

















//class PeripheralGatewayIndus5 {
//
////  enum MBTPeripheralState {
////    case characteristicDiscovering
////    case pairing
////    case deviceInformationDiscovering
////    case a2dpRequesting
////    case ready
////  }
////
////  private(set) var state = MBTPeripheralState.characteristicDiscovering
//
//  /// Indicate if the headset is connected or not to BLE and A2DP.
//  var isConnected: Bool {
//    #warning("TODO: Check A2DP connection?")
//    return (peripheral?.state ?? .disconnected) == .connected
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Properties
//  //----------------------------------------------------------------------------
//
//  private(set) var peripheral: CBPeripheral? {
//    didSet {
//      print(peripheral?.identifier)
//      updatePeripheral()
//    }
//  }
//
////  var isPreIndus5: Bool = true
//
//  private var peripheralCommunicator: PeripheralCommunicable?
//
//  private var peripheralValueReceiver: PeripheralValueReceiverProtocol? {
//    didSet {
//      peripheralValueReceiver?.delegate = self
//    }
//  }
//
//  private(set) var information: DeviceInformation? {
//    didSet {
//      guard let information = information else { return }
//      delegate?.didConnect(deviceInformation: information)
//    }
//  }
//
//  var ad2pName: String? {
//    return a2dpConnector.a2dpName
//  }
//
//  #warning("TODO: To remove")
//  private let peripheralManager: CBPeripheralManager
//
//  /// Authorization given to access to bluetooth.
//  private(set) var bluetoothAuthorization = BluetoothAuthorization.undetermined
//  private(set) var bluetoothState = BluetoothState.undetermined
//
//  /******************** Notifications ********************/
//
//  /// Enable or disable headset EEG notifications.
//  var isListeningToEEG = false {
//    didSet {
//      peripheralCommunicator?.notifyBrainActivityMeasurement(
//        value: isListeningToEEG
//      )
//    }
//  }
//
//  /// Enable or disable headset saturation notifications.
//  var isListeningToHeadsetStatus = false {
//    didSet {
//      peripheralCommunicator?.notifyHeadsetStatus(
//        value: isListeningToHeadsetStatus
//      )
//    }
//  }
//
//  /******************** Audio ********************/
//
////  private let a2dpConnector = MBTPeripheralA2DPConnector()
//
//  /******************** Attribute discover ********************/
//
//  private let characteristicDiscoverer = CharacteristicDiscoverer()
//
//  private let allIndusServiceCBUUIDs: [CBUUID]
//
//  private let deviceInformationBuilder = DeviceInformationBuilder()
//
//  /******************** Callbacks ********************/
//
//  weak var delegate: PeripheralDelegate?
//
//  var didUpdateBrainData: ((Data) -> Void)?
//  var didUpdateBatteryLevel: ((Int) -> Void)?
//  var didUpdateSaturationStatus: ((Int) -> Void)?
//
//  //----------------------------------------------------------------------------
//  // MARK: - Initialization
//  //----------------------------------------------------------------------------
//
//  init(peripheral: CBPeripheral,
//       isPreIndus5: Bool,
//       delegate: PeripheralDelegate? = nil) {
//    peripheralManager = CBPeripheralManager(delegate: nil, queue: nil)
//    allIndusServiceCBUUIDs = isPreIndus5
//      ? MBTService.PreIndus5.allCases.uuids
//      : MBTService.PostIndus5.allCases.uuids
//    super.init()
//
//    self.peripheral = peripheral
//    self.isPreIndus5 = isPreIndus5
//    self.delegate = delegate
//    setup()
//    updatePeripheral()
//  }
//
//  private override init() {
//    peripheralManager = CBPeripheralManager(delegate: nil, queue: nil)
//    allIndusServiceCBUUIDs = MBTService.allIndusCBUUIDs
//
//    super.init()
//    setup()
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Setup
//  //----------------------------------------------------------------------------
//
//  private func setup() {
//    setupPeripheralManager()
//    setupDeviceInformationBuilder()
//    setupCharacteristicsDiscoverer()
//    setupA2DPConnector()
//  }
//
//  private func setupPeripheralManager() {
//    peripheralManager.delegate = self
//  }
//
//  private func setupDeviceInformationBuilder() {
//    deviceInformationBuilder.didBuild = { [weak self] deviceInfomration in
//      self?.information = deviceInfomration
//
//
//
//      if let information = self?.information {
//        print(information)
//      }
//
//      if self!.isPreIndus5 {
//        self?.state = .a2dpRequesting
//        self?.peripheralCommunicator?.requestConnectA2DP()
//      } else {
//        self?.state = .ready
//      }
//    }
//
//    deviceInformationBuilder.didFail = { [weak self] error in
//      // TODO Handle error
//    }
//  }
//
//  private func setupCharacteristicsDiscoverer() {
//    characteristicDiscoverer.didDiscoverAllPreIndus5Characteristics = {
//      [weak self] characteristicContainer in
//      guard let self = self else { return }
//
//      guard let peripheral = self.peripheral else {
//        #warning("TODO: Handle error")
//        return
//      }
//
//      #warning("TODO: characteristicDiscoverer one callback giving peripheralCommunicator")
//      self.peripheralCommunicator = PreIndus5PeripheralCommunicator(
//        peripheral: peripheral,
//        characteristicContainer: characteristicContainer
//      )
//
//      self.peripheralValueReceiver = PreIndus5PeripheralValueReceiver()
//
//      self.state = .pairing
//      self.peripheralCommunicator?.requestPairing()
//    }
//
//    characteristicDiscoverer.didDiscoverAllPostIndus5Characteristics = {
//      [weak self] characteristicContainer in
//      guard let self = self else { return }
//
//      guard let peripheral = self.peripheral else {
//        #warning("TODO: Handle error")
//        return
//      }
//
//      self.peripheralCommunicator = PostIndus5PeripheralCommunicator(
//        peripheral: peripheral,
//        characteristicContainer: characteristicContainer
//      )
//
//      self.peripheralValueReceiver = PostIndus5PeripheralValueReceiver()
//
//      #warning("TODO When headset fixed")
//      //      self.state = .pairing
//      self.state = .deviceInformationDiscovering
//
//
//      self.peripheralCommunicator?.requestPairing()
//      // Continue after notification activated
//    }
//  }
//
//  private func setupA2DPConnector() {
//    a2dpConnector.didConnectA2DP = { [weak self] in
//      print("A2DP is connected.")
//      self?.delegate?.didA2DPConnect()
//    }
//
//    a2dpConnector.didDisconnectA2DP = { [weak self] in
//      print("A2DP is disconnected.")
//    }
//
//    a2dpConnector.requestDeviceSerialNumber = { [weak self] in
//      return self?.information?.deviceId
//    }
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Update
//  //----------------------------------------------------------------------------
//
//  func setPeripheral(_ newPeripheral: CBPeripheral, isPreIndus5: Bool) {
//    self.isPreIndus5 = isPreIndus5
//    peripheral = newPeripheral
//  }
//
//  func isVersionUpToDate(oadFirmwareVersion: FormatedVersion) -> Bool {
//    guard let peripheralInformation = information else {
//      log.error("Device information not found yet.")
//      return false
//    }
//    return peripheralInformation.isVersionUpToDate(
//      oadFirmwareVersion: oadFirmwareVersion
//    )
//  }
//
//  private func updatePeripheral() {
//    peripheral?.delegate = self
//    guard isConnected else { return }
//    updatePeripheralInformation()
//  }
//
//  private func updatePeripheralInformation() {
//    peripheral?.discoverServices(allIndusServiceCBUUIDs)
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Services
//  //----------------------------------------------------------------------------
//
//  private func handleDiscoverServices(for peripheral: CBPeripheral,
//                                      error: Error?) {
//    log.verbose("🆕 Did discover services")
//
//    // Check all the services of the connecting peripheral.
//    guard isConnected, let services = peripheral.services else {
//      log.error("BLE peripheral is connected ? \(isConnected)")
//      log.error("Services peripheral are nil ? \(peripheral.services == nil)")
//      return
//    }
//
//    guard !services.isEmpty else {
//      log.verbose("Empty services")
//      return
//    }
//
//    //    let isPreIndus5 =
//    //      services.contains { $0.uuid == BluetoothService.myBrainService.uuid }
//    //
//    //    if isPreIndus5 {
//    //      print("Is not indus 5")
//    //    }
//
//    // Security check to be sure to work with the right services
//    let allowedServices =
//      services.filter { allIndusServiceCBUUIDs.contains($0.uuid) }
//
//    let transparentServiceCBUUID =  MBTService.PostIndus5.transparent.uuid
//    isPreIndus5 =
//      allowedServices.allSatisfy { $0.uuid != transparentServiceCBUUID }
//
//    for service in allowedServices {
//      log.verbose("New service: \(service.uuid)")
//      peripheral.discoverCharacteristics(nil, for: service)
//    }
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Characteristics
//  //----------------------------------------------------------------------------
//
//  private func handleDiscoverCharacteristics(of peripheral: CBPeripheral,
//                                             for service: CBService,
//                                             error: Error?) {
//    log.verbose("🆕 Did discover characteristics")
//
//    guard isConnected, let characteristics = service.characteristics else {
//      log.error("BLE peripheral is connected ? \(isConnected)")
//      log.error(
//        "Characteristics peripheral are nil ? \(service.characteristics == nil)"
//      )
//      return
//    }
//
//    for characteristic in characteristics {
//      //      if let blCharacteristic = BluetoothService(uuid: characteristic.uuid),
//      //         BluetoothService.deviceCharacteristics.contains(blCharacteristic),
//      //         let data = characteristic.value,
//      //         let dataString = String(data: data, encoding: .ascii) {
//      //        print("\(blCharacteristic): \(dataString)")
//      //      }
//
//      print("Discovered:\n\(characteristic)\n "
//              + "from service:\n\(characteristic.service)\n")
//      characteristicDiscoverer.discover(characteristic: characteristic)
//    }
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - IO
//  //----------------------------------------------------------------------------
//
//  private func handleValueUpdate(of peripheral: CBPeripheral,
//                                 for characteristic: CBCharacteristic,
//                                 error: Error?) {
//
//    if state == .pairing {
//      peripheralValueReceiver?.handlePairingValudUpdate(for: characteristic,
//                                                        error: error)
//    } else {
//      peripheralValueReceiver?.handleValueUpdate(for: characteristic,
//                                                 error: error)
//    }
//  }
//
//  private func handleValueWrite(of peripheral: CBPeripheral,
//                                for characteristic: CBCharacteristic,
//                                error: Error?) {
//    if let error = error {
//      #warning("TODO: Handle error")
//      print(error.localizedDescription)
//      return
//    }
//
//    print("Write for: \(characteristic)\nWith value: \(characteristic.value)")
//
//    #warning("Remove end from here.")
//    // END
//    if isPreIndus5 {
//      state = .ready
//    }
//  }
//
//  private func handleNotificationStateUpdate(
//    of peripheral: CBPeripheral,
//    for characteristic: CBCharacteristic,
//    error: Error?) {
//    print("Notification state update for:")
//    print(characteristic)
//    print("is activated: \(characteristic.isNotifying)")
//
//    if let error = error {
//      print("With error: \(error.localizedDescription)")
//      return
//    }
//
//
//    //    peripheralCommunicator?.write(a2dpName: "MM2B100007")
//    peripheralCommunicator?.readDeviceInformation()
//    //    peripheralCommunicator?.readDeviceState()
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Commands
//  //----------------------------------------------------------------------------
//
//  func requestBatteryLevel() {
//    /// Used for pairing, so we prevent its access before that the device is
//    /// paired.
//    guard state == .ready else { return }
//    peripheralCommunicator?.readDeviceState()
//  }
//
//}
