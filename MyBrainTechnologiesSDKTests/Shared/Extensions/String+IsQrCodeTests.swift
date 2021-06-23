import XCTest
@testable import MyBrainTechnologiesSDK

class StringIsQrCodeTests: XCTestCase {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  let qrCodeBatch1 = "MM10000554"
  let qrCodeBatch2 = "MM1B20554."
  let qrCodeBatch3 = "MM1B300001"
  let qrCodeBatch4 = "MM1B400011"
  #warning("Swap fsk and batch5 qrcode?")
  let qrCodeFSK = "MM2B200007"
  let qrCodeBatch5 = "MM2B100007"

  var validQrCodes: [String] {
    return [
      qrCodeBatch1,
      qrCodeBatch2,
      qrCodeBatch3,
      qrCodeBatch4,
      qrCodeFSK,
      qrCodeBatch5
    ]
  }

  //----------------------------------------------------------------------------
  // MARK: - Tests
  //----------------------------------------------------------------------------

  func isNotAnOtherQRCodes(qrCode: String, condition: ((String) -> Bool)) {
    let isValidQRCode = validQrCodes.contains(qrCode)
    XCTAssertTrue(isValidQRCode)

    let otherQRCodes = validQrCodes.filter { $0 != qrCode }

    let isNotQRCodeInside = otherQRCodes.contains(qrCode)
    XCTAssertFalse(isNotQRCodeInside)

    for otherQRCode in otherQRCodes {
      print(otherQRCode)
      let isNotBatchQRCode = condition(otherQRCode)
      XCTAssertFalse(isNotBatchQRCode)
    }
  }

  func testIsQrCodeBatch1() {
    XCTAssertTrue(qrCodeBatch1.isQrCodeBatch1)
    // XCTAssertTrue("MM1B205544".isQrCodeBatch1)

    isNotAnOtherQRCodes(qrCode: qrCodeBatch1) {
      return $0.isQrCodeBatch1
    }

    XCTAssertFalse("MM100005544".isQrCodeBatch1)
    XCTAssertFalse("MM1000055".isQrCodeBatch1)
    XCTAssertFalse("M100005555".isQrCodeBatch1)
    XCTAssertFalse("1MM0005555".isQrCodeBatch1)
  }

  func testIsQrCodeBatch2() {
    XCTAssertTrue(qrCodeBatch2.isQrCodeBatch2)

    isNotAnOtherQRCodes(qrCode: qrCodeBatch2) {
      return $0.isQrCodeBatch2
    }

    XCTAssertFalse("MM1B2055".isQrCodeBatch2)
    XCTAssertFalse("MM1B20567.8".isQrCodeBatch2)
    XCTAssertFalse("M11B20554".isQrCodeBatch2)
    XCTAssertFalse("xMM1B2554".isQrCodeBatch2)
  }

  func test_is_QrCodeBatch3() {
    XCTAssertTrue(qrCodeBatch3.isQrCodeBatch3)

    isNotAnOtherQRCodes(qrCode: qrCodeBatch3) {
      return $0.isQrCodeBatch3
    }

    XCTAssertFalse("MM1B30054".isQrCodeBatch3)
    XCTAssertFalse("MM1B3005440".isQrCodeBatch3)
  }

  func test_is_QrCodeBatch4() {
    XCTAssertTrue(qrCodeBatch4.isQrCodeBatch4)

    isNotAnOtherQRCodes(qrCode: qrCodeBatch4) {
      return $0.isQrCodeBatch4
    }
    XCTAssertFalse("MM1B40054".isQrCodeBatch4)
    XCTAssertFalse("MM1B4005440".isQrCodeBatch4)
  }

  func test_is_QrCodeFSK() {
    XCTAssertTrue(qrCodeFSK.isQrCodeFSK)

    isNotAnOtherQRCodes(qrCode: qrCodeFSK) {
      return $0.isQrCodeFSK
    }
    XCTAssertFalse("MM2B20000".isQrCodeFSK)
    XCTAssertFalse("MM2B2000070".isQrCodeFSK)
  }

  func test_is_QrCodeBatch5() {
    XCTAssertTrue(qrCodeBatch5.isQrCodeBatch5)

    isNotAnOtherQRCodes(qrCode: qrCodeBatch5) {
      return $0.isQrCodeBatch5
    }
    XCTAssertFalse("MM2B10000".isQrCodeBatch5)
    XCTAssertFalse("MM2B1000070".isQrCodeBatch5)
  }

  func testIsQrCode() {
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
