//
//  MelomindEngine.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 09/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation

/// MBT engine to implement to work with the headset.
public class MelomindEngine {
    //MARK: - Variables
    /// Init a MBTBluetoothManager, which deals with
    /// the MBT headset bluetooth.
    internal static let bluetoothManager = MBTBluetoothManager.shared
    
    /// Init a MBTAcquisitionManager, which deals with
    /// data from the MBT Headset.
    internal static let acqusitionManager = MBTAcquisitionManager.shared
    
    
    //MARK: - Connect and Disconnect MBT Headset Methods

    /// Connect to bluetooth LE profile of the MBT headset.
    /// BLE deals with EEG, but also OAD, device information,
    /// battery, etc.
    /// - Parameters:
    ///     - delegate : The Melomind Engine Delegate which allow communication with the Headset.
    public static func connectEEG(withDelegate delegate: MelomindEngineDelegate) {
        bluetoothManager.connectTo("melomind", with: delegate, and: nil)
        
        // Add the Acquisition delegate to the Acquisition manager
        MelomindEngine.initAcquisitionManager(with: delegate)
    }
    
    /// Connect to the audio part of the MBT Headset (using the A2DP
    /// bluetooth protocol).
    /// - Remark: Audio can't be connect from code. User has to connect to it through
    /// settings, on the first time is using it.
    /// - Parameters:
    ///     - delegate : The Melomind Engine Delegate which allow communication with the Headset.
    public static func connectEEGAndA2DP(withDelegate delegate: MelomindEngineDelegate) {
        bluetoothManager.connectTo("melomind", with: delegate, and: delegate)
        
        // Add the Acquisition delegate to the Acquisition manager
        MelomindEngine.initAcquisitionManager(with: delegate)
    }
    
    /// Add delegate to Acquisition Manager
    /// - Parameters:
    ///     - delegate : The Melomind Engine Delegate to get Headset datas.
    internal static func initAcquisitionManager(with delegate: MelomindEngineDelegate) {
        if acqusitionManager.delegate == nil {
            acqusitionManager.delegate = delegate
        }
    }
    
    
    /// Disconnect the iDevice from the headset
    /// - Remark: The audio can't be disconnect from code.
    public static func disconnect() {
        bluetoothManager.disconnect()
    }
    
    
    //MARK: - Start / stop listening to EEG
    
    /// Start streaming EEG Data from MyBrainActivity Characteristic.
    /// - Remark: Data will be provided through the MelomineEngineDelegate.
    public static func startStream() {
        bluetoothManager.isListeningToEEG = true
    }
    
    /// Stop streaming EEG Data to MelomineEngineDelegate.
    public static func stropStream() {
        bluetoothManager.isListeningToEEG = false
    }
}
