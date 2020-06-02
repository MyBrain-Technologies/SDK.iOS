import XCTest
@testable import MyBrainTechnologiesSDK

class EEGAcquisitionBufferTests: XCTestCase {

  //----------------------------------------------------------------------------
  // MARK: - Basic Packet
  //----------------------------------------------------------------------------

  func testVeryBasicPackets() {
    let packets = EEGAcquisitonRawPacketsToBuffer.SetSample.packets
    let expectedPackets = EEGAcquisitonRawPacketsToBuffer.SetSample.savedPackets

    let acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: 3)

    for (index, packet) in packets.enumerated() {
      // When
      acquisitionBuffer.add(rawPacketValue: packet)

      // Then
      let savedPackets = acquisitionBuffer.getUsablePackets()
      XCTAssertEqual(savedPackets, expectedPackets[index])
    }
  }

  func testVeryBasicPacketsBy6() {
    let packets = EEGAcquisitonRawPacketsToBuffer.SetSample.packets
    let expectedPackets =
      EEGAcquisitonRawPacketsToBuffer.SetSample.savedPacketsBy6

    let acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: 6)

    for (index, packet) in packets.enumerated() {
      // When
      acquisitionBuffer.add(rawPacketValue: packet)

      // Then
      let savedPackets = acquisitionBuffer.getUsablePackets()
      XCTAssertEqual(savedPackets, expectedPackets[index])
    }
  }

  func testVeryBasicPacketsBy4() {
    let packets = EEGAcquisitonRawPacketsToBuffer.SetSample.packets
    let expectedPackets =
      EEGAcquisitonRawPacketsToBuffer.SetSample.savedPacketsBy4

    let acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: 4)

    for (index, packet) in packets.enumerated() {
      // When
      acquisitionBuffer.add(rawPacketValue: packet)

      // Then
      let savedPackets = acquisitionBuffer.getUsablePackets()
      XCTAssertEqual(savedPackets, expectedPackets[index])
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Basic Packets with lost packets
  //----------------------------------------------------------------------------

  
}
