//
//  MBTEEGPacket.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 29/06/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import RealmSwift

typealias StreamEEGPacketToSend = (current:MBTEEGPacket?,complete:MBTEEGPacket?)

/// Model to store processed data of an EEG Packet.
public class MBTEEGPacket: Object {
    
    /// The qualities stored in a list. The list size
    /// should be equal to the number of channels if there is
    /// a status channel. It's calculated by the Quality Checker
    /// and it indicates if the EEG datas are relevant or not.
    public let qualities = List<Quality>()
    
    /// The timestamp in milliseconds when this packet is created.
    public  dynamic var timestamp: Int = Int(NSDate().timeIntervalSince1970)
    
    /// The values from all channels.
    public let channelsData = List<ChannelDatas>()
    
    /// The values updated by the *Quality Checker* from all channels.
    public let modifiedChannelsData = List<ChannelDatas>()
    
    /// Create a new MBTEEGPacket
    ///
    /// - Returns: A new *MBTEEGPacket* instance which channelsData are set up
    class func createNewEEGPacket(_ nbChannel:Int) -> MBTEEGPacket {
        let newPacket = MBTEEGPacket()
        for _ in 0 ..< nbChannel {
            newPacket.channelsData.append(ChannelDatas())
        }
        return newPacket
    }
    
    
    /// Add *ChannelData* values to a *MBTEEGPacket*.
    /// - Parameters:
    ///     - values : *ChannelData* by channel in an array.
    ///     - eegPacket : The *MBTEEGPacket* to add the datas to.
    func addValues(_ values: [[ChannelData]],nbChannel:Int) {
        for index in 0 ..< nbChannel {
            for sample in values[index] {
                self.channelsData[index].value.append(sample)
            }
        }
    }
    
    /// Add *Quality* values, calculated by the Quality Checker, to a *MBTEEGPacket*.
    /// - Parameters:
    ///     - qualities : Array of *Quality* by channel.
    ///     - eegPacket : The *MBTEEGPacket* to add the *Quality* values to.
    func addQualities(_ qualities:[Float]) {
        for qualityFloat in qualities {
            let quality = Quality(data:qualityFloat)
            self.qualities.append(quality)
        }
        
    }
    
    /// Update the *ChannelData* values with the corrected values received
    /// from the Quality Checker.
    /// - Parameters:
    ///     - eegPacket : The *MBTEEGPacket* to update the EEG values.
    ///     - modifiedValues : Array of the corrected values, by channel.
    func addModifiedChannelsData(_ modifiedValues:[[Float]]) {
        if let device = DeviceManager.getCurrentDevice() {
            // Add the updated values to the packet copy.
            for channel in 0 ..< device.nbChannels {
                let channelDatas = ChannelDatas()
                for packetValue in 0 ..< device.sampRate {
                    let channelData = ChannelData(data: modifiedValues[channel][packetValue])
                    channelDatas.value.append(channelData)
                }
                self.modifiedChannelsData.append(channelDatas)
            }
        }
    }
    
