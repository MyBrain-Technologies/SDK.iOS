//
//  MBTAcquisitionDelegate.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 27/06/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation

/// Manage the acquisition data communication outside the SDK.
public protocol MBTEEGAcquisitionDelegate: class {

    /// Called to each EEG package sent by the BLE.
    /// - Parameter dataArray: *Dictionnary* of EEG data array.
    func onReceivingPackage(_ eegPacket: MBTEEGPacket)
}
