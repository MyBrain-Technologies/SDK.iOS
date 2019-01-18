//
//  MelomindEngine.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 09/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation

/// MBT engine to implement to work with the headset.
public class MBTClient {
    //MARK: - Variables
    /// Init a MBTBluetoothManager, which deals with
    /// the MBT headset bluetooth.
    internal let bluetoothManager:MBTBluetoothManager
    
    /// Init a MBTEEGAcquisitionManager, which deals with
    /// data from the MBT Headset.
    internal let eegAcqusitionManager:MBTEEGAcquisitionManager
    
    
    /// Init a MBTDeviceAcquisitionManager, which deals with
    /// data from the MBT Headset.
    internal let deviceAcqusitionManager:MBTDeviceAcquisitionManager
    
    /// Init a MBTSignalProcessingManager, which deals with
    /// the Signal Processing Library (via the bridge).
    internal let signalProcessingManager:MBTSignalProcessingManager
    
    internal var recordInfo:MBTRecordInfo = MBTRecordInfo()
    
    public static let main:MBTClient = MBTClient()
    
    public var isBluetoothOn:Bool {
        return bluetoothManager.tabHistoBluetoothState.last ?? false
    }
    
    public var isConnected:Bool {
        return bluetoothManager.isConnected
    }
    
    private init() {
        bluetoothManager = MBTBluetoothManager.shared
        if let deviceName = bluetoothManager.getDeviceNameA2DP(), !bluetoothManager.isConnected {
            bluetoothManager.connectTo(deviceName)
        }
        eegAcqusitionManager = MBTEEGAcquisitionManager.shared
        deviceAcqusitionManager = MBTDeviceAcquisitionManager.shared
        signalProcessingManager = MBTSignalProcessingManager.shared
    }
    
    //MARK: - Connect and Disconnect melomind Methods

    /// Connect to bluetooth LE profile of the MBT headset.
    /// BLE deals with EEG, but also OAD, device information,
    /// battery, etc.
    /// - Remark : deviceName is optional if deviceName isn't provided the MelomindEngine will connect to the first headset detected
    /// - Parameters:
    ///     - deviceName : The device Name Headset which be connect to the BLE
    ///     - delegate : The Melomind Engine Delegate which allow communication with the Headset.
    public func connectEEG(_ deviceName:String? = nil, withDelegate delegate: MelomindEngineDelegate) {
        setEEGDelegate(delegate)
        bluetoothManager.connectTo(deviceName)
    }
    
    /// Connect to the audio part of the MBT Headset (using the A2DP
    /// bluetooth protocol).
    /// - Remark: Audio can't be connected from code. User has to connect to it through
    /// - Remark : deviceName is optional if deviceName isn't provided the MelomindEngine will connect to the first headset detected
    /// settings, on the first time is using it.
    /// - Parameters:
    ///     - delegate : The Melomind Engine Delegate which allow communication with the Headset.
    public func connectEEGAndA2DP(_ deviceName:String? = nil ,withDelegate delegate: MelomindEngineDelegate) {
        setEEGAndA2DPDelegate(delegate)
        bluetoothManager.connectTo(deviceName)
    }
    
    /// Disconnect the iDevice from the headset
    /// - Remark: The audio can't be disconnect from code.
    public func cancelConnection() {
        bluetoothManager.disconnect()
    }
    
    //MARK: - Getters
    
    /// Get A2DP device Name
    ///
    /// - Returns: A *String* instance of A2DP device Name or nil if no melomind is connected (A2DP)
    public func getDeviceNameA2DP() -> String? {
       return bluetoothManager.getDeviceNameA2DP()
    }
    
    
    /// Get the latest battery level saved in DB
    ///
    /// - Returns: A *Int* instance of latest battery level saved in DB or nil if no melomind is connected (BLE)
    public func getBatteryLevel() -> Int? {
        return DeviceManager.getCurrentDevice()?.batteryLevel
    }
    
