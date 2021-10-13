import Foundation
import CoreBluetooth

class PostIndus5PeripheralValueReceiver: PeripheralValueReceiverProtocol {

  //----------------------------------------------------------------------------
  // MARK: - Error
  //----------------------------------------------------------------------------

  enum PostIndus5PeripheralValueReceiverError: Error {
    case invalidOpCode(byte: UInt8)
  }

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Decoder ********************/

  private let batteryLevelDecoder = PostIndus5BatteryLevelDecoder()

  /******************** Callbacks ********************/

  weak var delegate: PeripheralValueReceiverDelegate?

  //----------------------------------------------------------------------------
  // MARK: - Notification
  //----------------------------------------------------------------------------

  func handleNotificationStateUpdate(for characteristic: CBCharacteristic,
                                     error: Error?) {
    guard let mbtCharacteristic =
            MBTCharacteristic.PostIndus5(uuid: characteristic.uuid),
          mbtCharacteristic == .rx,
          characteristic.isNotifying == true else {
      return
    }

    delegate?.didPair()
//    guard let mbtCharacteristic =
//            MBTCharacteristic.PostIndus5(uuid: characteristic.uuid),
//          mbtCharacteristic == .rx else {
//      return
//    }
//
//    guard let error = error else {
//      delegate?.didPair()
//      return
//    }
//
//    if (error as NSError).code == CBATTError.insufficientEncryption.rawValue {
//      print(error.localizedDescription)
//      delegate?.didRequestPairing()
//      return
//    }
//
//    delegate?.didFail(with: error)
  }

  //----------------------------------------------------------------------------
  // MARK: - Write
  //----------------------------------------------------------------------------

  func handleValueWrite(for characteristic: CBCharacteristic,
                        error: Error?) {

  }

  //----------------------------------------------------------------------------
  // MARK: - Read
  //----------------------------------------------------------------------------

  func handleValueUpdate(for characteristic: CBCharacteristic, error: Error?) {
    if let error = error {
      delegate?.didFail(with: error)
      return
    }

    let characteristicCBUUID = characteristic.uuid
    guard let mbtCharacteristic =
            MBTCharacteristic.PostIndus5(uuid: characteristicCBUUID) else {
      log.error("Unknown characteristic", context: characteristicCBUUID)
      return
    }

    guard let data = characteristic.value else {
      #warning("TODO: Handle error")
      return
    }

    switch mbtCharacteristic {
      case .tx: handleTxUpdate(for: data)
      case .rx: handleRxUpdate(for: data)
      case .unknown:
        print("unknown characteristic")
        return
//      case .mailBox: handleMailboxUpdate(for: data)
    }

  }

  private func handleTxUpdate(for data: Data) {
    #warning("TODO")
  }

  private func handleRxUpdate(for data: Data) {
    let bytes = Bytes(data)

    guard let opCode = bytes.first else { return }

    guard let mailboxCommand = MailboxCommand(rawValue: opCode) else {
      print("Unknown Mailbox command: \(bytes)")
      let error =
        PostIndus5PeripheralValueReceiverError.invalidOpCode(byte: opCode)
      delegate?.didFail(with: error)
      return
    }

    let parameterBytes = Array(bytes.dropFirst())

    switch mailboxCommand {
      case .otaModeEvent: handleOtaModeUpdate(for: parameterBytes)
      case .otaIndexResetEvent: handleOtaIndexResetUpdate(for: parameterBytes)
      case .otaStatusEvent: handleOtaStatusUpdate(for: parameterBytes)
      case .a2dpConnection: handleA2dpConnectionUpdate(for: parameterBytes)
      case .setSerialNumber: handleSetSerialNumberUpdate(for: parameterBytes)
      case .batteryLevel: handleBatteryUpdate(for: parameterBytes)
      case .serialNumber: handleSerialNumberUpdate(for: parameterBytes)
      case .deviceId: handleProductNameUpdate(for: parameterBytes)
      case .firmewareVersion: handleFirmwareVersionUpdate(for: parameterBytes)
      case .hardwareVersion: handleHardwareVersionNameUpdate(for: parameterBytes)
      case .setA2dpName: handleA2dpNameUpdate(for: parameterBytes)
      case .startEeg: handleStartEeg(for: parameterBytes)
      case .stopEeg: handleStopEeg(for: parameterBytes)
      case .eegDataFrameEvent: handleEegDataFrame(for: parameterBytes)
      case .startImsAcquisition: handleStartImsAcquisition(for: parameterBytes)
      case .stopImsAcquisition: handleStopImsAcquisition(for: parameterBytes)
      case .imsDataFrameEvent: handleImsDataFrame(for: parameterBytes)
      case .mtuSize: handleMtuSize(for: parameterBytes)
      default: log.info("📲 Unknown MBX response")
    }
  }


  /******************** Device information ********************/

