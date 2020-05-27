import Foundation
import AVFoundation

// TEMP: LEGACY CODE
// swiftlint:disable function_body_length

extension MBTBluetoothManager {

  /// Audio A2DP changing route output handler.
  /// - Parameter notif: The *notification* received when audio route output changed.
  @objc func audioChangedRoute(_ notif: Notification) {
    log.verbose("🔊 Audio changed")
//    guard let userInfo = notif.userInfo else { return }

    // Get the last audio output route used
//    var lastOutput: AVAudioSessionPortDescription! = nil

//    let lastRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey]
//    if let previousRoute = lastRoute as? AVAudioSessionRouteDescription {
//      lastOutput = previousRoute.outputs[0]
//    }
    guard let lastOutput = AudioNotification(notif).lastAudioPort,
      let output = AudioOutputs().melomindOutput else { return }

    log.info("🔊 Last audio output port name", context: lastOutput.portName)

    print(AudioOutputs().outputs.map() { $0.portName })
    print(AudioOutputs().melomindOutput?.portName)

//    guard let output = AudioOutputs().melomindOutput,
//      let serialNumber = output.portName.serialNumberFromDeviceName,
//      let lastSerialNumber = lastOutput.portName.serialNumberFromDeviceName else {
//        log.error("current output portName")
//    }

    let serialNumber = output.portName.serialNumberFromDeviceName ?? ""
    let lastSerialNumber = lastOutput.portName.serialNumberFromDeviceName ?? ""

    // Get the actual route used
    guard
//      let output = AudioOutputs().melomindOutput,
      //  getSerialNumberFrom(deviceName: output.portName)
//      getSerialNumberFrom(deviceName: lastOutput.portName),
      serialNumber != lastSerialNumber else {
        // MBT A2DP audio is disconnected
        DispatchQueue.main.async {
          self.audioA2DPDelegate?.audioA2DPDidDisconnect?()
        }
        return
    }

    let meloName = "\(Constants.DeviceName.blePrefix)\(serialNumber)"
    log.info("📲 New output port name", context: meloName)

    // A2DP Audio is connected
    DispatchQueue.main.async {
      self.audioA2DPDelegate?.audioA2DPDidConnect?()

      guard self.isConnected else {
        self.connectTo(meloName)
        return
      }

      if !self.isOADInProgress {
        guard DeviceManager.connectedDeviceName == meloName else {
          self.connectTo(meloName)
          return
        }

        self.timers.stopA2DPConnectionTimer()
        
        self.eventDelegate?.onConnectionEstablished?()
        self.startBatteryLevelTimer()
      } else {
        guard self.isConnectedBLE, self.isOADInProgress else {
          self.connectTo(meloName)
          return
        }

        let currentFwVersion = FormatedVersion(string:
          DeviceManager.getCurrentDevice()?.deviceInfos?.firmwareVersion ?? ""
        )
        let oadFwVersion =
          FormatedVersion(string: self.OADManager?.fwVersion ?? "")

        log.info("📲 Current device firmware version",
                 context: currentFwVersion)
        log.info("📲 Expected firmware version",
                 context: oadFwVersion)

        if currentFwVersion == oadFwVersion {

          self.eventDelegate?.onProgressUpdate?(1.0)
          self.isOADInProgress = false
          self.OADState = .disable

        } else if self.OADState != .rebootRequired {

          self.isOADInProgress = false
          self.OADState = .disable

          let error = FirmwareError.versionInvalidAfterUpdate.error
          log.error("📲 Bluetooth transfer failed", context: error)

          self.eventDelegate?.onUpdateFailWithError?(error)
        }
      }
    }
  }
}
