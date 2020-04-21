import Foundation

struct FirmwareVersion: Comparable, Equatable {
  let major: Int
  let minor: Int
  let fix: Int

  var versionValue: Int {
    return major * 10000 + minor * 100 + fix
  }

  init(string: String) {
    let characterSet = CharacterSet(charactersIn: Constants.versionSeparators)
    let components = string.components(separatedBy: characterSet)

    self.major = Int(components[0]) ?? 0
    self.minor = Int(components[1]) ?? 0
    self.fix = Int(components[2]) ?? 0
  }

  static func < (lhs: FirmwareVersion, rhs: FirmwareVersion) -> Bool {
    return lhs.versionValue < rhs.versionValue
  }

  static func == (lhs: FirmwareVersion, rhs: FirmwareVersion) -> Bool {
    return lhs.versionValue == rhs.versionValue
  }

}
