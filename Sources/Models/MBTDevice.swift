//
//  MBTDevice.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 29/06/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import RealmSwift

/// Model to store data about the Headset connected.
class MBTDevice: Object {
    //MARK: - Properties
    
    /// The commercial name of the device.
    dynamic var productName:String = ""
    
    /// The id of the product.
    dynamic var productID:String = ""
    
    /// The product serial number.
    dynamic var serialNumber:String = ""
    
    /// The product hardware version.
    dynamic var hardwareVersion:String = ""
    
    /// The product firmware version.
    dynamic var firmwareVersion:String = ""
    
    /// The device unique id.
    dynamic var deviceUUID:String = ""
    
    /// The number of active channels in the device.
    dynamic var nbChannels:Int = 0
}
