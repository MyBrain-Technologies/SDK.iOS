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
  case SNR
  /// RMS algorithm is used in v2.5.0 of the Melomind SDK
  case RMS

  public static func algorithm(
    fromSDKVersion version: String
  ) -> MBTRelaxIndexAlgorithm {
    let sdkVersion = FormatedVersion(string: version)
    let rmsVersion = FormatedVersion(string: CPPVersion.rmsVersion.rawValue)

    return sdkVersion >= rmsVersion ? .RMS : .SNR
  }
}

/*******************************************************************************
 * CPP Version
 *
 * Different major CPP versions
 *
 ******************************************************************************/

enum CPPVersion: String {
  case rmsVersion = "2.5.0"
}
