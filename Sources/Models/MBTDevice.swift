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
    
    /// Device Name
    @objc dynamic public var deviceName: String = ""
    
    /// Device informations from MBT Headset Bluetooth LE.
    @objc dynamic public var deviceInfos: MBTDeviceInformations? = MBTDeviceInformations()
    
    /// The number of active channels in the device.
    @objc dynamic var nbChannels:Int = 0

    /// The rate at which EEG data is being sent by the headset.
    @objc dynamic var sampRate:Int = 0
    
    /// An EEG Packet length.
    @objc dynamic var eegPacketLength: Int = 0
    
    @objc dynamic var batteryLevel: Int = 0
    
    /// Locations of the acquisition electrodes.
    let acquisitionLocations = List<MBTAcquistionLocation>()
    
    /// Locations of the references for an electrode.
    let referencesLocations = List<MBTAcquistionLocation>()
    
    /// Locations of the ground electrodes.
    let groundsLocations = List<MBTAcquistionLocation>()
    
    /// Helper Function to get JSON
    ///
    /// - Parameter comments: user's comments
    /// - Returns: A *JSON* instance of MBTDevice
    internal func getJSON(_ comments:[String]) -> JSON {
        var jsonHeader = JSON()
        
        var finalsArrayComment = comments
        finalsArrayComment.insert("\(Date().timeIntervalSince1970)", at: 0)
        var acquisitions: [String] = Array()
        for acquisition in acquisitionLocations {
            acquisitions.append("\(acquisition.type)")
        }
        
        jsonHeader["deviceInfo"]                = deviceInfos!.getJSON()
        jsonHeader["recordingNb"].stringValue   = "0x03"
        jsonHeader["comments"].arrayObject      = finalsArrayComment
        jsonHeader["sampRate"].intValue         = sampRate
        jsonHeader["eegPacketLength"].intValue  = eegPacketLength
        jsonHeader["nbChannels"].intValue       = nbChannels
        jsonHeader["acquisitionLocation"]       = JSON(acquisitions)
        
        jsonHeader["referencesLocation"].arrayObject = [
            "\(referencesLocations.first!.type)"
        ]
        jsonHeader["groundsLocation"].arrayObject = [
            "\(groundsLocations.first!.type)"
        ]
        
        return jsonHeader
    }
}

//MARK: -

/// Files Names

public class FileName: Object {
    @objc public dynamic var value:String = ""
}

//MARK: -

/// Device Informations model.
public class MBTDeviceInformations: Object {
    /// The commercial name of the device.
    @objc public dynamic var productName:String? = nil
    
    /// The product specific serial number.
    @objc public dynamic var deviceId:String? = nil
    
    /// The product hardware version.
    @objc public dynamic var hardwareVersion:String? = nil
    
    /// The product firmware version.
    @objc public dynamic var firmwareVersion:String? = nil
    
    /// Helper Function to get JSON
    ///
    /// - Returns: A *JSON* instance of MBTDeviceInformations
    func getJSON() -> JSON {
        var jsonDevice = JSON()
       
        jsonDevice["productName"].stringValue               = productName ?? ""
        jsonDevice["hardwareVersion"].stringValue           = hardwareVersion ?? ""
        jsonDevice["firmwareVersion"].stringValue           = firmwareVersion ?? ""
        jsonDevice["uniqueDeviceIdentifier"].stringValue    = deviceId ?? ""
        
        return jsonDevice
    }
    
 
    
    func isDeviceInfoNotNil() -> Bool {
        return productName != nil && deviceId != nil && hardwareVersion != nil && firmwareVersion != nil
    }
}

//MARK: -

/// *MBTDevice* model DB Manager.
class DeviceManager: MBTRealmEntityManager {
    
    /// The headset bluetooth profile name to connect to.
    static var connectedDeviceName: String?
    
    
    /// Update *deviceInformations* of the newly connected device record in the DB.
    /// - Parameters:
    ///     - deviceInfos: *MBTDeviceInformations* from BLE to record.
    class func updateDeviceInformations(_ deviceInfos:MBTDeviceInformations) {
        // Get the myBrainTechnologies device connected.
        if let device = getCurrentDevice() {
            // Save the new device infos to Realm Database
            try! RealmManager.realm.write {
                device.deviceInfos!.productName = deviceInfos.productName ?? device.deviceInfos!.productName
                device.deviceInfos!.deviceId = deviceInfos.deviceId ?? device.deviceInfos!.deviceId
                device.deviceInfos!.hardwareVersion = deviceInfos.hardwareVersion ?? device.deviceInfos!.hardwareVersion
                device.deviceInfos!.firmwareVersion = deviceInfos.firmwareVersion ?? device.deviceInfos!.firmwareVersion
            }
        }
    }
    
