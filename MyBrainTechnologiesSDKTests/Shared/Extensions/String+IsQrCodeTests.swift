import XCTest
@testable import MyBrainTechnologiesSDK

class StringIsQrCodeTests: XCTestCase {

  func testIsQrCodeBatch1() {
    XCTAssertTrue("MM10000554".isQrCodeBatch1)
    XCTAssertTrue("MM1B205544".isQrCodeBatch1)

    XCTAssertFalse("MM1B20554".isQrCodeBatch1)
    XCTAssertFalse("MM100005544".isQrCodeBatch1)
    XCTAssertFalse("MM1000055".isQrCodeBatch1)
    XCTAssertFalse("M100005555".isQrCodeBatch1)
    XCTAssertFalse("1MM0005555".isQrCodeBatch1)
  }

  func testIsQrCodeBatch2() {
    XCTAssertTrue("MM1B20554".isQrCodeBatch2)

    XCTAssertFalse("MM10000554".isQrCodeBatch2)
    XCTAssertFalse("MM1B2055".isQrCodeBatch2)
    XCTAssertFalse("MM1B205678".isQrCodeBatch2)
    XCTAssertFalse("M11B20554".isQrCodeBatch2)
    XCTAssertFalse("xMM1B2554".isQrCodeBatch2)
  }

  func testIsQrCode() {
    XCTAssertTrue("MM1B20554".isQrCode)
    XCTAssertTrue("MM10000554".isQrCode)

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
