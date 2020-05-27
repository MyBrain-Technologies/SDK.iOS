import Foundation

/*******************************************************************************
 * OADStateType
 *
 * State of an Over Air Download transfer
 *
 ******************************************************************************/
public enum OADStateType: Int, Equatable, Comparable {

  /// The process has not started
  case disable = -1
  /// The process has started
  case started = 0
  /// The Melomind is ready to receive the binary
  case ready = 1
  /// The SDK is sending the binary
  case inProgress = 2
  /// The Melomind has received all the binary
  case completed = 3
  /// The SDK needs that the bluetooth device reboot
  case rebootRequired = 4
  /// The SDK try to reconnect the Melomind
  case connected = 5
}

//==============================================================================
// MARK: - CustomStringConvertible
//==============================================================================

extension OADStateType: CustomStringConvertible {

  public var description: String {
    switch self {
    case .disable: return "OAD disable"
    case .started: return "Start to process OAD"
    case .ready: return "Melomind is ready to transfert OAD"
    case .inProgress: return "OAD is in progress"
    case .completed: return "OAD is complete"
    case .rebootRequired: return "need to reboot bluetooth Device"
    case .connected: return "try to reconnect the Melomind"
    }
  }
}

//==============================================================================
// MARK: - Comparable
//==============================================================================

public func < (f: OADStateType, s: OADStateType) -> Bool {
  return f.rawValue < s.rawValue
}

//==============================================================================
// MARK: - Equatable
//==============================================================================

public func == (f: OADStateType, s: OADStateType) -> Bool {
  return f.rawValue == s.rawValue
}
