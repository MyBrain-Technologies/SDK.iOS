//
//  MBTBluetoothManagerV2.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by Laurent on 03/05/2021.
//  Copyright © 2021 MyBrainTechnologies. All rights reserved.
//

import Foundation
import CoreBluetooth
import SwiftyBeaver

public class MBTBluetoothManagerV2: NSObject {

  //----------------------------------------------------------------------------
  // MARK: - properties
  //----------------------------------------------------------------------------

  /******************** Delegate ********************/

  /// The MBTBluetooth Event Delegate.
  weak var eventDelegate: MBTBluetoothEventDelegate?

  let central = BluetoothCentral()

  let currentPeripheral = MBTPeripheral()

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  public override init() {
    super.init()
    initLog(logToFile: false, isDebugMode: true, options: [])
    setup()
  }

  private func setup() {
    setupCentral()
    setupPeripheral()
  }

  private func setupCentral() {
    central.didDiscoverPeripheral = { [weak self] peripheral in
      print(peripheral)

      self?.central.stopScanning()
      self?.central.connect(to: peripheral)
    }

    central.didConnectToPeripheral = { [weak self] peripheral in
      print("connected to \(peripheral)")
      self?.currentPeripheral.peripheral = peripheral
    }

    central.didConnectionFail = { [weak self] error in
      self?.eventDelegate?.onConnectionFailed?(error)
    }

    central.didDisconnect = { [weak self] peripheral, error in
      self?.eventDelegate?.onConnectionBLEOff?(error)
    }
  }

  private func setupPeripheral() {

  }


  //----------------------------------------------------------------------------
  // MARK: - Central
  //----------------------------------------------------------------------------

  public func startScanning() {
    let melomindService = MelomindBluetoothPeripheral.melomindService
    central.scan(services: [melomindService])
  }

  public func stopScanning() {
    central.stopScanning()
  }

}



extension MBTBluetoothManagerV2 {

    //----------------------------------------------------------------------------
    // MARK: - Properties
    //----------------------------------------------------------------------------

    private var hideAcquisitionFilter: FilterType {
      return Filters.Path.excludes("EEGAcquisition")
    }

    private var hideHeadsetServicesFilters: [FilterType] {
      return [
        Filters.Message.excludes("Did update value for characteristic"),
        Filters.Message.excludes("Brain activity service"),
        Filters.Message.excludes("Headset status service"),
        Filters.Message.excludes("Device battery service")
      ]
    }

    private var hideMailBoxFilter: FilterType {
      return Filters.Message.excludes("Mailbox")
    }

    //----------------------------------------------------------------------------
    // MARK: - Initialization
    //----------------------------------------------------------------------------

    public func initLog(logToFile: Bool,
                        isDebugMode: Bool = false,
                        options: [LogOptions] = []) {
      log.removeAllDestinations()

      var destination = getDestination(isFile: logToFile)
      destination = setupDestination(destination, isDebugMode: isDebugMode)
      destination = addFilters(on: destination, options: options)

      log.addDestination(destination)
    }

    private func getDestination(isFile: Bool) -> BaseDestination {
      return isFile ? FileDestination() : ConsoleDestination()
    }

    private func setupDestination(_ destination: BaseDestination,
                                  isDebugMode: Bool = false) -> BaseDestination {
      let debugFormat = "[SDK] $DHH:mm:ss ($N.$F:$l) $C$L $M $X"
      let defaultFormat = "[SDK] $DHH:mm:ss $C$L $M $X"
      destination.format = isDebugMode ? debugFormat : defaultFormat
      destination.minLevel = isDebugMode ? .verbose : .info

      return destination
    }

    private func addFilters(on destination: BaseDestination,
                            options: [LogOptions]) -> BaseDestination {
      var filters = [FilterType]()
      if !options.contains(.acquisition) {
        filters.append(hideAcquisitionFilter)
      }

      if !options.contains(.headsetServices) {
        filters.append(contentsOf: hideHeadsetServicesFilters)
      }

      if !options.contains(.headsetServices) {
        filters.append(hideMailBoxFilter)
      }

      for filter in filters {
        destination.addFilter(filter)
      }

      return destination
    }

}


















//==============================================================================
// MARK: - BluetoothCentral
//==============================================================================



