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

  #warning("TODO: Nullable init?")
  init(string: String) {
    let characterSet = CharacterSet(charactersIn: Constants.versionSeparators)
    let components = string.components(separatedBy: characterSet)

    guard components.count >= 3 else {
      self.major = 0
      self.minor = 0
      self.fix = 0
      return
    }

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
    let values = [(lhs: lhs.major, rhs: rhs.major),
                  (lhs: lhs.minor, rhs: rhs.minor),
                  (lhs: lhs.fix, rhs: rhs.fix)]
    let hasLowerValue = values.first() { $0.lhs < $0.rhs } != nil
    return hasLowerValue
  }

  //----------------------------------------------------------------------------
  // MARK: - Equatable
  //----------------------------------------------------------------------------

  static func == (lhs: FormatedVersion, rhs: FormatedVersion) -> Bool {
    let values = [(lhs: lhs.major, rhs: rhs.major),
                  (lhs: lhs.minor, rhs: rhs.minor),
                  (lhs: lhs.fix, rhs: rhs.fix)]

    let hasNoDifference = values.first() { $0.lhs != $0.rhs } == nil
    return hasNoDifference
  }

}
