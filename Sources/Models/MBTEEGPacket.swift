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
    let qualities = List<Quality>()
    
    /// The timestamp in milliseconds when this packet is created.
    dynamic var timestamp: Int = 0
    
    /// The values from all channels.
    let channelsData = List<ChannelDatas>()
    
    /// The packet index of the recording session.
    var packetIndex: Int = 0
}

//MARK: -
/// One quality value for one channel.
class Quality: Object {
    dynamic var value: Float = 0
}

/// One value from one channel.
class ChannelData: Object {
    dynamic var value: Float = 0
    
    convenience init(data: Float) {
        self.init()
        self.value = data
    }
}

/// All values from one channel.
class ChannelDatas: Object {
    let value = List<ChannelData>()
}


//MARK: -
/// *MBTEEGPacket* model DB Manager.
class EEGPacketManager: RealmEntityManager {
    class func saveEEGPacket(_ eegPacket: MBTEEGPacket) {
        try! RealmManager.realm.write {
            eegPacket.timestamp = Int(NSDate().timeIntervalSince1970)
            RealmManager.realm.add(eegPacket)
        }
        
        print(eegPacket)
    }
}
