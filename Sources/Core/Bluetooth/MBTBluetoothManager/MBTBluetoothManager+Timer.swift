import Foundation

extension MBTBluetoothManager: BluetoothTimersDelegate {

  func didSendExternalNameTimeout() {
    log.verbose(#function)
  }

  func didBleConnectionTimeout() {
    bluetoothConnection.cancelConnection()
//    bluetoothConnector.stopScanningForConnections()

    let error = BluetoothLowEnergyError.connectionTimeOut.error
    log.error("📲 Connection to device timeout", context: error)

    if isOADInProgress {
      isOADInProgress = false
      eventDelegate?.onUpdateFailWithError?(error)
    } else {
      eventDelegate?.onConnectionFailed?(error)
    }
  }

  func didBatteryLevelTimeout() {
    requestBatteryLevel()
  }

  /// Method Call Time Out Connection Protocol
  func didOADTimeout() {
    if OADState < .completed {
      isOADInProgress = false
    }

    let error = OADError.transferTimeOut.error
    log.error("OAD transfer has timeout", context: error)

    eventDelegate?.onUpdateFailWithError?(error)
  }

  func didFinalizeConnectionTimeout() {
    requestBatteryLevel()
  }

  func didA2DPConnectionTimeout() {
//    disconnect()

    let error = AudioError.audioConnectionTimeOut.error
    log.error("📲 Audio connection timeout", context: error)

    if isOADInProgress {
      eventDelegate?.onUpdateFailWithError?(error)
    } else {
      eventDelegate?.onConnectionFailed?(error)
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Legacy
  //----------------------------------------------------------------------------

  /// Start Update Battery Level Timer that will send event receiveBatteryLevelOnUpdate
  func startBatteryLevelTimer() {
    let timeInterval = eventDelegate?.timeIntervalOnReceiveBattery?()
    timers.startBatteryLevelTimer(timeInterval: timeInterval)
  }

}
