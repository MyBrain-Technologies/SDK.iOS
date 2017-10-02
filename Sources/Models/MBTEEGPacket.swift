//
//  MBTEEGPacket.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 29/06/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import RealmSwift

/// Model to store processed data of an EEG Packet.
public class MBTEEGPacket: Object {
    
    /// The qualities stored in a list. The list size
    /// should be equal to the number of channels if there is
    /// a status channel.
    public let qualities = List<Quality>()
    
    /// The timestamp in milliseconds when this packet is created.
    public  dynamic var timestamp: Int = Int(NSDate().timeIntervalSince1970)
    
    /// The values from all channels.
    public let channelsData = List<ChannelDatas>()
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
    
    /// Remove all EEGPacket saved in Realm DB.
    class func removeAllEEGPackets() {
        let packets = RealmManager.realm.objects(MBTEEGPacket.self)
        
        try! RealmManager.realm.write {
            RealmManager.realm.delete(packets)
        }
    }
    
    /// Build the JSON with the EEG session data.
    /// - Returns: All *MBTEEGPacket* db-saved.
    class func getEEGPackets() -> Results<MBTEEGPacket> {
        return RealmManager.realm.objects(MBTEEGPacket.self)
    }
    
    /// Add data samples to an EEGPacket.
    class func addValuesToEEGPacket(_ datasArray: Array<Array<ChannelData>>) -> MBTEEGPacket? {
        let lastPacket = getLastPacket()
        // Get the number of data saved in this packet.
        let samplesCount = lastPacket.channelsData.isEmpty ? 0 : lastPacket.channelsData[0].value.count
        // Get current device.
        let eegPacketLength = DeviceManager.getDeviceEEGPacketLength()
        
        // Check how many samples the MBTEEGPacket has.
        if samplesCount == eegPacketLength {
            let newPacket = createNewPacket()
            addValues(datasArray, to: newPacket)
            return lastPacket
        } else if samplesCount == (eegPacketLength - 2) {
            var firstPacketValues = Array<Array<ChannelData>>()
            firstPacketValues.append(Array(datasArray[0].dropLast(2)))
            firstPacketValues.append(Array(datasArray[1].dropLast(2)))
            addValues(firstPacketValues, to: lastPacket)

            let newPacket = createNewPacket()
            var lastPacketValues = Array<Array<ChannelData>>()
            lastPacketValues.append(Array(datasArray[0].dropFirst(2)))
            lastPacketValues.append(Array(datasArray[1].dropFirst(2)))
            addValues(lastPacketValues, to: newPacket)
            
            return lastPacket
        } else {
            addValues(datasArray, to: lastPacket)
            
            return nil
        }
    }
    
    /// Get the last packet to complete.
    /// - Returns: The last saved *MBTEEGPacket*.
    class func getLastPacket() -> MBTEEGPacket {
        let packets = getEEGPackets()
        
        guard let packet = packets.last else {
            return createNewPacket()
        }
        
        return packet
    }
    
    class func createNewPacket() -> MBTEEGPacket {
        let newPacket = MBTEEGPacket()
        
        for _ in 0 ..< 2 {
            newPacket.channelsData.append(ChannelDatas())
        }
        
        return saveEEGPacket(newPacket)
    }
    
    class func addValues(_ values: Array<Array<ChannelData>>, to eegPacket:MBTEEGPacket) {
        try! RealmManager.realm.write { // Double for imbriqué, pour dynamiser
            for P3Sample in values.first! {
                eegPacket.channelsData[0].value.append(P3Sample)
            }
            
            for P4Sample in values.last! {
                eegPacket.channelsData[1].value.append(P4Sample)
            }
        }
    }
    
    class func updateEEGPacketChannelsDataValues(_ eegPacket: MBTEEGPacket, newValues:[Float]) -> MBTEEGPacket {
        let updatedEEGPacket = MBTEEGPacket.init(value: eegPacket)
        // Remove old values.
        updatedEEGPacket.channelsData.removeAll()
        
        let device = DeviceManager.getCurrentDevice()
        
        for _ in 0 ..< device.nbChannels {
            let channelDatas = ChannelDatas()
            
            for packetValue in 0 ..< device.sampRate {
                let channelData = ChannelData(data: newValues[packetValue])
                channelDatas.value.append(channelData)
            }
            updatedEEGPacket.channelsData.append(channelDatas)
        }
        
        return updatedEEGPacket
    }
    
    class func addQualities(_ qualities:[Float],to eegPacket:MBTEEGPacket) {
        try! RealmManager.realm.write {
            for qualityFloat in qualities {
                let quality = Quality(data:qualityFloat)
                eegPacket.qualities.append(quality)
            }
        }
    }
}