    /// Getter for device informations of the MBT headset.
    /// - Returns: A *MBTDeviceInformations* instance of the connected headset if no melomind is connected (BLE).
    public func getDeviceInformations() -> MBTDeviceInformations? {
        return DeviceManager.getDeviceInfos()
    }
    
    
    /// Getter for Device Name of the MBT headset
    ///
    /// - Returns: A *String* instance of the device's name, or nil if no instance yet
    public func getDeviceName() -> String? {
        return DeviceManager.connectedDeviceName
    }
    
//    /// Getter for the session JSON.
//    /// - Returns: A *Data* JSON, based on *kwak* scheme. Nil if JSON does not exist.
//    public func getSessionJSON() -> Data? {
//        return MBTJSONHelper.getSessionData()
//    }
//    
    /// Getter Names of all regitered devices
    /// - Returns: A *[String]* instance of array of deviceName
    public func getRegisteredDevices() -> [MBTDevice]{
        var tabDeviceName = [MBTDevice]()
        
        for device in DeviceManager.getRegisteredDevices() {
            tabDeviceName.append(device)
        }
        
        return tabDeviceName
    }
    
    //MARK: - JSON EEG
    
    /// Send JSON File
    public func sendEEGFile(_ urlFile:URL, baseUrl:String,removeFile:Bool, accessTokens:String) {
        MBTBrainWebHelper.accessTokens = accessTokens
        MBTBrainWebHelper.sendJSONToBrainWeb(urlFile, baseURL: baseUrl, completion: {
            (success)in
            if success && removeFile {
                let _ = MBTJSONHelper.removeFile(urlFile)
            }
        })
    }
    
    
    /// Save the DB recording on file    ///
    /// - Parameters:
    ///   - idUser: A *Int* instance of the id user
    ///   - comments: A *[String]* instance of comments
    ///   - completion : A *URL* instance of the saved file, or nil if file is not created and save
    public func saveRecordingOnFile(_ idUser:Int, comments:[String] = [String](), completion:@escaping (URL?)->()){
        self.eegAcqusitionManager.saveRecordingOnFile(idUser, comments: comments, completion: completion)
        
    }
    
    //MARK: - Setter
    
    /// Set delegate to EEGAcquistionManager, DeviceAcquisitionManager & BluetoothManager (event Delegate)
    ///
    /// - Parameter delegate:  new delegate listening Melomind Engine Delegate
    public func setEEGDelegate(_ delegate:MelomindEngineDelegate) {
        // Add the Acquisition delegate to the Acquisition manager
        initAcquisitionManager(with: delegate)
        
        // Add the BluetoothEventDelegate and A2DPDelegate
        bluetoothManager.eventDelegate = delegate
    }
    
    /// Set delegate to EEGAcquistionManager, DeviceAcquisitionManager & BluetoothManager (eventDelegate & audioA2DPDelegate)
    ///
    /// - Parameter delegate:  new delegate listening Melomind Engine Delegate
    public func setEEGAndA2DPDelegate(_ delegate:MelomindEngineDelegate) {
        // Add the Acquisition delegate to the Acquisition manager
        
        initAcquisitionManager(with: delegate)
        
        // Add the BluetoothEventDelegate and A2DPDelegate
        bluetoothManager.eventDelegate = delegate
        bluetoothManager.audioA2DPDelegate = delegate
    }
    
    //MARK: - BluetoothManager
    
    /// Ask to read BatteryStatus
    /// - Remark: Data will be provided through the MelomineEngineDelegate.
    public func readBatteryStatus() {
        if let _ = DeviceManager.connectedDeviceName {
            bluetoothManager.requestUpdateBatteryLevel()
        }
    }
    
    /// Stop the batteryLevel Event
    public func stopReceiveBatteryLevelEvent() {
        if let _ = DeviceManager.connectedDeviceName {
            bluetoothManager.stopTimerUpdateBatteryLevel()
        }
    }
    
    /// Start the batteryLevel Event
    public func startReceiveBatteryLevelEvent() {
        if let _ = DeviceManager.connectedDeviceName {
            bluetoothManager.startTimerUpdateBatteryLevel()
        }
    }
    
    //MARK: - Acquisition Manager
    
