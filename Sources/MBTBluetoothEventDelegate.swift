//
//  MBTBluetoothEventDelegate.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 11/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation

// Delegate Protocol to communicate with the MBT headset.
public protocol MBTBluetoothEventDelegate {
    // Called when the headset has been connected
    // before the services and characteristics exploration.
    func onConnectionEstablished()
    
    // Called each time the BLE status change.
    // With a Bool informing if headset is connected or not
    // to the iDevice.
    func onBluetoothStatusUpdate(_ isConnected:Bool)
    
    // Called to each EEG package sent by the BLE.
    func onReceivingPackage(_ dataArray : [String: Any])
    
    func onReceivingBatteryLevel(_ notification: Notification)
    
    // Called if the SDK can't connect to the MBT Headset,
    // with the error.
    func onConnectionFailed(_ error: Error?)
    
    // Called when the headset lost connection.
    func onConnectionOff(_ error: Error?)
}
