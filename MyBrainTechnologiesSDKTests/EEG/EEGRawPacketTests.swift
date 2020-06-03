import XCTest
@testable import MyBrainTechnologiesSDK

class EEGRawPacketTests: XCTestCase {

  func testPacketIndex() {
    XCTAssertEqual(EEGRawPacket(rawValue: [0, 0]).packetIndex, 0)
    XCTAssertEqual(EEGRawPacket(rawValue: [0, 1]).packetIndex, 1)
    XCTAssertEqual(EEGRawPacket(rawValue: [0, 255]).packetIndex, 255)

    XCTAssertEqual(EEGRawPacket(rawValue: [1, 0]).packetIndex, 256)
    XCTAssertEqual(EEGRawPacket(rawValue: [1, 1]).packetIndex, 257)
    XCTAssertEqual(EEGRawPacket(rawValue: [1, 136]).packetIndex, 392)

    XCTAssertEqual(EEGRawPacket(rawValue: [2, 0]).packetIndex, 512)
  }

  func testValue() {
    XCTAssertEqual(EEGRawPacket(rawValue: [0, 0]).value, [])
    XCTAssertEqual(EEGRawPacket(rawValue: [0, 0, 0, 0]).value, [0, 0])
    XCTAssertEqual(EEGRawPacket(rawValue: [0, 0, 1, 2]).value, [1, 2])
  }

}
