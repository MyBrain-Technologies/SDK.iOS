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
internal class MBTEEGAcquisitionManager: NSObject  {
    /// Mandatory 8 to switch from 24 bits to 32 bits + variable part which fits fw config.
    static let SHIFT_MELOMIND: Int32 = 8+4
    // Constantes to get EEG values from bluetooth.
    static let CHECK_SIGN_MELOMIND: Int32 = (0x80 << SHIFT_MELOMIND)
    static let NEGATIVE_MASK_MELOMIND: Int32 = (0xFFFFFF << (32 - SHIFT_MELOMIND))
    static let POSITIVE_MASK_MELOMIND: Int32 = (~NEGATIVE_MASK_MELOMIND)
    static var previousIndex : Int16 = 0xFF
    
    /// Singleton declaration
    static let shared = MBTEEGAcquisitionManager()
    
    /// Bool to know if developer wants to use QC or not.
    var shouldUseQualityChecker: Bool!
    
    /// The MBTBluetooth Event Delegate.
    var delegate: MBTEEGAcquisitionDelegate!
    
    
    /// Constant to decod EEG data
    let voltageADS1299:Float = ( 0.286 * pow(10, -6)) / 8
    
    /// Constant use to
    var streamEEGPacket = MBTEEGPacket.createNewEEGPacket(DeviceManager.getChannelsCount())

    
    ///
    var isRecording:Bool = false
    
    var timeIntervalPerf = Date().timeIntervalSince1970
    
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
    
    func saveRecordingOnFile(_ userId:Int? = nil, comments:[String] = [String]()) -> URL? {
        MBTJSONHelper.uuid = UUID()
        // Collect data for the JSON.
        if let device = DeviceManager.getCurrentDevice() { //EEGPacketManager.getEEGPackets().count > 0 
            if let jsonObject = self.getJSONRecord(device,recordInfo:MelomindEngine.recordInfo ?? MBTRecordInfo(), comments: comments) {
                // Save JSON with EEG data received.
                let fileURL = MBTJSONHelper.saveJSONOnDevice(jsonObject, with: {
                    // Then delete all MBTEEGPacket saved.
                    EEGPacketManager.removeAllEEGPackets()
                })
                return fileURL
            }
        }
        return nil
    }
  
    
  
    
    /// Method to manage a complete *MBTEEGPacket* From streamEEGPacket. Use *Quality Checker*
    /// on it if user asks for it, or just send it via the delegate.
    /// - Parameter eegPacket : A complete *MBTEEGPacket*.
    func manageCompleteStreamEEGPacket(_ datasArray:[[ChannelData]],device:MBTDevice) {
        
        let streamsEEGPacketsToSend = MBTEEGPacket.addValuesToEEGPacket(datasArray, lastPacket: streamEEGPacket,WithEEGPacketLength: device.eegPacketLength,WithNBChannnel: device.nbChannels)


        if let currentStreamEEGPacket = streamsEEGPacketsToSend.current {
            streamEEGPacket = currentStreamEEGPacket
        }
        
        if let packetComplete = streamsEEGPacketsToSend.complete {
            if  shouldUseQualityChecker {
                // Get caluclated qualities of the EEGPacket.
                // Add *qualities* in streamEEGPacket
                let qualities = MBTSignalProcessingManager.shared.computeQualityValue(packetComplete.channelsData,sampRate:device.sampRate )
                packetComplete.addQualities(qualities)
                // Get the EEG values modified by the *QC* according to the *Quality* values.
                let correctedValues = MBTSignalProcessingManager.shared.getModifiedEEGValues()
                packetComplete.addModifiedChannelsData(correctedValues)
            }
         
            
            // Send EEGPacket to the delegate.
            delegate.onReceivingPackage?(packetComplete)
            print("Timer Perf : \(Date().timeIntervalSince1970 - timeIntervalPerf)")
            timeIntervalPerf = Date().timeIntervalSince1970

            if isRecording {
                let _ = EEGPacketManager.saveEEGPacket(packetComplete)
            }
            
        }
        
    }
    
