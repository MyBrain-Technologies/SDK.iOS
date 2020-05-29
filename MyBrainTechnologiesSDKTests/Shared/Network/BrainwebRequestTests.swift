import XCTest
@testable import MyBrainTechnologiesSDK

class BrainwebRequestTests: XCTestCase {

  override class func setUp() {
    super.setUp()
//    MBTClient.shared.initLog(logToFile: false, isDebugMode: false)
  }

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  let brainwebURL = "https://api.devz.mybraintech.com/melomind_v1.2.2"

  //----------------------------------------------------------------------------
  // MARK: - Tests
  //----------------------------------------------------------------------------

  func testSendJSON_invalidBrainwebURL() {
    let expectation = XCTestExpectation(description: "POST json to brainweb")
    let invalidURL = "www.test.com"
    let fileURL = URL(fileURLWithPath: "test")

    // When
    BrainwebRequest.shared.sendJSON(fileURL, baseURL: invalidURL) {
      success in

      // Then
      XCTAssertFalse(success)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10.0)
  }

  func testSendJSON_invalidFileURL() {
    let expectation = XCTestExpectation(description: "POST json to brainweb")
    let fileURL = URL(fileURLWithPath: "test")

    // When
    BrainwebRequest.shared.sendJSON(fileURL, baseURL: brainwebURL) {
      success in

      // Then
      XCTAssertFalse(success)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10.0)
  }

  func testSendJSON_invalidFileContent() {
    let expectation = XCTestExpectation(description: "POST json to brainweb")
    let fileURL = RecordFileSaver.shared.saveRecord("hello world", at: "test")!

    // When
    BrainwebRequest.shared.sendJSON(fileURL, baseURL: brainwebURL) {
      success in

      // Then
      XCTAssertFalse(success)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10.0)
  }

  func testSendJSON_invalidToken() {
    let expectation = XCTestExpectation(description: "POST json to brainweb")
    let fileURL = RecordFileSaver.shared.saveRecord("0.0,0.0", at: "test.json")!

    // When
    BrainwebRequest.shared.sendJSON(fileURL, baseURL: brainwebURL) {
      success in

      // Then
      XCTAssertFalse(success)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10.0)
  }

  func testSendJSON_success() {
    let expectation = XCTestExpectation(description: "POST json to brainweb")

    RecordFileSaver.shared.removeRecord(at: "test.json")

    let fileURL = RecordFileSaver.shared.saveRecord(
      TestsConstants.mockKwakFileContentJSON,
      at: "test.json"
      )!

    // When
    BrainwebRequest.shared.accessTokens = TestsConstants.token
    BrainwebRequest.shared.sendJSON(fileURL, baseURL: brainwebURL) { success in
      // Then
      XCTAssertTrue(success)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10.0)
  }
}
