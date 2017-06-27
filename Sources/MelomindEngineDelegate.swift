//
//  MelomindEngineDelegate.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 26/06/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation

/// General delegate of the SDK for MelomindEngine.
/// Get data or information from the Headset out the SDK.
public protocol MelomindEngineDelegate: MBTBluetoothEventDelegate, MBTBluetoothA2DPDelegate, MBTAcquisitionDelegate {}
