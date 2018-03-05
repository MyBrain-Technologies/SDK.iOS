//
//  AcquisitionManager.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 23/06/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import CoreBluetooth

/// Manage Acquisition data from the MBT device connected.
/// Such as EEG, device info, battery level ...
internal class MBTAcquisitionManager: NSObject  {
    /// Mandatory 8 to switch from 24 bits to 32 bits + variable part which fits fw config.
    static let SHIFT_MELOMIND: Int32 = 8+4
    // Constantes to get EEG values from bluetooth.
    static let CHECK_SIGN_MELOMIND: Int32 = (0x80 << SHIFT_MELOMIND)
    static let NEGATIVE_MASK_MELOMIND: Int32 = (0xFFFFFF << (32 - SHIFT_MELOMIND))
    static let POSITIVE_MASK_MELOMIND: Int32 = (~NEGATIVE_MASK_MELOMIND)
    static var previousIndex : Int16 = 0xFF
    
    /// Singleton declaration
    static let shared = MBTAcquisitionManager()
    
    /// Bool to know if developer wants to use QC or not.
    var shouldUseQualityChecker: Bool!
    
    /// The MBTBluetooth Event Delegate.
    var delegate: MBTAcquisitionDelegate!
    
    /// The multiplicative constant.
    let const = 4.5 * 1000000 / (pow(2.0, 23.0) - 1) / 24
    
    /// Constant to decod EEG data
    let voltageADS1299:Float = ( 0.286 * pow(10, -6)) / 12
    
    //MARK: - Manage streaming datas methods.
    
    /// Method called by MelomindEngine when a new EEG streaming
    /// session has began. Method will make everything ready, acquisition side
    /// for the new session.
    func streamHasStarted(_ useQualityChecker:Bool) {
        shouldUseQualityChecker = useQualityChecker
        
        // Start mainQualityChecker.
        if shouldUseQualityChecker && DeviceManager.connectedDeviceName != nil {
            MBTSignalProcessingManager.shared.initializeQualityChecker()
        }
    }
    
    /// Method called by MelomindEngine when the current EEG streaming
    /// session has finished.
    func streamHasStopped() {
        // Dealloc mainQC.
        if shouldUseQualityChecker {
            MBTSignalProcessingManager.shared.deinitQualityChecker()
        }
    }
    
    func startRecording() {
        // Deleting the previous session JSON.
        //        MBTJSONHelper.deleteJSONFromDevice()
        
        // Add a new UUID for a new streaming session.
        MBTJSONHelper.uuid = UUID()
    }
    
    func stopRecording() {
        // Collect data for the JSON.
        if let device = DeviceManager.getCurrentDevice() {
            let jsonObject = self.getJSONRecord(device)
            
            // Save JSON with EEG data received.
            MBTJSONHelper.saveJSON(jsonObject) { fileURL in
                // Then delete all MBTEEGPacket saved.
                EEGPacketManager.removeAllEEGPackets()
                
                // Send JSON to BrainWeb.
                MBTBrainWebHelper.sendJSONToBrainWeb(fileURL)
            }
        }
    
    }
    
    /// Add *ChannelData* values to Realm DB. If a packet is complete,
    /// it'll be sent to the packet complete management method.
    /// - Parameter datasArray : *Array* of *ChannelData* by channel.
    func addValuesToEEGPacket(_ datasArray:[[ChannelData]]) {
        if let packetComplete = EEGPacketManager.addValuesToEEGPacket(datasArray) {
            self.manageCompleteEEGPacket(packetComplete)
        }
    }
    
    
    /// Method to manage a complete *MBTEEGPacket*. Use *Quality Checker*
    /// on it if user asks for it, or just send it via the delegate.
    /// - Parameter eegPacket : A complete *MBTEEGPacket*.
    func manageCompleteEEGPacket(_ eegPacket:MBTEEGPacket) {
        if shouldUseQualityChecker && DeviceManager.connectedDeviceName != nil {
            // Get caluclated qualities of the EEGPacket.
            let qualities = MBTSignalProcessingManager.shared.computeQualityValue(eegPacket.channelsData)
            // Add *qualities* and save it in Realm DB.
            EEGPacketManager.addQualities(qualities, to:eegPacket)
            // Get the EEG values modified by the *QC* according to the *Quality* values.
            let correctedValues = MBTSignalProcessingManager.shared.getModifiedEEGValues()
            EEGPacketManager.addModifiedChannelsData(eegPacket,
                                                     modifiedValues: correctedValues)
        }
        
        // Send EEGPacket to the delegate.
        delegate.onReceivingPackage?(eegPacket)
    }
    
