//
//  ImsDataConverter.swift
//  MyBrainTechnologiesSDK
//
//  Created by Laurent on 14/08/2021.
//  Copyright © 2021 MyBrainTechnologies. All rights reserved.
//

import Foundation

class ImsDataConverter {

  typealias InputDataConverter = [[[UInt8]]]
  typealias OutputDataConverter = MbtImsPacket

  func convert(from values: InputDataConverter) -> OutputDataConverter? {
      guard values.count == 3 else { return nil }
      let xIndex = 0
      let yIndex = 1
      let zIndex = 2

  //    IMS
  //    [213, 255, 210, 255, 241, 255, 213, 255, 211, 255, 241, 255]
  //    Chunked IMS
  //    [[213, 255], [210, 255], [241, 255], [213, 255], [211, 255], [241, 255]]
  //    Spreaded IMS
  //    [[[213, 255], [213, 255]], [[210, 255], [211, 255]], [[241, 255], [241, 255]]]
      let xBytes = values[xIndex]

      return MbtImsPacket(x: 1, y: 1, z: 1)
    }
  }
}
