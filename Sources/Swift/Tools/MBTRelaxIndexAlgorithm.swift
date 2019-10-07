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
  
  public static func algorithm(fromSDKVersion version: String) -> MBTRelaxIndexAlgorithm {
    let sdkVersion = FormatedVersion(fromString: version)
    let rmsVersion = FormatedVersion(fromString: CPPVersion.V2_5_0.rawValue)
    
    if sdkVersion >= rmsVersion {
      return .RMS
    } else {
      return .SNR
    }
  }
}

// MARK: - FILEPRIVATE structs / enums
// Handle comparisons between cpp versions

enum CPPVersion: String {
  case V2_5_0 = "2.5.0"
}

struct FormatedVersion: Equatable {
  var majorVersion: Int
  var minorVersion: Int
  var patchVersion: Int
  
  
  init(majorVersion: Int, minorVersion: Int, patchVersion: Int) {
    self.majorVersion = majorVersion
    self.minorVersion = minorVersion
    self.patchVersion = patchVersion
  }
  
  init(fromString string: String) {
    let splited = string.split(separator: ".").map { Int(String($0)) ?? 0 }
    
    self.init(majorVersion: splited[0],
              minorVersion: splited[1],
              patchVersion: splited[2])
  }
  
  static func > (lhs: FormatedVersion, rhs: FormatedVersion) -> Bool {
    let lhsVersions = [lhs.majorVersion, lhs.minorVersion, lhs.patchVersion]
    let rhsVersions = [rhs.majorVersion, rhs.minorVersion, rhs.patchVersion]
    
    for i in 0 ..< lhsVersions.count {
      if lhsVersions[i] < rhsVersions[i] { return false }
    }
    return true
  }
  
  static func == (lhs: FormatedVersion, rhs: FormatedVersion) -> Bool {
    let lhsVersions = [lhs.majorVersion, lhs.minorVersion, lhs.patchVersion]
    let rhsVersions = [rhs.majorVersion, rhs.minorVersion, rhs.patchVersion]
    
    for i in 0 ..< lhsVersions.count {
      if lhsVersions[i] != rhsVersions[i] { return false }
    }
    return true
  }
  
  static func < (lhs: FormatedVersion, rhs: FormatedVersion) -> Bool {
    let lhsVersions = [lhs.majorVersion, lhs.minorVersion, lhs.patchVersion]
    let rhsVersions = [rhs.majorVersion, rhs.minorVersion, rhs.patchVersion]
    
    for i in 0 ..< lhsVersions.count {
      if lhsVersions[i] > rhsVersions[i] { return false }
    }
    return true
  }
  
  static func >= (lhs: FormatedVersion, rhs: FormatedVersion) -> Bool {
    return lhs > rhs || lhs == rhs
  }
}