    /// Add delegate to Acquisition Manager.
    /// - Parameters:
    ///     - delegate : The Melomind Engine Delegate to get Headset datas.
    internal func initAcquisitionManager(with delegate: MelomindEngineDelegate) {
        eegAcqusitionManager.delegate = delegate
        deviceAcqusitionManager.delegate = delegate
    }
    
    /// Start saving EEGPacket on DB    /// - Parameters :
    ///     - newRecord : Create a new recordId on the JSON File
    ///     - recordingType : Change the session's type
    public func startRecording(_ newRecord:Bool, recordingType:MBTRecordingType = MBTRecordingType()) -> UUID? {
        EEGPacketManager.removeAllEEGPackets()
        if let _ = DeviceManager.connectedDeviceName {
            if newRecord {
                recordInfo = MBTRecordInfo()
                recordInfo.recordingType = recordingType
            } else {
                recordInfo.recordingType = recordingType
            }
            
            eegAcqusitionManager.isRecording = true
            
            return recordInfo.recordId
        }
        return nil
    }
    
    /// Stop saving EEGPacket on DB
    public func stopRecording() {
        if let _ = DeviceManager.connectedDeviceName {
            eegAcqusitionManager.isRecording = false
        }
    }
    
    /// Start streaming EEG Data from MyBrainActivity Characteristic.
    /// Start streaming headSet Data from HeadsetStatus Characteristic.
    /// - Remark: Data will be provided through the MelomineEngineDelegate.
    public func startStream(_ shouldUseQualityChecker: Bool) {
         eegAcqusitionManager.streamHasStarted(shouldUseQualityChecker)
        bluetoothManager.isListeningToEEG = true
        bluetoothManager.isListeningToHeadsetStatus = true
    }
    
    
    /// Stop streaming EEG Data to MelomineEngineDelegate.
    /// Stop streaming headSet Data from MelomindEngineDelegate.
    /// - Remark: a JSON will be created with all the MBTEEGPacket.
    public func stopStream() {
//        bluetoothManager.isListeningToHeadsetStatus = false
        bluetoothManager.isListeningToEEG = false
        eegAcqusitionManager.streamHasStopped()
    }
    
    /// Start the OAD process
    public func startOADTransfer() {
        self.bluetoothManager.startOAD()
    }
    
    public func testOADTransfer() {
        bluetoothManager.startTestOAD()
    }
    
    /// To know if a new headset firmware version is available
    /// Asynchrone fonction call a block completion with an boolean argument
    /// - Parameter completion: block completion call after getting melomind info with boolean argument
    public func isMelomindNeedToBeUpdate() -> Bool? {
        return bluetoothManager.isMelomindNeedToBeUpdate()
    }
    
    //MARK: - Upload
    
    /// Remove a specific Device    
    /// parameters :
    ///     - deviceName : The Device name which will be remove from DB
    public func removeDevice(_ deviceName:String) -> Bool {
        return DeviceManager.removeDevice(deviceName)
    }

    //MARK: - Signal Processing Manager
    
    /// Compute calibration with the last 'n' complete packets.
    /// - Parameters:
    ///     - n : Number of complete packets to take to compute the calibration.
    /// - Returns: A dictionnary received by the Signal Processing library.
    public func computeCalibration(_ n:Int) -> [String:[Float]]? {
        if let _ = DeviceManager.connectedDeviceName, EEGPacketManager.getEEGPackets().count >= n {
            return signalProcessingManager.computeCalibration(n)
        }
        return nil
    }

    
    /// computeRelaxIndex
    ///
    /// - Returns: RelaxIndex
    public func computeRelaxIndex() -> Float? {
        if let _ = DeviceManager.connectedDeviceName, EEGPacketManager.getEEGPackets().count > 3 {
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
    public func computeSessionStatistics(_ inputSNR:[Float], threshold:Float) -> [String:Float] {
        
        if let _ = DeviceManager.connectedDeviceName, inputSNR.count > 3 {
            return signalProcessingManager.analyseSession(inputSNR, threshold: threshold)
        }
        
        return [String:Float]()
    }
}
