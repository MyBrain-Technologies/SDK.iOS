import Foundation

/*******************************************************************************
 * OADError
 *
 * Represent an error about the Over Air Download proccess
 *
 ******************************************************************************/
enum OADError: Int, MBTError {
  case reconnectionAfterTransferFailed = 908
  case transferTimeOut = 912
  case transferPreparationFailed = 913
  case transferInterrupted = 914
  case badBDAddr = 925

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// Error code used to create an NSError
  var code: Int { return rawValue }

  /// Localized description of the error
  var localizedDescription: String {
    switch self {
    case .reconnectionAfterTransferFailed:
      return "Impossible to reconnect to headset after updating the headset"
    case .transferTimeOut: return "Timeout while transfering data to headset"
    case .transferPreparationFailed:
      return "Prepare data transfer to headset failed"
    case .transferInterrupted: return "Transfer cannot be completed."
    case .badBDAddr: return "Bad BDADDR"
    }
  }
}
