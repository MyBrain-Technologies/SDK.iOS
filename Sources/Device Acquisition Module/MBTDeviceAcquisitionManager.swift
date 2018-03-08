//
//  AcquisitionManager.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 23/06/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import CoreBluetooth

/// Manage Acquisition data from the MBT device connected.
/// Such as EEG, device info, battery level ...
internal class MBTDeviceAcquisitionManager: NSObject  {
    /// Singleton declaration
    static let shared = MBTDeviceAcquisitionManager()
    
    /// The MBTBluetooth Event Delegate.
    var delegate: MBTDeviceAcquisitionDelegate!
    
    /// The multiplicative constant.

    
    /// Process the Device Information data
    /// - Parameter data : *Data* received from Device info MBT Headset.
    func processDeviceInformations(_ characteristic: CBCharacteristic) {
        let data = characteristic.value!
        let count = 8
        var bytesArray = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&bytesArray, length: count * MemoryLayout<UInt8>.size)
        
        guard let dataString = String(data: data, encoding: .ascii) else {
            return
        }
        
        // Init a MBTDevice instance with the connected headset
        let deviceInfos = MBTDeviceInformations()
        
        switch CBUUID(data: characteristic.uuid.data) {
        case MBTBluetoothLEHelper.productNameUUID:
            deviceInfos.productName = dataString
        case MBTBluetoothLEHelper.serialNumberUUID:
            deviceInfos.deviceId = dataString
        case MBTBluetoothLEHelper.hardwareRevisionUUID:
            deviceInfos.hardwareVersion = dataString
        case MBTBluetoothLEHelper.firmwareRevisionUUID:
            deviceInfos.firmwareVersion = dataString
        default:
            return
        }
        
        // Saving the new connected device in the DB.
        DeviceManager.updateDeviceInformations(deviceInfos)
    }
    
    
    func processDeviceBatteryStatus(_ characteristic: CBCharacteristic) {
        if characteristic.value != nil && DeviceManager.getCurrentDevice() != nil {
            let tabByte = [UInt8](characteristic.value!)
            if tabByte.count > 0 {
                let batteryLevel = Int(tabByte[0])
                if DeviceManager.getCurrentDevice()!.batteryLevel != batteryLevel || !(delegate.receiveBatteryLevelOnUpdate?() ?? false) {
                    DeviceManager.updateDeviceBatteryLevel(batteryLevel)
                    delegate.onReceivingBatteryLevel?(batteryLevel)
                }
            }
        }
    }
}

