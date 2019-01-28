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
    
    static let defaultModelExternalName = "melomind"
    
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
    
    var qrCode: String? {
        if let deviceId = deviceInfos?.deviceId {
            return MBTQRCodeSerial(qrCodeisKey: false).value(for: deviceId)
        }
        return nil
    }
    
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
        var acquisitions =  [String]()
        for acquisition in acquisitionLocations {
            acquisitions.append("\(acquisition.type.stringValue)")
        }
        
        jsonHeader["deviceInfo"]                = deviceInfos!.getJSON()
        jsonHeader["recordingNb"].stringValue   = "0x03"
        jsonHeader["comments"].arrayObject      = finalsArrayComment
        jsonHeader["sampRate"].intValue         = sampRate
        jsonHeader["eegPacketLength"].intValue  = eegPacketLength
        jsonHeader["nbChannels"].intValue       = nbChannels
        jsonHeader["acquisitionLocation"]       = JSON(acquisitions)
        
        var stringReferencesLocations = [String]()
        for referencesLocation in referencesLocations {
            stringReferencesLocations.append(referencesLocation.type.stringValue)
        }
        jsonHeader["referencesLocation"] = JSON(stringReferencesLocations)
        
        var stringGroundsLocations = [String]()
        for groundsLocation in groundsLocations {
            stringGroundsLocations.append(groundsLocation.type.stringValue)
        }
        jsonHeader["groundsLocation"] = JSON(stringGroundsLocations)
        
        return jsonHeader
    }
}

//MARK: -

///// Files Names
//
//public class FileName: Object {
//    @objc public dynamic var value:String = ""
//}

//MARK: -

/// Device Informations model.
public class MBTDeviceInformations: Object {
    /// The commercial name of the device.
    @objc public dynamic var externalName:String? = nil
    
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
       
        jsonDevice["productName"].stringValue               = externalName ?? ""
        jsonDevice["hardwareVersion"].stringValue           = hardwareVersion ?? ""
        jsonDevice["firmwareVersion"].stringValue           = firmwareVersion ?? ""
        jsonDevice["uniqueDeviceIdentifier"].stringValue    = deviceId ?? ""
        
