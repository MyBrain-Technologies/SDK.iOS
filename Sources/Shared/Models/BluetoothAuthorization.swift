import Foundation
import CoreBluetooth

/*******************************************************************************
 * Bluetooth Authorization
 *
 * The current authorization state of the bluetooth for the app using the SDK.
 *
 ******************************************************************************/

public enum BluetoothAuthorization: String {

  //----------------------------------------------------------------------------
  // MARK: - Cases
  //----------------------------------------------------------------------------

  /// App is authorized to use the device bluetooth
  case authorized = "authorized"

  /// App is not authorized to use the device bluetooth.
  case unauthorized = "unauthorized"

  /// App is not yet authorized or unauthorized to use the bluetooth. User will
  ///  be ask to choose.
  case undetermined = "undetermined"

  /// Current device doesn't support the bluetooth.
  case unsupported = "unsupported"

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  @available(iOS 13.0, *)
  init(authorization: CBManagerAuthorization, state: CBManagerState) {
    switch authorization {
    case .notDetermined: self = .undetermined
    case .restricted: self = .unauthorized
    case .denied: self = .unauthorized
    case .allowedAlways: self = .authorized
    @unknown default: self = .undetermined
    }

    if state == .unsupported {
      self = .unsupported
    }
  }

  init(state: CBManagerState) {
    switch state {
    case .unknown: self = .undetermined
    case .unsupported: self = .unsupported
    case .unauthorized: self = .unauthorized
    default: self = .authorized
    }
  }

}

//==============================================================================
// MARK: - Custom String Convertible
//==============================================================================

extension BluetoothAuthorization: CustomStringConvertible {

  public var description: String {
    return self.rawValue
  }

}
