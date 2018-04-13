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
    
    /// Parameters received to start a session.
    static var sessionParameters:[String: Any]!
    
    /// JSON UUID (for BrainWeb) and also JSON file's name.
    static var uuid: UUID!
    
    /// File URL of the saved JSON.
    static var fileURL: URL?
    
    /// Save the JSON on the iDevice.
    static func saveJSONOnDevice(_ json: JSON, idUser:Int? = nil, with completion: ()->()) -> URL? {
        let fileManager = FileManager.default
//        guard let json = getDataJSON(jsonObject) else {
//            return nil
//        }
        
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
            
            let fileName:String = MBTJSONHelper.getFileName(idUser)
            let fileURL = eegPacketJSONRecordingsPath.appendingPathComponent(fileName)
            
            // Saving JSON in device.
            try json.rawString([.castNilToNSNull:true])?.write(to: fileURL, atomically: true, encoding: .utf8)
            MBTJSONHelper.fileURL = fileURL
            print("json saved here : \(fileURL)")
            
            completion()
            return fileURL
        } catch {
            debugPrint("[MyBrainTechnologiesSDK] Error while saving JSON on device : \(error)")
        }
        
        return nil
    }
    
    /// Get File Name for a Record
    
    static func getFileName(_ idUser:Int? = nil) -> String {
        let date = Date()
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd--HH:mm:ss"
        let projectName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let deviceID =  "melo_" + (DeviceManager.getCurrentDevice()?.deviceInfos?.deviceId)!
        let stringIdUser = idUser != nil ? "\(idUser!)" : ""
        return "eegPacketsRecording_" + dateFormater.string(from: date) + "_" + projectName + "_" + deviceID + "_" + stringIdUser + ".json"
    }
    
    /// Remove the JSON saved on the iDevice.
    static func deleteJSONFromDevice() {
        if MBTJSONHelper.doesJSONExist() {
            let fileManager = FileManager.default
            
            do {
                try fileManager.removeItem(at: MBTJSONHelper.fileURL!)
            } catch {
                debugPrint("[MyBrainTechnologiesSDK] Error while deleting previous JSON : \(error)")
            }
        }
    }
    
    /// Getter for the session JSON.
    static func getSessionData() -> Data? {
        if MBTJSONHelper.doesJSONExist() {
            let fileManager = FileManager.default
            
            return fileManager.contents(atPath: MBTJSONHelper.fileURL!.path)
        }
        
        return nil
    }
    
    /// Check if a file URL has been saved,
    /// and if the json still exists.
    static func doesJSONExist() -> Bool {
        guard let fileURL = MBTJSONHelper.fileURL else {
            debugPrint("[MyBrainTechnologiesSDK] Error no JSON exists. Try to startStream() / stopStream() first.")
            
            return false
        }
        
        let fileManager = FileManager.default
        return  fileManager.fileExists(atPath: fileURL.path)
    }
}
