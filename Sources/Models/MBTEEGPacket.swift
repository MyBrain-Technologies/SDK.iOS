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
    
    /// The packet index of the recording session.
    public var packetIndex: Int = 0
}

//MARK: -
/// One quality value for one channel.
public class Quality: Object {
    /// Value property of the *Quality*.
    public dynamic var value: Float = 0
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
class EEGPacketManager: RealmEntityManager {
    
    /// Method to persist EEGPacket received in the Realm database.
    class func saveEEGPacket(_ eegPacket: MBTEEGPacket) {
        try! RealmManager.realm.write {
            RealmManager.realm.add(eegPacket)
        }
    }
    
    /// Remove all EEGPacket saved in Realm DB.
    class func removeAllEEGPackets() {
        let packets = RealmManager.realm.objects(MBTEEGPacket.self)
        
        try! RealmManager.realm.write {
            RealmManager.realm.delete(packets)
        }
    }
    
    /// Build the JSON with the EEG session data.
    class func getEEGPackets() -> Results<MBTEEGPacket> {
        return RealmManager.realm.objects(MBTEEGPacket.self)
    }
}