    /// Add data samples to the *ChannelsData* of
    /// the last *MBTEEGPacket* doesn't save in realm DB
    /// - Parameters:
    ///     - datasArray : EEG datas just received and processed, to add to the last packet.
    /// - Returns: A *StreamEEGPacketToSend* instance
    /// - Remark : if return value completed -> (current : newEEGPacket, complete : CompletedEEGPacket)
    /// - Remark : else return value no completed -> (current : currentEEGPacket, complete : nil)
    class func addValuesToEEGPacket(_ datasArray: [[ChannelData]],lastPacket:MBTEEGPacket,
                                    WithEEGPacketLength eegPacketLength:Int,
                                    WithNBChannnel nbChannels:Int) -> StreamEEGPacketToSend {
        // Get the number of data saved in this packet.
        let samplesCount = lastPacket.channelsData.isEmpty ? 0 : lastPacket.channelsData[0].value.count
        
        // Check how many samples the MBTEEGPacket has.
        if samplesCount == eegPacketLength { // The last packet saved is complete.
            // Create a new one.
            let newPacket = MBTEEGPacket.createNewEEGPacket(nbChannels)
            // Add EEG values to it.
            newPacket.addValues(datasArray, nbChannel: nbChannels)
            // return the *lastPacket* to *AcquisitionManager*.
            return (newPacket,lastPacket)
        }
            // Misses two samples for the *lastPacket*.
        else if samplesCount == (eegPacketLength - 2) {
            var firstPacketValues = [[ChannelData]]()
            var lastPacketValues = [[ChannelData]]()
            // Split EEG data in two arrays.
            for index in 0 ..< nbChannels {
                firstPacketValues.append(Array(datasArray[index].dropLast(2)))
                lastPacketValues.append(Array(datasArray[index].dropFirst(2)))
            }
            // Second array is for a new packet.
            let newPacket = MBTEEGPacket.createNewEEGPacket(nbChannels)
            newPacket.addValues(lastPacketValues, nbChannel: nbChannels)
            // First array is for the last Packet, which is complete.
            lastPacket.addValues(firstPacketValues, nbChannel: nbChannels)
            return (newPacket,lastPacket)
        } else { // Last packet is not complete or near.
            lastPacket.addValues(datasArray, nbChannel: nbChannels)
            return (lastPacket,nil)
        }
    }
    
    
}

//MARK: -
/// One quality value for one channel.
public class Quality: Object {
    /// Value property of the *Quality*.
    public dynamic var value: Float = 0
    
    /// Special init with the value of *Quality*.
    public convenience init(data: Float) {
        self.init()
        self.value = data
    }
}

/// One EEG value from one channel.
public class ChannelData: Object {
    /// Value property of a *Channel*.
    public dynamic var value: Float = 0
    
    /// Special init with the value of *ChannelData*.
    public convenience init(data: Float) {
        self.init()
        self.value = data
    }
}

/// All values from one channel.
public class ChannelDatas: Object {
    /// *RLMArray* of *ChannelData*.
    public let value = List<ChannelData>()
}


//MARK: -
/// *MBTEEGPacket* model DB Manager.
class EEGPacketManager: MBTRealmEntityManager {
    
    
    
    
    /// Create, saved in Realm DB and return a *MBTEEGPacket* instance.
    /// - Returns: The newly created and saved *MBTEEGPacket*.
    class func createNewPacket() -> MBTEEGPacket {
        return saveEEGPacket(MBTEEGPacket.createNewEEGPacket(DeviceManager.getChannelsCount()))
    }
    
    
    /// Method to persist EEGPacket received in the Realm database.
    /// - Parameters:
    ///     - eegPacket : *MBTEEGPacket* freshly created, soon db-saved.
    /// - Returns: The *MBTEEGPacket* saved in Realm-db.
    class func saveEEGPacket(_ eegPacket: MBTEEGPacket) -> MBTEEGPacket {
        try! RealmManager.realm.write {
            RealmManager.realm.add(eegPacket)
        }
        return eegPacket
    }
    

    
    /// Add *ChannelData* values to a *MBTEEGPacket*.
    /// - Parameters:
    ///     - values : *ChannelData* by channel in an array.
    ///     - eegPacket : The *MBTEEGPacket* to add the datas to.
    class func addValues(_ values: [[ChannelData]], to eegPacket:MBTEEGPacket) {
        try! RealmManager.realm.write {
            eegPacket.addValues(values, nbChannel: DeviceManager.getChannelsCount())
        }
    }

    
    /// Update the *ChannelData* values with the corrected values received
    /// from the Quality Checker.
    /// - Parameters:
    ///     - eegPacket : The *MBTEEGPacket* to update the EEG values.
    ///     - modifiedValues : Array of the corrected values, by channel.
    class func addModifiedChannelsData(_ eegPacket: MBTEEGPacket, modifiedValues:[[Float]]) {
        try! RealmManager.realm.write {
            eegPacket.addModifiedChannelsData(modifiedValues)
        }
    }

    
    /// Add *Quality* values, calculated by the Quality Checker, to a *MBTEEGPacket*.
    /// Then update the Realm DB.
    /// - Parameters:
    ///     - qualities : Array of *Quality* by channel.
    ///     - eegPacket : The *MBTEEGPacket* to add the *Quality* values to.
    class func addQualities(_ qualities:[Float],to eegPacket:MBTEEGPacket) {
        try! RealmManager.realm.write {
            for qualityFloat in qualities {
                let quality = Quality(data:qualityFloat)
                eegPacket.qualities.append(quality)
            }
        }
    }
    