        return jsonDevice
    }
    
 
    
    /// Allows to know if all properties have been initialized
    ///
    /// - Returns: A *Bool* instance which test if one of the four properties is nil
    func isDeviceInfoNotNil() -> Bool {
        return externalName != nil && deviceId != nil && hardwareVersion != nil && firmwareVersion != nil
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
            try! RealmManager.shared.realm.write {
                device.deviceInfos!.externalName = deviceInfos.externalName ?? device.deviceInfos!.externalName
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
            try! RealmManager.shared.realm.write {
                if batteryLevel >= 0 && batteryLevel <= 6 {
                    device.batteryLevel = batteryLevel
                } else {
                    device.batteryLevel = -1
                }
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
            try! RealmManager.shared.realm.write {
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
        if let deviceName = connectedDeviceName, !deviceName.isEmpty {
            if  let device = RealmManager.shared.realm.objects(MBTDevice.self).filter("deviceName = %@", deviceName).first {
                return device
            } else {
                    let newDevice = MBTDevice()
                    newDevice.deviceName = deviceName
                    
                    try! RealmManager.shared.realm.write {
                        RealmManager.shared.realm.add(newDevice)
                    }
                
                return newDevice
            }
        }
        return nil
    }
    
    /// Get Register Device
    /// - Returns : The array DB-saved *[MBTDevice]* instance
    class func getRegisteredDevices() -> [MBTDevice] {
        return [MBTDevice](RealmManager.shared.realm.objects(MBTDevice.self))
    }

    
    /// Get BLE device informations of the connected MBT device.
    /// - Returns: The DB-saved *MBTDeviceInformations* instance.
    class func getDeviceInfos() -> MBTDeviceInformations? {
        // Get current device.
        return getCurrentDevice()?.deviceInfos
    }
    
    /// Get EEG data samp rate of the connected device.
    /// - Returns: The *sampRate* of the current *MBTDevice*.
    class func getDeviceSampRate() -> Int? {
        return getCurrentDevice()?.sampRate
    }
    
    /// Get the number of channels of the connected device.
    /// - Returns: The *nbChannels* of the current *MBTDevice*.
    class func getChannelsCount() -> Int? {
        return getCurrentDevice()?.nbChannels
    }
    
    /// Get EEGPacket length of the connected device.
    /// - Returns: The *eegPacketLength* of the current *MBTDevice*.
    class func getDeviceEEGPacketLength() -> Int? {
        return getCurrentDevice()?.eegPacketLength
    }
    
    class func getDeviceQrCode() -> String? {
        return getCurrentDevice()?.qrCode
    }
    
    /// Deinit all properties of deviceInfos
    class func resetDeviceInfo() {
        if let currentDevice = DeviceManager.getCurrentDevice() {
            try! RealmManager.shared.realm.write {
                currentDevice.deviceInfos?.externalName = nil
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
        
        if let device = RealmManager.shared.realm.objects(MBTDevice.self).filter("deviceName = %@", deviceNameToDelete).first {
            try! RealmManager.shared.realm.write {
                RealmManager.shared.realm.delete(device)
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
            rawType = newValue.rawValue
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
    
    var stringValue:String {
        switch self {
        case .Fpz : return "Fpz"
        case .Fp1 : return "Fp1"
        case .Fp2 : return "Fp2"
            
        case .AF7 : return "AF7"
        case .AF3 : return "AF3"
        case .AFz : return "AFz"
        case .AF4 : return "AF4"
        case .AD8 : return "AD8"
            
        case .F9 : return "F9"
        case .F7 : return "F7"
        case .F5 : return "F5"
        case .F3 : return "F3"
        case .F1 : return "F1"
        case .Fz : return "Fz"
        case .F2 : return "F2"
        case .F4 : return "F4"
        case .F6 : return "F6"
        case .F8 : return "F8"
        case .F10 : return "F10"
            
        case .FT9 : return "FT9"
        case .FT7 : return "FT7"
        case .FC5 : return "FC5"
        case .FC3 : return "FC3"
        case .FC1 : return "FC1"
        case .FCz : return "FCz"
        case .FC2 : return "FC2"
        case .FC4 : return "FC4"
        case .FC6 : return "FC6"
        case .FT8 : return "FT8"
        case .FT10 : return "FT10"
            
        case .T7 : return "T7"
        case .C5 : return "C5"
        case .C3 : return "C3"
        case .C1 : return "C1"
        case .Cz : return "Cz"
        case .C2 : return "C2"
        case .C4 : return "C4"
        case .C6 : return "C6"
        case .T8 : return "T8"
            
        case .TP9 : return "TP9"
        case .TP7 : return "TP7"
        case .CP5 : return "CP5"
        case .CP3 : return "CP3"
        case .CP1 : return "CP1"
        case .CPz : return "CPz"
        case .CP2 : return "CP2"
        case .CP4 : return "CP4"
        case .CP6 : return "CP6"
        case .TP8 : return "TP8"
        case .TP10 : return "TP10"
            
        case .P9 : return "P9"
        case .P7 : return "P7"
        case .P5 : return "P5"
        case .P3 : return "P3"
        case .P1 : return "P1"
        case .Pz : return "Pz"
        case .P2 : return "P2"
        case .P4 : return "P4"
        case .P6 : return "P6"
        case .P8 : return "P8"
        case .P10 : return "P10"
            
        case .PO3 : return "PO3"
        case .POz : return "POz"
        case .PO4 : return "PO4"
            
        case .PO7 : return "PO7"
        case .O1 : return "O1"
        case .Oz : return "Oz"
        case .O2 : return "O2"
        case .PO8 : return "PO8"
            
        case .PO9 : return "PO9"
        case .O9 : return "O9"
        case .Iz : return "Iz"
        case .O10 : return "O10"
        case .PO10 : return "PO10"
            
        case .M1 : return "M1" // Mastoid 1
        case .M2 : return "M2"  // Mastoid 2
            
        case .ACC : return "ACC"
            
        case .EXT1 : return "EXT1"
        case .EXT2 : return "EXT2"
        case .EXT3 : return "EXT3"
            
        case .NULL1 : return "NULL1"
        case .NULL2 : return "NULL2"
        case .NULL3 : return "NULL3"
        }
    }
}


