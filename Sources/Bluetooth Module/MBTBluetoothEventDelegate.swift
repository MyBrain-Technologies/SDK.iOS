//
//  MBTBluetoothEventDelegate.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 11/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation

/// Event handler of the MBT Headset.
@objc public protocol MBTBluetoothEventDelegate:class {
    /// Called when the headset has been connected
    /// before the services and characteristics exploration.
    @objc optional func onConnectionEstablished()
    
    /// Called each time the BLE status change.
    /// With a *Bool* informing if headset is connected or not
    /// to the iDevice.
    /// - Parameter isConnected : *Bool* to know if BLE isConnected or not.
    @objc optional func onBluetoothStatusUpdate(_ isConnected:Bool)
    
    /// Called if the SDK can't connect to the MBT Headset,
    /// with the error.
    /// - Parameter error : The cause of the failure (Core Bluetooth error).
    @objc optional func onConnectionFailed(_ error: Error?)
    
    /// Called when the headset lost connection.
    /// - Parameter error : If failure, the cause of the failure (Core Bluetooth error).
    @objc optional func onConnectionOff(_ error: Error?)
    
    
    /// Called when initiate timerUpdateBatteryLevel
    /// returns -> schedules timerUpdateBatteryLevel with this timeInterval
    @objc optional func timeIntervalOnReceiveBattery() -> TimeInterval
    
    @objc optional func onDeviceReady()
    
    @objc optional func onProgressUpdate(_ progress:Float)
    
    @objc optional func onOADComplete()
    
    /// Called When a OAD process fail
    ///
    /// - Parameter status: *Int* give status fail
    /// 0 : CurrentVersion > Latest Bin Version
    /// 1 : OTA_MODE_EVT FAIL (0)
    /// 2 : OTA_STATUS_EVT FAIL (0)
    /// 3 : After Melomind Reboot, Latest Bin Version > CurrentVersion
    @objc optional func onOADFail(_ status:Int)
}
