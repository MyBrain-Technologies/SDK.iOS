import Foundation

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

  #warning("TODO: Use directly EEGRecordType. MBTRecordingType is useless.")
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

  /// Create a *MBTRecordingType* with provided RecordType, spVersion, Source,
  /// dataType
  public init(_ recordType: MBTRecordType,
              source: MBTDataSource,
              dataType: MBTDataType) {
    self.recordType = recordType
    self.source = source
    self.dataType = dataType
    self.spVersion = MBTQualityCheckerBridge.getVersion()
  }
}
