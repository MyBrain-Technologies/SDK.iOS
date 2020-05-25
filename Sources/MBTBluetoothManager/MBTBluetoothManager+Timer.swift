import Foundation

extension MBTBluetoothManager {

  /// Invalidate Update Battery Level Timer and set it to nil
  func stopTimerUpdateBatteryLevel() {
    if let timerUpdateBatteryLevel = timerUpdateBatteryLevel,
      timerUpdateBatteryLevel.isValid {
      timerUpdateBatteryLevel.invalidate()
    }
    timerUpdateBatteryLevel = nil
  }

  /// Invalidate Time Out Connection Timer and set it to nil
  func stopTimerTimeOutConnection() {
    if let timerTimeOutConnection = timerTimeOutConnection,
      timerTimeOutConnection.isValid {
      timerTimeOutConnection.invalidate()
    }
    timerTimeOutConnection = nil
  }

  /// Invalidate Time Out OAD Timer and set it to nil
  func stopTimerTimeOutOAD() {
    if let timerTimeOutOAD = timerTimeOutOAD,
      timerTimeOutOAD.isValid {
      timerTimeOutOAD.invalidate()
    }
    timerTimeOutOAD = nil
  }

  /// Invalidate Time Out A2DP Connection and set it to nil
  func stopTimerTimeOutA2DPConnection() {
    if let timerTimeOutA2DPConnection = timerTimeOutA2DPConnection,
      timerTimeOutA2DPConnection.isValid {
      timerTimeOutA2DPConnection.invalidate()
    }
    timerTimeOutA2DPConnection = nil
  }

  func stopTimerFinalizeConnectionMelomind() {
    if let timerFinalizeConnectionMelomind = timerFinalizeConnectionMelomind,
      timerFinalizeConnectionMelomind.isValid {
      timerFinalizeConnectionMelomind.invalidate()
    }
    timerFinalizeConnectionMelomind = nil
  }

  func stopTimerSendExternalName() {
    if let timerTimeOutSendExternalName = timerTimeOutSendExternalName,
      timerTimeOutSendExternalName.isValid {
      timerTimeOutSendExternalName.invalidate()
    }
  }

  /// Start Update Battery Level Timer that will send event receiveBatteryLevelOnUpdate
  func startTimerUpdateBatteryLevel() {
    stopTimerUpdateBatteryLevel()

    let timeInterval = eventDelegate?.timeIntervalOnReceiveBattery?()
      ?? Constants.Timeout.batteryLevel
    let timeDiff = TimeInterval(5)

    timerUpdateBatteryLevel = Timer.scheduledTimer(
      timeInterval: timeInterval - timeDiff,
      target: self,
      selector: #selector(requestUpdateBatteryLevel),
      userInfo: nil,
      repeats: true
    )

    Timer.scheduledTimer(timeInterval: timeDiff,
                         target: self,
                         selector: #selector(requestUpdateBatteryLevel),
                         userInfo: nil,
                         repeats: false)
  }

  /// Method Call if the Melomind can not connect after 20 Seconds
  @objc func connectionMelomindTimeOut() {
    bluetoothConnector.stopScanningForConnections()
    stopTimerTimeOutConnection()

    let error = BluetoothLowEnergyError.connectionTimeOut.error
    log.error("📲 Connection to device timeout", context: error)

    if isOADInProgress {
      isOADInProgress = false
      eventDelegate?.onUpdateFailWithError?(error)
    } else {
      eventDelegate?.onConnectionFailed?(error)
    }
  }

  @objc func connetionA2DPTimeOut() {
    disconnect()

    let error = AudioError.audioConnectionTimeOut.error
    log.error("📲 Audio connection timeout", context: error)

    if isOADInProgress {
      eventDelegate?.onUpdateFailWithError?(error)
    } else {
      eventDelegate?.onConnectionFailed?(error)
    }
  }

  @objc func sendExternalNameTimeOut() {
    log.verbose(#function)
  }

  /// Method Call Time Out Connection Protocol
  @objc func oadTransfertTimeOut() {
    stopTimerTimeOutOAD()

    if OADState < .completed {
      isOADInProgress = false
    }

    let error = OADError.transferTimeOut.error
    log.error("OAD transfer has timeout", context: error)

    eventDelegate?.onUpdateFailWithError?(error)
  }

}
