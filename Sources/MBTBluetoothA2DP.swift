//
//  MBTBluetoothA2DP.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 11/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import CoreBluetooth


// A2DPDelegate declaration
public protocol MBTBluetoothA2DPDelegate {
    func audioA2DPDidConnect()
    func audioA2DPDidDisconnect()
}


// Specifics methods and variables to help MBTBluetoothManager
// to manage Bluetooth A2DP ( audio ).
struct MBTBluetoothA2DP {
    // The UUID of Audio Sink.
    static let audioSingServiceUUID = CBUUID(string: "0x110B")
    
    // The UIID of the A/V Remote Control.
    static let remoteControlServiceUUID = CBUUID(string: "0x110C")
    
    // Getter of Bluetooth A2DP Services UUIDs.
    static func getUUIDs() -> [CBUUID] {
        return [audioSingServiceUUID, remoteControlServiceUUID]
    }
    
    // Specific MBT Headset A2DP UID
    static var uid: String! = nil
}
