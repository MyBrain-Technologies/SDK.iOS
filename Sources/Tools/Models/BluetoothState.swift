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

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  public var stateDescription: String {
    switch self {
    case .poweredOn:
      return "Bluetooth is powered on"
    case .poweredOff:
      return "Bluetooth is powered off"
    case .undetermined:
      return """
      Bluetooth powered state cannot be determined. Maybe BT authorization is not given.
      """
    }
  }
}