internal class BluetoothCentral: NSObject {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  // IOBluetoothPeripheral

  /******************** Delegate ********************/

  /// The MBTBluetooth Event Delegate.
  weak var eventDelegate: MBTBluetoothEventDelegate?

  /******************** Central Manager ********************/

  private let cbCentralManager: CBCentralManager

  var isScanning: Bool {
    return cbCentralManager.isScanning
  }

  private var discoveredPeripherals = [CBPeripheral]()

//  /// The BLE peripheral with which a connection has been established.
//  var blePeripheral: CBPeripheral?
////  {
////    didSet {
////      if isBLEConnected {
////        eventDelegate?.onHeadsetStatusUpdate?(true)
////      } else {
////        eventDelegate?.onHeadsetStatusUpdate?(false)
////      }
////    }
////  }


  /******************** Validation ********************/

  private let peripheralValidator = PeripheralValidator()

  /******************** Callbacks ********************/

  var didDiscoverPeripheral: ((CBPeripheral) -> Void)?
  var didConnectToPeripheral: ((CBPeripheral) -> Void)?
  var didConnectionFail: ((Error?) -> Void)?
  var didDisconnect: ((CBPeripheral, Error?) -> Void)?

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  override init() {
    cbCentralManager = CBCentralManager(delegate: nil, queue: nil)
    super.init()
    cbCentralManager.delegate = self
  }


  //----------------------------------------------------------------------------
  // MARK: - State
  //----------------------------------------------------------------------------

  private func handleBluetoothStateUpdate(for central: CBCentralManager) {
    log.verbose("🆕 Did update with state: \(central.state)")

    let centralState = central.state

    switch centralState {
      case .poweredOn: handleBluetoothPoweredOn()
      case .poweredOff: handleBluetoothPoweredOff()
      default: handleBluetoothUnsuportedState(centralState)
    }

//    let hasRebootBluetooth = bluetoothStatesHistory.isPoweredOn
//      && bluetoothStatesHistory.historyIsFull
//
//    if isOADInProgress && OADState == .rebootRequired && hasRebootBluetooth {
//      continueOADAfterBluetoothReboot()
//    }
  }

  private func handleBluetoothPoweredOn() {
    log.info("📲 Bluetooth powered on")

    // Scan for peripherals if BLE is turned on

//    if bluetoothStatesHistory.isPoweredOn == false {
//      bluetoothStatesHistory.addState(isConnected: true)
//      eventDelegate?.onBluetoothStateChange?(true)
//    }

//    guard DeviceManager.connectedDeviceName != nil,
//      timers.isBleConnectionTimerInProgress else { return }

//    bluetoothConnector.scanForMelomindConnections()

//   log.verbose("🧭 Start scanning for a melomind device")

    #warning("TODO use right service")
//    let melomindService = MelomindBluetoothPeripheral.melomindService
//    scan(services: [melomindService])
  }

  private func handleBluetoothPoweredOff() {
    log.info("📲 Bluetooth powered off")

//    if bluetoothStatesHistory.isPoweredOn {
//      bluetoothStatesHistory.addState(isConnected: false)
//      eventDelegate?.onBluetoothStateChange?(false)
//    }

//    if isOADInProgress {
//      didBluetoothPoweredOffDuringOAD()
//    } else {
//      sendBluetoothPoweredOffError()
//    }
  }

  private func handleBluetoothUnsuportedState(
    _ unsuportedState: CBManagerState
  ) {
    if unsuportedState == .poweredOn || unsuportedState == .poweredOff {
      assertionFailure("\(unsuportedState) is a supported state.")
    }
    log.info("📲 Bluetooth state is \(unsuportedState)")
  }

  //----------------------------------------------------------------------------
  // MARK: - Scanning
  //----------------------------------------------------------------------------

  // Will call `centralManager(_:didDiscover:advertisementData:rssi:)`
  func scan(services: [CBUUID]) {
    log.verbose("🧭 Start scanning for a melomind device")

    guard cbCentralManager.state == .poweredOn else {
      // Handle error
      return
    }

    discoveredPeripherals.removeAll()
    cbCentralManager.scanForPeripherals(withServices: services, options: nil)
  }

