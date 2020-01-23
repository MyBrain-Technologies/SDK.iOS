import Foundation

struct Constants {

  /// Regex to use to find a version number, as 1.2.3 or 1-2-3 or 1_2_3
  static let versionRegex = #"(\d+[_.-]){2}\d+(\.bin)?$"#

  static let versionSeparators = "_.-"

  /// Extension used for binary files
  static let binaryExtension = ".bin"

  /// Default value for productName on headset informations
  static let defaultProductName = "melomind"
}
