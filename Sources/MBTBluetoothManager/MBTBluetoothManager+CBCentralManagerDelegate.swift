import Foundation
import CoreBluetooth

// TEMP: LEGACY CODE
// swiftlint:disable function_body_length

extension MBTBluetoothManager: CBCentralManagerDelegate {

  /// Check status of BLE hardware. Invoked when the central
  /// manager's state is update.
  /// - Parameters:
  ///   - central: The central manager whose state has changed.
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == .poweredOn {
      log.info("📲 Bluetooth powered on")

      // Scan for peripherals if BLE is turned on
      if tabHistoBluetoothState.count == 0 {
        tabHistoBluetoothState.append(true)
        eventDelegate?.onBluetoothStateChange?(true)
      } else if let lastBluetoothState = tabHistoBluetoothState.last,
        !lastBluetoothState {
        tabHistoBluetoothState.append(true)
        eventDelegate?.onBluetoothStateChange?(true)
      }

      if DeviceManager.connectedDeviceName != nil,
        timerTimeOutConnection != nil {
        log.info("📲 Bluetooth broadcasting")

        let services = [BluetoothService.myBrainService.uuid]
        centralManager?.scanForPeripherals(withServices: services, options: nil)
      }
    } else if central.state == .poweredOff {
      log.info("📲 Bluetooth powered off")

      if tabHistoBluetoothState.count == 0 {
        tabHistoBluetoothState.append(false)
        eventDelegate?.onBluetoothStateChange?(false)
      } else if let lastBluetoothState = tabHistoBluetoothState.last,
        lastBluetoothState {
        tabHistoBluetoothState.append(false)
        eventDelegate?.onBluetoothStateChange?(false)
      }

      if !isOADInProgress {

        let error: MBTError = isConnected ?
          BluetoothLowEnergyError.poweredOff: BluetoothError.poweredOff

        log.error("📲 Bluetooth connection interrupted", context: error)

        isConnected ?
          eventDelegate?.onConnectionBLEOff?(error.error) :
          eventDelegate?.onConnectionFailed?(error.error)

        disconnect()
      } else if OADState != .rebootRequired {
        centralManager?.stopScan()
        if let blePeripheral = blePeripheral {
          centralManager?.cancelPeripheralConnection(blePeripheral)
        }
        blePeripheral = nil
        if OADState > .completed {
          OADState = .connected

          let error = OADError.reconnectionAfterTransferFailed.error
          log.error("📲 OAD transfer failed", context: error)

          eventDelegate?.onUpdateFailWithError?(error)
        } else {
          isOADInProgress = false
          OADState = .disable

          let error = BluetoothError.connectionLost.error
          log.error("📲 Bluetooth connection interrupter", context: error)

          eventDelegate?.onUpdateFailWithError?(error)
        }
      }

    } else if central.state == .unsupported {
      log.info("📲 Bluetooth is unsupported on this device")
    } else if central.state == .unauthorized {
      log.info("📲 Bluetooth access not allowed on the application")
    }

    if tabHistoBluetoothState.count > 3 {
      tabHistoBluetoothState.removeFirst()
    }

    guard let lastBluetoothStatus = tabHistoBluetoothState.last,
      tabHistoBluetoothState.count == 3
        && lastBluetoothStatus
        && isOADInProgress
        && OADState == .rebootRequired else { return }

    eventDelegate?.onRebootBluetooth?()

    guard let connectedDeviceName = DeviceManager.connectedDeviceName,
      connectedDeviceName != "" else {
        let error = OADError.reconnectionAfterTransferFailed.error
        log.error("📲 Bluetooth connection failed", context: error)

        eventDelegate?.onUpdateFailWithError?(error)
        return
    }

    blePeripheral = nil
    DeviceManager.resetDeviceInfo()

    let services = [BluetoothService.myBrainService.uuid]
    centralManager?.scanForPeripherals(withServices: services, options: nil)

    OADState = .connected
  }

  /// Check out the discovered peripherals to find the right device.
  /// Invoked when the central manager discovers a peripheral while scanning.
  /// - Parameters:
  ///   - central: The central manager providing the update.
  ///   - peripheral: The discovered peripheral.
  ///   - advertisementData: A dictionary containing any advertisement data.
  ///   - RSSI: The current received signal strength indicator (RSSI) of the peripheral, in decibels.
  func centralManager(
    _ central: CBCentralManager,
    didDiscover peripheral: CBPeripheral,
    advertisementData: [String: Any],
    rssi RSSI: NSNumber
  ) {
    let localName =
      advertisementData[CBAdvertisementDataLocalNameKey] as? String
    let uuidKeys =
      advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]

    guard let nameOfDeviceFound = localName,
      let serviceArray = uuidKeys else { return }

    guard serviceArray.contains(BluetoothService.myBrainService.uuid)
      && nameOfDeviceFound.lowercased().range(of: "melo_") != nil
      && (timerTimeOutConnection != nil
        || OADState >= .started) else { return }

    if DeviceManager.connectedDeviceName == "" {
      DeviceManager.connectedDeviceName = nameOfDeviceFound
    }

    guard DeviceManager.connectedDeviceName == nameOfDeviceFound else { return }

    // Stop scanning
    centralManager?.stopScan()
    // Set as the peripheral to use and establish connection
    blePeripheral = peripheral

    blePeripheral?.delegate = self
    centralManager?.connect(peripheral, options: nil)
    DeviceManager.updateDeviceToMelomind()
  }

  /// Discover services of the peripheral.
  /// Invoked when a connection is successfully created with a peripheral.
  /// - Parameters:
  ///   - central: The central manager providing this information.
  ///   - peripheral: The peripheral that has been connected to the system.
  func centralManager(_ central: CBCentralManager,
                      didConnect peripheral: CBPeripheral)
  {
    peripheral.discoverServices(nil)

    if isOADInProgress && OADState >= .completed {
      BluetoothDeviceCharacteristics.shared.deviceInformations.removeAll()
      //      requestUpdateDeviceInfo()
    } else {
      DeviceManager.resetDeviceInfo()
    }
  }

  /// If disconnected by error, start searching again,
  /// else let event delegate know that headphones
  /// are disconnected.
  /// Invoked when an existing connection with a peripheral is torn down.
  /// - Parameters:
  ///   - central: The central manager providing this information.
  ///   - peripheral: The peripheral that has been disconnected.
  ///   - error: If an error occurred, the cause of the failure.
  func centralManager(
    _ central: CBCentralManager,
    didDisconnectPeripheral peripheral: CBPeripheral,
    error: Error?)
  {
    processBatteryLevel = false
    if isOADInProgress {
      if OADState == .completed {
        eventDelegate?.onProgressUpdate?(0.95)
        eventDelegate?.requireToRebootBluetooth?()
        OADState = .rebootRequired
      } else {
        centralManager?.stopScan()
        if let blePeripheral = blePeripheral {
          centralManager?.cancelPeripheralConnection(blePeripheral)
        }
        blePeripheral = nil
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
    } else {
      if timerTimeOutConnection != nil {
        isOADInProgress = false

        let error = BluetoothError.pairingDenied.error
        log.error("📲 Bluetooth connection failed", context: error)

        eventDelegate?.onConnectionFailed?(error)
      } else {
        eventDelegate?.onConnectionBLEOff?(error)
      }
      disconnect()
    }

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
    eventDelegate?.onConnectionFailed?(error)
  }
}
