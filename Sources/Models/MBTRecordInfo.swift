//
//  MBTRecordInfo.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by facileit on 06/03/2018.
//  Copyright © 2018 MyBrainTechnologies. All rights reserved.
//

import Foundation

public class MBTRecordInfo {
    public var recordId:UUID
    public var recordingType:MBTRecordingType
    
    public init() {
        recordId = UUID()
        recordingType = MBTRecordingType()
    }
    
    public init(_ recordId:UUID) {
        self.recordId = recordId
        recordingType = MBTRecordingType()
    }
    
    public init(_ recordId:UUID, recordingType:MBTRecordingType) {
        self.recordId = recordId
        self.recordingType = recordingType
    }
}


public class MBTRecordingType {
    
    public var recordType:MBTRecordType
    public var spVersion:String
    public var source:MBTDataSource
    public var dataType:MBTDataType
    
    public init() {
        recordType = .RAWDATA
        spVersion = ""
        source = .DEFAULT
        dataType = .DEFAULT
    }
    
    public init(_ recordType:MBTRecordType, spVersion:String, source:MBTDataSource, dataType:MBTDataType) {
        self.recordType = recordType
        self.spVersion = spVersion
        self.source = source
        self.dataType = dataType
    }
    
    func getJsonRecordInfo() -> JSON {
        var jsonRecordType = JSON()
        jsonRecordType["recordType"].stringValue    = recordType.rawValue
        jsonRecordType["spVersion"].stringValue     = spVersion
        jsonRecordType["source"].stringValue        = source.rawValue
        jsonRecordType["dataType"].stringValue      = dataType.rawValue
        return jsonRecordType
    }
    
}


public enum MBTDataSource : String {
    case FREESESSION    = "FREESESSION"
    case RELAX_PROGRAM  = "RELAX_PROGRAM"
    case DEFAULT        = "DEFAULT"
}

public enum MBTDataType : String {
    case DEFAULT    = "DEFAULT"
    case JOURNEY    = "JOURNEY"
    case SWITCH     = "SWITCH"
    case STABILITY  = "STABILITY"
}


public enum MBTRecordType : String {
    case ADJUSTMENT     = "ADJUSTMENT"
    case CALIBRATION    = "CALIBRATION"
    case SESSION        = "SESSION"
    case RAWDATA        = "RAWDATA"
    case STUDY          = "STUDY"
}
