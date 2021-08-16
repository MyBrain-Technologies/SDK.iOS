//
//  ImsDeserializerTests.swift
//  MyBrainTechnologiesSDKTests
//
//  Created by Laurent on 16/08/2021.
//  Copyright © 2021 MyBrainTechnologies. All rights reserved.
//

import XCTest
@testable import MyBrainTechnologiesSDK

class ImsDeserializerTests: XCTestCase {

  func test_deserialization() throws {
    let expectedX: Float = -2
    let expectedY: Float = 1
    let expectedZ: Float = 63


    let fe = UInt8("FE", radix: 16)!
    let ff = UInt8("FF", radix: 16)!
    let _01 = UInt8("01", radix: 16)!
    let _00 = UInt8("00", radix: 16)!
    let _3f = UInt8("3F", radix: 16)!

    let bytes = [fe, ff, _01, _00, _3f, _00]

    let deserializer = ImsDeserializer(axisCount: 3, frameCount: 1)

    let imsPacket = deserializer.deserialize(bytes: bytes, scaleValue: 1)
    let coordinate = try XCTUnwrap(imsPacket?.coordinates.first)
    XCTAssertEqual(coordinate.x, expectedX)
    XCTAssertEqual(coordinate.y, expectedY)
    XCTAssertEqual(coordinate.z, expectedZ)
  }


}
