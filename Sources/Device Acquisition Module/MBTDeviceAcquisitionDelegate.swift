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

    /// Called when getting the battery level.
    /// - Parameter battery level : *batteryLevel* received.
    @objc optional func onReceivingBatteryLevel(_ levelBattery:Int)
    
    
    /// Called when calling onReceivingBatteryLevel
    /// - returns : A *Bool* instance of onReceivingBatteryLevel if batteryLevel Change
    @objc optional func receiveBatteryLevelOnUpdate() -> Bool
    
}
