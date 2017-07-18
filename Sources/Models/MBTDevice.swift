//
//  MBTDevice.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 29/06/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import RealmSwift

/// Model to store data about the Headset connected.
class MBTDevice: Object {
    //MARK: - Properties
    
    /// The commercial name of the device.
    dynamic var productName:String = ""
    
    /// The product serial number.
    dynamic var serialNumber:String = ""
    
    /// The product hardware version.
    dynamic var hardwareVersion:String = ""
    
    /// The product firmware version.
    dynamic var firmwareVersion:String = ""
    
    /// The id of the product.
    dynamic var productID:String = ""
    
    /// The device unique id.
    dynamic var deviceUUID:String = ""
    
    /// The number of active channels in the device.
    dynamic var nbChannels:Int = 0
}


/// *MBTDevice* model DB Manager.
class DeviceManager: RealmEntityManager {
    
    /// Update the newly connected device record in the DB.
    /// - Parameters:
    ///     - updatedDevice: *MBTDevice* to record.
    class func updateConnectedDevice(_ updatedDevice:MBTDevice) {
        // Save the new device to Realm Database
        let device = getDevice()
        
        try! RealmManager.realm.write {
            device.productName = updatedDevice.productName
            device.serialNumber = updatedDevice.serialNumber
            device.hardwareVersion = updatedDevice.hardwareVersion
            device.firmwareVersion = updatedDevice.firmwareVersion
        }
        
        print(device)
    }
    
    /// Get the DB-saved device or create one if any.
    /// - Returns: The DB-saved *MBTDevice* instance.
    class func getDevice() -> MBTDevice {
        // If no device saved in DB, then create it.
        guard let device = RealmManager.realm.objects(MBTDevice.self).first else {
            let newDevice = MBTDevice()
            
            try! RealmManager.realm.write {
                RealmManager.realm.add(newDevice)
            }
            
            return newDevice
        }
        
        return device
    }
    
    
//    class func formatJSONAsUser(_ json:JSON) -> User {
//        let metadata = Metadata()
//        
//        if let username = json["username"].string {
//            metadata.pseudo = username
//        }
//        if let age = json["age"].int {
//            metadata.age = age
//        }
//        if let sexe = json["gender"].string {
//            metadata.sexe = sexe
//        }
//        if let job = json["job"].string {
//            metadata.job = job
//        }
//        if let country = json["country"].string {
//            metadata.country = country
//        }
//        if let city = json["city"].string {
//            metadata.city = city
//        }
//        if let language = json["language"].string {
//            metadata.language = language
//        }
//        
//        let user = User()
//        if let email = json["email"].string {
//            user.email = email
//        }
//        if let password = json["password"].string {
//            user.password = password
//        }
//        user.metaData = metadata
//        
//        return user
//    }
    
}

