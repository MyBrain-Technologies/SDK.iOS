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
class MBTEEGPacket: Object {
    
    /// The qualities stored in a list. The list size
    /// should be equal to the number of channels if there is
    /// a status channel.
    let qualities = List<Quality>()
    
    /// The timestamp in milliseconds when this packet is created.
    dynamic var timestamp: Int = 0
    
    /// The values from all channels.
    let channelsData = List<ChannelDatas>()
}

/// One quality value for one channel.
class Quality: Object {
    dynamic var value: Float = 0
}

/// One value from one channel.
class ChannelData: Object {
    dynamic var value: Float = 0
}

/// All values from one channel.
class ChannelDatas: Object {
    let value = List<ChannelData>()
}
