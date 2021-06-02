//
//  MBTAcquisitionDelegate.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by Laurent on 02/06/2021.
//  Copyright © 2021 MyBrainTechnologies. All rights reserved.
//

import Foundation

public protocol MBTAcquisitionDelegate {

  func didUpdateBatteryLevel(_ levelBattery: Int)

  /// Called when
  ///
  /// - Parameter status: A *Int* of the saturation headset
  /// - Remarks:
  /// 0 -> no saturation,
  /// 1 -> left side saturation,
  /// 2 -> right side Saturation
  /// 3 -> both side Saturation
  func didUpdateSaturationStatus(_ status: Int)

  /// Called to each EEG package sent by the BLE.
  /// - Parameter dataArray: *Dictionnary* of EEG data array.
  func didUpdateEEGData(_ eegPacket: MBTEEGPacket)

  func didUpdateEEGRawData(_ data: Data)

}
