import Foundation

enum IndusVersion {
  case indus2
  case indus3

  var binaryPrefix: String {
    switch self {
    case .indus2: return "mm-ota-"
    case .indus3: return "mm-ota-i3-"
    }
  }

  var binaryNameRegex: String {
    return #"\(binaryPrefix)(\d+_){2}\d+.bin"#
  }
}