    /// Update *deviceBatteryLevel*
    /// - Parameters:
    ///     - batterylevel: *Int* from BLE to record.
    class func updateDeviceBatteryLevel(_ batteryLevel:Int) {
        // Get the myBrainTechnologies device connected.
        if let device = getCurrentDevice() {
            // Save the new battery status to Realm Database
            try! RealmManager.realm.write {
                device.batteryLevel = batteryLevel
            }
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
        if let device = getCurrentDevice() {
            try! RealmManager.realm.write {
                device.sampRate = 250
                device.nbChannels = 2
                device.eegPacketLength = 250
                
                // Add electrodes locations value.
                device.acquisitionLocations.removeAll()
                device.acquisitionLocations.append(acquisition1)
                device.acquisitionLocations.append(acquisition2)
                device.referencesLocations.removeAll()
                device.referencesLocations.append(reference)
                device.groundsLocations.removeAll()
                device.groundsLocations.append(ground)
            }
        }
     
    }
    
    /// Get the DB-saved device or create one if any.
    /// - Returns: The DB-saved *MBTDevice* instance.
    class func getCurrentDevice() -> MBTDevice? {
        // If no device saved in DB, then create it.
        if let deviceName = connectedDeviceName {
            guard let device = RealmManager.realm.objects(MBTDevice.self).filter("deviceName = %@", deviceName).first else {
                let newDevice = MBTDevice()
                newDevice.deviceName = deviceName
                
                try! RealmManager.realm.write {
                    RealmManager.realm.add(newDevice)
                }
                return newDevice
            }
            return device
        }
        
        return nil
    }
    
    /// Get Register Device
    /// - Returns : The array DB-saved *[MBTDevice]* instance
    class func getRegisteredDevices() -> [MBTDevice] {
        return [MBTDevice](RealmManager.realm.objects(MBTDevice.self))
    }

    
    /// Get BLE device informations of the connected MBT device.
    /// - Returns: The DB-saved *MBTDeviceInformations* instance.
    class func getDeviceInfos() -> MBTDeviceInformations? {
        // Get current device.
        return getCurrentDevice()?.deviceInfos
    }
    
    /// Get EEG data samp rate of the connected device.
    /// - Returns: The *sampRate* of the current *MBTDevice*.
    class func getDeviceSampRate() -> Float {
        return Float(getCurrentDevice()?.sampRate ?? 0)
    }
    
    /// Get the number of channels of the connected device.
    /// - Returns: The *nbChannels* of the current *MBTDevice*.
    class func getChannelsCount() -> Int {
        return getCurrentDevice()?.nbChannels ?? 0
    }
    
    /// Get EEGPacket length of the connected device.
    /// - Returns: The *eegPacketLength* of the current *MBTDevice*.
    class func getDeviceEEGPacketLength() -> Int {
        return getCurrentDevice()!.eegPacketLength
    }
    
    class func resetDeviceInfo() {
        if let currentDevice = DeviceManager.getCurrentDevice() {
            try! RealmManager.realm.write {
                currentDevice.deviceInfos?.productName = nil
                currentDevice.deviceInfos?.deviceId = nil
                currentDevice.deviceInfos?.hardwareVersion = nil
                currentDevice.deviceInfos?.firmwareVersion = nil
            }
        }
    }
    
    /// Remove the current device from Realm DB
    
    class func removeCurrentDevice() -> Bool {
        guard let deviceToDelete = connectedDeviceName else {
            return false
        }
        
        return removeDevice(deviceToDelete)
    }
    
    
    /// Remove the device with deviceName == deviceName from Realm DB
    class func removeDevice(_ deviceName: String) -> Bool {
        
        let deviceNameToDelete:String! = deviceName
        
        if let device = RealmManager.realm.objects(MBTDevice.self).filter("deviceName = %@", deviceNameToDelete).first {
            try! RealmManager.realm.write {
                RealmManager.realm.delete(device)
            }
            
            return true
        }
        
        return false
    }

}

//MARK: -

/// Electrode location model.
class MBTAcquistionLocation: Object {
    /// Value (in the enum) of the electrode, for Realm.
    @objc fileprivate dynamic var rawType = -1
    
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


