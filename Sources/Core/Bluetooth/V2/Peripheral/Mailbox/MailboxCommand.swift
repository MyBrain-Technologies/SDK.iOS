import Foundation

/*******************************************************************************
 * MailboxCommand
 *
 * Mail box event (communication with headset by BLE)
 *
 ******************************************************************************/
// Good
enum MailboxCommand: UInt8 {

  //----------------------------------------------------------------------------
  // MARK: - Cases
  //----------------------------------------------------------------------------

  case setADSConfig = 0x00

  case setAudioconfig = 0x01

  /// Product name configuration request
  case setProductName = 0x02

  /// Used by appli to request an OTA update (provides software major and minor
  ///  in payload)
  case startOTATFX = 0x03

  /// Notifies app of a lead off modification
  case leadOffEvent = 0x04

  /// Notifies appli that we switched to OTA mode
  case otaModeEvent = 0x05

  /// Notifies appli that we request a packet Idx reset
  case otaIndexResetEvent = 0x06

  /// Notifies appli with the status of the OTA transfert.
  case otaStatusEvent = 0x07

  /// allows to retrieve to system global status
  case systemGetStatus = 0x08

  /// trigger a reboot event at disconnection
  case systemRebootEvent = 0x09

  case setA2dpName = 0x0A

  /// Set the melomind serial nb
  case setSerialNumber = 0x10

  /// allows to hotswap the filters' parameters
  case setNotchFilter = 0x0B // GOOD

  /// Set the signal bandwidth by changing the embedded bandpass filter
  case setBandpassFilter = 0x12

  /// Set the eeg signal amplifier gain
  case setAmplifierSignalGain = 0x13

  /// Get the current configuration of the Notch filter, the bandpass filter, and the amplifier gain.
  case getEEGConfig = 0x14

  /// Enable or disable the p300 functionnality of the melomind.
  case toggleP300 = 0x15

  case enableDCOffset = 0x16

  #warning("TODO Check.")
  case a2dpConnection = 0x11 // GOOD

  /////////////
  case batteryLevel = 0x20

  case serialNumber = 0x22

  case deviceId = 0x23

  /// Response: 0 failure, 1 success
  case startEeg = 0x24

  // Response: 0 failure, 1 success
  case stopEeg = 0x25

  case firmewareVersion = 0x27

  case hardwareVersion = 0x28

  case mtuSize = 0x29

  case eegDataFrameEvent = 0x40

  case unknownEvent = 0xFF

  #warning("TODO since some commands are array")
//  var commandCode: [UInt8]
//  var responseOpCode: UInt8
//  init(fromResponseOpCode: UInt8)?

}
