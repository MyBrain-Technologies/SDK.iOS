//
//  MBTBluetoothManagerV2.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by Laurent on 03/05/2021.
//  Copyright © 2021 MyBrainTechnologies. All rights reserved.
//

import Foundation
import CoreBluetooth

internal class MBTBluetoothManagerV2: NSObject {

  //----------------------------------------------------------------------------
  // MARK: - properties
  //----------------------------------------------------------------------------


  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

}

internal class BluetoothIOGateway: NSObject {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  // IOBluetoothPeripheral

  /******************** Central Manager ********************/

  private lazy var cbCentralManager: CBCentralManager = {
    return CBCentralManager(delegate: self, queue: nil)
  }()


  /// The BLE peripheral with which a connection has been established.
  var blePeripheral: CBPeripheral?
//  {
//    didSet {
//      if isBLEConnected {
//        eventDelegate?.onHeadsetStatusUpdate?(true)
//      } else {
//        eventDelegate?.onHeadsetStatusUpdate?(false)
//      }
//    }
//  }


  /******************** Callbacks ********************/

  var didConnectToPeripheral: ((CBPeripheral) -> Void)?
  var didConnectionFail: ((Error?) -> Void)?

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  override init() {
    super.init()
  }

  //----------------------------------------------------------------------------
  // MARK: - Scanning
  //----------------------------------------------------------------------------

  // Will call `centralManager(_:didDiscover:advertisementData:rssi:)`
  func startScanning(services: [CBUUID]) {
    log.verbose("🧭 Start scanning for a melomind device")
    cbCentralManager.scanForPeripherals(withServices: services, options: nil)
  }

}

//==============================================================================
// MARK: - CBCentralManagerDelegate
//==============================================================================

extension BluetoothIOGateway: CBCentralManagerDelegate {

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    log.verbose("🆕 Did update with state: /(\(central.state)")


    switch central.state {
//      case .poweredOn: didBluetoothPoweredOn()
//      case .poweredOff: didBluetoothPoweredOff()
      default: break
    }

//    let hasRebootBluetooth = bluetoothStatesHistory.isPoweredOn
//      && bluetoothStatesHistory.historyIsFull
//
//    if isOADInProgress && OADState == .rebootRequired && hasRebootBluetooth {
//      continueOADAfterBluetoothReboot()
//    }
  }

  /// Check out the discovered peripherals to find the right device.
  /// Invoked when the central manager discovers a peripheral while scanning.
  func centralManager(_ central: CBCentralManager,
                      didDiscover peripheral: CBPeripheral,
                      advertisementData: [String: Any],
                      rssi RSSI: NSNumber) {
    log.verbose("🆕 Did discover peripheral")

//    let dataReader = BluetoothAdvertisementDataReader(data: advertisementData)
//
//    guard let newDeviceName = dataReader.localName,
//      let newDeviceServices = dataReader.uuidKeys else { return }
//
//    let isMelomindDevice = MelomindBluetoothPeripheral.isMelomindDevice(
//      deviceName: newDeviceName,
//      services: newDeviceServices
//    )
//    let isConnectingOrUpdating =
//      timers.isBleConnectionTimerInProgress || OADState >= .started
//
//    guard isMelomindDevice && isConnectingOrUpdating else { return }
//
//    if DeviceManager.connectedDeviceName == "" {
//      DeviceManager.connectedDeviceName = newDeviceName
//    }
//
//    guard DeviceManager.connectedDeviceName == newDeviceName else { return }
//
//    bluetoothConnector.stopScanningForConnections()
//    peripheralIO.peripheral = peripheral
//
//    peripheralIO.peripheral?.delegate = self
//
//    bluetoothConnector.connect(to: peripheral)
//
//    DeviceManager.updateDeviceToMelomind()
  }

  // Called when it succeeded
  func centralManager(_ central: CBCentralManager,
                      didConnect peripheral: CBPeripheral) {
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

  // Called when it failed
  func centralManager(_ central: CBCentralManager,
                      didFailToConnect peripheral: CBPeripheral,
                      error: Error?) {
    log.verbose("🆕 Did fail to connect to peripheral: \(peripheral)")
//    eventDelegate?.onConnectionFailed?(error)
    didConnectionFail?(error)
  }

  /// If disconnected by error, start searching again,
  /// else let event delegate know that headphones are disconnected.
  func centralManager(_ central: CBCentralManager,
                      didDisconnectPeripheral peripheral: CBPeripheral,
                      error: Error?) {
    log.verbose("🆕 Did disconnect peripheral \(peripheral)")

//    processBatteryLevel = false
//    if isOADInProgress {
//      peripheralDisconnectedDuringOAD()
//    } else {
//      peripheralDisconnected(error: error)
//    }
  }




}















