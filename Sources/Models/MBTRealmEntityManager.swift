//
//  RealmEntityManager.swift
//  Melomind
//
//  Created by Baptiste Rasschaert on 11/08/2016.
//  Copyright © 2016 Baptiste Rasschaert. All rights reserved.
//

import Foundation
import RealmSwift

/// Class to manage the structure to create entities manager.
class MBTRealmEntityManager: Object {
    /// Structure declaration to create DB Entity managers.
    struct RealmManager {
        /// The *Realm* object.
        static let shared = RealmManager()
        let realm:Realm
        
        var config:Realm.Configuration
        
        init() {
            let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                                 appropriateFor: nil, create: false)
            let url = documentDirectory.appendingPathComponent("MyBrainTechnologieSDKDB.realm")
            config = Realm.Configuration()
            config.deleteRealmIfMigrationNeeded = true
            config.fileURL = url
            config.schemaVersion = 1
            config.shouldCompactOnLaunch = { totalBytes, usedBytes in
                // totalBytes refers to the size of the file on disk in bytes (data + free space)
                // usedBytes refers to the number of bytes used by data in the file
                
                // Compact if the file is over 100MB in size and less than 50% 'used'
                let oneHundredMB = 100 * 1024 * 1024
                return (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
            }
            
            
            realm = try! Realm(configuration: config)
        }
    }

}
