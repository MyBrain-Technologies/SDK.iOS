import Foundation
import CoreBluetooth

// TEMP: LEGACY CODE
// swiftlint:disable function_body_length

extension MBTBluetoothManager : CBPeripheralDelegate {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Typealiases ********************/

  fileprivate typealias BLEHelper = MBTBluetoothLEHelper

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
    // Check all the services of the connecting peripheral.
    guard blePeripheral != nil, let services = peripheral.services else {
      return
    }
    counterServicesDiscover = 0

    for service in services {
      let currentService = service as CBService
      // Get the MyBrainService and Device info UUID
      let servicesUUID = MBTBluetoothLEHelper.getServicesUUIDs()

      // Check if manager should look at this service characteristics
      if servicesUUID.contains(CBUUID(data: service.uuid.data)) {
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

    guard blePeripheral != nil,
      let serviceCharacteristics = service.characteristics else {
        return
    }

    counterServicesDiscover -= 1
    // Get the device information characteristics UUIDs.
    let characteristicsUUIDS = BLEHelper.getDeviceInfoCharacteristicsUUIDS()

    // check the uuid of each characteristic
    // to find config and data characteristics
    for serviceCharacteristic in serviceCharacteristics {
      let characteristic = serviceCharacteristic as CBCharacteristic
      let characteristicData = CBUUID(data: characteristic.uuid.data)

      // MyBrainService's Characteristics
      if BluetoothService.brainActivityMeasurement.uuid == characteristicData {
        // Enable Sensor Notification and read the current value
        BLEHelper.brainActivityMeasurementCharacteristic = characteristic
      }

      // Device info's Characteristics
      if characteristicsUUIDS.contains(characteristicData) {
        BLEHelper.deviceInfoCharacteristic.append(characteristic)
      }

      // Device State's Characteristics
      if BluetoothService.deviceBatteryStatus.uuid == characteristicData {
        BLEHelper.deviceStateCharacteristic = characteristic
      }

      if BluetoothService.headsetStatus.uuid == characteristicData  {
        BLEHelper.headsetStatusCharacteristic = characteristic
      }

      if BluetoothService.mailBox.uuid == characteristicData {
        BLEHelper.mailBoxCharacteristic = characteristic
      }
      if BluetoothService.oadTransfert.uuid == characteristicData {
        BLEHelper.oadTransfertCharacteristic = characteristic
      }
    }

    guard counterServicesDiscover <= 0
      && BLEHelper.mailBoxCharacteristic != nil
      && BLEHelper.deviceInfoCharacteristic.count == 4 else { return }

    prepareDeviceWithInfo {
      self.requestUpdateBatteryLevel()
      self.timerFinalizeConnectionMelomind = Timer.scheduledTimer(
        timeInterval: 2.0,
        target: self,
        selector: #selector(self.requestUpdateBatteryLevel),
        userInfo: nil,
        repeats: false
      )
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
    guard let notifiedData = characteristic.value, blePeripheral != nil else {
      return
    }

    /******************** Quick access ********************/

    let eegAcqusition = MBTClient.shared.eegAcqusitionManager
    let deviceAcquisition = MBTClient.shared.deviceAcqusitionManager

    // Get the device information characteristics UUIDs.
    let characsUUIDS = MBTBluetoothLEHelper.getDeviceInfoCharacteristicsUUIDS()
    let characteristicUUID = CBUUID(data: characteristic.uuid.data)

    switch characteristicUUID {
    case BluetoothService.brainActivityMeasurement.uuid :
      DispatchQueue.main.async { [weak self] in
        guard let isListeningToEEG = self?.isListeningToEEG,
          isListeningToEEG else { return }
        eegAcqusition.processBrainActivityData(notifiedData)
      }

    case BluetoothService.headsetStatus.uuid :
      DispatchQueue.global(qos: .background).async {
        deviceAcquisition.processHeadsetStatus(characteristic)
      }
    case BluetoothService.deviceBatteryStatus.uuid :
      if processBatteryLevel {
        deviceAcquisition.processDeviceBatteryStatus(characteristic)
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
    case let uuid where characsUUIDS.contains(uuid) :
      deviceAcquisition.processDeviceInformations(characteristic)
    case BluetoothService.mailBox.uuid :
      stopTimerTimeOutA2DPConnection()
      if let data = characteristic.value {
        let length = data.count * MemoryLayout<UInt8>.size
        var bytesArray = [UInt8](repeating: 0, count: data.count)
        (data as NSData).getBytes(&bytesArray, length: length)

        switch MailBoxEvents.getMailBoxEvent(v: bytesArray[0]) {
        case .otaModeEvent :
          log.info("📲 MBX_OTA_MODE_EVT bytesArray",
                   context: bytesArray.description)

          if bytesArray[1] == 0x01 {
            OADState = .inProgress
            eventDelegate?.onReadyToUpdate?()
            eventDelegate?.onProgressUpdate?(0.1)
            sendOADBuffer()
          } else {
            isOADInProgress = false
            OADState = .disable
            if let characteristic = MBTBluetoothLEHelper.mailBoxCharacteristic {
              blePeripheral?.setNotifyValue(false, for: characteristic)
            }
            startTimerUpdateBatteryLevel()

            let error = OADError.transferPreparationFailed.error
            log.error("📲 Transfer failed", context: error)

            eventDelegate?.onUpdateFailWithError?(error)
          }
        case .otaIndexResetEvent :
          log.info("📲 MBX_OTA_IDX_RESET_EVT bytesArray",
                   context: bytesArray.description)
          let dispatchWorkItem =
            DispatchWorkItem(qos: .default, flags: .barrier) {
              let shift1 = Int16((bytesArray[2] & 0xFF)) << 8
              let shift2 = Int16(bytesArray[1] & 0xFF)
              let iBlock = shift1 | shift2
              self.OADManager?.oadProgress.iBlock = iBlock
          }

          DispatchQueue.global().async(execute: dispatchWorkItem)
        case .otaStatusEvent :
          log.info("📲 MBX_OTA_STATUS_EVT bytesArray",
                   context: bytesArray.description)
          if bytesArray[1] == 1 {
            stopTimerTimeOutOAD()
            OADState = .completed
            eventDelegate?.onProgressUpdate?(0.9)
            eventDelegate?.onUpdateComplete?()
          } else {
            startTimerUpdateBatteryLevel()
            isOADInProgress = false
            OADState = .disable

            let error = OADError.transferInterrupted.error
            log.error("📲 Transfer failed", context: error)

            eventDelegate?.onUpdateFailWithError?(error)
          }
        case .a2dpConnection :
          let bytesResponse = bytesArray[1]
          let bytesArrayA2DPStatus =
            MailBoxA2DPResponse.getA2DPResponse(from: bytesResponse)

          log.info("📲 A2DP bytes", context: bytesArray.description)
          log.info("📲 A2DP bits", context: bytesArrayA2DPStatus.description)

          if bytesArrayA2DPStatus.contains(.inProgress) {
            log.info("📲 A2DP in progress")
          }
          if bytesArrayA2DPStatus.contains(.success) {
            log.info("📲 A2DP connection success")
          } else {
            var error:Error?
            if bytesArrayA2DPStatus.contains(.failedBadAdress) {
              error = OADError.badBDAddr.error
            } else if bytesArrayA2DPStatus.contains(
              .failedAlreadyConnected
              ) {
              error = AudioError.audioAldreadyConnected.error
            } else if bytesArrayA2DPStatus.contains(.linkKeyInvalid) {
              error = AudioError.audioUnpaired.error
            } else if bytesArrayA2DPStatus.contains(.failedTimeout) {
              error = AudioError.audioConnectionTimeOut.error
            }

            if let error = error {
              log.error("📲 Transfer failed", context: error)

              if isOADInProgress {
                eventDelegate?.onUpdateFailWithError?(error)
              } else {
                eventDelegate?.onConnectionFailed?(error)
              }

              stopTimerTimeOutA2DPConnection()
              disconnect()
            }
          }
        case .setSerialNumber:
          log.info("📲 Set serial number bytes",
                   context: bytesArray.description)

          stopTimerSendExternalName()
          finalizeConnectionMelomind()
        default:
          log.info("📲 Unknown MBX response")
        }
      }
    default:
      break
    }
  }

  func peripheral(_ peripheral: CBPeripheral,
                  didWriteValueFor characteristic: CBCharacteristic,
                  error: Error?) {}

  /// Check if the notification status changed.
  /// Invoked when the peripheral receives a request to start
  /// or stop providing notifications for a specified characteristic’s value.
  /// - Parameters:
  ///   - peripheral: The peripheral that the services belong to.
  ///   - service: The characteristic whose value has been retrieved.
  ///   - error: If an error occurred, the cause of the failure.
  /// Remark : Absence of this function causes the notifications not to register anymore.
  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateNotificationStateFor characteristic: CBCharacteristic,
    error: Error?) {
  }
}
