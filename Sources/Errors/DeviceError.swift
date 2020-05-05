import Foundation

/*******************************************************************************
 * DeviceError
 *
 * Represent an error about a melomind device
 *
 ******************************************************************************/
enum DeviceError: Int, MBTError {
  case infoUnavailable = 909
  case notConnected = 916
  case retrieveInfoTimeOut = 917

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// Error code used to create an NSError
  var code: Int { return rawValue }

  /// Localized description of the error
  var localizedDescription: String {
    switch self {
    case .infoUnavailable: return "Device informations are not available"
    case .notConnected: return "Device not connected"
    case .retrieveInfoTimeOut: return "Timeout while getting device informations"
    }
  }
}
