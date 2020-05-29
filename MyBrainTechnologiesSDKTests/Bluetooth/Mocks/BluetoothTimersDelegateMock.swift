import Foundation
@testable import MyBrainTechnologiesSDK

class BluetoothTimersDelegateMock: BluetoothTimersDelegate {
  var bleCount = 0
  var sendExternalNameCount = 0
  var batteryLevelCount = 0
  var oadCount = 0
  var finalizeConnectionCount = 0
  var a2dpConnectionCount = 0

  func didBleConnectionTimeout() {
    bleCount += 1
  }

  func didSendExternalNameTimeout() {
    sendExternalNameCount += 1
  }

  func didBatteryLevelTimeout() {
    batteryLevelCount += 1
  }

  func didOADTimeout() {
    oadCount += 1
  }

  func didFinalizeConnectionTimeout() {
    finalizeConnectionCount += 1
  }

  func didA2DPConnectionTimeout() {
    a2dpConnectionCount += 1
  }

}
