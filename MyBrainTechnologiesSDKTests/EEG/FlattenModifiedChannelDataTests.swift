import XCTest
@testable import MyBrainTechnologiesSDK

class FlattenModifiedChannelDataTests: XCTestCase {

  //----------------------------------------------------------------------------
  // MARK: - FlattenModifiedChannelData
  //----------------------------------------------------------------------------

  func testFlattenModifiedChannelData() {
    let packets = [
      MBTEEGPacket(channelsValues: [[]]),
      MBTEEGPacket(channelsValues: [[]])
    ]

    packets[0].setModifiedChannelsData([
      [0.0, 0.1, 0.2], // channel[0]
      [0.3, 0.4, 0.5] // channel[1]
    ], sampRate: 3)

    packets[1].setModifiedChannelsData([
      [0.6, 0.7, 0.8], // channel[0]
      [0.9, 1.0, 1.1] // channel[1]
    ], sampRate: 3)

    // When
    let result = packets.flattenModifiedChannelData()

    XCTAssertEqual(
      result,
      [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1]
    )
  }

  func testFlattenModifiedChannelDataOnePacket() {
    let packets = [
      MBTEEGPacket(channelsValues: [[]])
    ]

    packets[0].setModifiedChannelsData([
      [0.0, 0.1, 0.2],
      [0.3, 0.4, 0.5]
    ], sampRate: 3)

    // When
    let result = packets.flattenModifiedChannelData()

    XCTAssertEqual(result, [0.0, 0.1, 0.2, 0.3, 0.4, 0.5])
  }

  func testFlattenModifiedChannelDataNoData() {
    let packets = [MBTEEGPacket(channelsValues: [[]])]

    // When
    let result = packets.flattenModifiedChannelData()

    XCTAssertEqual(result, [])
  }

}