    /// Get the last packet not complete.
    /// - Returns: The last saved *MBTEEGPacket*.
    class func getLastPacket() -> MBTEEGPacket {
        let packets = getEEGPackets()
        // Create one if no packet exists.
        guard let packet = packets.last else {
            return createNewPacket()
        }
        return packet
    }
    
    
    /// Get last n *MBTEEGPackets* from the Realm DB.
    /// - Parameters:
    ///     - n : Number of *MBTEEGPackets* wanted.
    /// - Returns : The last n *MBTEEGPacket*.
    class func getLastNPacketsComplete(_ n:Int) -> [MBTEEGPacket] {
        let packets = EEGPacketManager.getEEGPackets().dropLast()
        let packetsCount = packets.count
        var lastNPackets = [MBTEEGPacket]()
        
        // If there is less packets than wanted.
        if n > packetsCount {
            return Array(packets)
        } else {
            for i in (packetsCount - n) ..< packetsCount {
                lastNPackets.append(packets[i])
            }
            
            return lastNPackets
        }
    }
    
    
    /// Get all *MBTEEGPacket* saved in Realm DB.
    /// - Returns: All *MBTEEGPacket* db-saved from Realm query.
    class func getEEGPackets() -> Results<MBTEEGPacket> {
        return RealmManager.realm.objects(MBTEEGPacket.self)
    }
    
    /// Get Data Channel for eegPackets
    ///     - return : DataChannel
    class func getJSONEEGDatas() -> JSON {
        var eegDatas = [[Float?]]()
        if let device = DeviceManager.getCurrentDevice() {
            let eegPackets = EEGPacketManager.getEEGPackets()
            for eegPacket in eegPackets {
                for channelNumber in 0 ..< device.nbChannels {
                    if eegDatas.count < channelNumber + 1 {
                        eegDatas.append([Float?]())
                    }
                    if eegPacket.channelsData[channelNumber].value.count  == device.eegPacketLength {
                        for packetIndex in 0 ..< device.eegPacketLength{
                            if eegPacket.channelsData[channelNumber].value[packetIndex].value.isNaN {
                                eegDatas[channelNumber].append(nil)
                            } else {
                                eegDatas[channelNumber].append(eegPacket.channelsData[channelNumber].value[packetIndex].value)
                            }
                        }
                    }
                }
            }
        }
        
        return JSON(eegDatas)
    }
    
    /// Get Qualities Data for eegPackets
    ///     - return : QualitiesChannel
    class func getJSONQualities() -> JSON {
        var qualities = [Float]()
        
        let eegPackets = EEGPacketManager.getEEGPackets()
        for eegPacket in eegPackets {
            for channelNumber in 0 ..< eegPacket.qualities.count {
                qualities.append(eegPacket.qualities[channelNumber].value)
            }
        }
        
        return JSON(qualities)
    }
    
    
    /// Delete all EEGPacket saved in Realm DB.
    class func removeAllEEGPackets() {
        let packets = RealmManager.realm.objects(MBTEEGPacket.self)
        
        try! RealmManager.realm.write {
            RealmManager.realm.delete(packets)
        }
    }
    

}
