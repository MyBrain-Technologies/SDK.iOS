//
//  MBTBluetoothLE.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 11/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import CoreBluetooth

// Notification Keys
//let BLEDataSampleReceived = "MBT.BLEDataSampleReceivedNotificationKey"
//let BLELeadOffChanged = "MBT.BLELeadOffChangedNotificationKey"
//let BLEBatteryLevel = "MBT.BLEBatteryLevelNotificationKey"




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
    
    /// The multiplicative constant.
    internal static let const = 4.5 * 1000000 / (pow(2.0, 23.0) - 1) / 24
    
    //TODO: ADD COMMENT HERE
    internal static let voltageADS1299:Float = ( 0.286 * pow(10, -6)) / 12
    
    //MARK: - Bluetooth LE Methods
    
    /// Getter of Bluetooth LE Services UUIDs.
    /// - Returns : *Array* of BLE services UUIDs.
    static func getServicesUUIDs() -> [CBUUID] {
        return [myBrainServiceUUID, deviceInfoServiceUUID]
    }
    
    /// Process the brain activty measurement received and return the processed data.
    /// - Parameters:
    ///     - data : *Data* received from MBT Headset EEGs.
    /// - Returns: *Dictionnary* with the packet Index ( key : "packetIndex" ) and array of
    ///     P3 and P4 samples arrays ( key : "packet" )
    static func processBrainActivityData(_ data: Data) -> [String: Any] {
        //Get the bytes as unsigned shorts
        let count = 18
        var bytesArray = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&bytesArray, length: count * MemoryLayout<UInt8>.size)
        
        //Process the data.
        let packetIndex = Int(bytesArray[0]) << 8 | Int(bytesArray[1])
        var values = [Float]()
        for i in 0..<8 {
            let temp = Int(bytesArray[2 * i + 2]) << 8 | Int(bytesArray[2 * i + 3])
            var value = temp & Int(pow(2.0, 23.0) - 1)
            let sign = (temp & Int(pow(2.0, 23.0))) >> 23
            if sign == 0 {
                value -= Int(pow(2.0, 23.0))
            }
            values.append(Float(value))
        }
        
        let P3Sample1 = values[0] * voltageADS1299
        let P4Sample1 = values[1] * voltageADS1299
        let P3Sample2 = values[2] * voltageADS1299
        let P4Sample2 = values[3] * voltageADS1299
        let P3Sample3 = values[4] * voltageADS1299
        let P4Sample3 = values[5] * voltageADS1299
        let P3Sample4 = values[6] * voltageADS1299
        let P4Sample4 = values[7] * voltageADS1299
        
    
        // Return the EEG data. The data is in a matrix where the first dimension 
        // is the channels and the second one the times samples.
        return [
            "packetIndex": packetIndex,
            "packet":[
                [P3Sample1, P3Sample2, P3Sample3, P3Sample4],
                [P4Sample1, P4Sample2, P4Sample3, P4Sample4]
            ]
        ]
    }
    
    /// Process the Device Information data
    /// - Parameter data : *Data* received from Device info MBT Headset.
    static func processDeviceInformations(_ data:Data) {
        let count = 8
        var bytesArray = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&bytesArray, length: count * MemoryLayout<UInt8>.size)
        
        print("device information \(bytesArray)")
        print("device information data \(data)")
    }
}
