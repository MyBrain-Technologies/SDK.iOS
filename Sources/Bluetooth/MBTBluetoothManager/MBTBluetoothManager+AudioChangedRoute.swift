import Foundation
import AVFoundation

// TEMP: LEGACY CODE
// swiftlint:disable function_body_length

extension MBTBluetoothManager {

  /// Audio A2DP changing route output handler.
  /// - Parameter notif : The *notification* received when audio route output changed.
  @objc func audioChangedRoute(_ notif:Notification) {

    guard let userInfo = notif.userInfo else { return }

    //
    // Get the last audio output route used
    var lastOutput: AVAudioSessionPortDescription! = nil

    let lastRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey]
    if let previousRoute = lastRoute as? AVAudioSessionRouteDescription {
      lastOutput = previousRoute.outputs[0]
    }

    log.info("📲 Last output port name", context: lastOutput.portName)

    // Get the actual route used
    guard let output = getA2DPDeviceOutput(),
      let serialNumber = getSerialNumberFrom(deviceName: output.portName),
      let lastSerialNumber =
      getSerialNumberFrom(deviceName: lastOutput.portName),
      serialNumber != lastSerialNumber else {
        MBTBluetoothA2DPHelper.uid = nil
        // MBT A2DP audio is disconnected
        DispatchQueue.main.async {
          self.audioA2DPDelegate?.audioA2DPDidDisconnect?()
        }
        return
    }

    let meloName = "\(Constants.DeviceName.blePrefix)\(serialNumber)"
    log.info("📲 New output port name", context: meloName)

    MBTBluetoothA2DPHelper.uid = output.uid
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

        self.stopTimerTimeOutA2DPConnection()
        self.eventDelegate?.onConnectionEstablished?()
        self.startTimerUpdateBatteryLevel()
      } else {
        guard self.blePeripheral != nil, self.isOADInProgress else {
          self.connectTo(meloName)
          return
        }

        let currentFwVersion =
          DeviceManager.getCurrentDevice()?.deviceInfos?.firmwareVersion
        let oadFwVersion = self.OADManager?.fwVersion

        log.info("📲 Current device firmware version",
                 context: currentFwVersion)
        log.info("📲 Expected firmware version",
                 context: oadFwVersion)

        if let currentDeviceInfo =
          DeviceManager.getCurrentDevice()?.deviceInfos,
          self.OADManager != nil,
          let currentFwVersion = currentDeviceInfo.firmwareVersion,
          currentFwVersion.contains(self.OADManager!.fwVersion) {

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
