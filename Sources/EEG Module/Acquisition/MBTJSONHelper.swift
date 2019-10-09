//
//  MBTJSONHelper.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 31/07/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Helper to create and manage a JSON file (kwak format)
/// with the session data.
struct MBTJSONHelper {
    
    /// Save the JSON in a File.
    ///
    /// - Parameters:
    ///   - json: A *JSON* of the Session
    ///   - idDevice: A *Int* id of the Melomind Connected
    ///   - idUser: A *Int* id of the User Connected
    ///   - completion: A block which is execute after save the file or if it fail
    /// - Returns: return the URL of the file saved or nil if it fail
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
    ///
    /// - Parameters:
    ///   - idUser: A *Int* id of the connected user
    ///   - idDevice: A *Int* id of the connected melomind
    /// - Returns: Return the file name
    static func getFileName(_ idUser:Int, withIdDevice idDevice:String) -> String {
        let date = Date()
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd--HH:mm:ss"
        let projectName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let deviceName =  "melo_" + idDevice
        let stringIdUser = "\(idUser)"
        return "eegPacketsRecording_" + dateFormater.string(from: date) + "_" + projectName + "_" + deviceName + "_" + stringIdUser + ".json"
    }
    
    /// Remove the file
    ///
    /// - Parameter urlFile: A *URL* of the file to remove
    /// - Returns: Return the boolean if success or fail
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
