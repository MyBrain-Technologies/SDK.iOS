import Foundation

/*******************************************************************************
 * BluetoothTimersDelegate
 *
 * Methods called when a timer reach its timeout
 *
 ******************************************************************************/
protocol BluetoothTimersDelegate: class {
  func didBleConnectionTimeout()
  func didSendExternalNameTimeout()
  func didBatteryLevelTimeout()
  func didOADTimeout()
  func didFinalizeConnectionTimeout()
  func didA2DPConnectionTimeout()
}

/*******************************************************************************
 * BluetoothTimers
 *
 * Legacy use.
 * Set of timers used with the bluetooth manager.
 *
 ******************************************************************************/
class BluetoothTimers {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  var bleConnectionTimer: Timer?

  var a2dpConnectionTimer: Timer?

  var sendExternalNameTimer: Timer?

  var updateBatteryLevelTimer: Timer?

  var finalizeMelomindConnectionTimer: Timer?

  var oadTimer: Timer?

  /******************** Timer-related ********************/

  var isBleConnectionTimerInProgress: Bool {
    return bleConnectionTimer != nil
  }

  /******************** Delegate ********************/

  weak var delegate: BluetoothTimersDelegate?

  //----------------------------------------------------------------------------
  // MARK: - Initialize
  //----------------------------------------------------------------------------

  init(delegate: BluetoothTimersDelegate?) {
    self.delegate = delegate
  }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  func stopAllTimers() {
    stopBLEConnectionTimer()
    stopA2DPConnectionTimer()
    stopSendExternalNameTimer()
    stopBatteryLevelTimer()
    stopFinalizeConnectionMelomindTimer()
    stopOADTimer()
  }

  /******************** Battery Level ********************/

  /// Invalidate Update Battery Level Timer and set it to nil
  func stopBatteryLevelTimer() {
    log.verbose("⏰ Stop BatteryTimer")

    updateBatteryLevelTimer?.invalidate()
    updateBatteryLevelTimer = nil
  }

  func startBatteryLevelTimer(timeInterval: TimeInterval? = nil) {
    stopBatteryLevelTimer()

    log.verbose("⏰ Start BatteryTimer for \(String(describing: timeInterval))")

    updateBatteryLevelTimer = Timer.scheduledTimer(
      timeInterval: timeInterval ?? Constants.Timeout.batteryLevel,
      target: self,
      selector: #selector(batteryLevelHasTimeout),
      userInfo: nil,
      repeats: true
    )

    let verification = TimeInterval(5)
    Timer.scheduledTimer(timeInterval: verification,
                         target: self,
                         selector: #selector(batteryLevelHasTimeout),
                         userInfo: nil,
                         repeats: false)
  }

  @objc private func batteryLevelHasTimeout() {
    log.verbose("⏰ Timeout BatteryTimer")
    delegate?.didBatteryLevelTimeout()
  }

  /******************** BLE Connection ********************/

  func startBLEConnectionTimer() {
    stopBLEConnectionTimer()

    log.verbose("⏰ Start BLE timer for \(Constants.Timeout.connection)s")

    bleConnectionTimer = Timer.scheduledTimer(
      timeInterval: Constants.Timeout.connection,
      target: self,
      selector: #selector(bleConnectionTimeOut),
      userInfo: nil,
      repeats: false
    )
  }

  @objc private func bleConnectionTimeOut() {
    log.verbose("⏰ Timeout BLE Timer")

    stopBLEConnectionTimer()
    delegate?.didBleConnectionTimeout()
  }

  /// Invalidate Time Out Connection Timer and set it to nil
  func stopBLEConnectionTimer() {
    log.verbose("⏰ Stop BLE Timer")

    bleConnectionTimer?.invalidate()
    bleConnectionTimer = nil
  }

  /******************** OAD ********************/

  /// Invalidate Time Out OAD Timer and set it to nil
  func stopOADTimer() {
    log.verbose("⏰ Stop OAD Timer")
    oadTimer?.invalidate()
    oadTimer = nil
  }

  func startOADTimer() {
    log.verbose("⏰ Start OAD Timer")

    oadTimer = Timer.scheduledTimer(
      timeInterval: Constants.Timeout.oadTransfer,
      target: self,
      selector: #selector(self.oadTimeout),
      userInfo: nil,
      repeats: false
    )
  }

  @objc private func oadTimeout() {
    log.verbose("⏰ Timeout OAD Timer")

    stopOADTimer()
    delegate?.didOADTimeout()
  }

  /******************** A2DP Connection ********************/

  /// Invalidate Time Out A2DP Connection and set it to nil
  func stopA2DPConnectionTimer() {
    log.verbose("⏰ Stop A2DP Timer")

    a2dpConnectionTimer?.invalidate()
    a2dpConnectionTimer = nil
  }

  func startA2DPConnectionTimer() {
    log.verbose("⏰ Start A2DP Timer")

    a2dpConnectionTimer = Timer.scheduledTimer(
      timeInterval: Constants.Timeout.a2dpConnection,
      target: self,
      selector: #selector(a2dpConnectionTimeout),
      userInfo: nil,
      repeats: false
    )
  }

  @objc private func a2dpConnectionTimeout() {
    log.verbose("⏰ Timeout A2DP Timer")

    delegate?.didA2DPConnectionTimeout()
  }

  /******************** Finalize connection ********************/

  func stopFinalizeConnectionMelomindTimer() {
    log.verbose("⏰ Stop Finalize Connection Timer")

    finalizeMelomindConnectionTimer?.invalidate()
    finalizeMelomindConnectionTimer = nil
  }

  func startFinalizeConnectionTimer() {
    log.verbose("⏰ Start Finalize Connection Timer")

    finalizeMelomindConnectionTimer = Timer.scheduledTimer(
      timeInterval: Constants.Timeout.finalizeConnection,
      target: self,
      selector: #selector(finalizeConnectionTimeout),
      userInfo: nil,
      repeats: false
    )
  }

  @objc private func finalizeConnectionTimeout() {
    log.verbose("⏰ Timeout Finalize Connection Timer")

    delegate?.didFinalizeConnectionTimeout()
  }

  /******************** Send External Name ********************/

  func stopSendExternalNameTimer() {
    log.verbose("⏰ Stop SendExternalName Timer")

    sendExternalNameTimer?.invalidate()
    sendExternalNameTimer = nil
  }

  func startSendExternalNameTimer() {
    log.verbose("⏰ Start SendExternalName Timer")

    sendExternalNameTimer = Timer.scheduledTimer(
      timeInterval: Constants.Timeout.sendExternalName,
      target: self,
      selector: #selector(sendExternalNameTimeout),
      userInfo: nil,
      repeats: false
    )
  }

  @objc private func sendExternalNameTimeout() {
    log.verbose("⏰ Timeout SendExternalName Timer")
    delegate?.didSendExternalNameTimeout()
  }

}
