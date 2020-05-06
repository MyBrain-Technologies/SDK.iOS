//
//  MBTRecordInfo.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by facileit on 06/03/2018.
//  Copyright © 2018 MyBrainTechnologies. All rights reserved.
//

import Foundation
import SwiftyJSON

//MARK:- MBTRecordInfo

/// *MBTRecordInfo* Informations saved On JSON File
public class MBTRecordInfo {

  //MARK: Variable

  /// Id Record
  public var recordId:UUID

  /// Recording Type
  public var recordingType:MBTRecordingType

  //MARK: Init Methods

  /// Create a Default *MBTRecordInfo*
  /// recordId -> Random UUID
  /// recordingType -> Default *MBTRecordingType*
  public init() {
    recordId = UUID()
    recordingType = MBTRecordingType()
  }

  /// Create a *MBTRecordInfo* with provided Record Id
  public init(_ recordId:UUID) {
    self.recordId = recordId
    recordingType = MBTRecordingType()
  }

  /// Create a *MBTRecordInfo* with provided Record Id and RecordingType
  public init(_ recordId:UUID, recordingType:MBTRecordingType) {
    self.recordId = recordId
    self.recordingType = recordingType
  }
}

//MARK:- MBTRecordingType

public class MBTRecordingType {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// Record Type cf enum *MBTRecordType*
  public var recordType:MBTRecordType

  /// Signal Processing Version
  internal var spVersion:String = ""
  /// Data Source cf enum *MBTDataSource*
  public var source:MBTDataSource

  /// Data type cf enum *MBTDataType*
  public var dataType:MBTDataType

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  /// Create a *MBTRecordingType* with default values
  public init() {
    recordType = .RAWDATA
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

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /// get a JSON
  ///
  /// - Returns: A *JSON* instance of RecordingType
  internal func getJsonRecordInfo() -> JSON {
    var jsonRecordType = JSON()
    jsonRecordType["recordType"].stringValue = recordType.rawValue
    jsonRecordType["spVersion"].stringValue = spVersion
    jsonRecordType["source"].stringValue = source.rawValue
    jsonRecordType["dataType"].stringValue = dataType.rawValue
    return jsonRecordType
  }
}

/// enum of Data Source
public enum MBTDataSource: String {
  case FREESESSION = "FREESESSION"
  case RELAXPROGRAM = "RELAX_PROGRAM"
  case DEFAULT = "DEFAULT"
}

/// enum of DataType
public enum MBTDataType: String {
  case DEFAULT
  case JOURNEY
  case SWITCH
  case STABILITY
}

///enum of Record Type
public enum MBTRecordType: String {
  case ADJUSTMENT
  case CALIBRATION
  case SESSION
  case RAWDATA
  case STUDY
}
