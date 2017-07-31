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
    
    /// Send JSON to medical BrainWeb server.
    static func sendJSONToBrainWeb(_ fileURL: URL) {
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(fileURL, withName: "eeg")
        },
            to: "https://ingest.dev.mybraintech.com/medical-test/eeg",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        })
    }
}
