//
//  MBTAcquisitionDelegate.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 27/06/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation

/// Manage the acquisition data communication outside the SDK.
@objc public protocol MBTAcquisitionDelegate {
    
    /// Called to each EEG package sent by the BLE.
    /// - Parameter dataArray : *Dictionnary* of EEG data array.
    @objc optional func onReceivingPackage(_ dataArray : [String: Any])
    
    /// Called when getting the battery level.
    /// - Parameter notification : *Notification* received.
    @objc optional func onReceivingBatteryLevel(_ notification: Notification)
    
    /// Called when getting Device Information.
    /// - Parameter data : *Data* received.
    @objc optional func onReceivingDeviceInformation(_ data: Data)
}
