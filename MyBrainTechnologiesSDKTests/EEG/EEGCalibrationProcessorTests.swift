import XCTest
@testable import MyBrainTechnologiesSDK

class EEGCalibrationProcessorTests: XCTestCase {
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
    let result =
      EEGCalibrationProcessor.getFlattenModifiedChannelData(from: packets,
                                                            packetLength: 3,
                                                            nbChannels: 2)

    XCTAssertEqual(
      result,
      [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1]
    )
  }

  func testFlattenModifiedChannelDataLowerPacketLength() {
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
    let result =
      EEGCalibrationProcessor.getFlattenModifiedChannelData(from: packets,
                                                            packetLength: 2,
                                                            nbChannels: 2)
    XCTAssertEqual(
      result,
      [0.0, 0.1, 0.3, 0.4, 0.6, 0.7, 0.9, 1.0]
    )
  }

  func testFlattenModifiedChannelDataLowerNbChannels() {
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
    let result =
      EEGCalibrationProcessor.getFlattenModifiedChannelData(from: packets,
                                                            packetLength: 3,
                                                            nbChannels: 1)

    XCTAssertEqual(
      result,
      [0.0, 0.1, 0.2, 0.6, 0.7, 0.8]
    )
  }

  //----------------------------------------------------------------------------
  // MARK: - flattenQualities
  //----------------------------------------------------------------------------

  func testFlattenQualities() {
    let packets = [
      MBTEEGPacket(channelsValues: [[]]),
      MBTEEGPacket(channelsValues: [[]])
    ]

    packets[0].addQualities([1, 1, 1, 1, 1])
    packets[1].addQualities([0, 0, 0, 0, 0])

    let result = EEGCalibrationProcessor.getFlattenQualities(from: packets)

    XCTAssertEqual(result, [1, 1, 1, 1, 1, 0, 0, 0, 0, 0])
  }

  //----------------------------------------------------------------------------
  // MARK: - Decode
  //----------------------------------------------------------------------------

  func testDecodeCalibrationParameters() {
    let parameters = [
      "rawSnrCalib": [1.0, 2.0],
      "rawrelativeSnrCalib": [3.0, 4.0],
      "snrCalib": [5.0, 6.0],
      "histFrequencies": [7.0, 8.0],
      "errorMsg": [9.0, 10.0],
      "iafCalib": [11.0, 12.0]
    ]

    // When
    let result =
      EEGCalibrationProcessor.decode(calibrationParameters: parameters)

    // Then
    XCTAssertEqual(result?.rawValues, [1.0, 2.0])
    XCTAssertEqual(result?.relativeValues, [3.0, 4.0])
    XCTAssertEqual(result?.smoothedValues, [5.0, 6.0])
    XCTAssertEqual(result?.frequenciesHistory, [7.0, 8.0])
    XCTAssertEqual(result?.errorValues, [9.0, 10.0])
    XCTAssertEqual(result?.individualAlphaFrequency, [11.0, 12.0])
  }

  func testDecodeCalibrationParametersMissingField() {
    let parameters = [
      "rawSnrCalib": [1.0, 2.0],
      "rawrelativeSnrCalib": [3.0, 4.0],
      "snrCalib": [5.0, 6.0],
      //      "histFrequencies": [7.0, 8.0], // remove a field
      "errorMsg": [9.0, 10.0],
      "iafCalib": [11.0, 12.0]
    ]

    // When
    let result =
      EEGCalibrationProcessor.decode(calibrationParameters: parameters)

    // Then
    XCTAssertNil(result)
  }

  func testDecodeCalibrationParametersEmpty() {
    let parameters: [String: Any] = [:]

    // When
    let result =
      EEGCalibrationProcessor.decode(calibrationParameters: parameters)

    // Then
    XCTAssertNil(result)
  }

  func testDecodeCalibrationParametersInvalidValues() {
    let parameters: [String: Any] = [
      "rawSnrCalib": [1.0, 2.0],
      "rawrelativeSnrCalib": ["1", "2"],
      "snrCalib": [5.0, 6.0],
      "histFrequencies": [7.0, 8.0],
      "errorMsg": [9.0, 10.0],
      "iafCalib": [11.0, 12.0]
    ]

    // When
    let result =
      EEGCalibrationProcessor.decode(calibrationParameters: parameters)

    // Then
    XCTAssertNil(result)
  }
}
