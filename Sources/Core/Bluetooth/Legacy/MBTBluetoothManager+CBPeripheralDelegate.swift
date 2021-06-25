import Foundation
import CoreBluetooth

extension MBTBluetoothManager: CBPeripheralDelegate {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private var hasDiscoverAllCharacteristics: Bool {
    return counterServicesDiscover <= 0
      && bluetoothDeviceCharacteristics.mailBox != nil
      && bluetoothDeviceCharacteristics.deviceInformations.count == 4
  }

  //----------------------------------------------------------------------------
  // MARK: - Delegate Methods
  //----------------------------------------------------------------------------

  /// Check if the service discovered is a valid Service.
  /// Invoked when you discover the peripheral’s available services.
  /// - Parameters:
  ///   - peripheral: The peripheral that the services belong to.
  ///   - error: If an error occurred, the cause of the failure.
  func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverServices error: Error?
  ) {
    log.verbose("🆕 Did discover services")

    // Check all the services of the connecting peripheral.
    guard isBLEConnected, let services = peripheral.services else {
      log.error("BLE peripheral is connected ? \(isBLEConnected)")
      log.error("Services peripheral are nil ? \(peripheral.services == nil)")
      return
    }
    counterServicesDiscover = 0

    for service in services {
      let currentService = service as CBService
      // Get the MyBrainService and Device info UUID
      let servicesUUID = BluetoothService.melomindServices.uuids

      // Check if manager should look at this service characteristics
      if servicesUUID.contains(service.uuid) {
        peripheral.discoverCharacteristics(nil, for: currentService)
        counterServicesDiscover += 1
      }
    }
  }

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

    guard isBLEConnected, service.characteristics != nil else {
      return
    }

    counterServicesDiscover -= 1

    updateDeviceCharacteristics(with: service)

    if hasDiscoverAllCharacteristics {
      prepareDevice()
    }
  }

  private func updateDeviceCharacteristics(with service: CBService) {
    guard let serviceCharacteristics = service.characteristics else { return }

    bluetoothDeviceCharacteristics.update(with: serviceCharacteristics)
  }

  private func prepareDevice() {
    prepareDeviceWithInfo() {
      self.requestBatteryLevel()
      self.timers.startFinalizeConnectionTimer()
    }
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
    guard isBLEConnected else {
      log.error("Ble peripheral is not set")
      return
    }

    /******************** Quick access ********************/

    let deviceAcquisition = MBTClient.shared.deviceAcquisitionManager

    guard let service = BluetoothService(uuid: characteristic.uuid) else {
      log.error("unknown service", context: characteristic.uuid)
      return
    }

    let serviceString = service.uuid.uuidString
    log.verbose("🆕 Did update value for characteristic. (\(serviceString))")

    switch service {
    case .brainActivityMeasurement: brainActivityService(characteristic)
    case .headsetStatus: headsetStatusService(characteristic)
    case .deviceBatteryStatus: deviceBatteryService(characteristic)
    case .mailBox: mailBoxService(characteristic)
    default: break
    }

    let deviceCharacteristics = BluetoothService.deviceCharacteristics.uuids
    if deviceCharacteristics.contains(service.uuid) {
      deviceAcquisition.processDeviceInformations(characteristic)
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Service
  //----------------------------------------------------------------------------

  private func brainActivityService(_ characteristic: CBCharacteristic) {
    log.verbose("Brain activity service")

    guard let data = characteristic.value, isListeningToEEG else { return }

    DispatchQueue.main.async {
      self.didReceiveBrainData?(data)
    }
  }

  private func headsetStatusService(_ characteristic: CBCharacteristic) {
    log.verbose("Headset status service")

    DispatchQueue.global(qos: .background).async {
      self.didReceiveHeadsetStatus?(characteristic)
    }
  }

  private func deviceBatteryService(_ characteristic: CBCharacteristic) {
    log.verbose("Device battery service")

    if processBatteryLevel {
      let acquisitionManager = MBTClient.shared.deviceAcquisitionManager
      acquisitionManager.processDeviceBatteryStatus(characteristic)
    } else {
      log.info("📲 Fake finalize connection")

      processBatteryLevel = true
      if shouldUpdateDeviceExternalName() {
        if let name = getDeviceExternalName() {
          sendDeviceExternalName(name)
        } else {
          finalizeConnectionMelomind()
        }
      } else {
        finalizeConnectionMelomind()
      }
    }
  }

  private func mailBoxService(_ characteristic: CBCharacteristic) {
    log.verbose("Mailbox service")

    timers.stopOADTimer()

    guard let data = characteristic.value else { return }

    let length = data.count * MemoryLayout<UInt8>.size
    var bytesArray = [UInt8](repeating: 0, count: data.count)
    (data as NSData).getBytes(&bytesArray, length: length)
    guard let event = MailboxCommand(rawValue: bytesArray[0]) else {
      print("Unknown Mailbox command: \(bytesArray)")
      return
    }

    switch event {
    case .otaModeEvent: otaModeEvent(bytes: bytesArray)
    case .otaIndexResetEvent: otaIndexResetEvent(bytes: bytesArray)
    case .otaStatusEvent: otaStatusEvent(bytes: bytesArray)
    case .a2dpConnection: a2dpConnection(bytes: bytesArray)
    case .setSerialNumber: setSerialNumber(bytes: bytesArray)
    default: log.info("📲 Unknown MBX response")
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Mailbox Events
  //----------------------------------------------------------------------------

  private func otaModeEvent(bytes: [UInt8]) {
    log.info("📲 Mailbox OTA_MODE_EVT bytesArray", context: bytes.description)

    if bytes[1] == 0x01 {
      OADState = .inProgress
      eventDelegate?.onReadyToUpdate?()
      eventDelegate?.onProgressUpdate?(0.1)
      sendOADBuffer()
    } else {
      isOADInProgress = false
      OADState = .disable
      peripheralIO.notifyMailBox(value: false)
      startBatteryLevelTimer()

      let error = OADError.transferPreparationFailed.error
      log.error("📲 Transfer failed", context: error)

      eventDelegate?.onUpdateFailWithError?(error)
    }
  }

  private func otaIndexResetEvent(bytes: [UInt8]) {
    log.info("📲 Mailbox OTA_IDX_RESET_EVT bytesArray",
             context: bytes.description)

    let dispatchWorkItem =
      DispatchWorkItem(qos: .default, flags: .barrier) {
        let shift1 = Int16((bytes[2] & 0xFF)) << 8
        let shift2 = Int16(bytes[1] & 0xFF)
        let iBlock = shift1 | shift2
        self.OADManager?.oadProgress.iBlock = iBlock
    }

    DispatchQueue.global().async(execute: dispatchWorkItem)
  }

  private func otaStatusEvent(bytes: [UInt8]) {
    log.info("📲 Mailbox OTA_STATUS_EVT bytesArray",
             context: bytes.description)

    if bytes[1] == 0x01 {
      timers.stopOADTimer()

      OADState = .completed
      eventDelegate?.onProgressUpdate?(0.9)
      eventDelegate?.onUpdateComplete?()
    } else {
      startBatteryLevelTimer()
      isOADInProgress = false
      OADState = .disable

      let error = OADError.transferInterrupted.error
      log.error("📲 Transfer failed", context: error)

      eventDelegate?.onUpdateFailWithError?(error)
    }
  }

  private func a2dpConnection(bytes: [UInt8]) {
    log.verbose("📲 A2DP connection")

    let bytesResponse = bytes[1]
    let bytesA2DPStatus =
      MailBoxA2DPResponse.getA2DPResponse(from: bytesResponse)

    log.info("📲 A2DP bytes", context: bytes.description)
    log.info("📲 A2DP bits", context: bytesA2DPStatus.description)

    if bytesA2DPStatus.contains(.inProgress) {
      log.info("📲 A2DP in progress")
    }
    if bytesA2DPStatus.contains(.success) {
      log.info("📲 A2DP connection success")
    } else {
      var error: Error?
      if bytesA2DPStatus.contains(.failedBadAdress) {
        error = OADError.badBDAddr.error
      } else if bytesA2DPStatus.contains(
        .failedAlreadyConnected
        ) {
        error = AudioError.audioAldreadyConnected.error
      } else if bytesA2DPStatus.contains(.linkKeyInvalid) {
        error = AudioError.audioUnpaired.error
      } else if bytesA2DPStatus.contains(.failedTimeout) {
        error = AudioError.audioConnectionTimeOut.error
      }

      if let error = error {
        log.error("📲 Transfer failed", context: error)

        if isOADInProgress {
          eventDelegate?.onUpdateFailWithError?(error)
        } else {
          eventDelegate?.onConnectionFailed?(error)
        }

        timers.stopA2DPConnectionTimer()
        disconnect()
      }
    }
  }

  private func setSerialNumber(bytes: [UInt8]) {
    log.info("📲 Set serial number bytes", context: bytes.description)

    timers.stopSendExternalNameTimer()

    finalizeConnectionMelomind()
  }

  #warning("Unused?")
  func peripheral(_ peripheral: CBPeripheral,
                  didWriteValueFor characteristic: CBCharacteristic,
                  error: Error?) {
  }

  /// Check if the notification status changed.
  /// Invoked when the peripheral receives a request to start
  /// or stop providing notifications for a specified characteristic’s value.
  /// - Parameters:
  ///   - peripheral: The peripheral that the services belong to.
  ///   - service: The characteristic whose value has been retrieved.
  ///   - error: If an error occurred, the cause of the failure.
  /// Remark: Absence of this function causes the notifications not to register anymore.
  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateNotificationStateFor characteristic: CBCharacteristic,
    error: Error?) {
  }
}
