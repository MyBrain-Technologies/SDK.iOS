import XCTest
@testable import MyBrainTechnologiesSDK

class FormatedVersionTests: XCTestCase {

  //----------------------------------------------------------------------------
  // MARK: - Initialization Tests
  //----------------------------------------------------------------------------

  func testFormatedVersion_FromString() {
    let version = "1.0.2"

    // When
    let formatedVersion = FormatedVersion(string: version)

    // Then
    XCTAssertEqual(formatedVersion.major, 1)
    XCTAssertEqual(formatedVersion.minor, 0)
    XCTAssertEqual(formatedVersion.fix, 2)
  }

  func testFormatedVersion_FromUnderscoreString() {
    let version = "1_0_2"

    // When
    let formatedVersion = FormatedVersion(string: version)

    // Then
    XCTAssertEqual(formatedVersion.major, 1)
    XCTAssertEqual(formatedVersion.minor, 0)
    XCTAssertEqual(formatedVersion.fix, 2)
  }

  func testFormatedVersion_FromInvalidString() {
    let version = "hello1.0.2"

    // When
    let formatedVersion = FormatedVersion(string: version)

    // Then
    XCTAssertEqual(formatedVersion.major, 0)
    XCTAssertEqual(formatedVersion.minor, 0)
    XCTAssertEqual(formatedVersion.fix, 2)
  }

  func testFormatedVersion_FromIncompleteString() {
    let version = ".0.2"

    // When
    let formatedVersion = FormatedVersion(string: version)

    // Then
    XCTAssertEqual(formatedVersion.major, 0)
    XCTAssertEqual(formatedVersion.minor, 0)
    XCTAssertEqual(formatedVersion.fix, 2)
  }

  func testFormatedVersion_FromIncompleteString2() {
    let version = "0.2"

    // When
    let formatedVersion = FormatedVersion(string: version)

    // Then
    XCTAssertEqual(formatedVersion.major, 0)
    XCTAssertEqual(formatedVersion.minor, 0)
    XCTAssertEqual(formatedVersion.fix, 0)
  }

  func testFormatedVersion_Init2() {
    // When
    let formatedVersion = FormatedVersion(major: 1, minor: 2, fix: 3)

    // Then
    XCTAssertEqual(formatedVersion.major, 1)
    XCTAssertEqual(formatedVersion.minor, 2)
    XCTAssertEqual(formatedVersion.fix, 3)
  }

  //----------------------------------------------------------------------------
  // MARK: - Comparison Tests
  //----------------------------------------------------------------------------

  typealias Version = FormatedVersion

  func testFormatedVersion_Comparison() {
    XCTAssertTrue(Version(string: "1.0.0") < Version(string: "2.0.0"))
    XCTAssertTrue(Version(string: "1.0.1") < Version(string: "1.2.0"))
    XCTAssertTrue(Version(string: "1.0.1") < Version(string: "1.0.2"))
    XCTAssertTrue(Version(string: "1.0.100") < Version(string: "1.1.0"))
    XCTAssertTrue(Version(string: "1.1.100") < Version(string: "1.10.0"))
  }

  func testFormatedVersion_Equal() {
    XCTAssertTrue(Version(string: "1.0.0") == Version(string: "1.0.0"))
    XCTAssertTrue(Version(string: "2.0.0") == Version(string: "2.0.a"))
    XCTAssertTrue(Version(string: "2.0.0") == Version(string: "2..0"))

    XCTAssertTrue(Version(string: "1.0.0") != Version(string: "1.0.1"))
    XCTAssertTrue(Version(string: "1.0.0") != Version(string: "0.1.0"))
    XCTAssertTrue(Version(string: "1.0.0") != Version(string: "0.0.1"))
  }
}
