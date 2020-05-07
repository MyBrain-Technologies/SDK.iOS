import XCTest
@testable import MyBrainTechnologiesSDK

class CSVConverterTests: XCTestCase {

    func testCSVConverter_dataOneLine() {
      let string = "hello,world"

      // When
      let data = CSVConverter.data(fromString: string,
                                   lineSeparator: "\n",
                                   columnSeparator: ",")

      // Then
      XCTAssertEqual(data, [["hello", "world"]])
    }

    func testCSVConverter_dataSeveralLine() {
      let string = """
hello,world
how are you,my,little,pony
"""
      // When
      let data = CSVConverter.data(fromString: string,
                                   lineSeparator: "\n",
                                   columnSeparator: ",")

      // Then
      XCTAssertEqual(data, [
        ["hello", "world"],
        ["how are you", "my", "little", "pony"]
      ])
  }

  func testCSVConverter_dataClassicUse() {
    let string = """
    MM10000508,1010100967
    MM10001438,1010100968
    MM10000528,1010100969
    """

    // When
    let data = CSVConverter.data(fromString: string,
                                 lineSeparator: "\n",
                                 columnSeparator: ",")

    // Then
    XCTAssertEqual(data, [
      ["MM10000508", "1010100967"],
      ["MM10001438", "1010100968"],
      ["MM10000528", "1010100969"]
    ])
  }
}
