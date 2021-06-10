import Foundation

public enum MBTRecordType: String, Codable {

  case adjustement = "ADJUSTMENT"

  case calibration = "CALIBRATION"

  case session = "SESSION"

  case rawdata = "RAWDATA"

  case study = "STUDY"

  case restingStatePreSessionEyesClosed = "RESTING_STATE_PRE_SESSION_EYES_CLOSED"

  case restingStatePreSessionEyesOpen = "RESTING_STATE_PRE_SESSION_EYES_OPEN"

  case restingStatePostSessionEyesClosed = "RESTING_STATE_POST_SESSION_EYES_CLOSED"

  case restingStatePostSessionEyesOpen = "RESTING_STATE_POST_SESSION_EYES_OPEN"

}
