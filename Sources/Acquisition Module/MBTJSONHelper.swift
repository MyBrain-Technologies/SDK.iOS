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
    
    /// Func to create & save the JSON.
    static func saveJSON(_ jsonObject: [String: Any], with completion: (_ fileURL: URL)->())  {
        // Transform the array in JSON,
        // and save it on the iDevice.        
        do {
            let json = try JSONSerialization.data(
                withJSONObject: jsonObject,
                options: .prettyPrinted
            )
            
            MBTJSONHelper.saveJSONOnDevice(json, with: completion)
        } catch {
            debugPrint("[MyBrainTechnologiesSDK] Error while serialize JSON : \(error)")
        }
    }
    
    
    /// Save the JSON on the iDevice.
    static func saveJSONOnDevice(_ json:Data, with completion: (_ fileURL: URL)->()) {
        let fileManager = FileManager.default
        
        do {
            // Getting the url to save the json.
            let documentDirectory = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor:nil,
                create:false
            )
            let fileName:String = MBTJSONHelper.uuid.uuidString + ".json"
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            // Saving JSON in device.
            try json.write(to: fileURL)
            MBTJSONHelper.fileURL = fileURL
            print("json saved here : \(fileURL)")
            
            completion(fileURL)
        } catch {
            debugPrint("[MyBrainTechnologiesSDK] Error while saving JSON on device : \(error)")
        }
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