  func stopScanning(on peripheral: CBPeripheral? = nil) {
    log.verbose("🧭 Stop scanning for a melomind device")

    cbCentralManager.stopScan()

    guard let peripheral = peripheral else { return }

    cbCentralManager.cancelPeripheralConnection(peripheral)
  }

  private func handleNewDiscoveredPeripheral(_ peripheral: CBPeripheral,
                                             advertisementData: [String: Any],
                                             rssi RSSI: NSNumber) {
    log.verbose("🆕 Did discover peripheral")

    let isMelomindDevice = peripheralValidator.isMelomindPeripheral(
      advertisementData: advertisementData
    )

    let isNotConnected = peripheral.state != .connected

//    let isConnectingOrUpdating =
//      timers.isBleConnectionTimerInProgress || OADState >= .started

    guard isMelomindDevice, isNotConnected else { return }

    discoveredPeripherals.append(peripheral)
//    guard isMelomindDevice && isConnectingOrUpdating else { return }
//
//    if DeviceManager.connectedDeviceName == "" {
//      DeviceManager.connectedDeviceName = newDeviceName
//    }
//
//    guard DeviceManager.connectedDeviceName == newDeviceName else { return }
//



    didDiscoverPeripheral?(peripheral)
//    stopScanning()
//    self.peripheral.peripheral = peripheral
//    connect(to: peripheral)

//    bluetoothConnector.stopScanningForConnections()
//    peripheralIO.peripheral = peripheral
//
//    peripheralIO.peripheral?.delegate = self
//
//    bluetoothConnector.connect(to: peripheral)

    #warning("TODO: Move to MBTPeripheral")
//    DeviceManager.updateDeviceToMelomind()
  }

  //----------------------------------------------------------------------------
  // MARK: - Connection
  //----------------------------------------------------------------------------

  func connect(to peripheral: CBPeripheral) {
    log.verbose("🧭 Connection to peripheral \(peripheral)")
    cbCentralManager.connect(peripheral, options: nil)
  }

  private func handleConnectionSuccess(to peripheral: CBPeripheral) {
    log.verbose("🆕 Did connect to peripheral")
    didConnectToPeripheral?(peripheral)

//    peripheral.discoverServices(nil) // Return all the possible services
//
//    guard isOADInProgress && OADState >= .completed else {
//      return DeviceManager.resetDeviceInfo()
//    }
//
//    bluetoothDeviceCharacteristics.deviceInformations.removeAll()
  }

  private func handleConnectionFailure(for peripheral: CBPeripheral,
                                       error: Error?) {
    log.verbose("🆕 Did fail to connect to peripheral: \(peripheral)")
//    eventDelegate?.onConnectionFailed?(error)
    didConnectionFail?(error)
  }

  /// If disconnected by error, start searching again,
  /// else let event delegate know that headphones are disconnected.
  private func handleDisconnection(for peripheral: CBPeripheral,
                                   error: Error?) {
    log.verbose("🆕 Did disconnect peripheral \(peripheral)")

//    processBatteryLevel = false
//    if isOADInProgress {
//      peripheralDisconnectedDuringOAD()
//    } else {
//      peripheralDisconnected(error: error)
//    }

    didDisconnect?(peripheral, error)
  }

}

//==============================================================================
// MARK: - CBCentralManagerDelegate
//==============================================================================

extension BluetoothCentral: CBCentralManagerDelegate {

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    handleBluetoothStateUpdate(for: central)
  }

  /// Check out the discovered peripherals to find the right device.
  /// Invoked when the central manager discovers a peripheral while scanning.
  func centralManager(_ central: CBCentralManager,
                      didDiscover peripheral: CBPeripheral,
                      advertisementData: [String: Any],
                      rssi RSSI: NSNumber) {
    handleNewDiscoveredPeripheral(peripheral,
                                  advertisementData: advertisementData,
                                  rssi: RSSI)
  }

  func centralManager(_ central: CBCentralManager,
                      didConnect peripheral: CBPeripheral) {
    handleConnectionSuccess(to: peripheral)
  }

  func centralManager(_ central: CBCentralManager,
                      didFailToConnect peripheral: CBPeripheral,
                      error: Error?) {
    handleConnectionFailure(for: peripheral, error: error)
  }

  func centralManager(_ central: CBCentralManager,
                      didDisconnectPeripheral peripheral: CBPeripheral,
                      error: Error?) {
    handleDisconnection(for: peripheral, error: error)
  }

}








