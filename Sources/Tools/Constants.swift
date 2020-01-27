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
}