//// Peripheral

internal class Peripheral: NSObject {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  var peripheral: CBPeripheral? {
    didSet {
      updatePeripheral()
    }
  }

  lazy var peripheralManager: CBPeripheralManager = {
    return CBPeripheralManager(delegate: self, queue: nil)
  }()

  /// Authorization given to access to bluetooth.
  private(set) var bluetoothAuthorization = BluetoothAuthorization.undetermined
  private(set) var bluetoothState = BluetoothState.undetermined

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // MARK: - Update
  //----------------------------------------------------------------------------

  private func updatePeripheral() {

  }

}

extension Peripheral: CBPeripheralManagerDelegate {

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    if #available(iOS 13.0, *) {
      bluetoothAuthorization =
        BluetoothAuthorization(authorization: peripheral.authorization,
                               state: peripheral.state)
    } else {
      bluetoothAuthorization = BluetoothAuthorization(state: peripheral.state)
    }

    bluetoothState = BluetoothState(state: peripheral.state)
  }

}

extension Peripheral: CBPeripheralDelegate {

  /// Enable notification and sensor for desired characteristic of valid service.
  /// Invoked when you discover the characteristics of a specified service.
  /// - Parameters:
  ///   - peripheral: The peripheral that the services belong to.
  ///   - service: The service that the characteristics belong to.
  ///   - error: If an error occurred, the cause of the failure.
  func peripheral(_ peripheral: CBPeripheral,
                  didDiscoverCharacteristicsFor service: CBService,
                  error: Error?) {
    log.verbose("🆕 Did discover characteristics")

//    guard isBLEConnected, service.characteristics != nil else {
//      return
//    }
//
//    counterServicesDiscover -= 1
//
//    updateDeviceCharacteristics(with: service)
//
//    if hasDiscoverAllCharacteristics {
//      prepareDevice()
//    }
  }

  /// Check if the service discovered is a valid Service.
  /// Invoked when you discover the peripheral’s available services.
  /// - Parameters:
  ///   - peripheral: The peripheral that the services belong to.
  ///   - error: If an error occurred, the cause of the failure.
  func peripheral(_ peripheral: CBPeripheral,
                  didDiscoverServices error: Error?) {
    log.verbose("🆕 Did discover services")

//    // Check all the services of the connecting peripheral.
//    guard isBLEConnected, let services = peripheral.services else {
//      log.error("BLE peripheral is connected ? \(isBLEConnected)")
//      log.error("Services peripheral are nil ? \(peripheral.services == nil)")
//      return
//    }
//    counterServicesDiscover = 0
//
//    for service in services {
//      let currentService = service as CBService
//      // Get the MyBrainService and Device info UUID
//      let servicesUUID = BluetoothService.melomindServices.uuids
//
//      // Check if manager should look at this service characteristics
//      if servicesUUID.contains(service.uuid) {
//        peripheral.discoverCharacteristics(nil, for: currentService)
//        counterServicesDiscover += 1
//      }
//    }
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
//    case .brainActivityMeasurement: brainActivityService(characteristic)
//    case .headsetStatus: headsetStatusService(characteristic)
//    case .deviceBatteryStatus: deviceBatteryService(characteristic)
//    case .mailBox: mailBoxService(characteristic)
//    default: break
//    }
//
//    let deviceCharacteristics = BluetoothService.deviceCharacteristics.uuids
//    if deviceCharacteristics.contains(service.uuid) {
//      deviceAcquisition.processDeviceInformations(characteristic)
//    }
  }

}
