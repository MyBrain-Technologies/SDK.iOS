//
//  FormatedVersionTests.swift
//  MyBrainTechnologiesSDKTests-iOS
//
//  Created by Mathilde on 13/03/2019.
//  Copyright © 2019 MyBrainTechnologies. All rights reserved.
//

import XCTest
@testable import MyBrainTechnologiesSDK

class FormatedVersionTests: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testFormatedVersion() {
    XCTAssertEqual(FormatedVersion(fromString: "1.0.0"), FormatedVersion(majorVersion: 1, minorVersion: 0, patchVersion: 0))
//    XCTAssertEqual(FormatedVersion(fromString: "1.2.13"), FormatedVersion(majorVersion: 1, minorVersion: 2, patchVersion: 13))
//    XCTAssertEqual(FormatedVersion(fromString: "0.0.0"), FormatedVersion(majorVersion: 0, minorVersion: 0, patchVersion: 0))
//    XCTAssertEqual(FormatedVersion(fromString: "6.6.6"), FormatedVersion(majorVersion: 6, minorVersion: 6, patchVersion: 6))
  }
//
//  func testFormatedVersionGreaterThan() {
//    XCTAssertTrue(FormatedVersion(fromString: "1.2.0") > FormatedVersion(fromString: "1.1.0"))
//    XCTAssertTrue(FormatedVersion(fromString: "1.2.0") > FormatedVersion(fromString: "0.3.0"))
//    XCTAssertTrue(FormatedVersion(fromString: "1.2.0") > FormatedVersion(fromString: "1.1.9"))
//    XCTAssertTrue(FormatedVersion(fromString: "1.2.1") > FormatedVersion(fromString: "1.2.0"))
//    XCTAssertTrue(FormatedVersion(fromString: "2.0.0") > FormatedVersion(fromString: "1.1.0"))
//    XCTAssertTrue(FormatedVersion(fromString: "1.2.19") > FormatedVersion(fromString: "1.2.9"))
//    
//    XCTAssertFalse(FormatedVersion(fromString: "1.2.0") == FormatedVersion(fromString: "1.2.0"))
//  }
//  
//  func testFormatedVersionLowerThan() {
//    XCTAssertTrue(FormatedVersion(fromString: "1.2.0") < FormatedVersion(fromString: "1.3.0"))
//    XCTAssertTrue(FormatedVersion(fromString: "1.2.0") < FormatedVersion(fromString: "2.3.0"))
//    XCTAssertTrue(FormatedVersion(fromString: "1.2.0") < FormatedVersion(fromString: "1.2.1"))
//    XCTAssertTrue(FormatedVersion(fromString: "1.2.0") < FormatedVersion(fromString: "2.0.0"))
//    XCTAssertTrue(FormatedVersion(fromString: "0.2.0") < FormatedVersion(fromString: "0.2.2"))
//    XCTAssertTrue(FormatedVersion(fromString: "6.6.6") < FormatedVersion(fromString: "6.7.8"))
//    
//    XCTAssertFalse(FormatedVersion(fromString: "1.2.0") == FormatedVersion(fromString: "1.2.0"))
//  }
  
}
