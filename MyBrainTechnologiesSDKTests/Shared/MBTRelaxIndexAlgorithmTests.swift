import XCTest
@testable import MyBrainTechnologiesSDK

class MBTRelaxIndexAlgorithmTests: XCTestCase {

  func testAlgoForSDKVersion_SNR() {
    let algo = MBTRelaxIndexAlgorithm.algorithm(fromSDKVersion: "2.0.0")

    XCTAssertEqual(algo, .SNR)
  }

  func testAlgoForSDKVersion_equalRMS() {
    let algo = MBTRelaxIndexAlgorithm.algorithm(fromSDKVersion: "2.5.0")

    XCTAssertEqual(algo, .RMS)
  }

  func testAlgoForSDKVersion_higherRMS() {
    let algo = MBTRelaxIndexAlgorithm.algorithm(fromSDKVersion: "2.6.0")

    XCTAssertEqual(algo, .RMS)
  }
}
