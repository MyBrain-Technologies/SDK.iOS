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
    
    public func connectTo(_ deviceName:String,
                          with eventDelegate: MBTBluetoothEventDelegate,
                          and shouldConnectToAudio: Bool) {
        var servicesUUID = MBTBluetoothLE.getUUIDs()
        
        if shouldConnectToAudio {
            servicesUUID += MBTBluetoothA2DP.getUUIDs()
        }
        
        manager.connectTo(deviceName,
                          with: eventDelegate,
                          and: servicesUUID)
    }
    
    public func connectToEEG(_ deviceName:String,
                          with eventDelegate: MBTBluetoothEventDelegate) {
        
        self.connectTo(deviceName, with: eventDelegate, and: false)
    }
    
    public func connectToA2DPAndEEG(_ deviceName:String,
                                    with eventDelegate: MBTBluetoothEventDelegate) {
        self.connectTo(deviceName, with: eventDelegate, and: true)
    }
    
    public func disconnect() {
        manager.disconnect()
    }
    
    public init() {
        manager = MBTBluetoothManager()
    }
}
