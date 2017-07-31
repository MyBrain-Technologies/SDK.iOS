//
//  MBTBluetoothLE.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 11/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import CoreBluetooth


/// Help MBTBluetoothManager to manage Bluetooth Low Energy ( BLE ).
struct MBTBluetoothLEHelper {
    /// The *UUID* of the MyBrainServices.
    private static let myBrainServiceUUID = CBUUID(string: "0xB2A0")
    
    /// The *UUID* of the brainActivityMeasurement characteristic of the Measurement service.
    static let brainActivityMeasurementUUID = CBUUID(string: "0xB2A5")
    
    /// The *UUID* of the DeviceState characteristic of the Measurement service.
    static let deviceStateUUID = CBUUID(string: "0xB2A2")
    
    /// The *UUID* of the Device name characteristic.
    static let deviceNameUUID = CBUUID(string: "0xB2A3")
    
    /// The *UUID* of the DeviceInformation service.
    static let deviceInfoServiceUUID = CBUUID(string: "0x180A")
    
    /// The *UUID* of Model Number String service.
    static let productNameUUID = CBUUID(string: "0x2A24")
    
    /// The *UUID* of Serial Number String service.
    static let serialNumberUUID = CBUUID(string: "0x2A25")
    
    /// The *UUID* of Hardware revision String service.
    static let hardwareRevisionUUID = CBUUID(string: "0x2A27")
    
    /// The *UUID* of Firmware revision String service.
    static let firmwareRevisionUUID = CBUUID(string: "0x2A26")
    
    /// The *characteristic* of the Measurement service.
    static var brainActivityMeasurementCharacteristic: CBCharacteristic!
    
    /// The Device state characteristic of the myBrain service.
    static var deviceStateCharacteristic: CBCharacteristic!
    
    //MARK: - Bluetooth LE Methods
    
    /// Getter of Bluetooth LE Services UUIDs.
    /// - Returns : *Array* of BLE services UUIDs.
    static func getServicesUUIDs() -> [CBUUID] {
        return [myBrainServiceUUID, deviceInfoServiceUUID]
    }
    
    /// Getter of BLE device informations characteristics UUIDs.
    /// - Returns : *Array* of device information characteristics UUIDs.
    static func getDeviceInfoCharacteristicsUUIDS() -> [CBUUID] {
        return [productNameUUID, serialNumberUUID, hardwareRevisionUUID, firmwareRevisionUUID]
    }
}
