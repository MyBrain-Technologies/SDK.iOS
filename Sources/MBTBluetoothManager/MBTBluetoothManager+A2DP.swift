import Foundation
import AVFoundation

extension MBTBluetoothManager {

  //----------------------------------------------------------------------------
  // MARK: - Connection
  //----------------------------------------------------------------------------

  /// Request the Melomind to connect A2DP
  /// important: Event
  /// - didOADFailWithError: 924 | Time Out Connection
  /// - onConnectionFailed: 924 | Time Out Cnnection
  func requestConnectA2DP() {
    timers.startA2DPConnectionTimer()

    peripheralIO.notifyMailBox(value: true)
    peripheralIO.writeA2DPConnection()
  }

  /// Listen to the AVAudioSessionRouteChange Notification
  func connectA2DP() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(audioChangedRoute(_:)),
      name: AVAudioSession.routeChangeNotification,
      object: nil
    )

    guard audioA2DPDelegate != nil else { return }

    let session = AVAudioSession.sharedInstance()
    let output = session.currentRoute.outputs.first

    if let deviceName = DeviceManager.connectedDeviceName,
      output?.portName == deviceName && output?.portType == .bluetoothA2DP {
      // A2DP Audio is connected
      audioA2DPDelegate?.audioA2DPDidConnect?()
    } else {
      // Try to set Category to help device to connect
      // to the MBT A2DP profile

      do {
        try session.setCategory(.playback, options: .allowBluetooth)

      } catch {
        log.error("📲 Audio connection failed", context: error)
      }
    }
  }

  internal func shouldRequestA2DPConnection() -> Bool {
    return (audioA2DPDelegate?.autoConnectionA2DPFromBLE?() ?? false) == true
      && getBLEDeviceNameFromA2DP() != DeviceManager.connectedDeviceName
      && deviceFirmwareVersion(isHigherOrEqualThan: .a2dpFromHeadset)
  }

  //----------------------------------------------------------------------------
  // MARK: - Device Name
  //----------------------------------------------------------------------------

  /// Get the Device Name from the current outpus audio
  ///
  /// - Returns: A *String* value which is the current name of the
  /// Melomind connected in A2DP Protocol else nil if it is not a Melomind
  func getBLEDeviceNameFromA2DP() -> String? {
    if let nameA2DP = getA2DPDeviceName() {
      if !nameA2DP.isQrCode,
        let serialNumber = nameA2DP.components(separatedBy: "_").last {
        return "\(Constants.DeviceName.blePrefix)\(serialNumber)"
      } else {
        guard let serialNumber =
          MBTQRCodeSerial(qrCodeisKey: true).value(for: nameA2DP) else {
            return nil
        }
        return "\(Constants.DeviceName.blePrefix)\(serialNumber)"
      }
    }
    return nil
  }

  func getA2DPDeviceName() -> String? {
    return AudioOutputs().melomindOutput?.portName
  }

  func getA2DPDeviceNameFromBLE() -> String? {
    if deviceFirmwareVersion(isHigherOrEqualThan: .registerExternalName) {
      if let qrCode = DeviceManager.getDeviceQrCode() {
        return qrCode
      }
    }
    return DeviceManager.connectedDeviceName
  }

}
