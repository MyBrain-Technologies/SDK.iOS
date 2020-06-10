import Foundation

/*******************************************************************************
 * MBTRecordInfo
 *
 * *MBTRecordInfo* Informations saved On JSON File
 *
 ******************************************************************************/
public class MBTRecordInfo {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// Id Record
  public var recordId: UUID

  /// Recording Type
  public var recordingType: MBTRecordingType

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  /// Create a *MBTRecordInfo* with provided Record Id
  public init(_ recordId: UUID? = nil, recordingType: MBTRecordingType? = nil) {
    self.recordId = recordId ?? UUID()
    self.recordingType = recordingType ?? MBTRecordingType()
  }
}
