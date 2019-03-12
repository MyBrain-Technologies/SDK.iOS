
//
//  AcquisitionManager.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 23/06/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import CoreBluetooth
import RealmSwift

/// Manage Acquisition data from the MBT device connected.
/// Such as EEG, device info, battery level ...
internal class MBTEEGAcquisitionManager: NSObject  {
    
    
    /// Mandatory 8 to switch from 24 bits to 32 bits + variable part which fits fw config.
    static let SHIFT_MELOMIND: Int32 = 8+4
    
    // Constantes to get EEG values from bluetooth.
    static let CHECK_SIGN_MELOMIND: Int32 = (0x80 << SHIFT_MELOMIND)
    static let NEGATIVE_MASK_MELOMIND: Int32 = (0xFFFFFFF << (32 - SHIFT_MELOMIND))
    static let POSITIVE_MASK_MELOMIND: Int32 = (~NEGATIVE_MASK_MELOMIND)
    static let divider = 2
    
    /// Constant to decod EEG data
    let voltageADS1299:Float = ( 0.286 * pow(10, -6)) / 8
    
    /// Singleton declaration
    static let shared = MBTEEGAcquisitionManager()
    
    /// The MBTBluetooth Event Delegate.
    weak var delegate: MBTEEGAcquisitionDelegate?
    
    /// Bool to know if developer wants to use QC or not.
    var shouldUseQualityChecker: Bool?
    
    /// Previous Index Data Blutooth
    var previousIndex : Int16 = -1
    
    /// Buffer Data Byte
    var buffByte = [UInt8]()

    /// if the sdk record in DB EEGPacket
    var isRecording:Bool = false
    
    var eegPacketLength = 0
    
    var nbChannels = 0
    
    var sampRate = 0
    
    /// Test Variable
    var timeIntervalPerf = Date().timeIntervalSince1970
    
    
    /// Set up the EEGAcquisitionManager
    ///
    /// - Parameter device: A *MBTDevice* of the connected Melomind
    func setUpWith(device:MBTDevice) {
        eegPacketLength = device.eegPacketLength
        nbChannels = device.nbChannels
        sampRate = device.sampRate
    }
    
    //MARK: - Manage streaming datas methods.
    
    /// Method called by MelomindEngine when a new EEG streaming
    /// session has began. Method will make everything ready, acquisition side
    /// for the new session.
    func streamHasStarted(_ useQualityChecker:Bool) {
        // Start mainQualityChecker.
        if useQualityChecker {
            shouldUseQualityChecker = MBTSignalProcessingManager.shared.initializeQualityChecker()
        }
    }
    
    /// Method called by MelomindEngine when the current EEG streaming
    /// session has finished.
    func streamHasStopped() {
        // Dealloc mainQC.
        if let shouldUseQualityChecker = shouldUseQualityChecker, shouldUseQualityChecker {
            self.shouldUseQualityChecker = false
            MBTSignalProcessingManager.shared.deinitQualityChecker()
        }
    }
    
