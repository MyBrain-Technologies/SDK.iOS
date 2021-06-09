import Foundation

public enum IndusVersion: String, CaseIterable, Codable {

  //----------------------------------------------------------------------------
  // MARK: - Cases
  //----------------------------------------------------------------------------

  case indus2 = "indus2"
  case indus3 = "indus3"
  case indus5 = "indus5"

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  var binaryPrefix: String {
    switch self {
      case .indus2: return "mm-ota-"
      case .indus3: return "mm-ota-i3-"
      case .indus5:
        #warning("TODO CHECK IT")
        return "mm-ota-i5-"
    }
  }

  var binaryNameRegex: String {
    return "\(binaryPrefix)\(Constants.binaryVersionRegex)"
  }

  var hardwareVersion: String {
    switch self {
      case .indus2: return "1.0.0"
      case .indus3: return "1.1.0"
      case .indus5: return "2.1.0"
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init?(fromHardwareVersion hwVersion: String) {
    let version = IndusVersion.allCases.first() {
      $0.hardwareVersion == hwVersion
    }
    guard let indusVersion = version else { return nil }
    self = indusVersion
  }

}
