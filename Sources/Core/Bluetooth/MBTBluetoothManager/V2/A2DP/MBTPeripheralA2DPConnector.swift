import Foundation
import AVFoundation

class MBTPeripheralA2DPConnector {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** AVAuddioSession ********************/

  private var session: AVAudioSession {
    return AVAudioSession.sharedInstance()
  }

  private var output: AVAudioSessionPortDescription? {
    return session.currentRoute.outputs.first
  }

  private var outputPortName: String? {
    return output?.portName
  }

  private var outputPortType: AVAudioSession.Port? {
    return output?.portType
  }

  var a2dpName: String? {
    #warning("Move AudioOutputs functions here.")
    return AudioOutputs().melomindOutput?.portName
  }

  /******************** Callbacks ********************/

  var didConnectA2DP: (() -> Void)?
  var didDisconnectA2DP: (() -> Void)?
  var requestDeviceSerialNumber: (() -> String?)?

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(audioRouteDidChange(_:)),
      name: AVAudioSession.routeChangeNotification,
      object: nil
    )

    print(outputPortName)
    print(outputPortType)


//    if output?.portName == "melo_1010300431"
//      && output?.portType == .bluetoothA2DP {
//      // A2DP Audio is connected
//      didConnectA2DP?()
//      return
//    } else {
//      print("Not connected yet.")
//    }

    do {
      try session.setCategory(.playback, options: .allowBluetooth)
    } catch {
      print(error.localizedDescription)
      log.error("📲 Audio connection failed", context: error)
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  //----------------------------------------------------------------------------
  // MARK: - Connection
  //----------------------------------------------------------------------------

  func isConnected(currentDeviceSerialNumber: String) -> Bool {
    // "MM1B..."
    let lowercasedSerialNumber = currentDeviceSerialNumber.lowercased()
    let portName = output?.portName.lowercased()
    let isGoodSerialNumber = portName?.contains(lowercasedSerialNumber) ?? false
    // output?.portName == currentDeviceSerialNumber
    let isGoodPortType = output?.portType == .bluetoothA2DP
    return isGoodSerialNumber && isGoodPortType
  }

  //----------------------------------------------------------------------------
  // MARK: - Routing
  //----------------------------------------------------------------------------

  @objc private func audioRouteDidChange(_ notif: Notification) {
    // 1010300431

    guard let serialNumber = requestDeviceSerialNumber?(),
          isDifferentAudioOutput(audioNotif: notif,
                                 newSerialNumber: serialNumber) else {
//     let audioOutputName = getNewAudioOutputName() else {
      didDisconnectA2DP?()
      return
    }

    let audioOutputName = Constants.DeviceName.blePrefix + serialNumber
    log.info("📲 New output port name", context: audioOutputName)

    // A2DP Audio is connected
    didConnectA2DP?()
//    DispatchQueue.main.async {
//      self.audioA2DPDelegate?.audioA2DPDidConnect?()
//      self.completeAudioConnection(to: audioOutputName)
//    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Name retrivial
  //----------------------------------------------------------------------------

  private func isDifferentAudioOutput(audioNotif: Notification,
                                      newSerialNumber: String) -> Bool {
    guard let lastOutput = AudioNotification(audioNotif).lastAudioPort else {
      return false
    }

    log.info("🔊 Last audio output port name", context: lastOutput.portName)

    let lastSerialNumber = lastOutput.portName.serialNumberFromDeviceName ?? ""

    return newSerialNumber != lastSerialNumber
  }

  private func getNewAudioOutputName() -> String? {
    let melomindOutput = AudioOutputs().melomindOutput

    //guard
      let serialNumber = "1010300431"
      //melomindOutput?.portName.serialNumberFromDeviceName else { return nil }

    let melomindAudioOutputName =
      Constants.DeviceName.blePrefix + serialNumber

    log.info("📲 New output audio port name", context: melomindAudioOutputName)

    return melomindAudioOutputName
  }

//  private func isDeviceFirmwareVersionUpToDate() -> Bool {
//    let currentFwVersion = FormatedVersion(string:
//      DeviceManager.getCurrentDevice()?.deviceInfos?.firmwareVersion ?? ""
//    )
//    let oadFwVersion =
//      FormatedVersion(string: self.OADManager?.fwVersion ?? "")
//
//    log.info("📲 Current device firmware version",
//             context: currentFwVersion)
//    log.info("📲 Expected firmware version",
//             context: oadFwVersion)
//
//    return currentFwVersion == oadFwVersion
//  }

}

