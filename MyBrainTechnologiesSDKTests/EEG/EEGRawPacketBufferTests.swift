import XCTest
@testable import MyBrainTechnologiesSDK

class EEGRawPacketBufferTests: XCTestCase {

//  //----------------------------------------------------------------------------
//  // MARK: - Add
//  //----------------------------------------------------------------------------
//
//  func testAddBytes() {
//    let sizeMax = 5
//    let toAdd: [UInt8] = [0, 1, 2, 3]
//    let buffer = EEGRawPacketBuffer(bufferSizeMax: sizeMax)
//
//    XCTAssertEqual(buffer.buffer.count, 0)
//
//    // When
//    buffer.add(bytes: toAdd)
//    // Then
//    XCTAssertEqual(buffer.buffer, toAdd)
//    XCTAssertEqual(buffer.buffer.count, toAdd.count)
//
//    // When
//    buffer.add(bytes: toAdd)
//    // Then
//    XCTAssertEqual(buffer.buffer, toAdd + toAdd)
//    XCTAssertEqual(buffer.buffer.count, toAdd.count * 2)
//  }
//
//  func testAddNumberOfBytes() {
//    let sizeMax = 5
//    let toAdd: UInt8 = 0x01
//    let buffer = EEGRawPacketBuffer(bufferSizeMax: sizeMax)
//
//    // When
//    buffer.add(value: toAdd, count: 5)
//
//    // Then
//    XCTAssertEqual(buffer.buffer, [UInt8](repeating: toAdd, count: 5))
//    XCTAssertEqual(buffer.buffer.count, 5)
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Is Full
//  //----------------------------------------------------------------------------
//
//  func testIsFull() {
//    let sizeMax = 5
//    let toAdd: [UInt8] = [0, 1, 2, 3]
//    let buffer = EEGRawPacketBuffer(bufferSizeMax: sizeMax)
//
//    XCTAssertFalse(buffer.isFull)
//
//    // When
//    buffer.add(bytes: toAdd)
//    // Then
//    XCTAssertFalse(buffer.isFull)
//
//    // When
//    buffer.add(bytes: toAdd)
//    // Then
//    XCTAssertTrue(buffer.isFull)
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Flush buffer
//  //----------------------------------------------------------------------------
//
//  func testFlushBufferEmpty() {
//    let sizeMax = 5
//    let buffer = EEGRawPacketBuffer(bufferSizeMax: sizeMax)
//
//    // When
//    let content = buffer.flushBuffer()
//    // Then
//    XCTAssertTrue(content.isEmpty)
//  }
//
//  func testFlushBufferNotFull() {
//    let sizeMax = 5
//    let toAdd: [UInt8] = [0, 1, 2, 3]
//    let buffer = EEGRawPacketBuffer(bufferSizeMax: sizeMax)
//
//    buffer.add(bytes: toAdd)
//
//    // When
//    let content = buffer.flushBuffer()
//    // Then
//    XCTAssertEqual(content, toAdd)
//    XCTAssertTrue(buffer.buffer.isEmpty)
//  }
//
//  func testFlushBufferFull() {
//    let sizeMax = 5
//    let toAdd: [UInt8] = [0, 1, 2, 3, 4]
//    let buffer = EEGRawPacketBuffer(bufferSizeMax: sizeMax)
//
//    buffer.add(bytes: toAdd)
//
//    // When
//    let content = buffer.flushBuffer()
//    // Then
//    XCTAssertEqual(content, toAdd)
//    XCTAssertTrue(buffer.buffer.isEmpty)
//  }
//
//  func testFlushBufferOverFull() {
//    let sizeMax = 5
//    let toAdd: [UInt8] = [0, 1, 2, 3, 4, 5]
//    let buffer = EEGRawPacketBuffer(bufferSizeMax: sizeMax)
//
//    buffer.add(bytes: toAdd)
//
//    // When
//    let content = buffer.flushBuffer()
//    // Then
//    XCTAssertEqual(content, [0, 1, 2, 3, 4])
//    XCTAssertEqual(buffer.buffer.count, 1)
//    XCTAssertEqual(buffer.buffer[0], 5)
//  }
}
