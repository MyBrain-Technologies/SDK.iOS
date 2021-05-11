//
//  ViewController.swift
//  BluetoothTestApp
//
//  Created by Laurent on 08/05/2021.
//  Copyright © 2021 MyBrainTechnologies. All rights reserved.
//

import UIKit
import CoreBluetoothMock

extension CBUUID {
  static let nordicBlinkyService  = CBUUID(string: "00001523-1212-EFDE-1523-785FEABCD123")
  static let buttonCharacteristic = CBUUID(string: "00001524-1212-EFDE-1523-785FEABCD123")
  static let ledCharacteristic    = CBUUID(string: "00001525-1212-EFDE-1523-785FEABCD123")
}

extension CBMCharacteristicMock {

  static let buttonCharacteristic = CBMCharacteristicMock(
    type: .buttonCharacteristic,
    properties: [.notify, .read],
    descriptors: CBMClientCharacteristicConfigurationDescriptorMock()
  )

  static let ledCharacteristic = CBMCharacteristicMock(
    type: .ledCharacteristic,
    properties: [.write, .read]
  )

}

class BlinkyCBMPeripheralSpecDelegate: CBMPeripheralSpecDelegate {
  enum BlinkyCBMPeripheralSpecDelegateError: Error {
    case connectionFailed
  }

  private var ledEnabled: Bool = false
  private var buttonPressed: Bool = false

  private var ledData: Data {
    return ledEnabled ? Data([0x01]) : Data([0x00])
  }

  private var buttonData: Data {
    return buttonPressed ? Data([0x01]) : Data([0x00])
  }

  func peripheral(_ peripheral: CBMPeripheralSpec,
                  didReceiveReadRequestFor characteristic: CBMCharacteristic)
  -> Result<Data, Error> {
    if characteristic.uuid == .ledCharacteristic {
      return .success(ledData)
    } else {
      return .success(buttonData)
    }
  }

  func peripheral(_ peripheral: CBMPeripheralSpec,
                  didReceiveWriteRequestFor characteristic: CBMCharacteristic,
                  data: Data) -> Result<Void, Error> {
    if data.count > 0 {
      ledEnabled = data[0] != 0x00
    }
    return .success(())
  }

  func peripheral(_ peripheral: CBMPeripheralSpec,
                  didReceiveServiceDiscoveryRequest serviceUUIDs: [CBMUUID]?
  ) -> Result<Void, Error> {
    return .success(())
  }

  func peripheral(_ peripheral: CBMPeripheralSpec, didDisconnect error: Error?) {
    print("Disconnected")
  }

  func peripheralDidReceiveConnectionRequest(_ peripheral: CBMPeripheralSpec) -> Result<Void, Error> {
//    print("Connection")
    return .success(())
  }

}

class ViewController: UIViewController {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  @IBOutlet weak private var powerSwitch: UISwitch!


  /******************** Bluetooth ********************/

  var bluetoothMock: CBCentralManager?

  let mock = CBMCentralManagerMock()

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

  lazy var blinky: CBMPeripheralSpec = {
    let service = CBMServiceMock(type: CBUUID.nordicBlinkyService, primary: true)

    return CBMPeripheralSpec
      .simulatePeripheral(proximity: .immediate)
      .advertising(
        advertisementData: [
          CBAdvertisementDataLocalNameKey    : "nRF Blinky",
          CBAdvertisementDataServiceUUIDsKey : [CBUUID.nordicBlinkyService],
          CBAdvertisementDataIsConnectable   : true as NSNumber
        ],
        withInterval: 0.250,
        alsoWhenConnected: false)
      .connectable(
        name: "nRF Blinky",
        services: [service],
        delegate: BlinkyCBMPeripheralSpecDelegate(),
        connectionInterval: 0.150,
        mtu: 23)
      .build()
  }()

  private func setupMockBluetooth() {







    CBMCentralManagerMock.simulatePeripherals([blinky])

    bluetoothMock = CBCentralManagerFactory.instance(delegate: self,
                                                     queue: nil,
                                                     forceMock: true)

    CBMCentralManagerMock.simulatePowerOn()
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
        bluetoothMock?.scanForPeripherals(
          withServices: [CBUUID.nordicBlinkyService],
          options: nil
        )
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
    print("🆕 Did discover peripheral \(peripheral)")


    bluetoothMock?.stopScan()
    central.connect(peripheral, options: nil)

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
  func centralManager(_ central: CBMCentralManager,
                      didConnect peripheral: CBMPeripheral) {
    print("🆕 Did connect to peripheral")

    peripheral.delegate = self
    peripheral.discoverServices(nil)
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


extension ViewController: CBPeripheralDelegate {

  func peripheral(_ peripheral: CBMPeripheral,
                  didDiscoverServices error: Error?) {
    print(peripheral.services)
    if let services = peripheral.services,
       let service = services.first(where: { $0.uuid == CBUUID.nordicBlinkyService })  {
      print("Good \(service)")
    }
    print("End didDiscoverServices")
  }
}
