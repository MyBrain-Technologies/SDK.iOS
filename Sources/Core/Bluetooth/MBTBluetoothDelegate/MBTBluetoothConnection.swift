//
//  MBTBluetoothConnection.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by Ressier Mathilde on 24/11/2020.
//  Copyright © 2020 MyBrainTechnologies. All rights reserved.
//

import Foundation
import CoreBluetooth

class MBTBluetoothConnection: NSObject {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  // Delegate

  weak var delegate: MBTBluetoothConnectionDelegate? = nil

  // Private

  private var shouldScan = false

  private(set) var centralManager: CBCentralManager!
  private(set) var myPeripheral: CBPeripheral? = nil

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(delegate: MBTBluetoothConnectionDelegate?) {
    super.init()
    self.delegate = delegate
    centralManager = CBCentralManager(delegate: self, queue: nil)
    log.debug("Initialize MBTBluetoothConnection")
  }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  var isConnected: Bool {
    get { return (myPeripheral?.state ?? .disconnected) == .connected }
  }

  func connect() {
    shouldScan = true

    if centralManager.state == .poweredOn {
      scanForPeripherals()
    } else {
      log.verbose("Wait for central manager to trigger bluetooth change")
    }
  }

  func cancelConnection() {
    log.verbose("Cancel BLE connection")
    centralManager.stopScan()
    disconnect()
  }

  func disconnect() {
    if let peripheral = myPeripheral {
      log.verbose("Peripheral disconnection - \(peripheral.name ?? "(null)")")
      centralManager.cancelPeripheralConnection(peripheral)
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Tools
  //----------------------------------------------------------------------------

  private func scanForPeripherals() {
    guard shouldScan else { return }
    guard !centralManager.isScanning else { return }

    if let peripheral = myPeripheral {
      print("Try to connect to \(peripheral.name ?? "(null)")")
      centralManager.connect(peripheral, options: nil)
    } else {
      log.verbose("🧭 Start scanning for a device")
      centralManager.scanForPeripherals(withServices: delegate?.scanServices,
                                        options: nil)
    }
  }

  private func stopScanForPeripherals() {
    log.verbose("🧭 Stop scanning for a device")

    centralManager.stopScan()
  }

  private func save(peripheral: CBPeripheral?) {
    myPeripheral = peripheral
  }
}


//==============================================================================
// MARK: - Central Manager Delegate
//==============================================================================

extension MBTBluetoothConnection: CBCentralManagerDelegate {

  //----------------------------------------------------------------------------
  // MARK: - Did Update State
  //----------------------------------------------------------------------------

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    print("BLE status \(central.state == .poweredOn ? "powered on" : "other")")

    // register BLE status
    delegate?.didBluetoothStateChanged(central.state)

    if central.state == CBManagerState.poweredOn {
      scanForPeripherals()
    } else {
      print("Something wrong with BLE")
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Did Discover Peripheral
  //----------------------------------------------------------------------------

  func centralManager(
    _ central: CBCentralManager,
    didDiscover peripheral: CBPeripheral,
    advertisementData: [String : Any],
    rssi RSSI: NSNumber
  ) {
    let completePeripheral = MBTPeripheral(peripheral: peripheral,
                                           advertisementData: advertisementData,
                                           RSSI: RSSI)
    let canConnect =
      delegate?.isValidPeripheralToConnect(completePeripheral) ?? true

    print("discover \(peripheral) - connect ? \(canConnect)")

    guard canConnect else { return }

    stopScanForPeripherals()
    save(peripheral: peripheral)

    delegate?.willConnect(to: completePeripheral)
    centralManager.connect(peripheral, options: nil)
  }

  //----------------------------------------------------------------------------
  // MARK: - Did Connect Peripheral
  //----------------------------------------------------------------------------

  func centralManager(
    _ central: CBCentralManager,
    didConnect peripheral: CBPeripheral
  ) {
    print("connected to \(peripheral)")
    save(peripheral: peripheral)
    delegate?.didConnect(to: peripheral)
  }

  func centralManager(_ central: CBCentralManager,
                      didDisconnectPeripheral peripheral: CBPeripheral,
                      error: Error?) {
    print("disconnected from \(peripheral)")
    save(peripheral: nil)

    delegate?.didDisconnect(error: error)
  }

  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    delegate?.didFailToConnect(error: error)
  }

}
