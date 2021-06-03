import Foundation
import CoreBluetooth

/*******************************************************************************
 * BluetoothState
 *
 * Is bluetooth powered on, off or unknown
 *
 ******************************************************************************/

public enum BluetoothState: String {

  //----------------------------------------------------------------------------
  // MARK: - Cases
  //----------------------------------------------------------------------------

  /// Bluetooth is powered on
  case poweredOn = "powered on"

  /// Bluetooth is powered off
  case poweredOff = "powered off"

  /// Bluetooth state cannot be determined.
  /// It can be caused by a missing authorization or an unsupported device.
  /// Check BluetoothAuthorization.
  case undetermined = "not determined"

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
    return self.rawValue
  }

}
