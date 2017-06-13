//
//  MBTBluetoothA2DP.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 11/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import CoreBluetooth


/// Delegate to know if audio A2DP just connected or disconnected.
public protocol MBTBluetoothA2DPDelegate {
    /// Called when the MBT Headset audio A2DP get connected.
    func audioA2DPDidConnect()
    /// Called when the MBT Headset audio A2DP lost connection.
    func audioA2DPDidDisconnect()
}


/// Help MBTBluetoothManager to manage Bluetooth A2DP ( audio ).
struct MBTBluetoothA2DP {
    /// The *UUID* of Audio Sink.
    static let audioSingServiceUUID = CBUUID(string: "0x110B")
    
    /// The *UIID* of the A/V Remote Control.
    static let remoteControlServiceUUID = CBUUID(string: "0x110C")
    
    /// Specific MBT Headset A2DP UID
    static var uid: String! = nil
}
