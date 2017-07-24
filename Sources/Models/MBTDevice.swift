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
public class MBTDevice: Object {
    
    /// The commercial name of the device.
    dynamic var productName:String? = nil
    
    /// The product specific serial number.
    dynamic var deviceId:String? = nil
    
    /// The product hardware version.
    dynamic var hardwareVersion:String? = nil
    
    /// The product firmware version.
    dynamic var firmwareVersion:String? = nil
    
    /// The number of active channels in the device.
    dynamic var nbChannels:Int = 0

    /// The rate at which EEG data is being sent by the headset.
    dynamic var sampRate:Int = 0
    
    /// An EEG Packet length.
    dynamic var eegPacketLength: Int = 0
    
    /// Locations of the acquisition electrodes.
    let acquisitionLocations = List<MBTAcquistionLocation>()
    
    /// Locations of the references for an electrode.
    let referencesLocations = List<MBTAcquistionLocation>()
    
    /// Locations of the ground electrodes.
    let groundsLocations = List<MBTAcquistionLocation>()
}

//MARK: -

/// *MBTDevice* model DB Manager.
class DeviceManager: RealmEntityManager {
    
    /// Update the newly connected device record in the DB.
    /// - Parameters:
    ///     - updatedDevice: *MBTDevice* to record.
    class func updateConnectedDevice(_ updatedDevice:MBTDevice) {
        // Save the new device to Realm Database
        let device = getDevice()
        
        try! RealmManager.realm.write {
            device.productName = updatedDevice.productName ?? device.productName
            device.deviceId = updatedDevice.deviceId ?? device.deviceId
            device.hardwareVersion = updatedDevice.hardwareVersion ?? device.hardwareVersion
            device.firmwareVersion = updatedDevice.firmwareVersion ?? device.firmwareVersion
            
            device.nbChannels = updatedDevice.nbChannels != 0 ?
                updatedDevice.nbChannels: device.nbChannels
            device.sampRate = updatedDevice.sampRate != 0 ?
                updatedDevice.sampRate: device.sampRate
            device.eegPacketLength = updatedDevice.eegPacketLength != 0 ?
                updatedDevice.eegPacketLength: device.eegPacketLength
            
            if updatedDevice.acquisitionLocations.count != 0 {
                device.acquisitionLocations.removeAll()
                device.acquisitionLocations.append(objectsIn: updatedDevice.acquisitionLocations)
            }
            
            if updatedDevice.referencesLocations.count != 0 {
                device.referencesLocations.removeAll()
                device.referencesLocations.append(objectsIn: updatedDevice.referencesLocations)
            }
            
            if updatedDevice.groundsLocations.count != 0 {
                device.groundsLocations.removeAll()
                device.groundsLocations.append(objectsIn: updatedDevice.groundsLocations)
            }
        }
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


//MARK: -

/// Electrode location model.
public class MBTAcquistionLocation: Object {
    // Index of the exercice type
    fileprivate dynamic var rawType = -1
    var type: ElectrodeLocation {
        get {
            return ElectrodeLocation(rawValue: rawType)!
        }
        set {
            rawType = newValue.hashValue
        }
    }
    
    // Specify properties to ignore (Realm won't persist these)
    override public static func ignoredProperties() -> [String] {
        return ["type"]
    }
}

/// Enum of differents electrodes possible locations.
public enum ElectrodeLocation: Int {
    case Fpz
    case Fp1
    case Fp2
    
    case AF7
    case AF3
    case AFz
    case AF4
    case AD8
    
    case F9
    case F7
    case F5
    case F3
    case F1
    case Fz
    case F2
    case F4
    case F6
    case F8
    case F10
    
    case FT9
    case FT7
    case FC5
    case FC3
    case FC1
    case FCz
    case FC2
    case FC4
    case FC6
    case FT8
    case FT10
    
    case T7
    case C5
    case C3
    case C1
    case Cz
    case C2
    case C4
    case C6
    case T8
    
    case TP9
    case TP7
    case CP5
    case CP3
    case CP1
    case CPz
    case CP2
    case CP4
    case CP6
    case TP8
    case TP10
    
    case P9
    case P7
    case P5
    case P3
    case P1
    case Pz
    case P2
    case P4
    case P6
    case P8
    case P10
    
    case PO3
    case POz
    case PO4
    
    case PO7
    case O1
    case Oz
    case O2
    case PO8
    
    case PO9
    case O9
    case Iz
    case O10
    case PO10
    
    case M1 // Mastoid 1
    case M2  // Mastoid 2
    
    case ACC
    
    case EXT1
    case EXT2
    case EXT3
    
    case NULL1
    case NULL2
    case NULL3
}

