import CoreBluetooth

/*******************************************************************************
 * MBTBluetoothLEHelper
 *
 * Help MBTBluetoothManager to manage Bluetooth Low Energy ( BLE ).
 *
 ******************************************************************************/
struct MBTBluetoothLEHelper {
  /// The *UUID* of the MyBrainServices.
  static let myBrainServiceUUID = CBUUID(string: "0xB2A0")

  /// The *UUID* of the brainActivityMeasurement characteristic of the Measurement service.
  static let brainActivityMeasurementUUID = CBUUID(string: "0xB2A5")

  /// The *UUID* of the DeviceState characteristic of the Measurement service.
  static let deviceBatteryStatusUUID = CBUUID(string: "0xB2A2")

  /// The *UUID* of the Device name characteristic.
  static let headsetStatusUUID = CBUUID(string: "0xB2A3")

  /// The *UUID* of OAD Transfer
  static let oadTransfertUUID = CBUUID(string: "0xB2A6")

  /// The *UUID* of mail box
  static let mailBoxUUID = CBUUID(string: "0xB2A4")

  /// The *UUID* of the DeviceInformation service.
  static let deviceInfoServiceUUID = CBUUID(string: "0x180A")

  /// The *UUID* of Model Number String service.
  static let productNameUUID = CBUUID(string: "0x2A24")

  /// The *UUID* of Serial Number String service.
  static let serialNumberUUID = CBUUID(string: "0x2A25")

  /// The *UUID* of Hardware revision String service.
  static let hardwareRevisionUUID = CBUUID(string: "0x2A27")

  /// The *UUID* of Firmware revision String service.
  static let firmwareRevisionUUID = CBUUID(string: "0x2A26")

  static var deviceInfoCharacteristic = [CBCharacteristic]()

  /// The *characteristic* of the Measurement service.
  static var brainActivityMeasurementCharacteristic: CBCharacteristic!

  /// The Device state characteristic of the myBrain service.
  static var deviceStateCharacteristic: CBCharacteristic!

  /// The *characteristic* of the Headset Status
  static var headsetStatusCharacteristic: CBCharacteristic!

  /// The *characteristic* of the mail box
  static var mailBoxCharacteristic: CBCharacteristic!

  /// The *characteristic* of the OAD transfert
  static var oadTransfertCharacteristic: CBCharacteristic!

  //----------------------------------------------------------------------------
  // MARK: - Bluetooth Low Energy Methods
  //----------------------------------------------------------------------------

  /// Getter of Bluetooth LE Services UUIDs.
  /// - Returns : *Array* of BLE services UUIDs.
  static func getServicesUUIDs() -> [CBUUID] {
    return [myBrainServiceUUID, deviceInfoServiceUUID]
  }

  /// Getter of BLE device informations characteristics UUIDs.
  /// - Returns : *Array* of device information characteristics UUIDs.
  static func getDeviceInfoCharacteristicsUUIDS() -> [CBUUID] {
    return [productNameUUID, serialNumberUUID,
            hardwareRevisionUUID, firmwareRevisionUUID]
  }
}

/*******************************************************************************
 * MailBoxEvents
 *
 * Mail box event (communication with headset by BLE)
 *
 ******************************************************************************/
enum MailBoxEvents: UInt8 {
  case setADSConfig = 0
  case setAudioconfig = 1
  /// Product name configuration request
  case setProductName = 2
  /// Used by appli to request an OTA update (provides software major and minor in payload)
  case startOTATFX = 3
  /// Notifies app of a lead off modification
  case leadOffEvent = 4
  /// Notifies appli that we switched to OTA mode
  case otaModeEvent = 5
  /// Notifies appli that we request a packet Idx reset
  case otaIndexResetEvent = 6
  /// Notifies appli with the status of the OTA transfert.
  case otaStatusEvent = 7
  /// allows to retrieve to system global status
  case systemGetStatus = 8
  /// trigger a reboot event at disconnection
  case systemRebootEvent = 9
  /// Set the melomind serial nb
  case setSerialNumber = 10
  /// allows to hotswap the filters' parameters
  case setNotchFilter = 11
  /// Set the signal bandwidth by changing the embedded bandpass filter
  case setBandpassFilter = 12
  /// Set the eeg signal amplifier gain
  case setAmplifierSignalGain = 13
  /// Get the current configuration of the Notch filter, the bandpass filter, and the amplifier gain.
  case getEEGConfig = 14
  /// Enable or disable the p300 functionnality of the melomind.
  case toggleP300 = 15
  case enableDCOffset = 16
  case a2dpConnection = 17
  case unknownEvent = 0xFF

  static func getMailBoxEvent(v: UInt8) -> MailBoxEvents {
    return MailBoxEvents(rawValue: v) ?? .unknownEvent
  }
}

/*******************************************************************************
 * MailBoxA2DPResponse
 *
 * Mail Box Response of A2DP Connection
 *
 ******************************************************************************/
enum MailBoxA2DPResponse: UInt8, CaseIterable {
  case inProgress = 0x01
  case failedBadAdress = 0x02
  case failedAlreadyConnected = 0x04
  case failedTimeout = 0x08
  case linkKeyInvalid = 0x10
  case success = 0x80

  static func getA2DPResponse(from uint8: UInt8) -> [MailBoxA2DPResponse] {
    let arrayResponse = allCases.filter() {
      uint8 & $0.rawValue == $0.rawValue
    }

    return arrayResponse
  }
}
