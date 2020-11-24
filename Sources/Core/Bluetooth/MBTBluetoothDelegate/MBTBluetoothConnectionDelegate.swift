//
//  MBTBluetoothConnectionDelegate.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by Ressier Mathilde on 24/11/2020.
//  Copyright © 2020 MyBrainTechnologies. All rights reserved.
//

import Foundation
import CoreBluetooth

/// Delegate for BLE connection steps
protocol MBTBluetoothConnectionDelegate: class {
  var scanServices: [CBUUID] { get }

  func didBluetoothStateChanged(_ state: CBManagerState)

  func isValidPeripheralToConnect(_ peripheral: MBTPeripheral) -> Bool
  func willConnect(to peripheral: MBTPeripheral)
  func didConnect(to peripheral: CBPeripheral)
  func didFailToConnect(error: Error?)

  func didDisconnect(error: Error?)
}

