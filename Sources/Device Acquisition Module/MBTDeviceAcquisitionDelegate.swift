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
    @objc optional func onReceivingBatteryLevel(_ batteryLevel:Int)
    
    
    /// Called when calling onReceivingBatteryLevel
    /// - returns -> The boolean which use to call onReceivingBatteryLevel if batteryLevel Change
    @objc optional func receiveBatteryLevelOnUpdate() -> Bool
    
}
