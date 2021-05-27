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
  // MARK: - Properties
  //----------------------------------------------------------------------------

  var peripheral: CBPeripheral? {
    didSet {
      updatePeripheral()
    }
  }

  #warning("TODO: Rename to `isHeadsetConnected`")
  /// A *Bool* which indicate if the headset is connected or not to BLE and A2DP.
  var isConnected: Bool {
    // Before peripheral != nil
    return peripheral?.state == .connected
  }

  var indusVersion: IndusVersion {
    #warning("TODO")
    return .indus2

//    guard let hardwareVersion = hardwareVersion else { return nil }
//    return IndusVersion(fromHardwareVersion: hardwareVersion)
  }

  var firmwareVersion: FormatedVersion {
    #warning("TODO")
    return FormatedVersion(major: 0, minor: 0, fix: 0)
  }

  private let peripheralManager: CBPeripheralManager

  /// Authorization given to access to bluetooth.
  private(set) var bluetoothAuthorization = BluetoothAuthorization.undetermined
  private(set) var bluetoothState = BluetoothState.undetermined

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  override init() {
    peripheralManager = CBPeripheralManager(delegate: nil, queue: nil)
    super.init()
    peripheralManager.delegate = self
  }

  //----------------------------------------------------------------------------
  // MARK: - Update
  //----------------------------------------------------------------------------

  func isVersionUpToDate(oadFirmwareVersion: FormatedVersion) -> Bool {
    log.info("Device current firmware version", context: firmwareVersion)
    log.info("Expected firmware version", context: oadFirmwareVersion)
    return firmwareVersion == oadFirmwareVersion
  }

  private func updatePeripheral() {
    peripheral?.delegate = self
    guard isConnected else { return }
    peripheral?.discoverServices(nil)
  }

  private func updatePeripheralInformation() {
    
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
    for service in services {

      // Get the MyBrainService and Device info UUID
      let servicesUUID = BluetoothService.melomindServices.uuids

      // Check if manager should look at this service characteristics
      if servicesUUID.contains(service.uuid) {
        peripheral.discoverCharacteristics(nil, for: service)
//        counterServicesDiscover += 1
      }
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
      return
    }

    for characteristic in characteristics {

      if let blCharacteristic = BluetoothService(uuid: characteristic.uuid),
         BluetoothService.deviceCharacteristics.contains(blCharacteristic),
         let data = characteristic.value,
         let dataString = String(data: data, encoding: .ascii) {
        print("Characteristic: \(blCharacteristic): \(dataString)")
      }

      print(characteristic)
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





class AttributeDiscoverer {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  var didDiscoverAllServices: (() -> Void)?

  var didDiscoverAllCharacteristics: (() -> Void)?

  var didDiscoverAllAttributes: (() -> Void)?

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------


  //----------------------------------------------------------------------------
  // MARK: - Discover
  //----------------------------------------------------------------------------

  func discover(service: CBService) {

  }

  func discover(characteristic: CBCharacteristic) {

  }

}
