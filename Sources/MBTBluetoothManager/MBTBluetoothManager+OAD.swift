import Foundation

extension MBTBluetoothManager {

  /// Start the OAD Process
  /// - important: Event
  /// - didOADFailWithError: 916 | Device Not connected
  /// - didOADFailWithError: 909 | Device Infos is not available
  /// - didOADFailWithError: 910 | Latest firmware already installed
  /// - didOADFailWithError: 912 | Time Out OAD Transfert
  /// - onProgressUpdate
  func startOAD() {
    // Disconnect A2DP

    guard isConnected else {
      self.isOADInProgress = false

      let error = DeviceError.notConnected.error
      log.error("📲 OAD cannot start", context: error)

      self.eventDelegate?.onUpdateFailWithError?(error)
      return
    }

    isOADInProgress = true
    timers.stopOADTimer()

    guard let device = DeviceManager.getCurrentDevice() else {
      isOADInProgress = false

      let error = DeviceError.infoUnavailable.error
      log.error("📲 OAD cannot start", context: error)

      eventDelegate?.onUpdateFailWithError?(error)
      return
    }

    guard let filename = BinariesFileFinder().higherBinaryFilename(for: device),
      device.shouldUpdateFirmware else {
        isOADInProgress = false
        OADState = .disable

        let error = FirmwareError.alreadyUpToDate.error
        log.error("📲 OAD cannot start", context: error)

        eventDelegate?.onUpdateFailWithError?(error)
        return
    }

    OADState = .started
    timers.startOADTimer()

    OADManager = MBTOADManager(filename)

    let fwVersion = String(describing: OADManager?.fwVersion)
    log.info("Update firmware version to version", context: fwVersion)

    timers.stopBatteryLevelTimer()

    peripheralIO.notifyMailBox(value: true)

    sendFWVersionPlusLength()
  }

  /// Send the binary to the Melomind
  func sendOADBuffer() {
    DispatchQueue.global().async {
      var oldProgress = -1

      guard let oadManager = self.OADManager else { return }

      oadManager.oadProgress.iBlock = 0

      while oadManager.oadProgress.iBlock < oadManager.mOadBuffer.count {
        usleep(6000)
        if !self.isConnectedBLE || self.OADState != .inProgress {
          break
        }

        let iBlock = Float(oadManager.oadProgress.iBlock)
        let bufferCount = Float(oadManager.mOadBuffer.count)

        guard iBlock < bufferCount else { continue }

        let buffer = oadManager.getNextOADBuffer()
        self.peripheralIO.write(oadBuffer: buffer)

        DispatchQueue.main.async {
          let progress = Int(iBlock / bufferCount * 100)

          guard progress != oldProgress else { return }

          let progressValue = Float((Float(progress) * 0.80) / 100) + 0.1
          self.eventDelegate?.onProgressUpdate?(progressValue)
          oldProgress = progress
        }
      }
    }
  }

}
