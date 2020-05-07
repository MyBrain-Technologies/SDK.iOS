import Foundation

struct FormatedVersion: Comparable, Equatable, CustomStringConvertible {
  let major: Int
  let minor: Int
  let fix: Int

  var versionValue: Int {
    return major * 10000 + minor * 100 + fix
  }

  var description: String {
    return "\(major).\(minor).\(fix)"
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(string: String) {
    let characterSet = CharacterSet(charactersIn: Constants.versionSeparators)
    let components = string.components(separatedBy: characterSet)

    self.major = Int(components[0]) ?? 0
    self.minor = Int(components[1]) ?? 0
    self.fix = Int(components[2]) ?? 0
  }

  init(major: Int, minor: Int, fix: Int) {
    self.major = major
    self.minor = minor
    self.fix = fix
  }

  //----------------------------------------------------------------------------
  // MARK: - Comparable
  //----------------------------------------------------------------------------

  static func < (lhs: FormatedVersion, rhs: FormatedVersion) -> Bool {
    return lhs.versionValue < rhs.versionValue
  }

  //----------------------------------------------------------------------------
  // MARK: - Equatable
  //----------------------------------------------------------------------------

  static func == (lhs: FormatedVersion, rhs: FormatedVersion) -> Bool {
    return lhs.versionValue == rhs.versionValue
  }

}
