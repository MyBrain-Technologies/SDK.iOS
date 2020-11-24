//
//  MBTBluetoothManager+ConnectionDelegate.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by Ressier Mathilde on 24/11/2020.
//  Copyright © 2020 MyBrainTechnologies. All rights reserved.
//

import Foundation
import CoreBluetooth

extension MBTBluetoothManager: MBTBluetoothConnectionDelegate {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  var scanServices: [CBUUID] {
    get { return [BluetoothService.myBrainService.uuid] }
  }

  //----------------------------------------------------------------------------
  // MARK: - Bluetooth State
  //----------------------------------------------------------------------------

  func didBluetoothStateChanged(_ state: CBManagerState) {
    switch state {
      case .poweredOn: didBluetoothPoweredOn()
      case .poweredOff: didBluetoothPoweredOff()
      default: log.info("📲 Bluetooth state is \(state)")
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Connection
  //----------------------------------------------------------------------------

  func isValidPeripheralToConnect(_ peripheral: MBTPeripheral) -> Bool {
    let isConnectingOrUpdating =
      timers.isBleConnectionTimerInProgress || OADState >= .started

    let isValidNewDeviceName = DeviceManager.connectedDeviceName == ""
      || DeviceManager.connectedDeviceName == peripheral.deviceName

    return peripheral.isValidMelomindDevice
      && isConnectingOrUpdating
      && isValidNewDeviceName
  }

  func willConnect(to peripheral: MBTPeripheral) {
    DeviceManager.connectedDeviceName = peripheral.deviceName
    DeviceManager.updateDeviceToMelomind()
  }

  func didConnect(to peripheral: CBPeripheral) {
    bluetoothInterpret.discoverServices(onPeripheral: peripheral)

    guard isOADInProgress && OADState >= .completed else {
      log.debug("Only reset device info")
      return DeviceManager.resetDeviceInfo()
    }

    BluetoothDeviceCharacteristics.shared.deviceInformations.removeAll()
  }

  func didFailToConnect(error: Error?) {
    log.verbose("🆕 Did fail to connect to peripheral")
    eventDelegate?.onConnectionFailed?(error)
  }

  //----------------------------------------------------------------------------
  // MARK: - Disconnection
  //----------------------------------------------------------------------------

  func didDisconnect(error: Error?) {
    processBatteryLevel = false

    if isOADInProgress {
      peripheralDisconnectedDuringOAD()
    } else {
      peripheralDisconnected(error: error)
    }

    peripheralIO.peripheral = nil
  }

}
