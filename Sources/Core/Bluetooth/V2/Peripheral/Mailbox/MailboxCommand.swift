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

//  case setADSConfigMelomind = 0x00 // Only melomind. Not used. For reference.

//  case setAudioconfigMelomind = 0x01 // Only melomind. Not used. For reference.

  /// Product name configuration request
  case setProductName = 0x02 // Only melomind.

  /// Used by app to request an OTA update (provides software major and minor
  ///  in payload)
  case startOTATFX = 0x03 // Good

  /// Notifies app of a lead off modification
//  case leadOffEvent = 0x04 // Only melomind. Not used. For reference.

  /// Notifies appli that we switched to OTA mode
  case otaModeEvent = 0x05 // GOOD

  /// Notifies appli that we request a packet Idx reset
  case otaIndexResetEvent = 0x06 // GOOD

  /// Notifies appli with the status of the OTA transfert.
  case otaStatusEvent = 0x07 // GOOD

  /// allows to retrieve to system global status
  case systemGetStatus = 0x08 // Good

  /// trigger a reboot event at disconnection
  case systemRebootEvent = 0x09 // 0x09, 0x29, 0x08

  /// Set the melomind serial nb
  case setSerialNumber = 0x0A

  case setA2dpName = 0x1A // Set QRCode

  /// allows to hotswap the filters' parameters
  case setNotchFilter = 0x0B // GOOD

  /// Set the signal bandwidth by changing the embedded bandpass filter
  case setBandpassFilter = 0x0C // GOOD

  /// Set the eeg signal amplifier gain
  case setAmplifierSignalGain = 0x0D // GOOD

  /// Get the current configuration of the Notch filter, the bandpass filter,
  /// and the amplifier gain.
  case getEEGConfig = 0x0E // GOOD

  /// Enable or disable the p300 functionnality of the melomind.
  case toggleP300 = 0x0F // GOOD

  case enableDCOffset = 0x10 // GOOD

  #warning("TODO Check.")
  case a2dpConnection = 0x11 // GOOD

  /////////////
  case batteryLevel = 0x20 // GOOD

  case serialNumber = 0x22 // GOOD

  case deviceId = 0x23 // GOOD

  /// Response: 0 failure, 1 success
  case startEeg = 0x24 // GOOD

  // Response: 0 failure, 1 success
  case stopEeg = 0x25 // GOOD

  case reset = 0x26 // GOOD

  case firmewareVersion = 0x27 // GOOD

  case hardwareVersion = 0x28 // GOOD

  case mtuSize = 0x29 // GOOD

  case getFilterConfigurationType = 0x30 // GOOD

  case setFilterConfigurationType = 0x31 // GOOD

  case setAudioconfig = 0x32 // GOOD

  case startImsAcquisition = 0x33 // GOOD

  case stopImsAcquisition = 0x34 // GOOD

  case startPpgAcquisition = 0x35 // GOOD

  case stopPpgAcquisition = 0x36 // GOOD

  case startTemperatureAcquisition = 0x37 // Good

  case stopTemperatureAcquisition = 0x38 // Good

  case setImsConfiguration = 0x39 // Good

  case getSensorStatus = 0x41 // Good

  case setPpgConfiguration = 0x42 // Good

  case imsDataFrameEvent = 0x50 // Good

  case ppgDataFrameEvent = 0x60 // Good

  case eegDataFrameEvent = 0x40 // Good

  case unknownEvent = 0xFF

  #warning("TODO since some commands are array")
//  var commandCode: [UInt8]
//  var responseOpCode: UInt8
//  init(fromResponseOpCode: UInt8)?

}
