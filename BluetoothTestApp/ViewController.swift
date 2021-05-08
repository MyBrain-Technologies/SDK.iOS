//
//  ViewController.swift
//  BluetoothTestApp
//
//  Created by Laurent on 08/05/2021.
//  Copyright © 2021 MyBrainTechnologies. All rights reserved.
//

import UIKit
import CoreBluetoothMock

class ViewController: UIViewController {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  @IBOutlet weak private var powerSwitch: UISwitch!


  /******************** Bluetooth ********************/

  var bluetoothMock: CBCentralManager?

  //----------------------------------------------------------------------------
  // MARK: - Lifecycle
  //----------------------------------------------------------------------------

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  private func setup() {
    setupPowerSwitch()
    setupMockBluetooth()
  }

  private func setupPowerSwitch() {
    powerSwitch.isOn = false
  }

  private func setupMockBluetooth() {


    bluetoothMock = CBCentralManagerFactory.instance(delegate: self,
                                                     queue: nil,
                                                     forceMock: true)
//    bluetoothMock?.scanForPeripherals(withServices: nil, options: nil)
  }

  //----------------------------------------------------------------------------
  // MARK: - Actions
  //----------------------------------------------------------------------------

  @IBAction func SwitchPowerState(_ sender: UISwitch) {
    if sender.isOn {
      turnOnBluetooth()
    } else {
      turnOffBluetooth()
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Bluetooth
  //----------------------------------------------------------------------------

  private func turnOnBluetooth() {
    CBMCentralManagerMock.simulateInitialState(.poweredOn)
  }

  private func turnOffBluetooth() {
    CBMCentralManagerMock.simulateInitialState(.poweredOff)
  }

}

extension ViewController: CBCentralManagerDelegate {

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    print("🆕 Did update with state: \(central.state)")


    switch central.state {
      case .poweredOn:
        print("On")
      case .poweredOff:
        print("Off")
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
    print("🆕 Did discover peripheral")

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
  func centralManager(central: CBCentralManager,
                      didConnectPeripheral peripheral: CBPeripheral) {
    print("🆕 Did connect to peripheral")

//    didConnectToPeripheral?(peripheral)



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
    print("🆕 Did fail to connect to peripheral: \(peripheral)")
//    eventDelegate?.onConnectionFailed?(error)
//    didConnectionFail?(error)
  }

  /// If disconnected by error, start searching again,
  /// else let event delegate know that headphones are disconnected.
  func centralManager(_ central: CBCentralManager,
                      didDisconnectPeripheral peripheral: CBPeripheral,
                      error: Error?) {
    print("🆕 Did disconnect peripheral \(peripheral)")

//    processBatteryLevel = false
//    if isOADInProgress {
//      peripheralDisconnectedDuringOAD()
//    } else {
//      peripheralDisconnected(error: error)
//    }
  }


}
