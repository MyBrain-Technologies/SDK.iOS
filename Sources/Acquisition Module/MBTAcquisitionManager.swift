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
    
    /// Singleton declaration
    static let shared = MBTAcquisitionManager()
    
    /// The MBTBluetooth Event Delegate.
    var delegate: MBTAcquisitionDelegate!
    
    /// The multiplicative constant.
    let const = 4.5 * 1000000 / (pow(2.0, 23.0) - 1) / 24
    
    /// Constant to decod EEG data
    let voltageADS1299:Float = ( 0.286 * pow(10, -6)) / 12
    
    //MARK: - Process Received data Methods.
    
    /// Process the brain activty measurement received and return the processed data.
    /// - Parameters:
    ///     - data : *Data* received from MBT Headset EEGs.
    /// - Returns: *Dictionnary* with the packet Index (key : "packetIndex") and array of
    ///     P3 and P4 samples arrays ( key : "packet" )
    func processBrainActivityData(_ data: Data) {
        // Get the bytes as unsigned shorts
        let count = 18
        var bytesArray = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&bytesArray, length: count * MemoryLayout<UInt8>.size)
        
        // Process the data.
        let packetIndex = Int(bytesArray[0]) << 8 | Int(bytesArray[1])
        var values = [Float]()
        for i in 0..<8 {
            let temp = Int(bytesArray[2 * i + 2]) << 8 | Int(bytesArray[2 * i + 3])
            var value = temp & Int(pow(2.0, 23.0) - 1)
            let sign = (temp & Int(pow(2.0, 23.0))) >> 23
            if sign == 0 {
                value -= Int(pow(2.0, 23.0))
            }
            values.append(Float(value))
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
        // Create the P3 channel data array.
        let P3Datas = ChannelDatas()
        for P3Sample in P3DatasArray {
            P3Datas.value.append(P3Sample)
        }
        // Create the P4 channel data array.
        let P4Datas = ChannelDatas()
        for P4Sample in P4DatasArray {
            P4Datas.value.append(P4Sample)
        }
        
        // Create a *MBTEEGPacket* entity.
        let eegPacket = MBTEEGPacket()
        eegPacket.channelsData.append(P3Datas)
        eegPacket.channelsData.append(P4Datas)
        eegPacket.packetIndex = packetIndex
        
        // Sending the EEG data to the delegate. The data is in a matrix where the first dimension
        // is the channels and the second one the times samples.
        delegate.onReceivingPackage?(eegPacket)
        
        // Save it in the Realm DB.
        EEGPacketManager.saveEEGPacket(eegPacket)
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
        let device = MBTDevice()
        
        switch CBUUID(data: characteristic.uuid.data) {
        case MBTBluetoothLEHelper.productNameUUID:
            device.productName = dataString
        case MBTBluetoothLEHelper.serialNumberUUID:
            device.deviceId = dataString
        case MBTBluetoothLEHelper.hardwareRevisionUUID:
            device.hardwareVersion = dataString
        case MBTBluetoothLEHelper.firmwareRevisionUUID:
            device.firmwareVersion = dataString 
        default:
            return
        }
        
        // Saving the new connected device in the DB.
        DeviceManager.updateConnectedDevice(device)
    }
    
    
    
    //MARK: -
    
    /// Method called by MelomindEngine when a new EEG streaming
    /// session has began. Method will make everything ready, acquisition side
    /// for the new session.
    func streamHasStarted() {
        // Add a new UUID for a new streaming session.
        MBTJSONHelper.uuid = UUID()
        
        // Deleting the previous session JSON.
//        MBTJSONHelper.deleteJSONFromDevice()
    }
    
    /// Method called by MelomindEngine when the current EEG streaming
    /// session has finished. Method will create and save on the iDevice
    /// the JSON.
    func streamHasStopped() {
        // Collect data for the JSON.
        let jsonObject = self.createJSON()
        
        // Save JSON with EEG data received.
        MBTJSONHelper.saveJSON(jsonObject) { fileURL in
            // Then delete all MBTEEGPacket saved.
            EEGPacketManager.removeAllEEGPackets()
            
            // Send JSON to BrainWeb.
            MBTBrainWebHelper.sendJSONToBrainWeb(fileURL)
        }
    }
    
    /// Collecting the session datas to create the JSON.
    func createJSON() -> [String: Any] {
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
            "uuidJsonFile": MBTJSONHelper.uuid,
            "header": [
                "deviceInfo": [
                    "productName": device.productName!,
                    "hardwareVersion": device.hardwareVersion!,
                    "firmwareVersion": device.firmwareVersion!,
                    "uniqueDeviceIdentifier": device.deviceId!
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
                "firstPacketId": eegPackets.first!.packetIndex,
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
}
