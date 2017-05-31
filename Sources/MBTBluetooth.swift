//
//  MBTBluetooth.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 09/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation

// Public class to manage the headset.
public class MBTBluetooth {
    
    // Init a MBTBluetoothManager, which deals with
    // the MBT headset bluetooth
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
    
    
    // Method to connect to bluetooth LE profile of the
    // MBT headset. BLE deals with EEG, but also OAD,
    // device information, battery, etc. ( all that is not audio )
    public func connectToEEG(_ deviceName:String,
                          with eventDelegate: MBTBluetoothEventDelegate) {
        
        manager.connectTo(deviceName, with: eventDelegate, and: nil)
    }
    
    // Method to connect to the audio part of the MBT Headset ( using the A2DP
    // bluetooth protocol )
    // NB: audio can't be connect from code. User has to connect to it through
    // settings, on the first time is using it.
    public func connectToEEGAndA2DP(_ deviceName:String,
                                    with eventDelegate: MBTBluetoothEventDelegate,
                                    and audioA2DPDelegate: MBTBluetoothA2DPDelegate) {
        manager.connectTo(deviceName, with: eventDelegate, and: audioA2DPDelegate)
    }
    
    // Disconnect the iDevice from the headset
    // NB: the audio can't be disconnect from code
    public func disconnect() {
        manager.disconnect()
    }
    
    
    ///////////////////////////////////////////////////////
    //                                                   //
    //MARK: - Start / stop listening to EEG              //
    //                                                   //
    ///////////////////////////////////////////////////////
    
    // Methods to launch/stop readValue on MyBrainActivity Characteristic
    // NB:  data will be provided through the MBTBluetoothEventDelegate.
    public func startListeningToEEG() {
        manager.isListeningToEEG = true
    }
    
    public func stopListeningToEEG() {
        manager.isListeningToEEG = false
    }
}
