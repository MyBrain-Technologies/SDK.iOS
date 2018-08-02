//
//  MBTBrainWebHelper.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 31/07/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import Alamofire

/// Helper to deal with Brain Web (server).
struct MBTBrainWebHelper {
    
    static var accessTokens = ""
    
    static var path = "/ingest-legacy"
    
    /// Send JSON to medical BrainWeb server.
    static func sendJSONToBrainWeb(_ fileURL: URL, baseURL: String , completion: @escaping (Bool)->() ) {
        
        let url                 = URL(string: baseURL)!
        var urlRequest          = URLRequest(url: url.appendingPathComponent(MBTBrainWebHelper.path))
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.timeoutInterval = TimeInterval(20)
        urlRequest.setValue("Bearer " + accessTokens, forHTTPHeaderField: "Authorization")
        
        if let request = try? Alamofire.URLEncoding.default.encode(urlRequest as URLRequestConvertible, with: [String:String]()) {
            Alamofire.upload(multipartFormData:{ multipartFormData in
                multipartFormData.append(fileURL, withName: "eeg")
            }
                , with: request, encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint("#57685 - sendJSONToBrainWeb response :\(response)")
                            if response.response?.statusCode == 201 {
                                completion(true)
                            }
                            completion(false)
                        }
                    case .failure(let encodingError):
                        print("#57685 - sendJSONToBrainWeb failure : \(encodingError)")
                        completion(false)
                    }
            })
        }
    }
    /// Send ALL JSON to medical BrainWeb server.
    static func sendAllJSONToBrainWeb(_ baseURL: String, completion: @escaping (Bool)->() ) {
        
        let url                 = URL(string: baseURL)!
        var urlRequest          = URLRequest(url: url.appendingPathComponent(MBTBrainWebHelper.path))
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.timeoutInterval = TimeInterval(20)
        urlRequest.setValue("Bearer " + accessTokens, forHTTPHeaderField: "Authorization")
        
        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor:nil,
                create:false
            )
            
            let eegPacketJSONRecordingsPath = documentDirectory.appendingPathComponent("eegPacketJSONRecordings")

            let tabEegPacketsJSONFiles = try fileManager.contentsOfDirectory(at: eegPacketJSONRecordingsPath, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
            for fileURL in tabEegPacketsJSONFiles {
                if let request = try? Alamofire.URLEncoding.default.encode(urlRequest as URLRequestConvertible, with: [String:String]()) {
                    Alamofire.upload(multipartFormData:{ multipartFormData in
                        multipartFormData.append(fileURL, withName: "eeg")
                    }
                        , with: request, encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { response in
                                    debugPrint("#57685 - sendALLJsonToBrainWeb response : \(response)")
                                    if response.response?.statusCode == 201 {
                                        let _ = MBTJSONHelper.removeFile(fileURL)
                                        completion(true)
                                    }
                                    completion(false)
                                }
                            case .failure(let encodingError):
                                print("#57685 - sendAllJSONToBrainWeb failure : \(encodingError)")
                                completion(false)
                            }
                    })
                }
            }
            
        } catch {
            debugPrint("#57685 - [MyBrainTechnologiesSDK] Error while saving JSON on device : \(error)")
            completion(false)
        }
        
       
        
    }
}
