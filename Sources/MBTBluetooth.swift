//
//  MBTBluetooth.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 09/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation

/// Manage the Bluetooth connection to the headset.
public class MBTBluetooth {
    //MARK: Variables
    /// Init a MBTBluetoothManager, which deals with
    /// the MBT headset bluetooth
    internal static var manager = MBTBluetoothManager()
    
    //MARK: - Connect and Disconnect MBT Headset Methods

    /// Connect to bluetooth LE profile of the MBT headset.
    /// BLE deals with EEG, but also OAD, device information,
    /// battery, etc.
    /// - Parameters:
    ///     - deviceName: The name of the device to connect to (Bluetooth profile).
    ///     - eventDelegate : The delegate which will handle Bluetooth events.
    public static func connectToEEG(_ deviceName:String,
                          with eventDelegate: MBTBluetoothEventDelegate) {
        
        manager.connectTo(deviceName, with: eventDelegate, and: nil)
    }
    
    /// Connect to the audio part of the MBT Headset (using the A2DP
    /// bluetooth protocol)
    /// - Remark: Audio can't be connect from code. User has to connect to it through
    /// settings, on the first time is using it.
    /// - Parameters:
    ///     - deviceName: The name of the device to connect to (Bluetooth profile).
    ///     - eventDelegate: The delegate which whill handle Bluetooth events.
    ///     - audioA2DPDelegate: The audio A2DP protocol delegate to monitor A2DP connection state. Can be nil.
    public static func connectToEEGAndA2DP(_ deviceName:String,
                                    with eventDelegate: MBTBluetoothEventDelegate,
                                    and audioA2DPDelegate: MBTBluetoothA2DPDelegate) {
        manager.connectTo(deviceName, with: eventDelegate, and: audioA2DPDelegate)
    }
    
    /// Disconnect the iDevice from the headset
    /// - Remark: The audio can't be disconnect from code.
    public static func disconnect() {
        manager.disconnect()
    }
    
    
    //MARK: - Start / stop listening to EEG
    
    /// Start readValue on MyBrainActivity Characteristic.
    /// - Remark: Data will be provided through the MBTBluetoothEventDelegate.
    public static func startListeningToEEG() {
        manager.isListeningToEEG = true
    }
    
    /// Stop readValue on MyBrainActivity Characteristic.
    public static func stopListeningToEEG() {
        manager.isListeningToEEG = false
    }
}