    /// Collecting the session datas and create the JSON.
    /// - Returns: The *JSON* created with the session datas.
    func getJSONRecord(_ device:MBTDevice) -> [String: Any]  {
        let eegPackets = EEGPacketManager.getEEGPackets()

        var acquisitions: [String] = Array()
        for acquisition in device.acquisitionLocations {
            acquisitions.append("\(acquisition.type)")
        }
        
        // Get datas per channel.
        var eegDatas = [[Float]]()
        for eegPacket in eegPackets {
            for channelNumber in 0 ..< device.nbChannels {
                var arrayForOneChannel = [Float]()
                for packetIndex in 0 ..< device.eegPacketLength {
                    arrayForOneChannel.append(eegPacket.channelsData[channelNumber].value[packetIndex].value)
                }
                eegDatas.append(arrayForOneChannel)
            }
        }
        
        // Get the qualities per channel.
        var qualities = [Float]()
        for eegPacket in eegPackets {
            for channelNumber in 0 ..< device.nbChannels {
                qualities.append(eegPacket.qualities[channelNumber].value)
            }
        }
        // Create the session JSON.
        let jsonObject: [String: Any] = [
            "uuidJsonFile": MBTJSONHelper.uuid.uuidString,
            "header": [
                "deviceInfo": [
                    "productName": device.deviceInfos?.productName!,
                    "hardwareVersion": device.deviceInfos?.hardwareVersion!,
                    "firmwareVersion": device.deviceInfos?.firmwareVersion!,
                    "uniqueDeviceIdentifier": device.deviceInfos?.deviceId!
                ],
                "recordingNb": "0x14",
                "comments": [],
                "eegPacketLength": device.eegPacketLength,
                "sampRate": device.sampRate,
                "nbChannels": device.nbChannels,
                "acquisitionLocation": acquisitions,
                "referencesLocation": [
                    "\(device.referencesLocations.first!.type)"
                ],
                "groundsLocation": [
                    "\(device.groundsLocations.first!.type)"
                ]
            ],
            "recording": [
                "recordID": 123,
                "recordingType": [
                    "recordType": "RAWDATA",
                    "spVersion": "0.0.0",
                    "source": "DEFAULT",
                    "dataType": "DEFAULT"
                ],
                "recordingTime": eegPackets.first!.timestamp,
                "nbPackets": eegPackets.count,
                "firstPacketId": eegPackets.index(of: eegPackets.first!)!,
                "qualities": qualities,
                "channelData": eegDatas,
                "statusData": []
            ]
        ]
        
        return jsonObject
    }
    
    //MARK: - Process Received data Methods.
    
    /// Process the brain activty measurement received and return the processed data.
    /// - Parameters:
    ///     - data : *Data* received from MBT Headset EEGs.
    /// - Returns: *Dictionnary* with the packet Index (key : "packetIndex") and array of
    ///     P3 and P4 samples arrays ( key : "packet" )
    func processBrainActivityData(_ data: Data) {
        if data.count == 0 {
            return
        }
        
        let count = 18
        var bytesArray = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&bytesArray, length: count * MemoryLayout<UInt8>.size)
        let currentIndex : Int16 = Int16(bytesArray[0] & 0xff) << 8 | Int16(bytesArray[1] & 0xff)
        
        // Process the data.
        var values = [Float]()
        
        if MBTAcquisitionManager.previousIndex == 0xFF {
            MBTAcquisitionManager.previousIndex = currentIndex - 1
        }
    
        let diff = currentIndex - MBTAcquisitionManager.previousIndex
        
