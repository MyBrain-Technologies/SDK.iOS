import XCTest
@testable import MyBrainTechnologiesSDK

class BluetoothTimersTests: XCTestCase {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  // swiftlint:disable weak_delegate
  let delegate = BluetoothTimersDelegateMock()

  lazy var timers: BluetoothTimers = {
    return BluetoothTimers(delegate: delegate)
  }()

  //----------------------------------------------------------------------------
  // MARK: - Tools
  //----------------------------------------------------------------------------

  private func stopBefore(_ deadline: DispatchTime,
                          completion: @escaping (() -> Void)) {
    DispatchQueue.main.asyncAfter(deadline: deadline - 0.1,
                                  execute: completion)
  }

  private func stopAfter(_ deadline: DispatchTime,
                         completion: @escaping (() -> Void)) {
    DispatchQueue.main.asyncAfter(deadline: deadline + 0.1,
                                  execute: completion)
  }

  //----------------------------------------------------------------------------
  // MARK: - BLE Timer
  //----------------------------------------------------------------------------

  func testBLETimer() {
    let expectation = XCTestExpectation(description: "Timer")
    let duration = 1.0
    let expectedCount = delegate.bleCount + 1

    // When
    timers.startBLEConnectionTimer(timeInterval: duration)
    XCTAssertTrue(self.timers.isBleConnectionTimerInProgress)

    // Then
    stopAfter(.now() + duration) {
      XCTAssertEqual(self.delegate.bleCount, expectedCount)
      XCTAssertFalse(self.timers.isBleConnectionTimerInProgress)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: duration + 2)
  }

  func testStopBLETimer() {
    let expectation = XCTestExpectation(description: "Timer")
    let duration = 1.0
    let expectedCount = delegate.bleCount

    timers.startBLEConnectionTimer(timeInterval: duration)

    stopBefore(.now() + duration) {
      // When
      self.timers.stopBLEConnectionTimer()

      // Then
      XCTAssertEqual(self.delegate.bleCount, expectedCount)
      XCTAssertFalse(self.timers.isBleConnectionTimerInProgress)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: duration + 2)
  }

  //----------------------------------------------------------------------------
  // MARK: - Send External Name Timer
  //----------------------------------------------------------------------------

  func testSendExternalNameTimer() {
    let expectation = XCTestExpectation(description: "Timer")
    let duration = 1.0
    let expectedCount = delegate.sendExternalNameCount + 1

    // When
    timers.startSendExternalNameTimer(timeInterval: duration)

    // Then
    stopAfter(.now() + duration) {
      XCTAssertEqual(self.delegate.sendExternalNameCount, expectedCount)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: duration + 2)
  }

  func testStopSendExternalNameTimer() {
    let expectation = XCTestExpectation(description: "Timer")
    let duration = 1.0
    let expectedCount = delegate.sendExternalNameCount

    timers.startSendExternalNameTimer(timeInterval: duration)

    stopBefore(.now() + duration) {
      // When
      self.timers.stopSendExternalNameTimer()

      //Then
      XCTAssertEqual(self.delegate.sendExternalNameCount, expectedCount)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: duration + 2)
  }

  func testBatteryLevelTimer() {
    let expectation = XCTestExpectation(description: "Timer")
    let duration = 1.0
    let expectedCount = delegate.batteryLevelCount + 2

    // When
    timers.startBatteryLevelTimer(timeInterval: duration,
                                  verificationTimeInterval: duration,
                                  repeats: false)

    // Then
    stopAfter(.now() + duration) {
      XCTAssertEqual(self.delegate.batteryLevelCount, expectedCount)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: duration + 2)
  }

