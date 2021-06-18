import Foundation

/*******************************************************************************
 * MailBoxEvents
 *
 * Mail box event (communication with headset by BLE)
 *
 ******************************************************************************/
// Good
enum MailBoxEvents: UInt8 {

  //----------------------------------------------------------------------------
  // MARK: - Cases
  //----------------------------------------------------------------------------

  case setADSConfig = 0

  case setAudioconfig = 1

  /// Product name configuration request
  case setProductName = 2

  /// Used by appli to request an OTA update (provides software major and minor
  ///  in payload)
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

  case batteryLevel = 20

  case serialNumber = 22

  case deviceId = 23

  /// Response: 0 failure, 1 success
  case startEeg = 24

  // Response: 0 failure, 1 success
  case stopEeg = 25

  case firmewareVersion = 27

  case hardwareVersion = 28

  case mtuSize = 29

  case unknownEvent = 0xFF

  static func getMailBoxEvent(v: UInt8) -> MailBoxEvents {
    return MailBoxEvents(rawValue: v) ?? .unknownEvent
  }
}