    /// Collecting the session datas and create the JSON.
    /// - Returns: The *JSON* created with the session datas.
    func getJSONRecord(_ device:MBTDevice, recordInfo:MBTRecordInfo, comments:[String] = [String]() ) -> JSON?  {
        guard let _ = device.deviceInfos else {
            return nil
        }
        
        let eegPackets = EEGPacketManager.getEEGPackets()

        var acquisitions: [String] = Array()
        for acquisition in device.acquisitionLocations {
            acquisitions.append("\(acquisition.type)")
        }
        
        
     
        // Create the session JSON.
        
        var jsonObject = JSON()
        jsonObject["uuidJsonFile"].stringValue = MBTJSONHelper.uuid.uuidString
        jsonObject["header"] = device.getJSON(comments)

        var jsonRecord = JSON()
        jsonRecord["recordID"].stringValue = recordInfo.recordId.uuidString
        jsonRecord["recordingType"] = recordInfo.recordingType.getJsonRecordInfo()
        jsonRecord["recordingTime"].intValue = eegPackets.first?.timestamp ?? 0
        jsonRecord["nbPackets"].intValue = eegPackets.count
        jsonRecord["firstPacketId"].intValue = eegPackets.first != nil ? eegPackets.index(of: eegPackets.first! )! : 0
        jsonRecord["qualities"] = EEGPacketManager.getJSONQualities()
        jsonRecord["channelData"] = EEGPacketManager.getJSONEEGDatas()
        jsonRecord["statusData"].arrayObject = [Any]()
        jsonRecord["recordingParameters"].arrayObject = [Any]()
        
        jsonObject["recording"] = jsonRecord
        
        return jsonObject
    }
    
    //MARK: - Process Received data Methods.
    
    /// Process the brain activty measurement received and return the processed data.
    /// - Parameters:
    ///     - data : *Data* received from MBT Headset EEGs.
    /// - Returns: *Dictionnary* with the packet Index (key : "packetIndex") and array of
    ///     P3 and P4 samples arrays ( key : "packet" )
    func processBrainActivityData(_ data: Data) {
        guard let device = DeviceManager.getCurrentDevice() else {
            return
        }
        
        if data.count == 0 {
            return
        }
        
        let count = 18
        var bytesArray = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&bytesArray, length: count * MemoryLayout<UInt8>.size)
        let currentIndex : Int16 = Int16(bytesArray[0] & 0xff) << 8 | Int16(bytesArray[1] & 0xff)
        
        print("CurrentIndex : \(currentIndex)")
        
        // Process the data.
        var values = [Float]()

        if MBTEEGAcquisitionManager.previousIndex == 0xFF {
            MBTEEGAcquisitionManager.previousIndex = currentIndex - 1
        }

        let diff = currentIndex - MBTEEGAcquisitionManager.previousIndex

        // Lost packets management.
        if diff != 1 {
            print("lost \(diff) packet(s)")
            for _ in 0 ..< diff {
                let packetLostArray = Array(arrayLiteral: ChannelData(data: nan("")),
                                            ChannelData(data: nan("")),
                                            ChannelData(data: nan("")),
                                            ChannelData(data: nan("")))
                let datasArray = [packetLostArray, packetLostArray]
                let dispatchWorkItem = DispatchWorkItem(qos: .background, flags: .detached) {
                    [weak self] in
                    self?.manageCompleteStreamEEGPacket(datasArray,device: device)
                }

                DispatchQueue.main.async(execute: dispatchWorkItem)

            }
        }

        for i in 0..<8 {
            var temp : Int32 = 0x00000000
            temp = (Int32(bytesArray[2 * i + 2] & 0xFF) << MBTEEGAcquisitionManager.SHIFT_MELOMIND) | Int32(bytesArray[2 * i + 3] & 0xFF) << (MBTEEGAcquisitionManager.SHIFT_MELOMIND - 8)

            if ((temp & MBTEEGAcquisitionManager.CHECK_SIGN_MELOMIND) > 0) { // value is negative
                temp = Int32(temp | MBTEEGAcquisitionManager.NEGATIVE_MASK_MELOMIND )
            }
            else{
                // value is positive
                temp = Int32(temp & MBTEEGAcquisitionManager.POSITIVE_MASK_MELOMIND)
            }
            values.append(Float(temp))
        }

        // Save the current index as previousIndex.
        MBTEEGAcquisitionManager.previousIndex = currentIndex

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

        let dispatchWorkItem = DispatchWorkItem(qos: .background, flags: .detached) {
            [weak self] in
            self?.manageCompleteStreamEEGPacket(datasArray,device: device)
        }

        DispatchQueue.main.async(execute: dispatchWorkItem)
    }
}

