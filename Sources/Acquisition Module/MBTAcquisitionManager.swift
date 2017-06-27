//
//  AcquisitionManager.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 23/06/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation

/// Manage Acquisition data MBT Headset part. Such as EEG,
/// device info, battery level ...
internal class MBTAcquisitionManager: NSObject  {
    
    /// The MBTBluetooth Event Delegate.
    var delegate: MBTAcquisitionDelegate!
    
    /// The multiplicative constant.
    let const = 4.5 * 1000000 / (pow(2.0, 23.0) - 1) / 24
    
    /// Constant to decod EEG data
    let voltageADS1299:Float = ( 0.286 * pow(10, -6)) / 12
    
    
    //MARK: - Process Received data Methods.
    
    /// Process the brain activty measurement received and return the processed data.
    /// - Parameters:
    ///     - data : *Data* received from MBT Headset EEGs.
    /// - Returns: *Dictionnary* with the packet Index (key : "packetIndex") and array of
    ///     P3 and P4 samples arrays ( key : "packet" )
    func processBrainActivityData(_ data: Data) {
        // Get the bytes as unsigned shorts
        let count = 18
        var bytesArray = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&bytesArray, length: count * MemoryLayout<UInt8>.size)
        
        // Process the data.
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
        
        
        // Sending the EEG data to the delegate. The data is in a matrix where the first dimension
        // is the channels and the second one the times samples.
        delegate.onReceivingPackage?([
            "packetIndex": packetIndex,
            "packet":[
                [P3Sample1, P3Sample2, P3Sample3, P3Sample4],
                [P4Sample1, P4Sample2, P4Sample3, P4Sample4]
            ]
        ])
    }
    
    
    /// Process the Device Information data
    /// - Parameter data : *Data* received from Device info MBT Headset.
    func processDeviceInformations(_ data:Data) {
        let count = 8
        var bytesArray = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&bytesArray, length: count * MemoryLayout<UInt8>.size)
        
        delegate.onReceivingDeviceInformation?(data)
    }
}
