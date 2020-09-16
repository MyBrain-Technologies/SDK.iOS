import Foundation

struct Constants {

  /// Regex to use to find a version number, as 1.2.3 or 1-2-3 or 1_2_3
  static let versionRegex = #"(\d+[_.-]){2}\d+"#

  static let versionSeparators = "_.-"

  /// Extension used for binary files
  static let binaryExtension = ".bin"

  /// Regex to use to find a binary filename
  static let binaryVersionRegex =
  "\(Constants.versionRegex)(\(Constants.binaryExtension))?$"

  /// Default value for productName on headset informations
  static let defaultProductName = "melomind"

  static let bundleName = "com.MyBrainTech.MyBrainTechnologiesSDK"

  //----------------------------------------------------------------------------
  // MARK: - Timeouts
  //----------------------------------------------------------------------------

  struct Timeout {
    static let connection = 20.0
    static let oadTransfer = 600.0
    static let batteryLevel = 120.0
    static let a2dpConnection = 10.0
    static let finalizeConnection = 2.0
    static let sendExternalName = 10.0
  }

  //----------------------------------------------------------------------------
  // MARK: - Prefix
  //----------------------------------------------------------------------------

  struct DeviceName {
    static let a2dpPrefixLegacy = "melo_"
    static let a2dpPrefix = "audio_"
    static let blePrefix = "melo_"

    static let qrCodePrefix = "MM10"
    static let qrCodeLength = 10

    static let qrCodePrefixBatch2 = "MM1B2"
    static let qrCodeBatch2Length = 10
    static let qrCodeBatch2EndCharacter = "."

    static let qrCodePrefixBatch3 = "MM1B3"
    static let qrCodeBatch3Length = 10
  }

  //----------------------------------------------------------------------------
  // MARK: - Record
  //----------------------------------------------------------------------------

  struct EEGPackets {
    static let historySize = 1
    static let recordDirectory = "eegPacketJSONRecordings"
    static let recordFilename = "eegPacketsRecording"
  }
}