        // Lost packets management.
        if diff != 1 {
            print("lost \(diff) packet(s)")
            for _ in 0 ..< diff {
                let packetLostArray = Array(arrayLiteral: ChannelData(data: nan("")),
                                            ChannelData(data: nan("")),
                                            ChannelData(data: nan("")),
                                            ChannelData(data: nan("")))
                let datasArray = [packetLostArray, packetLostArray]
                self.addValuesToEEGPacket(datasArray)
            }
        }
        
        for i in 0..<8 {
            var temp : Int32 = 0x00000000
            temp = (Int32(bytesArray[2 * i + 2] & 0xFF) << MBTAcquisitionManager.SHIFT_MELOMIND) | Int32(bytesArray[2 * i + 3] & 0xFF) << (MBTAcquisitionManager.SHIFT_MELOMIND - 8)
            
            if ((temp & MBTAcquisitionManager.CHECK_SIGN_MELOMIND) > 0) { // value is negative
                temp = Int32(temp | MBTAcquisitionManager.NEGATIVE_MASK_MELOMIND )
            }
            else{
                // value is positive
                temp = Int32(temp & MBTAcquisitionManager.POSITIVE_MASK_MELOMIND)
            }
            values.append(Float(temp))
        }
        
        // Save the current index as previousIndex.
        MBTAcquisitionManager.previousIndex = currentIndex
        
        // Format eeg samples as ChannelData.
        let P3Sample1 = ChannelData(data: values[0] * voltageADS1299)
        let P4Sample1 = ChannelData(data: values[1] * voltageADS1299)
        let P3Sample2 = ChannelData(data: values[2] * voltageADS1299)
        let P4Sample2 = ChannelData(data: values[3] * voltageADS1299)
        let P3Sample3 = ChannelData(data: values[4] * voltageADS1299)
        let P4Sample3 = ChannelData(data: values[5] * voltageADS1299)
        let P3Sample4 = ChannelData(data: values[6] * voltageADS1299)
        let P4Sample4 = ChannelData(data: values[7] * voltageADS1299)
        
        // Saving EEG datas in the local DB.
        let P3DatasArray = Array(arrayLiteral: P3Sample1, P3Sample2, P3Sample3, P3Sample4)
        let P4DatasArray = Array(arrayLiteral: P4Sample1, P4Sample2, P4Sample3, P4Sample4)
        let datasArray = [P3DatasArray, P4DatasArray]
        // Add datas to the last uncomplete EEG Packet.
        self.addValuesToEEGPacket(datasArray)
    }
    
    
    /// Process the Device Information data
    /// - Parameter data : *Data* received from Device info MBT Headset.
    func processDeviceInformations(_ characteristic: CBCharacteristic) {
        let data = characteristic.value!
        let count = 8
        var bytesArray = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&bytesArray, length: count * MemoryLayout<UInt8>.size)
        
        guard let dataString = String(data: data, encoding: .ascii) else {
            return
        }
        
        // Init a MBTDevice instance with the connected headset
        let deviceInfos = MBTDeviceInformations()
        
        switch CBUUID(data: characteristic.uuid.data) {
        case MBTBluetoothLEHelper.productNameUUID:
            deviceInfos.productName = dataString
        case MBTBluetoothLEHelper.serialNumberUUID:
            deviceInfos.deviceId = dataString
        case MBTBluetoothLEHelper.hardwareRevisionUUID:
            deviceInfos.hardwareVersion = dataString
        case MBTBluetoothLEHelper.firmwareRevisionUUID:
            deviceInfos.firmwareVersion = dataString
        default:
            return
        }
        
        // Saving the new connected device in the DB.
        DeviceManager.updateDeviceInformations(deviceInfos)
    }
    
    
    func processDeviceBatteryStatus(_ characteristic: CBCharacteristic) {
        if characteristic.value != nil && DeviceManager.getCurrentDevice() != nil {
            let tabByte = [UInt8](characteristic.value!)
            if tabByte.count > 0 {
                let batteryLevel = Int(tabByte[0])
                if DeviceManager.getCurrentDevice()!.batteryLevel != batteryLevel || !(delegate.receiveBatteryLevelOnUpdate?() ?? false) {
                    DeviceManager.updateDeviceBatteryLevel(batteryLevel)
                    delegate.onReceivingBatteryLevel?(batteryLevel)
                }
            }
        }
    }
}

