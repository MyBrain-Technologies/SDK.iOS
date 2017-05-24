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
    
    ////////////////////////
    //                    //
    //MARK: - Init Method //
    //                    //
    ////////////////////////
    public init() {
        manager = MBTBluetoothManager()
    }
    
    
    ///////////////////////////////////////////////////////
    //                                                   //
    //MARK: - Connect and Disconnect MBT Headset Methods //
    //                                                   //
    ///////////////////////////////////////////////////////
    public func connectToEEG(_ deviceName:String,
                          with eventDelegate: MBTBluetoothEventDelegate) {
        
        manager.connectTo(deviceName, with: eventDelegate, and: nil)
    }
    
    public func connectToEEGAndA2DP(_ deviceName:String,
                                    with eventDelegate: MBTBluetoothEventDelegate,
                                    and audioA2DPDelegate: MBTBluetoothA2DPDelegate) {
        manager.connectTo(deviceName, with: eventDelegate, and: audioA2DPDelegate)
    }
    
    public func disconnect() {
        manager.disconnect()
    }
}
