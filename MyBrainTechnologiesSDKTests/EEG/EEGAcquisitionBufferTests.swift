import XCTest
@testable import MyBrainTechnologiesSDK

class EEGAcquisitionBufferTests: XCTestCase {

  //----------------------------------------------------------------------------
  // MARK: - Basic Packet
  //----------------------------------------------------------------------------

  func testVeryBasicPackets() {
    let packets = EEGAcquisitonRawPacketsToBuffer.SetSample.packets
    let expectedPackets =
      EEGAcquisitonRawPacketsToBuffer.SetSample.savedPacketsBy3

    let acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: 3)

    // When
    let savedPackets = getUsablePackets(from: packets, on: acquisitionBuffer)

    // Then
    XCTAssertEqual(savedPackets, expectedPackets)
  }

  func testVeryBasicPacketsBy6() {
    let packets = EEGAcquisitonRawPacketsToBuffer.SetSample.packets
    let expectedPackets =
      EEGAcquisitonRawPacketsToBuffer.SetSample.savedPacketsBy6

    let acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: 6)

    // When
    let savedPackets = getUsablePackets(from: packets, on: acquisitionBuffer)

    // Then
    XCTAssertEqual(savedPackets, expectedPackets)
  }

  func testVeryBasicPacketsBy4() {
    let packets = EEGAcquisitonRawPacketsToBuffer.SetSample.packets
    let expectedPackets =
      EEGAcquisitonRawPacketsToBuffer.SetSample.savedPacketsBy4

    let acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: 4)

    // When
    let savedPackets = getUsablePackets(from: packets, on: acquisitionBuffer)

    // Then
    XCTAssertEqual(savedPackets, expectedPackets)
  }

  //----------------------------------------------------------------------------
  // MARK: - Basic Packets with lost packets
  //----------------------------------------------------------------------------

  func testVeryBasicLostPackets() {
    let packets =
      EEGAcquisitonRawPacketsToBuffer.SetSampleLostPackets.packets
    let expectedPackets =
      EEGAcquisitonRawPacketsToBuffer.SetSampleLostPackets.savedPacketsBy3

    let acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: 3)

    // When
    let savedPackets = getUsablePackets(from: packets, on: acquisitionBuffer)

    // Then
    XCTAssertEqual(savedPackets, expectedPackets)
  }

  func testVeryBasicLostPacketsBy6() {
    let packets =
      EEGAcquisitonRawPacketsToBuffer.SetSampleLostPackets.packets
    let expectedPackets =
      EEGAcquisitonRawPacketsToBuffer.SetSampleLostPackets.savedPacketsBy6

    let acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: 6)

    // When
    let savedPackets = getUsablePackets(from: packets, on: acquisitionBuffer)

    // Then
    XCTAssertEqual(savedPackets, expectedPackets)
  }

  func testVeryBasicLostPacketsBy4() {
    let packets = EEGAcquisitonRawPacketsToBuffer.SetSampleLostPackets.packets
    let expectedPackets =
      EEGAcquisitonRawPacketsToBuffer.SetSampleLostPackets.savedPacketsBy4

    let acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: 4)

    // When
    let savedPackets = getUsablePackets(from: packets, on: acquisitionBuffer)

    // Then
    XCTAssertEqual(savedPackets, expectedPackets)
  }

  //----------------------------------------------------------------------------
  // MARK: - Realistic packet
  //----------------------------------------------------------------------------

  func testRealisticSet() {
    let packets =
      EEGAcquisitonRawPacketsToBuffer.Set1.packets
    let expectedPackets =
      EEGAcquisitonRawPacketsToBuffer.Set1.savedPackets

    let acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: 40)

    // When
    let savedPackets = getUsablePackets(from: packets, on: acquisitionBuffer)

    // Then
    XCTAssertEqual(savedPackets, expectedPackets)
  }

  //----------------------------------------------------------------------------
  // MARK: - Realistic packets with lost values
  //----------------------------------------------------------------------------

  func testRealisticSet2() {
    let packets =
      EEGAcquisitonRawPacketsToBuffer.Set2.packets
    let expectedPackets =
      EEGAcquisitonRawPacketsToBuffer.Set2.savedPacketsBy40

    let acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: 40,
                                                 lastIndex: 1565)

    // When
    let savedPackets = getUsablePackets(from: packets, on: acquisitionBuffer)

    // Then
    XCTAssertEqual(savedPackets.count, expectedPackets.count)
    for index in 0 ..< savedPackets.count {
      XCTAssertEqual(savedPackets[index],
                     expectedPackets[index],
                     "array at \(index) are not equal")
    }
  }

  func testRealisticSet2By360() {
    let packets =
      EEGAcquisitonRawPacketsToBuffer.Set2.packets
    let expectedPackets =
      EEGAcquisitonRawPacketsToBuffer.Set2.savedPacketsBy400

    let acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: 400,
                                                 lastIndex: 1565)

    // When
    let savedPackets = getUsablePackets(from: packets, on: acquisitionBuffer)

    // Then
    XCTAssertEqual(savedPackets.count, expectedPackets.count)
    for index in 0 ..< savedPackets.count {
      XCTAssertEqual(savedPackets[index],
                     expectedPackets[index],
                     "array at \(index) are not equal")
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Tools
  //----------------------------------------------------------------------------

  private func getUsablePackets(from packets: [[UInt8]],
                                on buffer: EEGAcquisitionBuffer) -> [[UInt8]?] {
    var savedPackets = [[UInt8]?]()

    for packet in packets {
      buffer.add(rawPacketValue: packet)
      savedPackets.append(buffer.getUsablePackets())
    }

    while let savedPacket = buffer.getUsablePackets() {
      savedPackets.append(savedPacket)
    }
    return savedPackets
  }

}