  func testRepeatBatteryLevelTimer() {
    let expectation = XCTestExpectation(description: "Timer")
    let duration = 1.0
    let repeatCount = 3.0
    let totalDuration = duration * repeatCount
    let expectedCount = delegate.batteryLevelCount + Int(repeatCount) + 1

    // When
    timers.startBatteryLevelTimer(timeInterval: duration,
                                  verificationTimeInterval: duration,
                                  repeats: true)

    // Then
    stopAfter(.now() + totalDuration) {
      XCTAssertEqual(self.delegate.batteryLevelCount, expectedCount)

      self.timers.stopBatteryLevelTimer()

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: totalDuration + 2)
  }

  func testStopBatteryLevelTimer() {
    let expectation = XCTestExpectation(description: "Timer")
    let duration = 0.5
    let repeatCount = 3.0
    let totalDuration = duration * repeatCount
    let expectedCount = delegate.batteryLevelCount + Int(repeatCount) + 1

    timers.startBatteryLevelTimer(timeInterval: duration,
                                  verificationTimeInterval: duration,
                                  repeats: true)

    stopAfter(.now() + totalDuration) {
      XCTAssertEqual(self.delegate.batteryLevelCount, expectedCount)

      // When
      self.timers.stopBatteryLevelTimer()

      // Then
      self.stopAfter(.now() + duration) {
        XCTAssertEqual(self.delegate.batteryLevelCount, expectedCount)

        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: totalDuration + 2)
  }

  func testOADTimer() {
    let expectation = XCTestExpectation(description: "Timer")
    let duration = 1.0
    let expectedCount = delegate.oadCount + 1

    // When
    timers.startOADTimer(timeInterval: duration)

    // Then
    stopAfter(.now() + duration) {
      XCTAssertEqual(self.delegate.oadCount, expectedCount)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: duration + 2)
  }

  func testStopOADTimer() {
    let expectation = XCTestExpectation(description: "Timer")
    let duration = 1.0
    let expectedCount = delegate.oadCount

    timers.startOADTimer(timeInterval: duration)

    stopBefore(.now() + duration) {
      // When
      self.timers.stopOADTimer()

      //Then
      XCTAssertEqual(self.delegate.oadCount, expectedCount)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: duration + 1)
  }

  func testFinalizeConnectionTimer() {
    let expectation = XCTestExpectation(description: "Timer")
    let duration = 1.0
    let expectedCount = delegate.finalizeConnectionCount + 1

    // When
    timers.startFinalizeConnectionTimer(timeInterval: duration)

    // Then
    stopAfter(.now() + duration) {
      XCTAssertEqual(self.delegate.finalizeConnectionCount, expectedCount)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: duration + 2)
  }

  func testStopFinalizeConnectionTimer() {
    let expectation = XCTestExpectation(description: "Timer")
    let duration = 1.0
    let expectedCount = delegate.finalizeConnectionCount

    timers.startFinalizeConnectionTimer(timeInterval: duration)

    stopBefore(.now() + duration) {
      // When
      self.timers.stopFinalizeConnectionMelomindTimer()

      //Then
      XCTAssertEqual(self.delegate.finalizeConnectionCount, expectedCount)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: duration + 1)
  }

  func testA2DPConnectionTimer() {
    let expectation = XCTestExpectation(description: "Timer")
    let duration = 1.0
    let expectedCount = delegate.a2dpConnectionCount + 1

    // When
    timers.startA2DPConnectionTimer(timeInterval: duration)

    // Then
    stopAfter(.now() + duration) {
      XCTAssertEqual(self.delegate.a2dpConnectionCount, expectedCount)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: duration + 2)
  }

  func testStopA2DPConnectionTimer() {
    let expectation = XCTestExpectation(description: "Timer")
    let duration = 1.0
    let expectedCount = delegate.a2dpConnectionCount

    timers.startA2DPConnectionTimer(timeInterval: duration)

    stopBefore(.now() + duration) {
      // When
      self.timers.stopA2DPConnectionTimer()

      //Then
      XCTAssertEqual(self.delegate.a2dpConnectionCount, expectedCount)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: duration + 1)
  }
}
