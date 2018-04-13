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
    
    /// Send JSON to medical BrainWeb server.
    static func sendJSONToBrainWeb(_ fileURL: URL, completion: @escaping (Bool)->() ) {
        
        let url                 = URL(string: "https://api.preprodz.mybraintech.com/v1.0.1beta/ingest-legacy")!
        var urlRequest          = URLRequest(url: url)
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
                            debugPrint(response)
                            if response.response?.statusCode == 201 {
                                completion(true)
                            }
                            completion(false)
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                        completion(false)
                    }
            })
        }
    }
    /// Send ALL JSON to medical BrainWeb server.
    static func sendAllJSONToBrainWeb(completion: @escaping (Bool)->() ) {
        
        let url                 = URL(string: "https://api.preprodz.mybraintech.com/v1.0.1beta/ingest-legacy")!
        var urlRequest          = URLRequest(url: url)
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
                                    debugPrint(response)
                                    if response.response?.statusCode == 201 {
                                        completion(true)
                                    }
                                    completion(false)
                                }
                            case .failure(let encodingError):
                                print(encodingError)
                                completion(false)
                            }
                    })
                }
            }
            
        } catch {
            debugPrint("[MyBrainTechnologiesSDK] Error while saving JSON on device : \(error)")
            completion(false)
        }
        
       
        
    }
}
