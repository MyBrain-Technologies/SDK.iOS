import Foundation
import SwiftyJSON

/*******************************************************************************
 * MBTRecordingType
 *
 * ?
 *
 ******************************************************************************/
public class MBTRecordingType {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// Record Type cf enum *MBTRecordType*
  public var recordType: MBTRecordType

  /// Signal Processing Version
  internal var spVersion: String = ""
  /// Data Source cf enum *MBTDataSource*
  public var source: MBTDataSource

  /// Data type cf enum *MBTDataType*
  public var dataType: MBTDataType

  /********************  Computed properties ********************/

  var eegRecordType: EEGRecordType {
    return EEGRecordType(recordType: recordType,
                         source: source,
                         dataType: dataType,
                         spVersion: spVersion)
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  #warning("TODO: remove this init and use default value for second init")
  /// Create a *MBTRecordingType* with default values
  public init() {
    recordType = .rawdata
    source = .DEFAULT
    dataType = .DEFAULT
    spVersion = MBTQualityCheckerBridge.getVersion()
  }

  /// Create a *MBTRecordingType* with provided RecordType, spVersion, Source, dataType
  public init(_ recordType: MBTRecordType,
              source: MBTDataSource,
              dataType: MBTDataType) {
    self.recordType = recordType
    self.source = source
    self.dataType = dataType
    self.spVersion = MBTQualityCheckerBridge.getVersion()
  }
}

/// enum of Data Source
public enum MBTDataSource: String, Codable {
  case FREESESSION = "FREESESSION"
  case RELAXPROGRAM = "RELAX_PROGRAM"
  case DEFAULT = "DEFAULT"
}

/// enum of DataType
public enum MBTDataType: String, Codable {
  case DEFAULT
  case JOURNEY
  case SWITCH
  case STABILITY
}

///enum of Record Type
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
