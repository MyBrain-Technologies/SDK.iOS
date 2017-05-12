//
//  MBTBluetoothEventDelegate.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 11/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation


public protocol MBTBluetoothEventDelegate {
    /**
     * Called when the connection has been established.
     */
    func onBluetoothStatusUpdate(_ isConnected:Bool)
    
    func onReceivingPackage(_ notification: Notification)
    
    func onReceivingBatteryLevel(_ notification: Notification)
}
