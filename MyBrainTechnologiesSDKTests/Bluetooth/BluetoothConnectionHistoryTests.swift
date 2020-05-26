import XCTest
@testable import MyBrainTechnologiesSDK

class BluetoothConnectionHistoryTests: XCTestCase {

  func testAddState() {
    let history = BluetoothConnectionHistory(historySize: 3)

    // When
    history.addState(isConnected: true)
    // Then
    XCTAssertTrue(history.isConnected)

    // When
    history.addState(isConnected: false)
    // Then
    XCTAssertFalse(history.isConnected)
  }

  func testAddState_moreThanLimit() {
    let history = BluetoothConnectionHistory(historySize: 2)

    // When
    history.addState(isConnected: true)
    history.addState(isConnected: true)
    // Then
    XCTAssertTrue(history.isConnected)

    // When
    history.addState(isConnected: true)
    // Then
    XCTAssertTrue(history.isConnected)

    // When
    history.addState(isConnected: false)
    // Then
    XCTAssertFalse(history.isConnected)
    XCTAssertTrue(history.historyIsFull)
  }

  func testHistoryIsFull() {
    let history = BluetoothConnectionHistory(historySize: 2)

    // When
    history.addState(isConnected: true)
    history.addState(isConnected: true)
    // Then
    XCTAssertTrue(history.historyIsFull)

    // When
    history.addState(isConnected: true)
    // Then
    XCTAssertTrue(history.historyIsFull)
  }

  func testHasNoHistory() {
    let history = BluetoothConnectionHistory(historySize: 2)

    // Then
    XCTAssertTrue(history.hasNoHistory)

    // When
    history.addState(isConnected: true)
    // Then
    XCTAssertFalse(history.hasNoHistory)
  }
}