  private func handleProductNameUpdate(for bytes: Bytes) {
    guard let valueText = String(bytes: bytes, encoding: .ascii) else { return }
    delegate?.didUpdate(productName: valueText)
  }

  private func handleSerialNumberUpdate(for bytes: Bytes) {
    guard let valueText = String(bytes: bytes, encoding: .ascii) else { return }
    delegate?.didUpdate(serialNumber: valueText)
  }

  private func handleFirmwareVersionUpdate(for bytes: Bytes) {
    guard let valueText = String(bytes: bytes, encoding: .ascii) else { return }
    delegate?.didUpdate(firmwareVersion: valueText)
  }

  private func handleHardwareVersionNameUpdate(for bytes: Bytes) {
    guard let valueText = String(bytes: bytes, encoding: .ascii) else { return }
    delegate?.didUpdate(hardwareVersion: valueText)
  }

  /******************** Battery ********************/

  private func handleBatteryUpdate(for bytes: Bytes) {
    guard bytes.count > 0,
          let batteryLevel =
            batteryLevelDecoder.decode(headsetBatteryValue: bytes[0]) else {
      #warning("TODO: Handle postIndus5 battery error")
      return
    }

    delegate?.didUpdate(batteryLevel: batteryLevel)
  }

  /******************** EEG ********************/

  private func handleStartEeg(for bytes: Bytes) {
    print("EEG start command.")
  }

  private func handleStopEeg(for bytes: Bytes) {
    print("EEG stop command")
  }

  private func handleEegDataFrame(for bytes: Bytes) {
    let data = Data(bytes)
    delegate?.didUpdate(brainData: data)
  }


  /******************** Accelerometer ********************/

  private func handleStartImsAcquisition(for bytes: Bytes) {
    print("IMS start command.")
  }

  private func handleStopImsAcquisition(for bytes: Bytes) {
    print("IMS stop command")
  }

  private func handleImsDataFrame(for bytes: Bytes) {
    let data = Data(bytes)
    delegate?.didUpdate(imsData: data)
  }

  /******************** MTU ********************/

  private func handleMtuSize(for bytes: Bytes) {
    guard let byte = bytes.first else { return }
    guard byte != 0 else {
      print("error")
      return
    }
    let sampleBufferSize = Int(byte)
    delegate?.didUpdate(sampleBufferSizeFromMtu: sampleBufferSize)
  }

  /******************** A2DP ********************/

  private func handleA2dpNameUpdate(for bytes: Bytes) {
    guard let valueText = String(bytes: bytes, encoding: .ascii) else { return }
    print("Set new A2DP name: \(valueText)")
  }

  private func handleOtaModeUpdate(for bytes: Bytes) {
    #warning("TODO handleOtaModeUpdate")
  }

  private func handleOtaIndexResetUpdate(for bytes: Bytes) {
    #warning("TODO handleOtaIndexResetUpdate")
  }

  private func handleOtaStatusUpdate(for bytes: Bytes) {
    #warning("TODO handleOtaStatusUpdate")
  }

  private func handleA2dpConnectionUpdate(for bytes: Bytes) {
    log.verbose("📲 A2DP connection")

    let bytesResponse = bytes[1]
    let bytesA2DPStatus =
      MailBoxA2DPResponse.getA2DPResponse(from: bytesResponse)

    log.info("📲 A2DP bytes", context: bytes.description)
    log.info("📲 A2DP bits", context: bytesA2DPStatus.description)

    if bytesA2DPStatus.contains(.inProgress) {
      log.info("📲 A2DP in progress")
    }
    guard bytesA2DPStatus.contains(.success) else {
      var error: Error?
      if bytesA2DPStatus.contains(.failedBadAdress) {
        error = OADError.badBDAddr.error
      } else if bytesA2DPStatus.contains(.failedAlreadyConnected) {
        error = AudioError.audioAldreadyConnected.error
      } else if bytesA2DPStatus.contains(.linkKeyInvalid) {
        error = AudioError.audioUnpaired.error
      } else if bytesA2DPStatus.contains(.failedTimeout) {
        error = AudioError.audioConnectionTimeOut.error
      }
      #warning("TODO: Handle unknown error")

      if let error = error {
        log.error("📲 A2DP Transfer failed", context: error)
        delegate?.didFail(with: error)
//        if isOADInProgress {
//          eventDelegate?.onUpdateFailWithError?(error)
//        } else {
//          eventDelegate?.onConnectionFailed?(error)
//        }
//
//        timers.stopA2DPConnectionTimer()
//        disconnect()
      }
      return
    }

    log.info("📲 A2DP connection success")
    delegate?.didA2DPConnectionRequestSucceed()
  }

  private func handleSetSerialNumberUpdate(for bytes: Bytes) {
    guard let valueText = String(bytes: bytes, encoding: .ascii) else { return }
    print("Set new serial number: \(valueText)")
  }

}