    /// Save the EEGPackets recorded
    ///
    /// - Parameters:
    ///   - idUser: A *Int* id of the connected user
    ///   - comments: An array of *String* contains Optional Comments
    ///   - completion: A block which execute after create the file or fail to create
    func saveRecordingOnFile(_ idUser:Int, comments:[String] = [String](), completion: @escaping (URL?) ->()) {
        guard let device = DeviceManager.getCurrentDevice() else {
            completion(nil)
            return
        }
        
        let deviceTSR = ThreadSafeReference(to: device)
        let packetToRemove = EEGPacketManager.getArrayEEGPackets()
        var packetsToSaveTSR = [ThreadSafeReference<MBTEEGPacket>]()
        let currentRecordInfo = MBTRecordInfo.init(MBTClient.main.recordInfo.recordId, recordingType: MBTClient.main.recordInfo.recordingType)
        prettyPrint(log.ln(" saveRecordingOnFile - \(currentRecordInfo)"))

        for eegPacket in packetToRemove {
            packetsToSaveTSR.append(ThreadSafeReference(to: eegPacket))
        }
    
            // Collect data for the JSON.
        ///let allPackets = EEGPacketManager.getEEGPackets()
        
//        let config = EEGPacketManager.
        
        DispatchQueue(label: "MelomindSaveProcess").async {
            let config = MBTRealmEntityManager.RealmManager.shared.config
            
            if let realm = try? Realm(configuration:config) {
                var resPacketsToSave = [MBTEEGPacket]()
                
                for eegPacket in packetsToSaveTSR {
                    if let resEEGPacket = realm.resolve(eegPacket) {
                        resPacketsToSave.append(resEEGPacket)
                    }
                }
                
                if let resDevice = realm.resolve(deviceTSR), resPacketsToSave.count == packetsToSaveTSR.count {
                    let jsonObject = self.getJSONRecord(resDevice,idUser: idUser ,eegPackets: resPacketsToSave,recordInfo:currentRecordInfo, comments: comments)
                    // Save JSON with EEG data received.
                    let fileURL = MBTJSONHelper.saveJSONOnDevice(jsonObject, idDevice: resDevice.deviceInfos!.deviceId!, idUser: idUser, with: {
                        // Then delete all MBTEEGPacket saved.
                        DispatchQueue.main.async {
                            EEGPacketManager.removePackets(packetToRemove)
                        }
                        
                    })
                    DispatchQueue.main.async {
                        completion(fileURL)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
  
    
  
    
    /// Method to manage a complete *MBTEEGPacket* From streamEEGPacket. Use *Quality Checker*
    /// on it if user asks for it, or just send it via the delegate.
    /// - Parameter eegPacket : A complete *MBTEEGPacket*.
    func manageCompleteStreamEEGPacket(_ datasArray:[[Float]]) {
        
        let packetComplete = MBTEEGPacket.createNewEEGPacket(arrayData: datasArray, nbChannels: nbChannels)
        
        if  let shouldUseQualityChecker = shouldUseQualityChecker, shouldUseQualityChecker {
            // Get caluclated qualities of the EEGPacket.
            // Add *qualities* in streamEEGPacket
            let qualities = MBTSignalProcessingManager.shared.computeQualityValue(packetComplete.channelsData,sampRate:self.sampRate, eegPacketLength: eegPacketLength)
            packetComplete.addQualities(qualities)
            
            // Get the EEG values modified by the *QC* according to the *Quality* values.
            let correctedValues = MBTSignalProcessingManager.shared.getModifiedEEGValues()
            packetComplete.addModifiedChannelsData(correctedValues,nbChannels: self.nbChannels,sampRate: self.sampRate)
            //            print("#57685 - FinishaddModifiedChannelsData ")
           
            
        }
        
        self.delegate?.onReceivingPackage?(packetComplete)
        prettyPrint(log.ln("manageCompleteStreamEEGPacket - Timer Perf : \(Date().timeIntervalSince1970 - self.timeIntervalPerf)"))
        self.timeIntervalPerf = Date().timeIntervalSince1970
        
        if self.isRecording {
            EEGPacketManager.saveEEGPacket(packetComplete)
        }
        
        
    }
    
    
    /// Create the EEG JSON
    ///
    /// - Parameters:
    ///   - device: A *MBTDevice* of the connected Melomind
    ///   - idUser: A *Int* id of the connected user
    ///   - eegPackets: An array of *MBTEEGPacket* of the relaxIndexes
    ///   - recordInfo: A *MBTRecordInfo* of the session metadata
    ///   - comments: An array of *String* contains Optional Comments
    /// - Returns: return an instance of *JSON*
    func getJSONRecord(_ device:MBTDevice,idUser:Int, eegPackets:[MBTEEGPacket],recordInfo:MBTRecordInfo, comments:[String] = [String]()) -> JSON  {
     
        // Create the session JSON.
        var jsonObject = JSON()
        jsonObject["uuidJsonFile"].stringValue = UUID().uuidString
        jsonObject["header"] = device.getJSON(comments)
        
        var jsonContext = JSON()
        jsonContext["ownerId"].intValue = idUser
        jsonContext["riAlgo"].stringValue = MBTSignalProcessingManager.shared.relaxIndexAlgorithm.rawValue
        jsonObject["context"] = jsonContext
        

        var jsonRecord = JSON()
        jsonRecord["recordID"].stringValue = recordInfo.recordId.uuidString
        jsonRecord["recordingType"] = recordInfo.recordingType.getJsonRecordInfo()
        jsonRecord["recordingTime"].intValue = eegPackets.first?.timestamp ?? 0
        jsonRecord["nbPackets"].intValue = eegPackets.count
        jsonRecord["firstPacketId"].intValue = eegPackets.first != nil ? eegPackets.index(of: eegPackets.first! )! : 0
        jsonRecord["qualities"] = EEGPacketManager.getJSONQualities(eegPackets)
        jsonRecord["channelData"] = EEGPacketManager.getJSONEEGDatas(eegPackets)
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
        
        if data.count == 0 {
            return
        }
        
        let count = data.count
        var bytesArray = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&bytesArray, length: count * MemoryLayout<UInt8>.size)
        let currentIndex : Int16 = Int16(bytesArray[0] & 0xff) << 8 | Int16(bytesArray[1] & 0xff)
        
        if currentIndex == 0 {
            previousIndex = 0
        }
        
        if previousIndex == -1 {
            previousIndex = currentIndex - 1
        }
        
        if previousIndex >= 32767 {
            previousIndex = 0
        }
        
        
        let diff:Int32 = (Int32(currentIndex - previousIndex))

        if diff != 1 {
            prettyPrint(log.ln("#processBrainActivityData - diff is \(diff)"))
        }
//        print("#57685 - CurrentIndex : \(currentIndex)")
        
        // Lost packets management.
        if diff != 1 && diff > 0 {
            prettyPrint(log.ln("#processBrainActivityData - lost \(diff) packet(s)"))
            for _ in 0 ..< diff {
                for _ in 0 ..< count - 2 {
                    buffByte.append(0xFF)
                }
            }
        }
        
        
        buffByte += bytesArray.suffix(count - 2)
        
//        for i in 0 ..< bytesArray.count / 2 {
//            if bytesArray[i * 2] == bytesArray[i * 2 + 1] && bytesArray[i * 2] == 0xFF {
//                print("#57685 - Oui")
//            }
//        }
        
        previousIndex = currentIndex
        
        let limitBuffCount = eegPacketLength * 2 * 2
        
        if  buffByte.count >= limitBuffCount {
            var byteArray = [UInt8]()
            for _ in 0 ... (limitBuffCount - 1)  {
                byteArray.append(buffByte.removeFirst())
            }
            self.manageCompleteStreamEEGPacket(self.process(byteArray))
        }
    }
    
    /// Convert the data brut in RelaxIndex
    ///
    /// - Parameter bytesArray: An array of *UInt8*
    /// - Returns: return the RelaxIndexes
    func process(_ bytesArray:[UInt8]) -> [[Float]] {
        
        var values = [Float]()
        
        for i in 0 ..< bytesArray.count / MBTEEGAcquisitionManager.divider  {
            var temp : Int32 = 0x00000000
            
            temp = (Int32(bytesArray[2 * i] & 0xFF) << MBTEEGAcquisitionManager.SHIFT_MELOMIND) | Int32(bytesArray[2 * i + 1] & 0xFF) << (MBTEEGAcquisitionManager.SHIFT_MELOMIND - 8)
//
//            if temp == 0x000FFFF0 {
////                values.append(Float.nan)
//                print((Int32(bytesArray[2 * (i + 1)] & 0xFF) << MBTEEGAcquisitionManager.SHIFT_MELOMIND) | Int32(bytesArray[2 * (i + 1) + 1] & 0xFF) << (MBTEEGAcquisitionManager.SHIFT_MELOMIND - 8))
//            }
//
            if ((temp & MBTEEGAcquisitionManager.CHECK_SIGN_MELOMIND) > 0) { // value is negative
                temp = Int32(temp | MBTEEGAcquisitionManager.NEGATIVE_MASK_MELOMIND )
            } else {
                // value is positive
                temp = Int32(temp & MBTEEGAcquisitionManager.POSITIVE_MASK_MELOMIND)
            }
            
            values.append(Float(temp))
        }


        var P3DatasArray = [Float]()
        var P4DatasArray = [Float]()

        for i in 0 ..< values.count {
            if i % 2 == 0 {
                P3DatasArray.append(values[i] * voltageADS1299)
            } else {
                P4DatasArray.append(values[i] * voltageADS1299)
            }
        }
        
        let dataArray = [P3DatasArray, P4DatasArray]

        return dataArray
    }
}

