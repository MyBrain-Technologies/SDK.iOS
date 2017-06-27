//
//  MBTBluetoothLE.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 11/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import CoreBluetooth


/// Help MBTBluetoothManager to manage Bluetooth Low Energy ( BLE ).
struct MBTBluetoothLE {
    /// The *UUID* of the MyBrainServices.
    private static let myBrainServiceUUID = CBUUID(string: "0xB2A0")
    
    /// The *UUID* of the DeviceInformation service.
    static let deviceInfoServiceUUID = CBUUID(string: "0x180A")
    
    /// The *UUID* of the brainActivityMeasurement
    /// characteristic of the Measurement service.
    static let brainActivityMeasurementUUID = CBUUID(string: "0xB2A5")
    
    /// The *characteristic* of the Measurement service.
    static var brainActivityMeasurementCharacteristic: CBCharacteristic!
    
    //MARK: - Bluetooth LE Methods
    
    /// Getter of Bluetooth LE Services UUIDs.
    /// - Returns : *Array* of BLE services UUIDs.
    static func getServicesUUIDs() -> [CBUUID] {
        return [myBrainServiceUUID, deviceInfoServiceUUID]
    }
}
