//
//  MBTAcquisitionDelegate.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 27/06/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation

/// Manage the acquisition data communication outside the SDK.
@objc public protocol MBTDeviceAcquisitionDelegate {

    /// Called when receiving batteryLevel from BLE
    ///
    /// - Parameter battery level : *batteryLevel* received.
    @objc optional func onReceivingBatteryLevel(_ levelBattery:Int)
    
    
    /// Permit to set up the onReceivingBatteryLevel event when the batteryLevelChange or not
    ///
    /// Remarks : Default value is false
    /// - returns : A *Bool* instance of onReceivingBatteryLevel if batteryLevel Change
    @objc optional func receiveBatteryLevelOnUpdate() -> Bool
    
    /// Called when
    ///
    /// - Parameter status: A *Int* of the saturation headset
    /// - Remarks : 0 -> no saturation, 1 -> left side saturation, 2 -> right side Saturation, 3 -> both side Saturation
    @objc optional func onReceivingSaturationStatus(_ status:Int)
    
    
}
