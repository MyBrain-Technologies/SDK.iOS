//
//  MBTBluetoothLE.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 11/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import CoreBluetooth


/// Help MBTBluetoothManager to manage Bluetooth Low Energy ( BLE ).
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
  //MARK: - Bluetooth LE Methods

  /// Getter of Bluetooth LE Services UUIDs.
  /// - Returns : *Array* of BLE services UUIDs.
  static func getServicesUUIDs() -> [CBUUID] {
    return [myBrainServiceUUID, deviceInfoServiceUUID]
  }

  /// Getter of BLE device informations characteristics UUIDs.
  /// - Returns : *Array* of device information characteristics UUIDs.
  static func getDeviceInfoCharacteristicsUUIDS() -> [CBUUID] {
    return [productNameUUID, serialNumberUUID, hardwareRevisionUUID, firmwareRevisionUUID]
  }
}

// TEMP: disable - too much variable to rename
//swiftlint:disable identifier_name

enum MailBoxEvents: UInt8 {

  case MBX_SET_ADS_CONFIG = 0
  case MBX_SET_AUDIO_CONFIG = 1
  case MBX_SET_PRODUCT_NAME = 2 // Product name configuration request
  case MBX_START_OTA_TXF = 3 // Used by appli to request an OTA update (provides software major and minor in payload)
  case MBX_LEAD_OFF_EVT = 4 // Notifies app of a lead off modification
  case MBX_OTA_MODE_EVT = 5 // Notifies appli that we switched to OTA mode
  case MBX_OTA_IDX_RESET_EVT = 6 // Notifies appli that we request a packet Idx reset
  case MBX_OTA_STATUS_EVT = 7 // Notifies appli with the status of the OTA transfert.
  case MBX_SYS_GET_STATUS = 8 // allows to retrieve to system global status
  case MBX_SYS_REBOOT_EVT = 9 // trigger a reboot event at disconnection
  case MBX_SET_SERIAL_NUMBER = 10 // Set the melomind serial nb
  case MBX_SET_NOTCH_FILT = 11 // allows to hotswap the filters' parameters
  case MBX_SET_BANDPASS_FILT = 12 // Set the signal bandwidth by changing the embedded bandpass filter
  case MBX_SET_AMP_GAIN = 13 // Set the eeg signal amplifier gain
  case MBX_GET_EEG_CONFIG = 14 // Get the current configuration of the Notch filter, the bandpass filter, and the amplifier gain.
  case MBX_P300_ENABLE = 15 // Enable or disable the p300 functionnality of the melomind.
  case MBX_DCOFFSET_ENABLE = 16
  case MBX_CONNECT_IN_A2DP = 17
  case MBX_BAD_EVT = 0xFF

  static func getMailBoxEvent(v:UInt8) -> MailBoxEvents {
    if let mbe = MailBoxEvents(rawValue: v){
      return mbe
    }
    return .MBX_BAD_EVT
  }
}

///Mail Box Response of A2DP Connection
enum MailBoxA2DPResponse : UInt8 {
  case CMD_CODE_IN_PROGRESS = 0x01
  case CMD_CODE_FAILED_BAD_BDADDR = 0x02
  case CMD_CODE_FAILED_ALREADY_CONNECTED = 0x04
  case CMD_CODE_FAILED_TIME_OUT = 0x08
  case CMD_CODE_LINKKEY_INVALID = 0x10
  case CMD_CODE_SUCCESS = 0x80


  static func getArrayCaseEnum() -> [MailBoxA2DPResponse] {
    return [
      .CMD_CODE_IN_PROGRESS,
      .CMD_CODE_FAILED_BAD_BDADDR,
      .CMD_CODE_FAILED_ALREADY_CONNECTED,
      .CMD_CODE_FAILED_TIME_OUT,
      CMD_CODE_LINKKEY_INVALID,
      CMD_CODE_SUCCESS
    ]
  }

  static func getA2DPResponseFromUint8(_ uint8: UInt8) -> [MailBoxA2DPResponse] {
    var arrayResponse = [MailBoxA2DPResponse]()
    let arrayCaseEnum = MailBoxA2DPResponse.getArrayCaseEnum()

    for caseEnum in arrayCaseEnum {
      if uint8 & caseEnum.rawValue == caseEnum.rawValue {
        arrayResponse.append(caseEnum)
      }
    }

    return arrayResponse
  }
}
