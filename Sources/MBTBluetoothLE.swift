//
//  MBTBluetoothLE.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 11/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import CoreBluetooth

struct MBTBluetoothLE {
    /**
     * The UIID of the MyBrainServices.
     */
    static let myBrainServiceUUID = CBUUID(string: "0xB2A0")
    
    /**
     * The UIID of the DeviceInformation service.
     */
    static let deviceInfoServiceUUID = CBUUID(string: "0x180A")
    
    /**
     * Getter of Bluetooth LE Services UUIDs.
     */
    static func getUUIDs() -> [CBUUID] {
        return [myBrainServiceUUID, deviceInfoServiceUUID]
    }
}
