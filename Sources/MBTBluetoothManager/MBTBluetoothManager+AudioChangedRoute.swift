import Foundation
import AVFoundation

// TEMP: LEGACY CODE
// swiftlint:disable function_body_length

extension MBTBluetoothManager {

  /// Audio A2DP changing route output handler.
  /// - Parameter notif: The *notification* received when audio route output changed.
  @objc func audioChangedRoute(_ notif: Notification) {
    guard isAudioOutputValid(audioNotif: notif),
     let audioOutputName = getNewAudioOutputName() else {
        DispatchQueue.main.async {
          self.audioA2DPDelegate?.audioA2DPDidDisconnect?()
        }
        return
    }

    log.info("📲 New output port name", context: audioOutputName)

    // A2DP Audio is connected
    DispatchQueue.main.async {
      self.audioA2DPDelegate?.audioA2DPDidConnect?()
      self.completeAudioConnection(to: audioOutputName)
    }
  }

  private func completeAudioConnection(to deviceName: String) {
    guard isAudioAndBLEConnected else {
      connectTo(deviceName)
      return
    }

    if isOADInProgress {
      completeAudioConnectionAfterOAD(to: deviceName)
    } else {
      completeBasicAudioConnection(to: deviceName)
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Default Audio Connection
  //----------------------------------------------------------------------------

  private func completeBasicAudioConnection(to deviceName: String) {
    guard DeviceManager.connectedDeviceName == deviceName else {
      connectTo(deviceName)
      return
    }

    timers.stopA2DPConnectionTimer()

    eventDelegate?.onConnectionEstablished?()
    startBatteryLevelTimer()
  }

  //----------------------------------------------------------------------------
  // MARK: - Audio connection after OAD
  //----------------------------------------------------------------------------

  private func completeAudioConnectionAfterOAD(to deviceName: String) {
    guard isBLEConnected, isOADInProgress else {
      connectTo(deviceName)
      return
    }

    if isDeviceFirmwareVersionUpToDate() {
      completeOADProgressAfterAudioConnection()
    } else {
      if OADState == .rebootRequired {
        log.verbose("Reboot is still required to update devices informations !")
        return
      }

      interruptOADProgressAfterAudioConnection()
    }
  }

  private func completeOADProgressAfterAudioConnection() {
    eventDelegate?.onProgressUpdate?(1.0)
    isOADInProgress = false
    OADState = .disable
  }

  private func interruptOADProgressAfterAudioConnection() {
    isOADInProgress = false
    OADState = .disable

    let error = FirmwareError.versionInvalidAfterUpdate.error
    log.error("📲 Bluetooth transfer failed", context: error)

    eventDelegate?.onUpdateFailWithError?(error)
  }



  //----------------------------------------------------------------------------
  // MARK: - Tools
  //----------------------------------------------------------------------------

  private func getNewAudioOutputName() -> String? {
    let melomindOutput = AudioOutputs().melomindOutput

    guard let serialNumber =
      melomindOutput?.portName.serialNumberFromDeviceName else { return nil }

    let melomindAudioOutputName =
      Constants.DeviceName.blePrefix + serialNumber

    log.info("📲 New output audio port name", context: melomindAudioOutputName)

    return melomindAudioOutputName
  }

  private func isAudioOutputValid(audioNotif: Notification) -> Bool {
    guard let lastOutput = AudioNotification(audioNotif).lastAudioPort,
      let output = AudioOutputs().melomindOutput else { return false }

    log.info("🔊 Last audio output port name", context: lastOutput.portName)

    let serialNumber = output.portName.serialNumberFromDeviceName ?? ""
    let lastSerialNumber = lastOutput.portName.serialNumberFromDeviceName ?? ""

    return serialNumber != lastSerialNumber
  }

  private func isDeviceFirmwareVersionUpToDate() -> Bool {
    let currentFwVersion = FormatedVersion(string:
      DeviceManager.getCurrentDevice()?.deviceInfos?.firmwareVersion ?? ""
    )
    let oadFwVersion =
      FormatedVersion(string: self.OADManager?.fwVersion ?? "")

    log.info("📲 Current device firmware version",
             context: currentFwVersion)
    log.info("📲 Expected firmware version",
             context: oadFwVersion)

    return currentFwVersion == oadFwVersion
  }
}
