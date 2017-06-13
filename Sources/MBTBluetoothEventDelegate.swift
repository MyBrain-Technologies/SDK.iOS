//
//  MBTBluetoothEventDelegate.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 11/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation

/// Event handler of the MBT Headset.
public protocol MBTBluetoothEventDelegate {
    /// Called when the headset has been connected
    /// before the services and characteristics exploration.
    func onConnectionEstablished()
    
    /// Called each time the BLE status change.
    /// With a *Bool* informing if headset is connected or not
    /// to the iDevice.
    /// - Parameter isConnected : *Bool* to know if BLE isConnected or not.
    func onBluetoothStatusUpdate(_ isConnected:Bool)
    
    /// Called to each EEG package sent by the BLE.
    /// - Parameter dataArray : *Dictionnary* of EEG data array.
    func onReceivingPackage(_ dataArray : [String: Any])
    
    /// Called when getting the battery level.
    /// - Parameter notification : *Notification* received.
    func onReceivingBatteryLevel(_ notification: Notification)
    
    /// Called if the SDK can't connect to the MBT Headset,
    /// with the error.
    /// - Parameter error : The cause of the failure ( Core Bluetooth error ).
    func onConnectionFailed(_ error: Error?)
    
    /// Called when the headset lost connection.
    /// - Parameter error : If failure, the cause of the failure ( Core Bluetooth error ).
    func onConnectionOff(_ error: Error?)
}
