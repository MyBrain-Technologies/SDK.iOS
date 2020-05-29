import Foundation

/*******************************************************************************
 * BluetoothLowEnergyError
 *
 * Represent an error about the bluetooth low energy connection
 *
 ******************************************************************************/
enum BluetoothLowEnergyError: Int, MBTError {
  case connectionTimeOut = 918
  case poweredOff = 920

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// Error code used to create an NSError
  var code: Int { return rawValue }

  /// Localized description of the error
  var localizedDescription: String {
    switch self {
    case .connectionTimeOut:
      return "Timeout while connecting bluetooth low energy"
    case .poweredOff:
      return "Bluetooth low energy is powered off"
    }
  }
}
