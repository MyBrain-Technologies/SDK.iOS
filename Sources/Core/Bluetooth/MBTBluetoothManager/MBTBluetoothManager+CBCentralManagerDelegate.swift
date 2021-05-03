import Foundation
import CoreBluetooth

extension MBTBluetoothManager: CBCentralManagerDelegate {

  //----------------------------------------------------------------------------
  // MARK: - centralManager DidUpdateState
  //----------------------------------------------------------------------------

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    log.verbose("🆕 Did update state")

    switch central.state {
    case .poweredOn: didBluetoothPoweredOn()
    case .poweredOff: didBluetoothPoweredOff()
    default: log.info("📲 Bluetooth state is \(central.state)")
    }

    let hasRebootBluetooth = bluetoothStatesHistory.isPoweredOn
      && bluetoothStatesHistory.historyIsFull

    if isOADInProgress && OADState == .rebootRequired && hasRebootBluetooth {
      continueOADAfterBluetoothReboot()
    }
  }

  /// Bluetooth state changed to powered on
  private func didBluetoothPoweredOn() {
    log.info("📲 Bluetooth powered on")

    // Scan for peripherals if BLE is turned on

    if bluetoothStatesHistory.isPoweredOn == false {
      bluetoothStatesHistory.addState(isConnected: true)
      eventDelegate?.onBluetoothStateChange?(true)
    }

    guard DeviceManager.connectedDeviceName != nil,
      timers.isBleConnectionTimerInProgress else { return }

    bluetoothConnector.scanForMelomindConnections()
  }

  /// bluetooth state changed to powered off
  private func didBluetoothPoweredOff() {
    log.info("📲 Bluetooth powered off")

    if bluetoothStatesHistory.isPoweredOn {
      bluetoothStatesHistory.addState(isConnected: false)
      eventDelegate?.onBluetoothStateChange?(false)
    }

    if isOADInProgress {
      didBluetoothPoweredOffDuringOAD()
    } else {
      sendBluetoothPoweredOffError()
    }
  }

  private func sendBluetoothPoweredOffError() {
    let error: MBTError = isAudioAndBLEConnected ?
      BluetoothLowEnergyError.poweredOff: BluetoothError.poweredOff

    log.error("📲 Bluetooth connection interrupted", context: error)

    isAudioAndBLEConnected ?
      eventDelegate?.onConnectionBLEOff?(error.error) :
      eventDelegate?.onConnectionFailed?(error.error)

    disconnect()
  }

  private func didBluetoothPoweredOffDuringOAD() {
    guard OADState != .rebootRequired else { return }

    bluetoothConnector.stopScanningForConnections(
      on: peripheralIO.peripheral
    )
    peripheralIO.peripheral = nil

    if OADState > .completed {
      OADState = .connected

      let error = OADError.reconnectionAfterTransferFailed.error
      log.error("📲 OAD transfer failed", context: error)

      eventDelegate?.onUpdateFailWithError?(error)
    } else {
      isOADInProgress = false
      OADState = .disable

      let error = BluetoothError.connectionLost.error
      log.error("📲 Bluetooth connection interrupted", context: error)

      eventDelegate?.onUpdateFailWithError?(error)
    }
  }

  /// Bluetooth has rebooth, continue OAD
  private func continueOADAfterBluetoothReboot() {
    eventDelegate?.onRebootBluetooth?()

    guard let connectedDeviceName = DeviceManager.connectedDeviceName,
      connectedDeviceName != "" else {
        let error = OADError.reconnectionAfterTransferFailed.error
        log.error("📲 Bluetooth connection failed", context: error)

        eventDelegate?.onUpdateFailWithError?(error)
        return
    }

    peripheralIO.peripheral = nil
    DeviceManager.resetDeviceInfo()

    bluetoothConnector.scanForMelomindConnections()

    OADState = .connected
  }

  /// Check out the discovered peripherals to find the right device.
  /// Invoked when the central manager discovers a peripheral while scanning.
  func centralManager(_ central: CBCentralManager,
                      didDiscover peripheral: CBPeripheral,
                      advertisementData: [String: Any],
                      rssi RSSI: NSNumber) {
    log.verbose("🆕 Did discover peripheral")

    let dataReader = BluetoothAdvertisementDataReader(data: advertisementData)

    guard let newDeviceName = dataReader.localName,
      let newDeviceServices = dataReader.uuidKeys else { return }

    let isMelomindDevice = MelomindBluetoothPeripheral.isMelomindDevice(
      deviceName: newDeviceName,
      services: newDeviceServices
    )
    let isConnectingOrUpdating =
      timers.isBleConnectionTimerInProgress || OADState >= .started

    guard isMelomindDevice && isConnectingOrUpdating else { return }

    if DeviceManager.connectedDeviceName == "" {
      DeviceManager.connectedDeviceName = newDeviceName
    }

    guard DeviceManager.connectedDeviceName == newDeviceName else { return }

    bluetoothConnector.stopScanningForConnections()
    peripheralIO.peripheral = peripheral

    peripheralIO.peripheral?.delegate = self

    bluetoothConnector.connect(to: peripheral)

    DeviceManager.updateDeviceToMelomind()
  }

  //----------------------------------------------------------------------------
  // MARK: - CentralManager DidConnectPeripheral
  //----------------------------------------------------------------------------

  func centralManager(_ central: CBCentralManager,
                      didConnect peripheral: CBPeripheral) {
    log.verbose("🆕 Did connect to peripheral")

    peripheral.discoverServices(nil)

    guard isOADInProgress && OADState >= .completed else {
      return DeviceManager.resetDeviceInfo()
    }

    bluetoothDeviceCharacteristics.deviceInformations.removeAll()
  }

  //----------------------------------------------------------------------------
  // MARK: - CentralManager - DidDisconnectPeripheral
  //----------------------------------------------------------------------------

  /// If disconnected by error, start searching again,
  /// else let event delegate know that headphones are disconnected.
  func centralManager(_ central: CBCentralManager,
                      didDisconnectPeripheral peripheral: CBPeripheral,
                      error: Error?) {
    log.verbose("🆕 Did disconnect peripheral")

    processBatteryLevel = false
    if isOADInProgress {
      peripheralDisconnectedDuringOAD()
    } else {
      peripheralDisconnected(error: error)
    }
  }

  /// Connected peripheral has been disconnected during  OAD
  private func peripheralDisconnectedDuringOAD() {
    guard OADState != .completed else {
      eventDelegate?.onProgressUpdate?(0.95)
      eventDelegate?.requireToRebootBluetooth?()
      OADState = .rebootRequired
      return
    }

    bluetoothConnector.stopScanningForConnections(
      on: peripheralIO.peripheral
    )
    peripheralIO.peripheral = nil

    if OADState >= .completed {
      OADState = .connected

      let error = OADError.reconnectionAfterTransferFailed.error
      log.error("📲 Bluetooth connection failed", context: error)

      eventDelegate?.onUpdateFailWithError?(error)
    } else {
      isOADInProgress = false
      OADState = .disable

      let error = BluetoothError.connectionLost.error
      log.error("📲 Bluetooth connection lost", context: error)

      eventDelegate?.onUpdateFailWithError?(error)
    }
  }

  /// Connected peripheral has been disconnected
  private func peripheralDisconnected(error: Error?) {
    if timers.isBleConnectionTimerInProgress {
      isOADInProgress = false

      let error = BluetoothError.pairingDenied.error
      log.error("📲 Bluetooth connection failed", context: error)

      eventDelegate?.onConnectionFailed?(error)
    } else {
      eventDelegate?.onConnectionBLEOff?(error)
    }
    disconnect()
  }

  /// If connection failed, call the event delegate
  /// with the error.
  /// Invoked when the central manager fails to create a connection with a peripheral.
  /// - Parameters:
  ///   - central: The central manager providing this information.
  ///   - peripheral: The peripheral that failed to connect.
  ///   - error: The cause of the failure.
  func centralManager(_ central: CBCentralManager,
                      didFailToConnect peripheral: CBPeripheral,
                      error: Error?) {
    log.verbose("🆕 Did fail to connect to peripheral")
    eventDelegate?.onConnectionFailed?(error)
  }
}
