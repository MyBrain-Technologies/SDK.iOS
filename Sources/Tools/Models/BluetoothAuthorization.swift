import Foundation
import CoreBluetooth

/*******************************************************************************
 * Bluetooth Authorization
 *
 * The current authorization state of the bluetooth for the app using the SDK.
 *
 ******************************************************************************/
public enum BluetoothAuthorization {
  /// App is authorized to use the device bluetooth
  case authorized
  /// App is not authorized to use the device bluetooth.
  case unauthorized
  /// App is not yet authorized or unauthorized to use the bluetooth. User will be ask to choose.
  case undetermined
  /// Current device doesn't support the bluetooth.
  case unsupported

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

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  public var stateDescription: String {
    switch self {
    case .authorized:
      return "Bluetooth access is authorized and can be used at any time"
    case .unauthorized: return """
      Bluetooth access is not authorized.
      Manual authorization from settings is required.
      """
    case .undetermined: return """
      Bluetooth acces has not be determined yet. It will be asked to the user.
      """
    case .unsupported:
      return "The current device does not support bleutooth"
    }
  }
}
