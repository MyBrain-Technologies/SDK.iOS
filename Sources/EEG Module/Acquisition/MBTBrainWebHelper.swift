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
    
    /// Send JSON to BrainWeb server.
    ///
    /// - Parameters:
    ///   - fileURL: A *URL* of the file which sends
    ///   - baseURL: A *String* of BrainWeb base url (without the endpoint)
    ///   - completion: A block which is execute after the success or the failure of the request
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
                            prettyPrint(log.url("sendJSONToBrainWeb response : \n \(response)"))
                            if let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 {
                                completion(true)
                            } else {
                                completion(false)
                            }
                        }
                    case .failure(let encodingError):
                        prettyPrint(log.url("sendJSONToBrainWeb failure : \(encodingError)"))
                        completion(false)
                    }
            })
        }
    }
    
    /// Send ALL JSON to BrainWeb server.
    ///
    /// - Parameters:
    ///   - baseURL: A *String* of BrainWeb base url (without the endpoint)
    ///   - completion: A block which is execute after the success or the failure of the request
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
                                    prettyPrint(log.url("sendALLJsonToBrainWeb - response : \n\(response)"))
                                    if response.response?.statusCode == 201 {
                                        let _ = MBTJSONHelper.removeFile(fileURL)
                                        completion(true)
                                    }
                                    completion(false)
                                }
                            case .failure(let encodingError):
                                prettyPrint(log.url("sendAllJSONToBrainWeb - failure : \(encodingError)"))
                                completion(false)
                            }
                    })
                }
            }
            
        } catch {
            prettyPrint(log.ln("sendAllJSONToBrainWeb - "))
            prettyPrint(log.error(error as NSError))
            completion(false)
        }
        
       
        
    }
}
