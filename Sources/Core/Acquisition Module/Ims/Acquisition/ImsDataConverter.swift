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

  #warning("TODO: add full-scale to ratio enum")
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



//    let fe = UInt8("FE", radix: 16)!
//    let ff = UInt8("FF", radix: 16)!
//    let _01 = UInt8("01", radix: 16)!
//    let _00 = UInt8("00", radix: 16)!
//    let _3f = UInt8("3F", radix: 16)!
//
//    let values = [[fe, ff], [_01, _00], [_3f, _00]]
//
//    var results = [Float]()
//    for axis in values {
//      var result: Float
//      if axis[1] == _00 {
//        result = Float(axis[0])
//      } else {
//        let tmp = axis[0] - 1
//        result = Float(ff - tmp) * -1
//      }
//      results.append(result)
//    }

    return MbtImsPacket(x: 1, y: 1, z: 1)
  }

}
