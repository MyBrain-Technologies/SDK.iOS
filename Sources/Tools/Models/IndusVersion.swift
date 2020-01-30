import Foundation

enum IndusVersion: CaseIterable {
  case indus2
  case indus3

  var binaryPrefix: String {
    switch self {
    case .indus2: return "mm-ota-"
    case .indus3: return "mm-ota-i3-"
    }
  }

  var binaryNameRegex: String {
    return "\(binaryPrefix)\(Constants.binaryVersionRegex)"
  }

  var hardwareVersion: String {
    switch self {
    case .indus2: return "1.0.0"
    case .indus3: return "1.1.0"
    }
  }

  init?(fromHardwareVersion hwVersion: String) {
    let version = IndusVersion.allCases.first() {
      $0.hardwareVersion == hwVersion
    }
    guard let indusVersion = version else { return nil }
    self = indusVersion
  }
}
