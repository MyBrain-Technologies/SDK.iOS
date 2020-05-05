import Foundation

/*******************************************************************************
 * AudioError
 *
 * Represent an error about the audio connection
 *
 ******************************************************************************/
enum AudioError: Int, MBTError {
  case audioUnpaired = 922
  case audioAldreadyConnected = 923
  case audioConnectionTimeOut = 924

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// Error code used to create an NSError
  var code: Int { return rawValue }

  /// Localized description of the error
  var localizedDescription: String {
    switch self {
    case .audioUnpaired: return "Audio is not paired to the device"
    case .audioAldreadyConnected:
      return "Audio is already connected to another device"

      case .audioConnectionTimeOut: return "Timeout while connecting audio"
    }
  }
}
