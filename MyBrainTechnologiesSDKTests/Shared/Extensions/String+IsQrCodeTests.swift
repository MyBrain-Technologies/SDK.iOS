import XCTest
@testable import MyBrainTechnologiesSDK

class StringIsQrCodeTests: XCTestCase {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  let qrCodeBatch1 = "MM10000554"
  let qrCodeBatch2 = "MM1B20554."
  let qrCodeBatch3 = "MM1B300001"

  //----------------------------------------------------------------------------
  // MARK: - Tests
  //----------------------------------------------------------------------------

  func testIsQrCodeBatch1() {
    XCTAssertTrue(qrCodeBatch1.isQrCodeBatch1)
    // XCTAssertTrue("MM1B205544".isQrCodeBatch1)

    XCTAssertFalse(qrCodeBatch2.isQrCodeBatch1)
    XCTAssertFalse(qrCodeBatch3.isQrCodeBatch1)
    XCTAssertFalse("MM100005544".isQrCodeBatch1)
    XCTAssertFalse("MM1000055".isQrCodeBatch1)
    XCTAssertFalse("M100005555".isQrCodeBatch1)
    XCTAssertFalse("1MM0005555".isQrCodeBatch1)
  }

  func testIsQrCodeBatch2() {
    XCTAssertTrue(qrCodeBatch2.isQrCodeBatch2)

    XCTAssertFalse(qrCodeBatch1.isQrCodeBatch2)
    XCTAssertFalse(qrCodeBatch3.isQrCodeBatch2)
    XCTAssertFalse("MM1B2055".isQrCodeBatch2)
    XCTAssertFalse("MM1B20567.8".isQrCodeBatch2)
    XCTAssertFalse("M11B20554".isQrCodeBatch2)
    XCTAssertFalse("xMM1B2554".isQrCodeBatch2)
  }

  func test_is_QrCodeBatch3() {
    XCTAssertTrue(qrCodeBatch3.isQrCodeBatch3)

    XCTAssertFalse(qrCodeBatch1.isQrCodeBatch3)
    XCTAssertFalse(qrCodeBatch2.isQrCodeBatch3)
    XCTAssertFalse("MM1B30054".isQrCodeBatch3)
    XCTAssertFalse("MM1B3005440".isQrCodeBatch3)
  }

  func testIsQrCode() {
    let validQrCodes = [qrCodeBatch1, qrCodeBatch2, qrCodeBatch3]
    for validQrCode in validQrCodes {
      XCTAssertTrue(validQrCode.isQrCode)
    }

    XCTAssertFalse("xMM1B2554".isQrCode)
    XCTAssertFalse("MM1000055".isQrCode)
    XCTAssertFalse("M100005555".isQrCode)
    XCTAssertFalse("1MM0005555".isQrCode)
    XCTAssertFalse("MM123456".isQrCode)
    XCTAssertFalse("MM123456789".isQrCode)
    XCTAssertFalse("".isQrCode)
    XCTAssertFalse("MM".isQrCode)
    XCTAssertFalse("MM1B2".isQrCode)
  }
}
