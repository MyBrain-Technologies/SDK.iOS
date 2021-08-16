import XCTest
@testable import MyBrainTechnologiesSDK

class MBTEEGPacketTests: XCTestCase {

//  //----------------------------------------------------------------------------
//  // MARK: - Test Init
//  //----------------------------------------------------------------------------
//
//  func testCreateEEGPacket() {
//    let data: [[Float]] = [
//      [0.0, 0.1, 0.2],
//      [0.3, 0.4, 0.5]
//    ]
//
//    // When
//    let packet = MBTEEGPacket(channelsValues: data)
//
//    // Then
//    XCTAssertEqual(packet.channelsData.count, 2)
//    XCTAssertEqual(Array(packet.channelsData[0].values), data[0])
//    XCTAssertEqual(Array(packet.channelsData[1].values), data[1])
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Test Qualities
//  //----------------------------------------------------------------------------
//
//  func testAddQualities() {
//    let packet = MBTEEGPacket(channelsValues: [])
//    let qualities: [Float] = [0.0, 0.1, 0.2]
//
//    // When
//    packet.addQualities(qualities)
//
//    // Then
//    XCTAssertEqual(packet.qualities.count, qualities.count)
//    XCTAssertEqual(Array(packet.qualities), qualities)
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Test Modified data
//  //----------------------------------------------------------------------------
//
//  func testSetModifiedChannelDataSampRateLower() {
//    let packet = MBTEEGPacket(channelsValues: [])
//    let modifiedValues: [[Float]] = [
//      [0.0, 0.1, 0.2],
//      [0.3, 0.4, 0.5]
//    ]
//
//    // When
//    packet.setModifiedChannelsData(modifiedValues, sampRate: 2)
//
//    // Then
//    XCTAssertEqual(packet.modifiedChannelsData.count, 2)
//    XCTAssertEqual(packet.modifiedChannelsData[0].values.count, 2)
//    XCTAssertEqual(Array(packet.modifiedChannelsData[0].values),
//                   Array(modifiedValues[0].prefix(2)))
//    XCTAssertEqual(Array(packet.modifiedChannelsData[1].values),
//                   Array(modifiedValues[1].prefix(2)))
//  }
//
//  func testSetModifiedChannelDataSampRateEqual() {
//    let packet = MBTEEGPacket(channelsValues: [])
//    let modifiedValues: [[Float]] = [
//      [0.0, 0.1, 0.2],
//      [0.3, 0.4, 0.5]
//    ]
//
//    // When
//    packet.setModifiedChannelsData(modifiedValues, sampRate: 3)
//
//    // Then
//    XCTAssertEqual(packet.modifiedChannelsData.count, 2)
//    XCTAssertEqual(packet.modifiedChannelsData[0].values.count, 3)
//    XCTAssertEqual(Array(packet.modifiedChannelsData[0].values),
//                   Array(modifiedValues[0]))
//    XCTAssertEqual(Array(packet.modifiedChannelsData[1].values),
//                   Array(modifiedValues[1]))
//  }
//
//  func testSetModifiedChannelDataSampRateHigher() {
//    let packet = MBTEEGPacket(channelsValues: [])
//    let modifiedValues: [[Float]] = [
//      [0.0, 0.1, 0.2],
//      [0.3, 0.4, 0.5]
//    ]
//
//    // When
//    packet.setModifiedChannelsData(modifiedValues, sampRate: 4)
//
//    // Then
//    XCTAssertEqual(packet.modifiedChannelsData.count, 2)
//    XCTAssertEqual(packet.modifiedChannelsData[0].values.count, 3)
//    XCTAssertEqual(Array(packet.modifiedChannelsData[0].values),
//                   Array(modifiedValues[0]))
//    XCTAssertEqual(Array(packet.modifiedChannelsData[1].values),
//                   Array(modifiedValues[1]))
//  }
}
