import XCTest
@testable import MyBrainTechnologiesSDK

class EEGDeserializerTests: XCTestCase {

//  //----------------------------------------------------------------------------
//  // MARK: - Set 1
//  //----------------------------------------------------------------------------
//
//  func testEEGDeserializer() {
//    let bytes = EEGAcquitionRawPacketsDeserializable.Set1.input
//
//    // When
//    let output = EEGDeserializer.deserializeToRelaxIndex(bytes: bytes)
//
//    // Then
//    XCTAssertEqual(output[0],
//                   EEGAcquitionRawPacketsDeserializable.Set1.p3Output)
//    XCTAssertEqual(output[1],
//                   EEGAcquitionRawPacketsDeserializable.Set1.p4Output)
//  }
//
//  func testRemoveAmplification() {
//    let bytes = EEGAcquitionRawPacketsDeserializable.Set1.middleOutput
//
//    // When
//    let output = EEGDeserializer.removeAmplification(values: bytes)
//
//    // then
//    XCTAssertEqual(output, EEGAcquitionRawPacketsDeserializable.Set1.mergedP3P4)
//  }
//
//  func testConvert24to32Bit() {
//    // When
//    let output = EEGDeserializer.convert24to32Bit(
//      bytes: EEGAcquitionRawPacketsDeserializable.Set1.input
//    )
//
//    // Then
//    XCTAssertEqual(output,
//                   EEGAcquitionRawPacketsDeserializable.Set1.middleOutput)
//  }
//
//  func testSpreadBetweenElectrodes() {
//    let bytes = EEGAcquitionRawPacketsDeserializable.Set1.mergedP3P4
//
//    // When
//    let output =
//      EEGDeserializer.spreadBetweenElectrodes(values: bytes,
//                                              numberOfElectrodes: 2)
//
//    // Then
//    XCTAssertEqual(output[0],
//                   EEGAcquitionRawPacketsDeserializable.Set1.p3Output)
//    XCTAssertEqual(output[1],
//                   EEGAcquitionRawPacketsDeserializable.Set1.p4Output)
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Set 2
//  //----------------------------------------------------------------------------
//
//  func testEEGDeserializerSet2() {
//    let bytes = EEGAcquitionRawPacketsDeserializable.Set2.input
//
//    // When
//    let output = EEGDeserializer.deserializeToRelaxIndex(bytes: bytes)
//
//    // Then
//    XCTAssertEqual(output[0],
//                   EEGAcquitionRawPacketsDeserializable.Set2.p3Output)
//    XCTAssertEqual(output[1],
//                   EEGAcquitionRawPacketsDeserializable.Set2.p4Output)
//  }
//
//  func testRemoveAmplificationSet2() {
//    let bytes = EEGAcquitionRawPacketsDeserializable.Set2.middleOutput
//
//    // When
//    let output = EEGDeserializer.removeAmplification(values: bytes)
//
//    // then
//    XCTAssertEqual(output,
//                   EEGAcquitionRawPacketsDeserializable.Set2.mergedP3P4)
//  }
//
//  func testConvert24to32BitSet2() {
//    // When
//    let output = EEGDeserializer.convert24to32Bit(
//      bytes: EEGAcquitionRawPacketsDeserializable.Set2.input
//    )
//
//    // Then
//    XCTAssertEqual(output,
//                   EEGAcquitionRawPacketsDeserializable.Set2.middleOutput)
//  }
//
//  func testSpreadBetweenElectrodesSet2() {
//    let bytes = EEGAcquitionRawPacketsDeserializable.Set2.mergedP3P4
//
//    // When
//    let output =
//      EEGDeserializer.spreadBetweenElectrodes(values: bytes,
//                                              numberOfElectrodes: 2)
//
//    // Then
//    XCTAssertEqual(output[0],
//                   EEGAcquitionRawPacketsDeserializable.Set2.p3Output)
//    XCTAssertEqual(output[1],
//                   EEGAcquitionRawPacketsDeserializable.Set2.p4Output)
//  }

}
