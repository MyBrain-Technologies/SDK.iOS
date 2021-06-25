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
// GOOD
class BluetoothTimers {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private var bleConnectionTimer: Timer?

  private var a2dpConnectionTimer: Timer?

  private var sendExternalNameTimer: Timer?

  private var updateBatteryLevelTimer: Timer?

  private var finalizeMelomindConnectionTimer: Timer?

  private var oadTimer: Timer?

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

  //----------------------------------------------------------------------------
  // MARK: - Battery Level
  //----------------------------------------------------------------------------

  /// Invalidate Update Battery Level Timer and set it to nil
  func stopBatteryLevelTimer() {
    log.verbose("⏰ Stop BatteryTimer")

    updateBatteryLevelTimer?.invalidate()
    updateBatteryLevelTimer = nil
  }

  #warning("TODO: battery is read in looping mode with batteryLevelHasTimeout")
  func startBatteryLevelTimer(
    timeInterval: TimeInterval = Constants.Timeout.batteryLevel,
    verificationTimeInterval: TimeInterval = 5,
    repeats: Bool = true
  ) {
    stopBatteryLevelTimer()

    log.verbose("⏰ Start BatteryTimer for \(String(describing: timeInterval))")

    updateBatteryLevelTimer = Timer.scheduledTimer(
      timeInterval: timeInterval,
      target: self,
      selector: #selector(batteryLevelHasTimeout),
      userInfo: nil,
      repeats: repeats
    )

    Timer.scheduledTimer(timeInterval: verificationTimeInterval,
                         target: self,
                         selector: #selector(batteryLevelHasTimeout),
                         userInfo: nil,
                         repeats: false)
  }

  @objc private func batteryLevelHasTimeout() {
    log.verbose("⏰ Timeout BatteryTimer")

    delegate?.didBatteryLevelTimeout()
  }

  //----------------------------------------------------------------------------
  // MARK: - BLE Connection
  //----------------------------------------------------------------------------

  func startBLEConnectionTimer(
    timeInterval: TimeInterval = Constants.Timeout.connection
  ) {
    stopBLEConnectionTimer()

    log.verbose("⏰ Start BLE timer for \(timeInterval)s")

    bleConnectionTimer = Timer.scheduledTimer(
      timeInterval: timeInterval,
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

  //----------------------------------------------------------------------------
  // MARK: - OAD
  //----------------------------------------------------------------------------

  /// Invalidate Time Out OAD Timer and set it to nil
  func stopOADTimer() {
    log.verbose("⏰ Stop OAD Timer")
    oadTimer?.invalidate()
    oadTimer = nil
  }

  func startOADTimer(
    timeInterval: TimeInterval = Constants.Timeout.oadTransfer
  ) {
    log.verbose("⏰ Start OAD Timer")

    oadTimer = Timer.scheduledTimer(
      timeInterval: timeInterval,
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

  //----------------------------------------------------------------------------
  // MARK: - A2DP Connection
  //----------------------------------------------------------------------------

  /// Invalidate Time Out A2DP Connection and set it to nil
  func stopA2DPConnectionTimer() {
    log.verbose("⏰ Stop A2DP Timer")

    a2dpConnectionTimer?.invalidate()
    a2dpConnectionTimer = nil
  }

  func startA2DPConnectionTimer(
    timeInterval: TimeInterval = Constants.Timeout.a2dpConnection
  ) {
    log.verbose("⏰ Start A2DP Timer")

    a2dpConnectionTimer = Timer.scheduledTimer(
      timeInterval: timeInterval,
      target: self,
      selector: #selector(a2dpConnectionTimeout),
      userInfo: nil,
      repeats: false
    )
  }

  @objc private func a2dpConnectionTimeout() {
    log.verbose("⏰ Timeout A2DP Timer")

    stopA2DPConnectionTimer()
    delegate?.didA2DPConnectionTimeout()
  }

  //----------------------------------------------------------------------------
  // MARK: - Finalize connection
  //----------------------------------------------------------------------------

  func stopFinalizeConnectionMelomindTimer() {
    log.verbose("⏰ Stop Finalize Connection Timer")

    finalizeMelomindConnectionTimer?.invalidate()
    finalizeMelomindConnectionTimer = nil
  }

  func startFinalizeConnectionTimer(
    timeInterval: TimeInterval = Constants.Timeout.finalizeConnection
  ) {
    log.verbose("⏰ Start Finalize Connection Timer")

    finalizeMelomindConnectionTimer = Timer.scheduledTimer(
      timeInterval: timeInterval,
      target: self,
      selector: #selector(finalizeConnectionTimeout),
      userInfo: nil,
      repeats: false
    )
  }

  @objc private func finalizeConnectionTimeout() {
    log.verbose("⏰ Timeout Finalize Connection Timer")

    stopFinalizeConnectionMelomindTimer()
    delegate?.didFinalizeConnectionTimeout()
  }

  //----------------------------------------------------------------------------
  // MARK: - Send External Name
  //----------------------------------------------------------------------------

  func stopSendExternalNameTimer() {
    log.verbose("⏰ Stop SendExternalName Timer")

    sendExternalNameTimer?.invalidate()
    sendExternalNameTimer = nil
  }

  func startSendExternalNameTimer(
    timeInterval: TimeInterval = Constants.Timeout.sendExternalName
  ) {
    log.verbose("⏰ Start SendExternalName Timer")

    sendExternalNameTimer = Timer.scheduledTimer(
      timeInterval: timeInterval,
      target: self,
      selector: #selector(sendExternalNameTimeout),
      userInfo: nil,
      repeats: false
    )
  }

  @objc private func sendExternalNameTimeout() {
    log.verbose("⏰ Timeout SendExternalName Timer")

    stopSendExternalNameTimer()
    delegate?.didSendExternalNameTimeout()
  }

}
