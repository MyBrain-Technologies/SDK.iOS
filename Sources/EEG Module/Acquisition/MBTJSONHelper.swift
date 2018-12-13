//
//  MBTJSONHelper.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 31/07/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation

/// Helper to create and manage a JSON file (kwak format)
/// with the session data.
struct MBTJSONHelper {
    
    /// Save the JSON on the iDevice.
    static func saveJSONOnDevice(_ json: JSON,idDevice:String ,idUser:Int, with completion: ()->()) -> URL? {
        let fileManager = FileManager.default
        
        do {
            // Getting the url to save the json.
            let documentDirectory = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor:nil,
                create:false
            )
            
            let eegPacketJSONRecordingsPath = documentDirectory.appendingPathComponent("eegPacketJSONRecordings")
            
            if !fileManager.fileExists(atPath: eegPacketJSONRecordingsPath.path) {
                try fileManager.createDirectory(at: eegPacketJSONRecordingsPath, withIntermediateDirectories: true, attributes: nil)
            }
            
            let fileName:String = MBTJSONHelper.getFileName(idUser,withIdDevice: idDevice)
            let fileURL = eegPacketJSONRecordingsPath.appendingPathComponent(fileName)
            
            // Saving JSON in device.
            try json.rawString([.castNilToNSNull:true])?.write(to: fileURL, atomically: true, encoding: .utf8)
//            MBTJSONHelper.fileURL = fileURL
            prettyPrint(log.ln("saveJSONOnDevice - json saved here : \(fileURL)"))
            
            completion()
            return fileURL
        } catch {
            prettyPrint(log.ln("saveJSONOnDevice - Error while saving JSON on device :"))
            prettyPrint(log.error(error as Error as NSError))
        }
        
        return nil
    }
    
    /// Get File Name for a Record
    
    static func getFileName(_ idUser:Int, withIdDevice idDevice:String) -> String {
        let date = Date()
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd--HH:mm:ss"
        let projectName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let deviceID =  "melo_" + idDevice
        let stringIdUser = "\(idUser)"
        return "eegPacketsRecording_" + dateFormater.string(from: date) + "_" + projectName + "_" + deviceID + "_" + stringIdUser + ".json"
    }
    
    static func removeFile(_ urlFile:URL) -> Bool {
        
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(atPath: urlFile.path)
        } catch {
            prettyPrint(log.ln("getFileName - Can't remove File : \(urlFile.path)"))
            prettyPrint(log.error(error as NSError))
            return false
        }
        
        return true
    }
}
