import Foundation

public struct FormatedVersion  {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Semantic versioning ********************/

  public let major: Int
  public let minor: Int
  public let fix: Int

  public var versionValue: Int {
    return major * 10000 + minor * 100 + fix
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  #warning("TODO: Nullable init?")
  public init(string: String) {
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

  public init(major: Int, minor: Int, fix: Int) {
    self.major = major
    self.minor = minor
    self.fix = fix
  }

}

//==============================================================================
// MARK: - Comparable
//==============================================================================

extension FormatedVersion: Comparable {

  public static func < (lhs: FormatedVersion, rhs: FormatedVersion) -> Bool {
    let values = [(lhs: lhs.major, rhs: rhs.major),
                  (lhs: lhs.minor, rhs: rhs.minor),
                  (lhs: lhs.fix, rhs: rhs.fix)]
    let hasLowerValue = values.first() { $0.lhs < $0.rhs } != nil
    return hasLowerValue
  }

}

//==============================================================================
// MARK: - Equatable
//==============================================================================

extension FormatedVersion: Equatable {

  public static func == (lhs: FormatedVersion, rhs: FormatedVersion) -> Bool {
    let values = [(lhs: lhs.major, rhs: rhs.major),
                  (lhs: lhs.minor, rhs: rhs.minor),
                  (lhs: lhs.fix, rhs: rhs.fix)]

    let hasNoDifference = values.first() { $0.lhs != $0.rhs } == nil
    return hasNoDifference
  }

}

//==============================================================================
// MARK: - CustomStringConvertible
//==============================================================================

extension FormatedVersion: CustomStringConvertible {

  public var description: String {
    return "\(major).\(minor).\(fix)"
  }

}
