import Foundation
import CoreBluetooth

internal class BluetoothCentral: NSObject {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Central Manager ********************/

  private let cbCentralManager: CBCentralManager

  var isScanning: Bool {
    return cbCentralManager.isScanning
  }

  private var discoveredPeripherals = [CBPeripheral]()

  /******************** Validation ********************/

  private let peripheralValidator = PeripheralValidator()

  /******************** State ********************/

  var authorization: BluetoothAuthorization {
    if #available(iOS 13.0, *) {
      return
        BluetoothAuthorization(authorization: cbCentralManager.authorization,
                               state: cbCentralManager.state)
    } else {
      return BluetoothAuthorization(state: cbCentralManager.state)
    }
  }

  var state: BluetoothState {
    return BluetoothState(state: cbCentralManager.state)
  }

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

//    #warning("TODO use right service")
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
    guard unsuportedState != .poweredOn && unsuportedState != .poweredOff else {
      assertionFailure("\(unsuportedState) is a supported state.")
      return
    }
    log.info("📲 Bluetooth state is \(unsuportedState)")
  }

  //----------------------------------------------------------------------------
  // MARK: - Scanning
  //----------------------------------------------------------------------------

  // Will call `centralManager(_:didDiscover:advertisementData:rssi:)`
  func scan(services: [CBUUID]?) {
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
    log.verbose("🆕 Did discover peripheral: \(peripheral.name ?? "Unknown")")

    
    let isMbtPeripheral = peripheralValidator.isMbtPeripheral(
      advertisementData: advertisementData
    )

    let isNotConnected = peripheral.state != .connected

//    let isConnectingOrUpdating =
//      timers.isBleConnectionTimerInProgress || OADState >= .started

    guard isMbtPeripheral, isNotConnected else { return }

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

  func disconnect(from peripheral: CBPeripheral) {
    cbCentralManager.cancelPeripheralConnection(peripheral)
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
