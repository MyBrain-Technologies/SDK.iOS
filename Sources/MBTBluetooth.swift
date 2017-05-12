//
//  MBTBluetooth.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 09/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation

public class MBTBluetooth {
    
    internal var manager: MBTBluetoothManager
    internal var bluetoothLEData: MBTBluetoothLE
    internal var bluetoothA2DPData: MBTBluetoothA2DP
    
    public func connectTo(_ deviceName:String,
                          with eventDelegate: MBTBluetoothEventDelegate) {
        
        manager.connectTo(deviceName, eventDelegate: eventDelegate)
    }
    
    public func disconnect() {
        manager.disconnect()
    }
    
    public init() {
        manager = MBTBluetoothManager()
        bluetoothLEData = MBTBluetoothLE()
        bluetoothA2DPData = MBTBluetoothA2DP()
    }
}
