//
//  MBTBluetoothA2DP.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 11/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import CoreBluetooth

struct MBTBluetoothA2DP {
    /**
     * The UIID of Audio Sink.
     */
    static let audioSingServiceUUID = CBUUID(string: "0x110B")
    
    /**
     * The UIID of the A/V Remote Control.
     */
    static let remoteControlServiceUUID = CBUUID(string: "0x110C")
    
    /**
     * Getter of Bluetooth A2DP Services UUIDs.
     */
    static func getUUIDs() -> [CBUUID] {
        return [audioSingServiceUUID, remoteControlServiceUUID]
    }

    static var uid: String! = nil
}


public protocol MBTBluetoothA2DPDelegate {
    func audioA2DPDidConnect()
    func audioA2DPDidDisconnect()
}
