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
    
    /// Device informations from MBT Headset Bluetooth LE.
    public private(set) var deviceInfos: MBTDeviceInformations? = MBTDeviceInformations()
    
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

/// Device Informations model.
public class MBTDeviceInformations: Object {
    
    /// The commercial name of the device.
    public dynamic var productName:String? = nil
    
    /// The product specific serial number.
    public dynamic var deviceId:String? = nil
    
    /// The product hardware version.
    public dynamic var hardwareVersion:String? = nil
    
    /// The product firmware version.
    public dynamic var firmwareVersion:String? = nil
}

//MARK: -

/// *MBTDevice* model DB Manager.
class DeviceManager: MBTRealmEntityManager {
    
    /// Update *deviceInformations* of the newly connected device record in the DB.
    /// - Parameters:
    ///     - deviceInfos: *MBTDeviceInformations* from BLE to record.
    class func updateDeviceInformations(_ deviceInfos:MBTDeviceInformations) {
        // Save the new device infos to Realm Database
        let device = getCurrentDevice()
        
        try! RealmManager.realm.write {
            device.deviceInfos?.productName = deviceInfos.productName ?? device.deviceInfos?.productName
            device.deviceInfos?.deviceId = deviceInfos.deviceId ?? device.deviceInfos?.deviceId
            device.deviceInfos?.hardwareVersion = deviceInfos.hardwareVersion ?? device.deviceInfos?.hardwareVersion
            device.deviceInfos?.firmwareVersion = deviceInfos.firmwareVersion ?? device.deviceInfos?.firmwareVersion
        }
    }
    
    /// Init device with Melomind specifications.
    class func updateDeviceToMelomind() {
        
        // Acquisition Electrodes
        let acquisition1 = MBTAcquistionLocation()
        acquisition1.type = .P3
        let acquisition2 = MBTAcquistionLocation()
        acquisition2.type = .P4
        
        // Reference Electrode
        let reference = MBTAcquistionLocation()
        reference.type = .M1
        
        // Ground Electrode
        let ground = MBTAcquistionLocation()
        ground.type = .M2
        
        // Save Melomind info to DB
        let device = getCurrentDevice()
        try! RealmManager.realm.write {
            device.sampRate = 250
            device.nbChannels = 2
            device.eegPacketLength = 250
            
            // Add electrodes locations value.
            device.acquisitionLocations.append(acquisition1)
            device.acquisitionLocations.append(acquisition2)
            device.acquisitionLocations.append(reference)
            device.acquisitionLocations.append(ground)
        }
    }
    
    /// Get the DB-saved device or create one if any.
    /// - Returns: The DB-saved *MBTDevice* instance.
    class func getCurrentDevice() -> MBTDevice {
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
    
    /// Get BLE device informations of the connected MBT device.
    /// - Returns: The DB-saved *MBTDeviceInformations* instance.
    class func getDeviceInfos() -> MBTDeviceInformations? {
        // Get current device.
        let device = getCurrentDevice()
        
        return device.deviceInfos
    }
    
    /// Get EEG data samp rate of the connected device.
    /// - Returns: The *sampRate* of the current *MBTDevice*.
    class func getDeviceSampRate() -> Float {
        // Get current device.
        let device = getCurrentDevice()
        let sampRate = Float(device.sampRate)
        
        return sampRate
    }
}

//MARK: -

/// Electrode location model.
class MBTAcquistionLocation: Object {
    /// Value (in the enum) of the electrode, for Realm.
    fileprivate dynamic var rawType = -1
    
    /// Human Readable value of an electrode location.
    var type: ElectrodeLocation {
        get {
            return ElectrodeLocation(rawValue: rawType)!
        }
        set {
            rawType = newValue.hashValue
        }
    }
    
    /// Properties to ignore (Realm won't persist these).
    override public static func ignoredProperties() -> [String] {
        return ["type"]
    }
}

/// Enum of differents electrodes possible locations.
enum ElectrodeLocation: Int {
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