//==============================================================================
// MARK: - PeripheralValidator
//==============================================================================

class PeripheralValidator {

  //----------------------------------------------------------------------------
  // MARK: - Validation
  //----------------------------------------------------------------------------

  func isMelomindPeripheral(advertisementData: [String: Any]) -> Bool {
    let dataReader = BluetoothAdvertisementDataReader(data: advertisementData)

    guard let newDeviceName = dataReader.localName,
          let newDeviceServices = dataReader.uuidKeys else {
      return false
    }

    print(newDeviceServices)
    if newDeviceServices.first?.uuidString == "B2A0" {
      print("advertisementData Pre indus 5")
    }
    for data in advertisementData {
      print(data.key)
    }

    let isMelomindDevice = MelomindBluetoothPeripheral.isMelomindDevice(
      deviceName: newDeviceName,
      services: newDeviceServices
    )

    return isMelomindDevice
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

  var peripheral: CBPeripheral? {
    didSet {
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

  var information: DeviceInformation?
  //  {
  //    didSet {
  //      peripheral?.discoverServices(nil)
  //    }
  //  }

  #warning("TODO: To remove")
  private let peripheralManager: CBPeripheralManager

  /// Authorization given to access to bluetooth.
  private(set) var bluetoothAuthorization = BluetoothAuthorization.undetermined
  private(set) var bluetoothState = BluetoothState.undetermined


  /******************** Attribute discover ********************/

  private let characteristicDiscoverer = CharacteristicDiscoverer()

  private let allIndusServiceCBUUIDs: [CBUUID]

  /******************** Callbacks ********************/


  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  override init() {
    peripheralManager = CBPeripheralManager(delegate: nil, queue: nil)

    let preIndus5ServicesCBUUIDs = MBTService.PreIndus5.allCases.map { $0.uuid }
    let postIndus5ServicesCBUUIDs =
      MBTService.PostIndus5.allCases.map { $0.uuid }
    allIndusServiceCBUUIDs =
      preIndus5ServicesCBUUIDs + postIndus5ServicesCBUUIDs

    super.init()
    setup()
  }

  //----------------------------------------------------------------------------
  // MARK: - Setup
  //----------------------------------------------------------------------------

  private func setup() {
    setupPeripheralManager()
    setupCharacteristicsDiscoverer()
  }

  private func setupPeripheralManager() {
    peripheralManager.delegate = self
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

      self.state = .pairing

      self.peripheralCommunicator = PostIndus5PeripheralCommunicator(
        peripheral: peripheral,
        characteristicContainer: characteristicContainer
      )
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
//    counterServicesDiscover = 0
//
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
//        counterServicesDiscover += 1
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

      print(characteristic)
      characteristicDiscoverer.discover(characteristic: characteristic)
    }

//
//    counterServicesDiscover -= 1
//
//    updateDeviceCharacteristics(with: service)
//
//    if hasDiscoverAllCharacteristics {
//      prepareDevice()
//    }
  }

  //----------------------------------------------------------------------------
  // MARK: - IO
  //----------------------------------------------------------------------------

  private func handleValueUpdate(of peripheral: CBPeripheral,
                                 for characteristic: CBCharacteristic,
                                 error: Error?) {
//    let dataString = String(data: characteristic.value!, encoding: .ascii)!
//    print("Update for: \(characteristic.uuid.uuidString) with value: \(dataString)")

    if state == .pairing {
      peripheralValueReceiver?.handlePairingValudUpdate(for: characteristic,
                                                        error: error)
    } else {
      peripheralValueReceiver?.handleValueUpdate(for: characteristic,
                                                 error: error)
    }

//    guard isBLEConnected else {
//      log.error("Ble peripheral is not set")
//      return
//    }
//
//    /******************** Quick access ********************/
//
//    let deviceAcquisition = MBTClient.shared.deviceAcquisitionManager
//
//    guard let service = BluetoothService(uuid: characteristic.uuid) else {
//      log.error("unknown service", context: characteristic.uuid)
//      return
//    }
//
//    let serviceString = service.uuid.uuidString
//    log.verbose("🆕 Did update value for characteristic. (\(serviceString))")
//
//    switch service {
//      case .brainActivityMeasurement: brainActivityService(characteristic)
//      case .headsetStatus: headsetStatusService(characteristic)
//      case .deviceBatteryStatus: deviceBatteryService(characteristic)
//      case .mailBox: mailBoxService(characteristic)
//      default: break
//    }
//
//    let deviceCharacteristics = BluetoothService.deviceCharacteristics.uuids
//    if deviceCharacteristics.contains(service.uuid) {
//      deviceAcquisition.processDeviceInformations(characteristic)
//    }
  }

  private func handleValueWrite(of peripheral: CBPeripheral,
                                for characteristic: CBCharacteristic,
                                error: Error?) {

  }

  private func handleNotificationStateUpdate(
    of peripheral: CBPeripheral,
    for characteristic: CBCharacteristic,
    error: Error?) {

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
  /// Remark: Absence of this function causes the notifications not to register anymore.
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
  }

  func didUpdate(brainData: Data) {
    print(brainData)
  }

  func didUpdate(saturationStatus: Int) {
    print(saturationStatus)
  }

  func didUpdate(productName: String) {
    print(productName)
  }

  func didUpdate(serialNumber: String) {
    print(serialNumber)
  }

  func didUpdate(firmwareVersion: String) {
    print(firmwareVersion)
  }

  func didUpdate(hardwareVersion: String) {
    print(hardwareVersion)
  }

  func didRequestPairing() {
    log.verbose("Did resquest pairing")
    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
      self.peripheralCommunicator?.requestPairing()
    }
  }

  func didPair() {
    state = .ready

    peripheralCommunicator?.readDeviceState()
    peripheralCommunicator?.readDeviceInformation()
  }

  func didFail(with error: Error) {
    print(error.localizedDescription)
  }

}


class CharacteristicDiscoverer {

