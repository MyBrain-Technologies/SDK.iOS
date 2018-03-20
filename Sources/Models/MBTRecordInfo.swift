//
//  MBTRecordInfo.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by facileit on 06/03/2018.
//  Copyright © 2018 MyBrainTechnologies. All rights reserved.
//

import Foundation

/// *MBTRecordInfo* Informations saved On JSON File
public class MBTRecordInfo {
    
    /// Id Record
    public var recordId:UUID
    
    /// Recording Type
    public var recordingType:MBTRecordingType
    
    
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


public class MBTRecordingType {
    
    /// Record Type cf enum *MBTRecordType*
    public var recordType:MBTRecordType
    
    /// Signal Processing Version
    public var spVersion:String
    
    /// Data Source cf enum *MBTDataSource*
    public var source:MBTDataSource
    
    /// Data type cf enum *MBTDataType*
    public var dataType:MBTDataType
    
    /// Create a *MBTRecordingType* with
    /// - recordType = .RAWDATA
    /// - spVersion = ""
    /// - source = .DEFAULT
    /// - dataType = .DEFAULT
    public init() {
        recordType = .RAWDATA
        spVersion = ""
        source = .DEFAULT
        dataType = .DEFAULT
    }
    
    /// Create a *MBTRecordingType* with provided RecordType, spVersion, Source, dataType
    public init(_ recordType:MBTRecordType, spVersion:String, source:MBTDataSource, dataType:MBTDataType) {
        self.recordType = recordType
        self.spVersion = spVersion
        self.source = source
        self.dataType = dataType
    }
    
    /// get a JSON
    ///
    /// - Returns: A *JSON* instance of RecordingType
    func getJsonRecordInfo() -> JSON {
        var jsonRecordType = JSON()
        jsonRecordType["recordType"].stringValue    = recordType.rawValue
        jsonRecordType["spVersion"].stringValue     = spVersion
        jsonRecordType["source"].stringValue        = source.rawValue
        jsonRecordType["dataType"].stringValue      = dataType.rawValue
        return jsonRecordType
    }
    
}


/// enum of Data Source
public enum MBTDataSource : String {
    case FREESESSION    = "FREESESSION"
    case RELAX_PROGRAM  = "RELAX_PROGRAM"
    case DEFAULT        = "DEFAULT"
}

/// enum of DataType
public enum MBTDataType : String {
    case DEFAULT    = "DEFAULT"
    case JOURNEY    = "JOURNEY"
    case SWITCH     = "SWITCH"
    case STABILITY  = "STABILITY"
}

///enum of Record Type
public enum MBTRecordType : String {
    case ADJUSTMENT     = "ADJUSTMENT"
    case CALIBRATION    = "CALIBRATION"
    case SESSION        = "SESSION"
    case RAWDATA        = "RAWDATA"
    case STUDY          = "STUDY"
}
