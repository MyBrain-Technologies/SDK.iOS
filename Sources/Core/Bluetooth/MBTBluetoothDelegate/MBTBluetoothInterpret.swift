//
//  BluetoothLowEnergyInterpret.swift
//  BLE Connection
//
//  Created by Ressier Mathilde on 24/11/2020.
//

import Foundation
import CoreBluetooth

protocol MBTBluetoothInterpretDelegate: class {
  var discoverServices: [CBUUID] { get }

  func didUpdateValueFor(characteristic: CBCharacteristic)
  func didDiscoverServiceWithCharacteristics(_ service: CBService)
  func didCompletePeripheralDiscovery(_ peripheral: CBPeripheral)
}

class MBTBluetoothInterpret: NSObject {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  // Delegate
  weak var delegate: MBTBluetoothInterpretDelegate? = nil

  // Private
  private(set) var myPeripheral: CBPeripheral? = nil

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(delegate: MBTBluetoothInterpretDelegate?, peripheral: CBPeripheral?) {
    super.init()
    self.delegate = delegate
    self.myPeripheral = peripheral
    print("Initialize MBTBluetoothInterpret")
  }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  func discoverServices(onPeripheral peripheral: CBPeripheral) {
    save(peripheral: peripheral)
    log.debug("discover services")
    myPeripheral?.discoverServices(delegate?.discoverServices)
  }

  func save(peripheral: CBPeripheral?) {
    myPeripheral = peripheral
    myPeripheral?.delegate = self
  }
}

//==============================================================================
// MARK: - CBPeripheral extension
//==============================================================================

extension MBTBluetoothInterpret: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral,
                  didUpdateValueFor characteristic: CBCharacteristic,
                  error: Error?) {
    if let error = error {
      print("Did update value for \(characteristic.uuid) error : \(error)")
    }

    print("Did update value for \(characteristic.uuid)")
    delegate?.didUpdateValueFor(characteristic: characteristic)
  }

  func peripheral(_ peripheral: CBPeripheral,
                  didDiscoverServices error: Error?) {
    print("Discover services of \(peripheral)")

    for service in peripheral.services ?? [] {
      peripheral.discoverCharacteristics(nil, for: service)
    }
  }

  func peripheral(_ peripheral: CBPeripheral,
                  didDiscoverCharacteristicsFor service: CBService,
                  error: Error?) {
    print("Discover charac. of \(peripheral.name ?? "") - \(service.uuid)")

    delegate?.didDiscoverServiceWithCharacteristics(service)

    if let expectedServices = delegate?.discoverServices,
     peripheral.hasDiscoveredCharacteristics(forServices: expectedServices) {
      print("Discover all characteristics !")
      save(peripheral: peripheral)
      delegate?.didCompletePeripheralDiscovery(peripheral)
    }
  }
}

//==============================================================================
// MARK: - CBService extension
//==============================================================================

extension CBService {
  var characteristicsUUID: [CBUUID] {
    get { return characteristics?.compactMap({ $0.uuid }) ?? [] }
  }
}

//==============================================================================
// MARK: - CBPeripheral extensions
//==============================================================================

extension CBPeripheral {
  /// Check if characteristics have been discovered for a set of services in the current peripheral
  /// - Parameter services: list of services that should have characteristics discovered
  /// - Returns: true if characteristics are discovered, false otherwise
  func hasDiscoveredCharacteristics(forServices services: [CBUUID]) -> Bool {
    let incompleteService = services.first() {
      !hasDiscoveredCharacteristics(forService: $0)
    }
    return incompleteService == nil
  }

  /// Check if characteristics have been discovered for a service in the current peripheral
  /// - Parameter service: the service that should have characteristics discovered
  /// - Returns: true if characteristics are discovered, false otherwise
  func hasDiscoveredCharacteristics(forService service: CBUUID) -> Bool {
    let service = services?.first() { $0.uuid == service }

    guard let characteristics = service?.characteristics else {
      return false // incomplete
    }
    return !characteristics.isEmpty
  }
}
