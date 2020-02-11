import Foundation

/// State of the OAD
public enum OADStateType:Int {
  /// The process has not started
  case DISABLE = -1
  /// The process has started
  case START_OAD = 0
  /// The Melomind is ready to receive the binary
  case READY = 1
  /// The SDK is sending the binary
  case IN_PROGRESS = 2
  /// The Melomind has received all the binary
  case OAD_COMPLETE = 3
  /// The SDK needs that the bluetooth device reboot
  case REBOOT_BLUETOOTH = 4
  /// The SDK try to reconnect the Melomind
  case CONNECT = 5


  /// Decription Error
  var description:String {
    switch self {
    case .DISABLE :
      return "OAD disable"
    case .START_OAD :
      return "Start to process OAD"
    case .READY :
      return "Melomind is ready to transfert OAD"
    case .IN_PROGRESS :
      return "OAD is in progress"
    case .OAD_COMPLETE :
      return "OAD is complete"
    case .REBOOT_BLUETOOTH :
      return "need to reboot bluetooth Device"
    case .CONNECT :
      return "try to reconnect the Melomind"
    }
  }
}

func >(f:OADStateType,s:OADStateType) -> Bool {
  return f.rawValue > s.rawValue
}

func <(f:OADStateType,s:OADStateType) -> Bool {
  return f.rawValue < s.rawValue
}

func >=(f:OADStateType,s:OADStateType) -> Bool {
  return f.rawValue > s.rawValue || f.rawValue == s.rawValue
}

func <=(f:OADStateType,s:OADStateType) -> Bool {
  return f.rawValue < s.rawValue || f.rawValue == s.rawValue
}
