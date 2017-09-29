//
//  AcquisitionManager.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 23/06/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import CoreBluetooth

/// Manage Acquisition data MBT Headset part. Such as EEG,
/// device info, battery level ...
internal class MBTAcquisitionManager: NSObject  {
    
    static let SHIFT_MELOMIND: Int32 = 8+4 //mandatory 8 to switch from 24 bits to 32 bits + variable part which fits fw config
    static let CHECK_SIGN_MELOMIND: Int32 = (0x80 << SHIFT_MELOMIND)
    static let NEGATIVE_MASK_MELOMIND: Int32 = (0xFFFFFF << (32 - SHIFT_MELOMIND))
    static let POSITIVE_MASK_MELOMIND: Int32 = (~NEGATIVE_MASK_MELOMIND)
    static var previousIndex : Int16 = 0xFF
    
    /// Singleton declaration
    static let shared = MBTAcquisitionManager()
    
    /// Bool to know if developer wants to use QC or not.
    var shouldUseQualityChecker = true
    
    /// The MBTBluetooth Event Delegate.
    var delegate: MBTAcquisitionDelegate!
    
    /// The multiplicative constant.
    let const = 4.5 * 1000000 / (pow(2.0, 23.0) - 1) / 24
    
    /// Constant to decod EEG data
    let voltageADS1299:Float = ( 0.286 * pow(10, -6)) / 12
    
    //MARK: -
    
    /// Method called by MelomindEngine when a new EEG streaming
    /// session has began. Method will make everything ready, acquisition side
    /// for the new session.
    func streamHasStarted() {
        // Add a new UUID for a new streaming session.
        MBTJSONHelper.uuid = UUID()
        
        // Deleting the previous session JSON.
        //        MBTJSONHelper.deleteJSONFromDevice()
        
        // Start mainQualityChecker.
        if shouldUseQualityChecker {
            MBTSignalProcessingManager.shared.initializeQualityChecker()
        }
        
        // Register to packet Complete notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(packetComplete),
                                               name: Notification.Name("packetComplete"),
                                               object: nil)
    }
    
    /// Method called by MelomindEngine when the current EEG streaming
    /// session has finished. Method will create and save on the iDevice
    /// the JSON.
    func streamHasStopped() {
        // Collect data for the JSON.
        let jsonObject = self.collectSessionData()
        
        // Save JSON with EEG data received.
        MBTJSONHelper.saveJSON(jsonObject) { fileURL in
            // Then delete all MBTEEGPacket saved.
            EEGPacketManager.removeAllEEGPackets()
            
            // Send JSON to BrainWeb.
            MBTBrainWebHelper.sendJSONToBrainWeb(fileURL)
        }
        
        // Dealloc mainQC.
        if shouldUseQualityChecker {
            MBTSignalProcessingManager.shared.deinitQualityChecker()
        }
        
        // Unregister to packet Complete notification
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name("packetComplete"),
                                                  object: nil)
    }
    
    func packetComplete(_ notif:Notification) {
        let eegPacket = notif.object as! MBTEEGPacket
        
        // Get caluclated qualities of the EEGPacket.
        let qualities = MBTSignalProcessingManager.shared.computeQualityValue(eegPacket.channelsData)
        
        // Save it to Realm DB.
        EEGPacketManager.addQualities(qualities,to:eegPacket)
        
        // Update EEG data and add calculated qualities to the EEGPacket.
        //        if shouldUseQualityChecker {
        //
        //        }
        
        // Send EEGPacket to the delegate.
        delegate.onReceivingPackage?(eegPacket)
    }
    
    /// Collecting the session datas to create the JSON.
    func collectSessionData() -> [String: Any] {
        let eegPackets = EEGPacketManager.getEEGPackets()
        
        let device = DeviceManager.getCurrentDevice()
        var acquisitions: [String] = Array()
        for acquisition in device.acquisitionLocations {
            acquisitions.append("\(acquisition.type)")
        }
        
        // Get datas per channel.
        var channel1: [Float] = Array()
        var channel2: [Float] = Array()
        for eegPacket in eegPackets {
            for channelData in eegPacket.channelsData.first!.value {
                channel1.append(channelData.value)
            }
            
            for channelData in eegPacket.channelsData.last!.value {
                channel2.append(channelData.value)
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
                "recordingNB": "0x14",
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
                "qualities": [[],[]],
                "channelData": [
                    channel1,
                    channel2
                ],
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
        // Get the bytes as unsigned shorts

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
        
        if diff != 1 {
            print("lost \(diff) packet(s)")
            for _ in 0...diff {
                let packetLostArray = Array(arrayLiteral: ChannelData(data: nan("")), ChannelData(data: nan("")), ChannelData(data: nan("")), ChannelData(data: nan("")))
                let datasArray = [packetLostArray, packetLostArray]
                EEGPacketManager.addValueToEEGPacket(datasArray)
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
        
        EEGPacketManager.addValueToEEGPacket(datasArray)
        MBTAcquisitionManager.previousIndex = currentIndex
        //        // Create the P3 channel data array.
        //        let P3Datas = ChannelDatas()
        //        for P3Sample in P3DatasArray {
        //            P3Datas.value.append(P3Sample)
        //        }
        //        // Create the P4 channel data array.
        //        let P4Datas = ChannelDatas()
        //        for P4Sample in P4DatasArray {
        //            P4Datas.value.append(P4Sample)
        //        }
        //
        //        // Create a *MBTEEGPacket* entity.
        //        let eegPacket = MBTEEGPacket()
        //        eegPacket.channelsData.append(P3Datas)
        //        eegPacket.channelsData.append(P4Datas)
        //
        //        // Get caluclated qualities of the EEGPacket.
        //        let qualities = MBTSignalProcessingManager.shared.computeQualityValue(eegPacket.channelsData)
        //
        //        for qualityFloat in qualities {
        //            let quality = Quality(data:qualityFloat)
        //            eegPacket.qualities.append(quality)
        //        }
        //
        //        // Update EEG data and add calculated qualities to the EEGPacket.
        //        if shouldUseQualityChecker {
        //
        //        }
        //
        //        // Send EEGPacket to the delegate.
        //        delegate.onReceivingPackage?(eegPacket)
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
}

