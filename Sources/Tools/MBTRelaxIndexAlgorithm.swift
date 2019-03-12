//
//  MBTRelaxIndexAlgorithm.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by Mathilde on 12/03/2019.
//  Copyright © 2019 MyBrainTechnologies. All rights reserved.
//

import Foundation

public enum MBTRelaxIndexAlgorithm: String {
  /// SNR algorithm is used in v2.3.1 of the Melomind SDK
  case SNR = "SNR"
  /// RMS algorithm is used in v2.5.0 of the Melomind SDK
  case RMS = "RMS"
  
  static func algorithm(fromSDKVersion version: String) -> MBTRelaxIndexAlgorithm {
    switch version {
    case "2.5.0": return .RMS
    default: return .SNR
    }
  }
}
