import Foundation

/*******************************************************************************
 * BluetoothError
 *
 * Represent an error about the bluetooth connection
 *
 ******************************************************************************/
enum BluetoothError: Int, MBTError {
  case connectionLost = 911
  case poweredOff = 919
  case pairingDenied = 921

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// Error code used to create an NSError
  var code: Int { return rawValue }

  /// Localized description of the error
  var localizedDescription: String {
    switch self {
    case .connectionLost: return "Bluetooth connection have been lost"
    case .poweredOff: return "Bluetooth is powered off"
    case .pairingDenied:
      return "Bluetooth pairing demand have been denied"
    }
  }
}
