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
    
    /// Init a MBTEEGAcquisitionManager, which deals with
    /// data from the MBT Headset.
    internal static let eegAcqusitionManager = MBTEEGAcquisitionManager.shared
    
    
    /// Init a MBTDeviceAcquisitionManager, which deals with
    /// data from the MBT Headset.
    internal static let deviceAcqusitionManager = MBTDeviceAcquisitionManager.shared
    
    /// Init a MBTSignalProcessingManager, which deals with
    /// the Signal Processing Library (via the bridge).
    internal static let signalProcessingManager = MBTSignalProcessingManager.shared
    
    internal static var recordInfo:MBTRecordInfo?
    
    
    
    
    
    //MARK: - Connect and Disconnect MBT Headset Methods

    /// Connect to bluetooth LE profile of the MBT headset.
    /// BLE deals with EEG, but also OAD, device information,
    /// battery, etc.
    /// - Remark : deviceName is optional if deviceName isn't provided the MelomindEngine will connect to the first headset detected
    /// - Parameters:
    ///     - deviceName : The device Name Headset which be connect to the BLE
    ///     - delegate : The Melomind Engine Delegate which allow communication with the Headset.
    public static func connectEEG(_ deviceName:String? = nil, withDelegate delegate: MelomindEngineDelegate) {
       bluetoothManager.connectTo(deviceName, with: delegate, and: nil)
        
        // Add the Acquisition delegate to the Acquisition manager
        MelomindEngine.initAcquisitionManager(with: delegate)
        
        
    }
    
    /// Connect to the audio part of the MBT Headset (using the A2DP
    /// bluetooth protocol).
    /// - Remark: Audio can't be connected from code. User has to connect to it through
    /// - Remark : deviceName is optional if deviceName isn't provided the MelomindEngine will connect to the first headset detected
    /// settings, on the first time is using it.
    /// - Parameters:
    ///     - delegate : The Melomind Engine Delegate which allow communication with the Headset.
    public static func connectEEGAndA2DP(_ deviceName:String? = nil ,withDelegate delegate: MelomindEngineDelegate) {
        bluetoothManager.connectTo(deviceName, with: delegate, and: delegate)
        
        // Add the Acquisition delegate to the Acquisition manager
        MelomindEngine.initAcquisitionManager(with: delegate)
    }
    
    /// Disconnect the iDevice from the headset
    /// - Remark: The audio can't be disconnect from code.
    public static func disconnect() {
        bluetoothManager.disconnect()
    }
    
    /// Send JSON File
    public static func sendEEGFile(_ urlFile:URL, accessTokens:String) {
        MBTBrainWebHelper.accessTokens = accessTokens
        MBTBrainWebHelper.sendJSONToBrainWeb(urlFile, completion: {(finished)in})
    }
    
    /// Save the DB recording on file
    /// returns : A *URL* instance of the saved file, or nil if file is not created and save
    public static func saveRecordingOnFile() -> URL? {
        return eegAcqusitionManager.saveRecordingOnFile()
    }
    
    //MARK: - Getters
    
    /// Getter for device informations of the MBT headset.
    /// - Returns: A *MBTDeviceInformations* instance of the connected headset, or nil if no instance yet.
    public static func getDeviceInformations() -> MBTDeviceInformations? {
        return DeviceManager.getDeviceInfos()
    }
    
    /// Getter for Device Name of the MBT headset
    ///
    /// - Returns: A *String* instance of the device's name, or nil if no instance yet
    public static func getDeviceName() -> String? {
        return DeviceManager.connectedDeviceName
    }
    
    /// Getter for the session JSON.
    /// - Returns: A *Data* JSON, based on *kwak* scheme. Nil if JSON does not exist.
    public static func getSessionJSON() -> Data? {
        return MBTJSONHelper.getSessionData()
    }
    
    /// Getter Names of all regitered devices
    /// - Returns: A *[String]* instance of array of deviceName
    public static func getRegisteredDevices() -> [String]{
        var tabDeviceName = [String]()
        
        for device in DeviceManager.getRegisteredDevices() {
            tabDeviceName.append(device.deviceName)
        }
        
        return tabDeviceName
    }
    
    //MARK: - BluetoothManager
    
    /// Ask to read BatteryStatus
    /// - Remark: Data will be provided through the MelomineEngineDelegate.
    public static func readBatteryStatus() {
        if let _ = DeviceManager.connectedDeviceName {
            bluetoothManager.requestUpdateBatteryLevel()
        }
    }
    
    /// Stop the batteryLevel Event
    public static func stopReceiveBatteryLevelEvent() {
        if let _ = DeviceManager.connectedDeviceName {
            bluetoothManager.stopTimerUpdateBatteryLevel()
        }
    }
    
    /// Start the batteryLevel Event
    public static func startReceiveBatteryLevelEvent() {
        if let _ = DeviceManager.connectedDeviceName {
            bluetoothManager.startTimerUpdateBatteryLevel()
        }
    }
    
    //MARK: - Acquisition Manager
    
    /// Add delegate to Acquisition Manager.
    /// - Parameters:
    ///     - delegate : The Melomind Engine Delegate to get Headset datas.
    internal static func initAcquisitionManager(with delegate: MelomindEngineDelegate) {
        if eegAcqusitionManager.delegate == nil {
            eegAcqusitionManager.delegate = delegate
        }
        if deviceAcqusitionManager.delegate == nil {
            deviceAcqusitionManager.delegate = delegate
        }
    }
    
    /// Start saving EEGPacket on DB    /// - Parameters :
    ///     - newRecord : Create a new recordId on the JSON File
    ///     - recordingType : Change the session's type
    public static func startRecording(_ newRecord:Bool, recordingType:MBTRecordingType = MBTRecordingType()) {
        if let _ = DeviceManager.connectedDeviceName {
            if newRecord {
                recordInfo = MBTRecordInfo()
                recordInfo?.recordingType = recordingType
            } else if let currentId = recordInfo?.recordId {
                recordInfo = MBTRecordInfo(currentId,recordingType:recordingType)
            }
            
            eegAcqusitionManager.isRecording = true
        }
    }
    
    /// Stop saving EEGPacket on DB
    public static func stopRecording() {
        if let _ = DeviceManager.connectedDeviceName {
            eegAcqusitionManager.isRecording = false
        }
    }
    
    /// Start streaming EEG Data from MyBrainActivity Characteristic.
    /// Start streaming headSet Data from HeadsetStatus Characteristic.
    /// - Remark: Data will be provided through the MelomineEngineDelegate.
    public static func startStream(_ shouldUseQualityChecker: Bool) {
        eegAcqusitionManager.streamHasStarted(shouldUseQualityChecker)
        bluetoothManager.isListeningToEEG = true
        bluetoothManager.isListeningToHeadsetStatus = true

    }
    
    
    /// Stop streaming EEG Data to MelomineEngineDelegate.
    /// Stop streaming headSet Data from MelomindEngineDelegate.
    /// - Remark: a JSON will be created with all the MBTEEGPacket.
    public static func stopStream() {
        bluetoothManager.isListeningToHeadsetStatus = false
        bluetoothManager.isListeningToEEG = false
        eegAcqusitionManager.streamHasStopped()
    }
    
    //MARK: - Upload
    
    /// Remove a specific Device
    /// parameters :
    ///     - deviceName : The Device name which will be remove from DB
    public static func removeDevice(_ deviceName:String) -> Bool {
        return DeviceManager.removeDevice(deviceName)
    }
    


    //MARK: - Signal Processing Manager
    
    /// Compute calibration with the last 'n' complete packets.
    /// - Parameters:
    ///     - n : Number of complete packets to take to compute the calibration.
    /// - Returns: A dictionnary received by the Signal Processing library.
    public static func computeCalibration(_ n:Int) -> [String:[Float]]? {
        if let _ = DeviceManager.connectedDeviceName {
            return signalProcessingManager.computeCalibration(n)
        }
        return nil
    }

    
    /// computeRelaxIndex
    ///
    /// - Returns: RelaxIndex
    public static func computeRelaxIndex() -> Float? {
        if let _ = DeviceManager.connectedDeviceName {
            return signalProcessingManager.computeRelaxIndex()
        }
        return nil
    }
    
    /// ComputeSessionStatistics
    ///
    /// - Parameters:
    ///   - inputSNR:
    ///   - threshold:
    /// - Returns:
    public static func computeSessionStatistics(_ inputSNR:[Float], threshold:Float) -> [String:Float] {
        return signalProcessingManager.analyseSession(inputSNR, threshold: threshold)
    }
}
