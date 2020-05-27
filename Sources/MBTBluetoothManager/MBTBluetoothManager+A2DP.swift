import Foundation
import AVFoundation

extension MBTBluetoothManager {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// A *Bool* which indicate if the headset is connected or not to A2DP.
  static func isA2DPConnected() -> Bool {
    guard let deviceName = DeviceManager.connectedDeviceName
      else { return false }

    let output = AVAudioSession.sharedInstance().currentRoute.outputs.first

    return output?.portName == deviceName
      && output?.portType == AVAudioSession.Port.bluetoothA2DP
  }

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

//  func getA2DPDeviceOutput() -> AVAudioSessionPortDescription? {
//    let session = AVAudioSession.sharedInstance()
//    let outputs = session.currentRoute.outputs
//    let portNamePrefixLegacy = Constants.DeviceName.a2dpPrefixLegacy
//    let portNamePrefix = Constants.DeviceName.a2dpPrefix
//
//    if let output = outputs.filter({
//      $0.portName.lowercased().range(of: portNamePrefixLegacy) != nil
//    }).first {
//      return output
//    }
//
//    if let output = outputs.filter({
//      $0.portName.lowercased().range(of: portNamePrefix) != nil
//    }).first {
//      return output
//    }
//
//    if let output = outputs.filter({ isQrCode($0.portName) }).first {
//      return output
//    }
//    return nil
//  }

  func getA2DPDeviceNameFromBLE() -> String? {
    if deviceFirmwareVersion(isHigherOrEqualThan: .registerExternalName) {
      if let qrCode = DeviceManager.getDeviceQrCode() {
        return qrCode
      }
    }
    return DeviceManager.connectedDeviceName
  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - QR Code
//  //----------------------------------------------------------------------------
//
//  func isQrCode(_ string: String) -> Bool {
//    return isQrCodeBatch1(string) || isQrCodeBatch2(string)
//  }
//
//  func isQrCodeBatch1(_ string: String) -> Bool {
//    return string.range(of: Constants.DeviceName.qrCodePrefix) != nil
//      && string.count == Constants.DeviceName.qrCodeLength
//  }
//
//  func isQrCodeBatch2(_ string: String) -> Bool {
//    return string.range(of: Constants.DeviceName.qrCodePrefixBatch2) != nil
//      && string.count == Constants.DeviceName.qrCodeBatch2Length
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Serial Number
//  //----------------------------------------------------------------------------
//
//  func getSerialNumberFrom(deviceName: String) -> String? {
//    if isQrCode(deviceName) {
//      return getSerialNumber(fromQrCode: deviceName)
//    } else {
//      return deviceName.components(separatedBy: "_").last
//    }
//  }
//
//  func getSerialNumber(fromQrCode qrCode: String) -> String? {
//    var qrCode = qrCode
//    if isQrCodeBatch2(qrCode) {
//      qrCode.append(Constants.DeviceName.qrCodeBatch2EndCharacter)
//    }
//    return MBTQRCodeSerial(qrCodeisKey: true).value(for: qrCode)
//  }
}
