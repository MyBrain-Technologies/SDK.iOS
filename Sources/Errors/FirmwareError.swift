import Foundation

/*******************************************************************************
 * FirmwareError
 *
 * Represent an error about the devices firmware
 *
 ******************************************************************************/
enum FirmwareError: Int, MBTError {
  case alreadyUpToDate = 910
  case versionInvalidAfterUpdate = 915

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// Error code used to create an NSError
  var code: Int { return rawValue }

  /// Localized description of the error
  var localizedDescription: String {
    switch self {
    case .alreadyUpToDate:
      return "Latest firmware version already installed"
    case .versionInvalidAfterUpdate:
      return "Headset firmware version is not the one expected after update"
    }
  }
}