  //----------------------------------------------------------------------------
  // MARK: - Typealias
  //----------------------------------------------------------------------------

  typealias PreIndus5CharacteristicToCBCharacteristic =
    [MBTCharacteristic.PreIndus5: CBCharacteristic?]

  typealias PostIndus5CharacteristicToCBCharacteristic =
    [MBTCharacteristic.PostIndus5: CBCharacteristic?]

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** CBUUIDs ********************/

  private var preIndus5CharacteristicMap =
    PreIndus5CharacteristicToCBCharacteristic()

  private var postIndus5CharacteristicMap =
    PostIndus5CharacteristicToCBCharacteristic()

  /******************** Callbacks ********************/

  var didDiscoverAllPreIndus5Characteristics:
    ((PreIndus5CharacteristicContainer) -> Void)?

  var didDiscoverAllPostIndus5Characteristics:
    ((PostIndus5CharacteristicContainer) -> Void)?

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(preIndus5Characteristics: [MBTCharacteristic.PreIndus5]
        = MBTCharacteristic.PreIndus5.allCases,
       postIndus5Characteristics: [MBTCharacteristic.PostIndus5]
        = MBTCharacteristic.PostIndus5.allCases
  ) {

    for characteristic in preIndus5Characteristics {
      preIndus5CharacteristicMap.updateValue(nil, forKey: characteristic)
    }

    for characteristic in postIndus5Characteristics {
      postIndus5CharacteristicMap.updateValue(nil, forKey: characteristic)
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Lifecycle
  //----------------------------------------------------------------------------

  func reset() {
    preIndus5CharacteristicMap.forEach { (key, value) in
      preIndus5CharacteristicMap.updateValue(nil, forKey: key)
    }

    postIndus5CharacteristicMap.forEach { (key, value) in
      postIndus5CharacteristicMap.updateValue(nil, forKey: key)
    }

  }

  //----------------------------------------------------------------------------
  // MARK: - Discover
  //----------------------------------------------------------------------------

  func discover(characteristic: CBCharacteristic) {
    preIndus5CharacteristicMap.forEach { (key, value) in
      if key.uuid == characteristic.uuid {
        preIndus5CharacteristicMap[key] = characteristic
      }
    }

    postIndus5CharacteristicMap.forEach { (key, value) in
      if key.uuid == characteristic.uuid {
        postIndus5CharacteristicMap[key] = characteristic
      }
    }

    if preIndus5CharacteristicMap.allSatisfy( { (key, value) in value != nil } ) {
      handleDiscoveryForAllPreIndus5Characteristics()
    } else if postIndus5CharacteristicMap.allSatisfy( { (key, value) in value != nil } ) {
      handleDiscoveryForAllPostIndus5Characteristics()
    }

  }

  private func handleDiscoveryForAllPreIndus5Characteristics() {
    guard let productName =
            preIndus5CharacteristicMap[.productName] as? CBCharacteristic else {
      assertionFailure("Handle error")
      return
    }

    guard let serialNumber =
            preIndus5CharacteristicMap[.serialNumber] as? CBCharacteristic else {
      assertionFailure("Handle error")
      return
    }

    guard let hardwareRevision =
            preIndus5CharacteristicMap[.hardwareRevision] as? CBCharacteristic
    else {
      assertionFailure("Handle error")
      return
    }

    guard let firmwareRevision =
            preIndus5CharacteristicMap[.firmwareRevision] as? CBCharacteristic
    else {
      assertionFailure("Handle error")
      return
    }

    guard let brainActivityMeasurement =
            preIndus5CharacteristicMap[.brainActivityMeasurement]
            as? CBCharacteristic else {
      assertionFailure("Handle error")
      return
    }

    guard let deviceState =
            preIndus5CharacteristicMap[.deviceBatteryStatus]
            as? CBCharacteristic else {
      assertionFailure("Handle error")
      return
    }

    guard let headsetStatus =
            preIndus5CharacteristicMap[.headsetStatus] as? CBCharacteristic
    else {
      assertionFailure("Handle error")
      return
    }

    guard let mailBox =
            preIndus5CharacteristicMap[.mailBox] as? CBCharacteristic else {
      assertionFailure("Handle error")
      return
    }

    guard let oadTransfert =
            preIndus5CharacteristicMap[.oadTransfert] as? CBCharacteristic
    else {
      assertionFailure("Handle error")
      return
    }

    let preIndus5CharacteristicContainer = PreIndus5CharacteristicContainer(
      productName: productName,
      serialNumber: serialNumber,
      hardwareRevision: hardwareRevision,
      firmwareRevision: firmwareRevision,
      brainActivityMeasurement: brainActivityMeasurement,
      deviceState: deviceState,
      headsetStatus: headsetStatus,
      mailBox: mailBox,
      oadTransfert: oadTransfert)

    didDiscoverAllPreIndus5Characteristics?(preIndus5CharacteristicContainer)
  }

  private func handleDiscoveryForAllPostIndus5Characteristics() {
    guard let tx = postIndus5CharacteristicMap[.tx] as? CBCharacteristic else {
      assertionFailure("Handle error")
      return
    }

    guard let rx = postIndus5CharacteristicMap[.rx] as? CBCharacteristic else {
      assertionFailure("Handle error")
      return
    }

    guard let mailBox =
            postIndus5CharacteristicMap[.mailBox] as? CBCharacteristic else {
      assertionFailure("Handle error")
      return
    }

    let postIndus5CharacteristicContainer =
      PostIndus5CharacteristicContainer(tx: tx, rx: rx, mailBox: mailBox)

    didDiscoverAllPostIndus5Characteristics?(postIndus5CharacteristicContainer)
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
    let event = MailBoxEvents.getMailBoxEvent(v: bytes[0])

    switch event {
      case .otaModeEvent: handleOtaModeUpdate(for: bytes)
      case .otaIndexResetEvent: handleOtaIndexResetUpdate(for: bytes)
      case .otaStatusEvent: handleOtaStatusUpdate(for: bytes)
      case .a2dpConnection: handleA2dpConnectionUpdate(for: bytes)
      case .setSerialNumber: handleSetSerialNumberUpdate(for: bytes)
      default: log.info("📲 Unknown MBX response")
    }
  }

  private func handleOtaModeUpdate(for bytes: Bytes) {

  }

  private func handleOtaIndexResetUpdate(for bytes: Bytes) {

  }

  private func handleOtaStatusUpdate(for bytes: Bytes) {

  }

  private func handleA2dpConnectionUpdate(for bytes: Bytes) {

  }

  private func handleSetSerialNumberUpdate(for bytes: Bytes) {

  }


}
