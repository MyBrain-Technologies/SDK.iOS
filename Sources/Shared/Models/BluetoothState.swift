import Foundation
import CoreBluetooth

/*******************************************************************************
 * BluetoothState
 *
 * Is bluetooth powered on, off or unknown
 *
 ******************************************************************************/
public enum BluetoothState {
  /// Bluetooth is powered on
  case poweredOn
  /// Bluetooth is powered off
  case poweredOff
  /// Bluetooth state cannot be determined.
  /// It can be caused by a missing authorization or an unsupported device. Check BluetoothAuthorization.
  case undetermined

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(state: CBManagerState) {
    switch state {
    case .poweredOff: self = .poweredOff
    case .poweredOn: self = .poweredOn
    default: self = .undetermined
    }
  }
}

//==============================================================================
// MARK: - Custom String Convertible
//==============================================================================

extension BluetoothState: CustomStringConvertible {
  public var description: String {
    switch self {
    case .poweredOff: return "powered off"
    case .poweredOn: return "powered on"
    case .undetermined: return "not determined"
    }
  }
}
