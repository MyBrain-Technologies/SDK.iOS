//
//  MBTBluetoothManager.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 11/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import CoreBluetooth
import AVFoundation


let TIMEOUT_CONNECTION = 20.0
let TIMEOUT_OAD = 600.0
let TIMER_BATTERY_LEVEL = 120.0
let TIMER_A2DP = 10.0

let A2DP_DEVICE_NAME_PREFIX_LEGACY = "melo_"
let A2DP_DEVICE_NAME_PREFIX = "audio_"

let BLE_DEVICE_NAME_PREFIX = "melo_"

let MBT_DEVICE_NAME_QR_PREFIX = "MM"
let MBT_DEVICE_NAME_QR_LENGTH = 10

let MBT_DEVICE_NAME_QR_PREFIX_BATCH2 = "MM1B2"
let MBT_DEVICE_NAME_QR_LENGTH_BATCH2 = 9
let MBT_DEVICE_BATCH_2_END_CHARACTER = "."

enum MBTFirmwareVersion: String {
  case A2DP_FROM_HEADSET = "1.6.7"
  case REGISTER_EXTERNAL_NAME = "1.7.1"
}

/// Manage for the SDK the MBT Headset Bluetooth Part (connection/deconnection).
internal class MBTBluetoothManager: NSObject {
  
  //MARK: - Variable
  
  //MARK: Global -> Variable reachable in the client : MelomindEngine
  
  /// Singleton declaration
  static let shared = MBTBluetoothManager()
  
  /// The MBTBluetooth Event Delegate.
  weak var eventDelegate: MBTBluetoothEventDelegate?
  
  /// The MBT Audio A2DP Delegate.
  /// Tell developers when audio connect / disconnect
  weak var audioA2DPDelegate: MBTBluetoothA2DPDelegate?
  
  /// A *Bool* which indicate if the headset is connected or not to BLE and A2DP.
  /// - Remark: Sends a notification when changed (on *willSet*).
  var isConnected:Bool {
    
    if audioA2DPDelegate?.autoConnectionA2DPFromBLE?() ?? false
      && deviceFirmwareVersion(isHigherOrEqualThan: .A2DP_FROM_HEADSET) && isConnectedBLE {
      return DeviceManager.connectedDeviceName == getBLEDeviceNameFromA2DP()
    } else {
      return isConnectedBLE
    }
  }
  
  /// A *Bool* which indicate if the headset is connected or not to BLE and A2DP.
  /// - Remark: Sends a notification when changed (on *willSet*).
  var isConnectedBLE:Bool {
    return blePeripheral != nil
  }
  
  /// A *Bool* which enable or disable headset EEG notifications.
  var isListeningToEEG = false {
    didSet {
      if MBTBluetoothLEHelper.brainActivityMeasurementCharacteristic != nil {
        self.blePeripheral?.setNotifyValue(
          isListeningToEEG,
          for: MBTBluetoothLEHelper.brainActivityMeasurementCharacteristic
        )
      }
    }
  }
  
  /// A *Bool* which enable or disable headset saturation notifications.
  var isListeningToHeadsetStatus = false {
    didSet {
      if MBTBluetoothLEHelper.headsetStatusCharacteristic != nil {
        self.blePeripheral?.setNotifyValue(
          isListeningToHeadsetStatus,
          for: MBTBluetoothLEHelper.headsetStatusCharacteristic
        )
      }
    }
  }
  
  /// Flag switch to the first reading charasteristic to finalize Connection or to process the receiving Battery Level
  var processBatteryLevel:Bool = false
  
  //MARK: Private variable

  /// A *Bool* which indicate if the headset is connected or not to A2DP.
  var isConnectedA2DP:Bool = {
    let output = AVAudioSession.sharedInstance().currentRoute.outputs.first
    
    if let deviceName = DeviceManager.connectedDeviceName {
      return output?.portName == deviceName && output?.portType == AVAudioSession.Port.bluetoothA2DP
    }
    
    return false
  }()
  
  /// The BLE central manager.
  var centralManager : CBCentralManager?
  
  /// The BLE peripheral with which a connection has been established.
  var blePeripheral : CBPeripheral? {
    didSet {
      if let _ = blePeripheral {
        eventDelegate?.onHeadsetStatusUpdate?(true)
      } else {
        eventDelegate?.onHeadsetStatusUpdate?(false)
      }
    }
  }
  
  /// A counter which allows to know if all the characteristics have been discovered
  var counterServicesDiscover = 0
  
  /// the timer for the connection timeout
  var timerTimeOutConnection : Timer?
  
  var timerTimeOutA2DPConnection : Timer?
  
  var timerTimeOutSendExternalName : Timer?
  
  /// the timer for the battery level update
  var timerUpdateBatteryLevel: Timer?
  
  var timerFinalizeConnectionMelomind: Timer?
  
  // OAD Transfert

  // the timer for the OAD timeout
  var timerTimeOutOAD: Timer?

  // the array which contains the last three states of Blue
  var tabHistoBluetoothState = [Bool]()
  
  /// Flag OAD is enable
  var isOADInProgress = false {
    didSet {
      
    }
  }
  
  /// OAD State (Enum:OADStateType)
  var OADState:OADStateType = .DISABLE {
    didSet {
      if OADState == .DISABLE {
        stopTimerTimeOutOAD()
      }
    }
  }
  
  var OADManager:MBTOADManager?
  
  /// First Init BluetoothManager
  override init() {
    super.init()
    connectA2DP()
    initBluetoothManager()
  }
  

  //MARK: - Connect and Disconnect MBT Headset Methods
  
  /// Start the connection process.
  /// - Parameters:
  ///   - deviceName : The name of the device to connect (Bluetooth profile).
  func connectTo(_ deviceName:String? = nil) {
    
    
    // Check if a current device is already saved in the DB, and delete it
    //DeviceManager.deleteCurrentDevice()
    if let lastBluetoothState = tabHistoBluetoothState.last ,
      OADState == .CONNECT
        && lastBluetoothState
    {
      stopTimerTimeOutConnection()

      centralManager?.scanForPeripherals(withServices: [MBTBluetoothLEHelper.myBrainServiceUUID], options: nil)

      return
    }
    
    if let _ = blePeripheral {
      disconnect()
    }


    initBluetoothManager()
    
    if let deviceName = deviceName {
      DeviceManager.connectedDeviceName = deviceName
    } else {
      DeviceManager.connectedDeviceName = ""
    }
    stopTimerTimeOutConnection()
    
    timerTimeOutConnection = Timer.scheduledTimer(timeInterval: TIMEOUT_CONNECTION, target: self, selector: #selector(connectionMelomindTimeOut), userInfo: nil, repeats: false)

  }
  
  /// Initialise or Re-initialise the BluetoothManager [Prepare all variable for the connection]
  func initBluetoothManager() {
    // Download Init
    isOADInProgress = false
    OADState = .DISABLE
    
    // Connection Init
    counterServicesDiscover = 0
    isConnectedA2DP = false
    isListeningToEEG = false
    isListeningToHeadsetStatus = false
    processBatteryLevel = false
    
    // CentralManager Init
    centralManager = nil
    centralManager = CBCentralManager(delegate: self, queue: nil)
    
    DeviceManager.connectedDeviceName = nil

    // Characteristic Init
    MBTBluetoothLEHelper.brainActivityMeasurementCharacteristic = nil
    MBTBluetoothLEHelper.deviceStateCharacteristic = nil
    MBTBluetoothLEHelper.deviceInfoCharacteristic.removeAll()
  }
  
  /// Disconnect centralManager, and remove session's values.
  func disconnect() {
    // Invalid Timer
    stopTimerTimeOutConnection()
    stopTimerTimeOutA2DPConnection()
    stopTimerUpdateBatteryLevel()
    stopTimerTimeOutOAD()
    stopTimerFinalizeConnectionMelomind()
    
    // Disconnect CentralManager
    centralManager?.stopScan()
    
    if let blePeripheral = blePeripheral {
      centralManager?.cancelPeripheralConnection(blePeripheral)
    }
    
    blePeripheral = nil
  }
  
  /// Finalize the connection
  func finalizeConnectionMelomind() {
    stopTimerFinalizeConnectionMelomind()
    guard let currentDevice = DeviceManager.getCurrentDevice() else {
      let error = NSError(domain: "Bluetooth Manager", code: 916, userInfo: [NSLocalizedDescriptionKey : "OAD Error : Device Not Connected"]) as Error
      eventDelegate?.onConnectionFailed?(error)
      prettyPrint(log.error(error as NSError))
      return
    }
    
    MBTClient.shared.eegAcqusitionManager.setUpWith(device: currentDevice)

    if !isOADInProgress {
      stopTimerTimeOutConnection()
      if shouldRequestA2DPConnection() {
        requestConnectA2DP()
      } else {
        eventDelegate?.onConnectionEstablished?()
        startTimerUpdateBatteryLevel()
      }
    } else {
      if shouldRequestA2DPConnection() {
        requestConnectA2DP()
      } else {
        prettyPrint(log.ble("finalizeConnectionMelomind - RequestDeviceInfo : deviceVersion -> \(String(describing:  DeviceManager.getCurrentDevice()?.deviceInfos?.firmwareVersion))"))
        prettyPrint(log.ble("finalizeConnectionMelomind - RequestDeviceInfo : OadVersion -> \(String(describing:  self.OADManager?.fwVersion))"))
        if let currentDeviceInfo = DeviceManager.getCurrentDevice()?.deviceInfos ,
          let OADManager = OADManager,
          currentDeviceInfo.firmwareVersion?.contains(OADManager.fwVersion) ?? false {
          isOADInProgress = false
          OADState = .DISABLE
          eventDelegate?.onProgressUpdate?(1.0)
        } else {
          let error = NSError(domain: "Bluetooth Manager", code: 915, userInfo: [NSLocalizedDescriptionKey : "headset firmware version does not match to the update"]) as Error
          isOADInProgress = false
          OADState = .DISABLE
          eventDelegate?.onUpdateFailWithError?(error)
        }
      }
    }
  }
  
  /// Run the completion after the device infos is available with a time out
  ///
  /// - important : Event
  /// - onConnectionFailed : 917 | "Time out getting device infos"
  /// - Parameter completion: the block to execute after getting the device infos
  func prepareDeviceWithInfo(completion:@escaping ()->()) {
    requestUpdateDeviceInfo()
    
    DispatchQueue.global().async {
      var isDeviceInfoNotNil = false
      var indexLoop = 0.0
      while !isDeviceInfoNotNil {
        prettyPrint(log.ble("prepareDeviceWithInfo - PrepareDeviceWithInfo sleep"))
        usleep(500000)
        DispatchQueue.main.sync {
          if let currentDeviceInfo = DeviceManager.getCurrentDevice()?.deviceInfos {
            isDeviceInfoNotNil = currentDeviceInfo.isDeviceInfoNotNil()
          }
        }
        
        indexLoop += 0.5
        if indexLoop > 120 {
          let error = NSError(domain: "Bluetooth Manager", code: 917, userInfo: [NSLocalizedDescriptionKey : "Connection Failed : Time Out getting device infos"]) as Error
          self.eventDelegate?.onConnectionFailed?(error)
          self.disconnect()
          prettyPrint(log.ble("prepareDeviceWithInfo -"))
          prettyPrint(log.error(error as NSError))
          return
        }
      }
      
      
      DispatchQueue.main.sync {
        if let isMelomindNeedToBeUdpdate = self.isMelomindNeedToBeUpdate(),
          isMelomindNeedToBeUdpdate {
          self.eventDelegate?.onNeedToUpdate?()
        }
        
        completion()
      }
    }
  }
  
  //MARK: - A2DP methods
  
  /// Get the Device Name from the current outpus audio
  ///
  /// - Returns: A *String* value which is the current name of the Melomind connected in A2DP Protocol else nil if it is not a Melomind
  func getBLEDeviceNameFromA2DP() -> String? {
    if let nameA2DP = getA2DPDeviceName() {
      if !isQrCode(nameA2DP), let serialNumber = nameA2DP.components(separatedBy: "_").last {
        return "\(BLE_DEVICE_NAME_PREFIX)\(serialNumber)"
      } else {
        guard let serialNumber = MBTQRCodeSerial(qrCodeisKey: true).value(for: nameA2DP) else {
          return nil
        }
        return "\(BLE_DEVICE_NAME_PREFIX)\(serialNumber)"
      }
    }
    return nil
  }
  
  func getA2DPDeviceName() -> String? {
    return getA2DPDeviceOutput()?.portName
  }
  
  func getA2DPDeviceOutput() -> AVAudioSessionPortDescription? {
    let session = AVAudioSession.sharedInstance()
    let outputs = session.currentRoute.outputs
    
    if let output = outputs.filter({($0.portName.lowercased().range(of: A2DP_DEVICE_NAME_PREFIX_LEGACY) != nil)}).first {
      return output
    }
    
    if let output = outputs.filter({($0.portName.lowercased().range(of: A2DP_DEVICE_NAME_PREFIX) != nil)}).first {
      return output
    }
    
    if let output = outputs.filter({(isQrCode($0.portName))}).first {
      return output
    }
    return nil
  }
  
  func getA2DPDeviceNameFromBLE() -> String? {
    if deviceFirmwareVersion(isHigherOrEqualThan: .REGISTER_EXTERNAL_NAME) {
      if let qrCode = DeviceManager.getDeviceQrCode() {
        return qrCode
      }
    }
    return DeviceManager.connectedDeviceName
  }
  
  func isQrCode(_ string: String) -> Bool {
    return isQrCodeBatch1(string) || isQrCodeBatch2(string)
  }
  
  func isQrCodeBatch1(_ string: String) -> Bool {
    return string.range(of: MBT_DEVICE_NAME_QR_PREFIX) != nil
      && string.count == MBT_DEVICE_NAME_QR_LENGTH
  }
  
  func isQrCodeBatch2(_ string: String) -> Bool {
    return string.range(of: MBT_DEVICE_NAME_QR_PREFIX_BATCH2) != nil
      && string.count == MBT_DEVICE_NAME_QR_LENGTH_BATCH2
  }
  
  func getSerialNumberFrom(deviceName: String) -> String? {
    print("device name \(deviceName) is Qr Code ? \(isQrCode(deviceName))")
    if (isQrCode(deviceName)) {
      return getSerialNumber(fromQrCode: deviceName)
    } else {
      return deviceName.components(separatedBy: "_").last
    }
  }
  
  func getSerialNumber(fromQrCode qrCode: String) -> String? {
    var qrCode = qrCode
    if isQrCodeBatch2(qrCode) {
      qrCode.append(MBT_DEVICE_BATCH_2_END_CHARACTER)
    }
    return MBTQRCodeSerial(qrCodeisKey: true).value(for: qrCode)
  }
  
  /// Listen to the AVAudioSessionRouteChange Notification
  func connectA2DP() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(audioChangedRoute(_:)),
                                           name:AVAudioSession.routeChangeNotification,
                                           object: nil)
    if audioA2DPDelegate != nil {
      let session = AVAudioSession.sharedInstance()
      let output = session.currentRoute.outputs.first
      
      if let deviceName = DeviceManager.connectedDeviceName,
        output?.portName == deviceName && output?.portType == .bluetoothA2DP {
        // Save the UUID of the concerned headset
        MBTBluetoothA2DPHelper.uid = output?.uid
        // A2DP Audio is connected
        audioA2DPDelegate?.audioA2DPDidConnect?()
      } else {
        // Try to set Category to help device to connect
        // to the MBT A2DP profile
        
        do {
          try session.setCategory(.playback, options: .allowBluetooth)

        } catch {
          prettyPrint(log.ble("connectA2DP - "))
          prettyPrint(log.error(error as NSError))
        }
      }
      
      // Register to Audio Session output / input changes
      // to monitor the A2DP connection status
      
    }
  }
  
  private func shouldRequestA2DPConnection() -> Bool {
    return (audioA2DPDelegate?.autoConnectionA2DPFromBLE?() ?? false) == true
      && getBLEDeviceNameFromA2DP() != DeviceManager.connectedDeviceName
      && deviceFirmwareVersion(isHigherOrEqualThan: .A2DP_FROM_HEADSET)
  }
  
  // MARK: - External Name / Product Name methods
  
  private func shouldUpdateDeviceExternalName() -> Bool {
    return DeviceManager.getDeviceInfos()?.productName == MBTDevice.defaultProductName
      && deviceFirmwareVersion(isHigherOrEqualThan: .REGISTER_EXTERNAL_NAME)
  }
  
  private func getDeviceExternalName() -> String? {
    if let deviceId = DeviceManager.getDeviceInfos()?.deviceId,
      let name = MBTQRCodeSerial(qrCodeisKey: false).value(for: deviceId) {
      return name
    }
    return nil
  }
  
  /// If the connected Melomind need to be Update
  ///
  /// - Returns: A *Bool* value which is true if the last binary version is greater than the Melomind
  /// firmware version else false but can be nil if Melomind firmware version info is not available
  /// or if no file binary is found
  func isMelomindNeedToBeUpdate() -> Bool? {
    guard let deviceFirmwareVersion =
      DeviceManager.getCurrentDevice()?.deviceInfos?.firmwareVersion,
      let filename = BinariesFileFinder().getLastBinaryVersionFileName() else {
        return nil
    }

    guard let binaryVersion = filename.versionNumber else { return nil }

    let binaryVersionArray = binaryVersion.components(separatedBy: "_")
    let deviceFWVersionArray = deviceFirmwareVersion.components(separatedBy: ".")

    return compareArrayVersion(arrayA: binaryVersionArray, isGreaterThan: deviceFWVersionArray) == 1

  }
  
  /// Test Function install Start
  func startTestOAD() {
    // Disconnect A2DP
    
    timerTimeOutOAD?.invalidate()
    timerTimeOutOAD = nil
    timerTimeOutOAD = Timer.scheduledTimer(
      timeInterval: TIMEOUT_OAD,
      target: self,
      selector: #selector(oadTransfertTimeOut),
      userInfo: nil,
      repeats: false
    )

    OADManager = MBTOADManager("mm-ota-1_6_2")
    
    stopTimerUpdateBatteryLevel()
    
    blePeripheral?.setNotifyValue(true, for: MBTBluetoothLEHelper.mailBoxCharacteristic)
    
    isOADInProgress = true
    OADState = .START_OAD
    
    sendFWVersionPlusLength()
  }
  
  /// Start the OAD Process
  /// - important : Event
  /// - didOADFailWithError : 916 | Device Not connected
  /// - didOADFailWithError : 909 | Device Infos is not available
  /// - didOADFailWithError : 910 | Latest firmware already installed
  /// - didOADFailWithError : 912 | Time Out OAD Transfert
  /// - onProgressUpdate
  func startOAD() {
    // Disconnect A2DP
    
    guard isConnected else {
      self.isOADInProgress = false
      let message = "OAD Error : Device Not Connected"
      let error = NSError(domain: "Bluetooth Manager",
                          code: 916,
                          userInfo: [NSLocalizedDescriptionKey: message])
      self.eventDelegate?.onUpdateFailWithError?(error as Error)
      prettyPrint(log.ble("startOAD - "))
      prettyPrint(log.error(error))
      return
    }

    isOADInProgress = true
    stopTimerTimeOutOAD()
    
    guard let isMelomindNeedToBeUpdate = isMelomindNeedToBeUpdate() else {
      let message = "OAD Error : Device info is not available"
      let error = NSError(domain: "Bluetooth Manager",
                          code: 909,
                          userInfo: [NSLocalizedDescriptionKey: message])
      isOADInProgress = false
      eventDelegate?.onUpdateFailWithError?(error as Error)
      prettyPrint(log.ble("startOAD - "))
      prettyPrint(log.error(error))
      return
    }

    guard let fileName = BinariesFileFinder().getLastBinaryVersionFileName(),
      isMelomindNeedToBeUpdate else {
        let message =
          "OAD Error : Latest FirmwareVersion Installed already installed"
        let error = NSError(domain: "Bluetooth Manager",
                            code: 910,
                            userInfo: [NSLocalizedDescriptionKey: message])
        isOADInProgress = false
        OADState = .DISABLE
        eventDelegate?.onUpdateFailWithError?(error as Error)
        prettyPrint(log.ble("startOAD - "))
        prettyPrint(log.error(error))
        return
    }

    OADState = .START_OAD
    timerTimeOutOAD = Timer.scheduledTimer(
      timeInterval: TIMEOUT_OAD,
      target: self,
      selector: #selector(self.oadTransfertTimeOut),
      userInfo: nil,
      repeats: false
    )

    OADManager = MBTOADManager(fileName)

    let fwVersion = String(describing: OADManager?.fwVersion)
    prettyPrint(log.ble("startOAD - Start OAD Firmware Version : \(fwVersion)"))

    stopTimerUpdateBatteryLevel()

    if let characteristic = MBTBluetoothLEHelper.mailBoxCharacteristic {
      blePeripheral?.setNotifyValue(true, for: characteristic)
    }

    sendFWVersionPlusLength()
  }
  
  /// Send the binary to the Melomind
  func sendOADBuffer() {
    DispatchQueue.global().async {
      var oldProgress = -1
      
      self.OADManager?.mProgInfo.iBlock = 0
      
      guard let oadManager = self.OADManager else { return }

      while oadManager.mProgInfo.iBlock < oadManager.mOadBuffer.count {
        usleep(6000)
        if !self.isConnectedBLE || self.OADState != .IN_PROGRESS {
          break
        }


        let iBlock = Float(oadManager.mProgInfo.iBlock)
        let bufferCount = Float(oadManager.mOadBuffer.count)

        guard iBlock < bufferCount else { continue }

        self.blePeripheral?.writeValue(
          oadManager.getNextOADBufferData(),
          for: MBTBluetoothLEHelper.oadTransfertCharacteristic,
          type: .withoutResponse
        )

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
  
  /// Send firmware version and the buffer length to the Melomind
  /// important : Event
  /// - onProgressUpdate
  func sendFWVersionPlusLength() {
    if let OADManager = OADManager {
      var bytesArray = [UInt8](repeating: 0, count: 5)
      
      bytesArray[0] = MailBoxEvents.MBX_START_OTA_TXF.rawValue
      bytesArray[1] = OADManager.getFWVersionAsByteArray()[0]
      bytesArray[2] = OADManager.getFWVersionAsByteArray()[1]
      bytesArray[3] = ConversionUtils.loUInt16(v: OADManager.mProgInfo.nBlock)
      bytesArray[4] = ConversionUtils.hiUInt16(v: OADManager.mProgInfo.nBlock)
      
      blePeripheral?.writeValue(Data(bytesArray),
                                for: MBTBluetoothLEHelper.mailBoxCharacteristic,
                                type: .withResponse)
      eventDelegate?.onProgressUpdate?(0.05)
      OADState = .READY
    }
  }
  
  //MARK: - Timer Method
  
  /// Invalidate Update Battery Level Timer and set it to nil
  func stopTimerUpdateBatteryLevel() {
    if let timerUpdateBatteryLevel = timerUpdateBatteryLevel,
      timerUpdateBatteryLevel.isValid {
      timerUpdateBatteryLevel.invalidate()
    }
    timerUpdateBatteryLevel = nil
  }
  
  /// Invalidate Time Out Connection Timer and set it to nil
  func stopTimerTimeOutConnection() {
    if let timerTimeOutConnection = timerTimeOutConnection,
      timerTimeOutConnection.isValid {
      timerTimeOutConnection.invalidate()
    }
    timerTimeOutConnection = nil
  }
  
  /// Invalidate Time Out OAD Timer and set it to nil
  func stopTimerTimeOutOAD() {
    if let timerTimeOutOAD = timerTimeOutOAD,
      timerTimeOutOAD.isValid {
      timerTimeOutOAD.invalidate()
    }
    timerTimeOutOAD = nil
  }
  
  /// Invalidate Time Out A2DP Connection and set it to nil
  func stopTimerTimeOutA2DPConnection() {
    if let timerTimeOutA2DPConnection = timerTimeOutA2DPConnection,
      timerTimeOutA2DPConnection.isValid {
      timerTimeOutA2DPConnection.invalidate()
    }
    timerTimeOutA2DPConnection = nil
  }
  
  func stopTimerFinalizeConnectionMelomind() {
    if let timerFinalizeConnectionMelomind = timerFinalizeConnectionMelomind,
      timerFinalizeConnectionMelomind.isValid {
      timerFinalizeConnectionMelomind.invalidate()
    }
    timerFinalizeConnectionMelomind = nil
  }
  
  func stopTimerSendExternalName() {
    if let timerTimeOutSendExternalName = timerTimeOutSendExternalName,
      timerTimeOutSendExternalName.isValid {
      timerTimeOutSendExternalName.invalidate()
    }
  }
  
  /// Start Update Battery Level Timer that will send event receiveBatteryLevelOnUpdate
  func startTimerUpdateBatteryLevel() {
    stopTimerUpdateBatteryLevel()

    let timeInterval =
      eventDelegate?.timeIntervalOnReceiveBattery?() ?? TIMER_BATTERY_LEVEL
    let timeDiff = TimeInterval(5)

    timerUpdateBatteryLevel = Timer.scheduledTimer(
      timeInterval: timeInterval - timeDiff,
      target: self,
      selector: #selector(requestUpdateBatteryLevel),
      userInfo: nil,
      repeats: true
    )

    Timer.scheduledTimer(timeInterval: timeDiff,
                         target: self,
                         selector: #selector(requestUpdateBatteryLevel),
                         userInfo: nil,
                         repeats: false)
  }
  
  /// Method Call if the Melomind can not connect after 20 Seconds
  @objc func connectionMelomindTimeOut() {
    centralManager?.stopScan()
    stopTimerTimeOutConnection()

    let message = "Connection Failed : Time Out Connection Melomind"
    let error = NSError(domain: "Bluetooth Manager",
                        code: 918,
                        userInfo: [NSLocalizedDescriptionKey: message])
    prettyPrint(log.ble("connectionMelomindTimeOut -"))
    prettyPrint(log.error(error))

    if isOADInProgress {
      isOADInProgress = false
      eventDelegate?.onUpdateFailWithError?(error)
    } else {
      eventDelegate?.onConnectionFailed?(error)
    }
  }
  
  @objc func connetionA2DPTimeOut() {
    disconnect()

    let message = "Failed to connect A2DP cause: Time Out Connection"
    let error = NSError(domain: "Bluetooth Manager",
                        code: 924,
                        userInfo: [NSLocalizedDescriptionKey : message])
    prettyPrint(log.ble("connectionA2DPTimeOut - "))
    prettyPrint(log.error(error))

    if isOADInProgress {
      eventDelegate?.onUpdateFailWithError?(error)
    } else {
      eventDelegate?.onConnectionFailed?(error)
    }
  }

  @objc func sendExternalNameTimeOut() {
    prettyPrint(log.ble(#function))
  }
  
  /// Method Call Time Out Connection Protocol
  @objc func oadTransfertTimeOut() {
    stopTimerTimeOutOAD()

    let message = "OAD Error : Time Out OADTransfer -> \(OADState.description)"
    let error = NSError(domain: "Bluetooth Manager",
                        code: 912,
                        userInfo: [NSLocalizedDescriptionKey: message])
    prettyPrint(log.ble("oadTransfertTimeOut  - "))
    prettyPrint(log.error(error))

    if OADState < .OAD_COMPLETE {
      isOADInProgress = false
    }
    eventDelegate?.onUpdateFailWithError?(error)
  }
  
  //MARK: - Read Characteristic Methods
  
  /// Request the Melomind to connect A2DP
  /// important : Event
  /// - didOADFailWithError : 924 | Time Out Connection
  /// - onConnectionFailed : 924 | Time Out Cnnection
  func requestConnectA2DP() {
    timerTimeOutA2DPConnection = Timer.scheduledTimer(timeInterval: TIMER_A2DP, target: self, selector: #selector(connetionA2DPTimeOut), userInfo: nil, repeats: false)
    let bytesArray:[UInt8] = [MailBoxEvents.MBX_CONNECT_IN_A2DP.rawValue,0x25,0xA2]
    blePeripheral?.setNotifyValue(true, for: MBTBluetoothLEHelper.mailBoxCharacteristic)
    blePeripheral?.writeValue( Data(bytesArray), for: MBTBluetoothLEHelper.mailBoxCharacteristic, type: .withResponse)
  }
  
  func sendDeviceExternalName(_ name: String) {
    timerTimeOutSendExternalName = Timer.scheduledTimer(timeInterval: TIMER_A2DP, target: self, selector: #selector(sendExternalNameTimeOut), userInfo: nil, repeats: false)
    let bytesArray:[UInt8] = [MailBoxEvents.MBX_SET_SERIAL_NUMBER.rawValue, 0xAB, 0x21] + [UInt8](name.utf8)
    blePeripheral?.setNotifyValue(true, for: MBTBluetoothLEHelper.mailBoxCharacteristic)
    blePeripheral?.writeValue(Data(bytesArray), for: MBTBluetoothLEHelper.mailBoxCharacteristic, type: .withResponse)
  }
  
  //  Method Request Update Status Battery
  @objc func requestUpdateBatteryLevel() {
    if blePeripheral != nil && MBTBluetoothLEHelper.deviceStateCharacteristic != nil   {
      blePeripheral?.readValue(for: MBTBluetoothLEHelper.deviceStateCharacteristic)
    }
  }
  
  func requestUpdateDeviceInfo() {
    DeviceManager.resetDeviceInfo()
    if blePeripheral != nil && MBTBluetoothLEHelper.deviceInfoCharacteristic.count != 0 {
      for characteristic in MBTBluetoothLEHelper.deviceInfoCharacteristic {
        blePeripheral?.readValue(for: characteristic)
      }
    }
  }
  
  //MARK: - Utlis Methods
  
  func compareArrayVersion( arrayA:[String], isGreaterThan arrayB:[String]) -> Int {
    let coeffArrayA = Int(arrayA[0])! * 10000 + Int(arrayA[1])! * 100 + Int(arrayA[2])!
    
    let coeffArrayB = Int(arrayB[0])! * 10000 + Int(arrayB[1])! * 100 + Int(arrayB[2])!
    
    if coeffArrayA > coeffArrayB {
      return 1
    }
    
    if coeffArrayA < coeffArrayB {
      return -1
    }
    
    return 0
    
  }
  
  /// Compare the firmware version to determine if it's equal or higher to another version
  ///
  /// - Returns: A *Bool* value which is true if the firmware version is same or higher than the parameter
  private func deviceFirmwareVersion(isHigherOrEqualThan version: MBTFirmwareVersion) -> Bool {
    guard let deviceFWVersion = DeviceManager.getCurrentDevice()?.deviceInfos?.firmwareVersion else {
      return false
    }
    
    print ("device firmware version \(deviceFWVersion)")
    let versionArray = version.rawValue.components(separatedBy: ".")
    let deviceFWVersionArray = deviceFWVersion.components(separatedBy: ".")
    
    return (compareArrayVersion(arrayA: deviceFWVersionArray, isGreaterThan: versionArray) >= 0)
  }

}

//MARK: - Central Manager Delegate Methods

extension MBTBluetoothManager : CBCentralManagerDelegate {
  /// Check status of BLE hardware. Invoked when the central
  /// manager's state is update.
  /// - Parameters:
  ///   - central: The central manager whose state has changed.
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == .poweredOn {
      prettyPrint(log.ble("centralManagerDidUpdateState - PoweredOn"))

      // Scan for peripherals if BLE is turned on
      if tabHistoBluetoothState.count == 0 {
        tabHistoBluetoothState.append(true)
        eventDelegate?.onBluetoothStateChange?(true)
      } else if let lastBluetoothState = tabHistoBluetoothState.last,
        !lastBluetoothState {
        tabHistoBluetoothState.append(true)
        eventDelegate?.onBluetoothStateChange?(true)
      }
      
      if let _ = DeviceManager.connectedDeviceName, let _ = timerTimeOutConnection {
        prettyPrint(log.ble("centralManagerDidUpdateState - Broadcasting ..."))
        centralManager?.scanForPeripherals(withServices: [MBTBluetoothLEHelper.myBrainServiceUUID], options: nil)
      }
      
      
      
    } else if central.state == .poweredOff {
      prettyPrint(log.ble("centralManagerDidUpdateState - PoweredOff"))

      if tabHistoBluetoothState.count == 0 {
        tabHistoBluetoothState.append(false)
        eventDelegate?.onBluetoothStateChange?(false)
      } else if let lastBluetoothState = tabHistoBluetoothState.last,
        lastBluetoothState {
        tabHistoBluetoothState.append(false)
        eventDelegate?.onBluetoothStateChange?(false)
      }
      
      if !isOADInProgress {
        if !isConnected {
          let error = NSError(domain: "Bluetooth Manager", code: 919, userInfo: [NSLocalizedDescriptionKey : "Connection Failed : CoreBluetooth detect bluetooth is poweredOff"]) as Error
          eventDelegate?.onConnectionFailed?(error)
          prettyPrint(log.ble("centralManagerDidUpdateState - "))
          prettyPrint(log.error(error as NSError))
        } else {
          let error = NSError(domain: "Bluetooth Manager", code: 920, userInfo: [NSLocalizedDescriptionKey : "Lost Connection : CoreBluetooth detect bluetooth is poweredOff"]) as Error
          eventDelegate?.onConnectionBLEOff?(error)
          prettyPrint(log.ble("centralManagerDidUpdateState - "))
          prettyPrint(log.error(error as NSError))
        }
        disconnect()
      } else if OADState != .REBOOT_BLUETOOTH {
        centralManager?.stopScan()
        if let blePeripheral = blePeripheral {
          centralManager?.cancelPeripheralConnection(blePeripheral)
        }
        blePeripheral = nil
        if OADState > .OAD_COMPLETE {          let error = NSError(domain: "Bluetooth Manager", code: 908, userInfo: [NSLocalizedDescriptionKey : "OAD Error : Impossible reconnect the Melomoind"]) as Error
          OADState = .CONNECT
          prettyPrint(log.ble("centralManagerDidUpdateState - "))
          prettyPrint(log.error(error as NSError))
          eventDelegate?.onUpdateFailWithError?(error)
        } else {          let error = NSError(domain: "Bluetooth Manager", code: 911, userInfo: [NSLocalizedDescriptionKey : "OAD Error : Lost Connection BLE during OAD"]) as Error
          isOADInProgress = false
          prettyPrint(log.ble("centralManagerDidUpdateState - "))
          prettyPrint(log.error(error as NSError))
          OADState = .DISABLE
          eventDelegate?.onUpdateFailWithError?(error)
        }
      }
      
    } else if central.state == .unsupported {
      prettyPrint(log.ble("centralManagerDidUpdateState - Unsupported"))
    } else if central.state == .unauthorized {
      prettyPrint(log.ble("centralManagerDidUpdateState - This option is not allowed by your application"))
    }
    
    
    if tabHistoBluetoothState.count > 3 {
      tabHistoBluetoothState.removeFirst()
    }
    
    if let lastBluetoothStatus = tabHistoBluetoothState.last ,
      tabHistoBluetoothState.count == 3
        && lastBluetoothStatus
        && isOADInProgress
        && OADState == .REBOOT_BLUETOOTH {
      eventDelegate?.onRebootBluetooth?()
      if let connectedDeviceName = DeviceManager.connectedDeviceName,
        connectedDeviceName != "" {
        blePeripheral = nil
        DeviceManager.resetDeviceInfo()
        centralManager?.scanForPeripherals(withServices: [MBTBluetoothLEHelper.myBrainServiceUUID], options: nil)
        OADState = .CONNECT
      } else {
        let error = NSError(domain: "Bluetooth Manager", code: 908, userInfo:[NSLocalizedDescriptionKey : "OAD Error : Impossible de reconnect the Melomoind"])
        eventDelegate?.onUpdateFailWithError?(error)
        prettyPrint(log.ble("centralManagerDidUpdateState - "))
        prettyPrint(log.error(error as NSError))
      }
    }
    

  }
  
  
  /// Check out the discovered peripherals to find the right device.
  /// Invoked when the central manager discovers a peripheral while scanning.
  /// - Parameters:
  ///   - central: The central manager providing the update.
  ///   - peripheral: The discovered peripheral.
  ///   - advertisementData: A dictionary containing any advertisement data.
  ///   - RSSI: The current received signal strength indicator (RSSI) of the peripheral, in decibels.
  func centralManager(
    _ central: CBCentralManager,
    didDiscover peripheral: CBPeripheral,
    advertisementData: [String : Any],
    rssi RSSI: NSNumber)
  {
    guard let nameOfDeviceFound = advertisementData[CBAdvertisementDataLocalNameKey] as? String else { return }
    
    
    
    if let array = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? Array<CBUUID>,
      array.contains(MBTBluetoothLEHelper.myBrainServiceUUID)
        && nameOfDeviceFound.lowercased().range(of: "melo_") != nil
        && (timerTimeOutConnection != nil
          || OADState >= .START_OAD) {
      
      if DeviceManager.connectedDeviceName == "" {
        DeviceManager.connectedDeviceName = nameOfDeviceFound
      }
      
      if DeviceManager.connectedDeviceName == nameOfDeviceFound  {
        // Stop scanning
        centralManager?.stopScan()
        // Set as the peripheral to use and establish connection
        blePeripheral = peripheral

        blePeripheral?.delegate = self
        centralManager?.connect(peripheral, options: nil)
        DeviceManager.updateDeviceToMelomind()
      }
    }
  }
  
  /// Discover services of the peripheral.
  /// Invoked when a connection is successfully created with a peripheral.
  /// - Parameters:
  ///   - central: The central manager providing this information.
  ///   - peripheral: The peripheral that has been connected to the system.
  func centralManager(_ central: CBCentralManager,
                      didConnect peripheral: CBPeripheral)
  {
    peripheral.discoverServices(nil)
    
    if isOADInProgress && OADState >= .OAD_COMPLETE {
      MBTBluetoothLEHelper.deviceInfoCharacteristic.removeAll()
      //      requestUpdateDeviceInfo()
    } else {
      DeviceManager.resetDeviceInfo()
    }
  }

  
  /// If disconnected by error, start searching again,
  /// else let event delegate know that headphones
  /// are disconnected.
  /// Invoked when an existing connection with a peripheral is torn down.
  /// - Parameters:
  ///   - central: The central manager providing this information.
  ///   - peripheral: The peripheral that has been disconnected.
  ///   - error: If an error occurred, the cause of the failure.
  func centralManager(
    _ central: CBCentralManager,
    didDisconnectPeripheral peripheral: CBPeripheral,
    error: Error?)
  {
    processBatteryLevel = false
    if isOADInProgress {
      if OADState == .OAD_COMPLETE {
        eventDelegate?.onProgressUpdate?(0.95)
        eventDelegate?.requireToRebootBluetooth?()
        OADState = .REBOOT_BLUETOOTH
      } else {
        centralManager?.stopScan()
        if let blePeripheral = blePeripheral {
          centralManager?.cancelPeripheralConnection(blePeripheral)
        }
        blePeripheral = nil
        if OADState >= .OAD_COMPLETE {
          let error = NSError(domain: "Bluetooth Manager", code: 908, userInfo: [NSLocalizedDescriptionKey : "OAD Error : Impossible reconnect the Melomoind"]) as Error
          OADState = .CONNECT
          
          prettyPrint(log.error(error as NSError))
          eventDelegate?.onUpdateFailWithError?(error)
        } else {
          let error = NSError(domain: "Bluetooth Manager", code: 911, userInfo: [NSLocalizedDescriptionKey : "OAD Error : Lost Connection BLE during OAD"]) as Error
          isOADInProgress = false
          OADState = .DISABLE
          
          prettyPrint(log.error(error as NSError))
          eventDelegate?.onUpdateFailWithError?(error)
        }
        //        let error = NSError(domain: "Bluetooth Manager", code: 911, userInfo: [NSLocalizedDescriptionKey : "OAD Error : Lost Connection BLE during OAD"]) as Error
        //        isOADInProgress = false
        //        OADState = .DISABLE
        //        disconnect()
        //        eventDelegate?.onUpdateFailWithError?(error)
      }
    } else {
      if let _ = timerTimeOutConnection {
        let error = NSError(domain: "Bluetooth Manager", code: 921, userInfo: [NSLocalizedDescriptionKey : "Lost Connection : User refuse to paire the Melomind in BLE"]) as Error
        
        prettyPrint(log.error(error as NSError))
        isOADInProgress = false
        eventDelegate?.onConnectionFailed?(error)
      } else {
        eventDelegate?.onConnectionBLEOff?(error)
      }
      disconnect()
    }

  }
  
  /// If connection failed, call the event delegate
  /// with the error.
  /// Invoked when the central manager fails to create a connection with a peripheral.
  /// - Parameters:
  ///   - central: The central manager providing this information.
  ///   - peripheral: The peripheral that failed to connect.
  ///   - error: The cause of the failure.
  func centralManager(_ central: CBCentralManager,
                      didFailToConnect peripheral: CBPeripheral,
                      error: Error?) {
    eventDelegate?.onConnectionFailed?(error)
  }
  
  
}

//MARK: - CBPeripheral Delegate Methods

extension MBTBluetoothManager : CBPeripheralDelegate {
  
  /// Check if the service discovered is a valid Service.
  /// Invoked when you discover the peripheral’s available services.
  /// - Parameters:
  ///   - peripheral: The peripheral that the services belong to.
  ///   - error: If an error occurred, the cause of the failure.
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    // Check all the services of the connecting peripheral.
    guard let _ = blePeripheral, let services = peripheral.services else {
      return
    }
    counterServicesDiscover = 0
    
    for service in services {
      let currentService = service as CBService
      // Get the MyBrainService and Device info UUID
      let servicesUUID = MBTBluetoothLEHelper.getServicesUUIDs()
      
      // Check if manager should look at this service characteristics
      if servicesUUID.contains(CBUUID(data: service.uuid.data)) {
        peripheral.discoverCharacteristics(nil, for: currentService)
        counterServicesDiscover += 1
      }
    }
    
  }
  
  /// Enable notification and sensor for desired characteristic of valid service.
  /// Invoked when you discover the characteristics of a specified service.
  /// - Parameters:
  ///   - peripheral: The peripheral that the services belong to.
  ///   - service: The service that the characteristics belong to.
  ///   - error: If an error occurred, the cause of the failure.
  func peripheral(_ peripheral: CBPeripheral,
                  didDiscoverCharacteristicsFor service: CBService,
                  error: Error?) {
    guard let _ = blePeripheral else {
      return
    }
    counterServicesDiscover -= 1
    // Get the device information characteristics UUIDs.
    let characsUUIDS = MBTBluetoothLEHelper.getDeviceInfoCharacteristicsUUIDS()
    
    // check the uuid of each characteristic to find config and data characteristics
    for characteristic in service.characteristics! {
      let thisCharacteristic = characteristic as CBCharacteristic
      
      // MyBrainService's Characteristics
      if MBTBluetoothLEHelper.brainActivityMeasurementUUID  == CBUUID(data: thisCharacteristic.uuid.data) {
        // Enable Sensor Notification and read the current value
        MBTBluetoothLEHelper.brainActivityMeasurementCharacteristic = thisCharacteristic
      }
      
      // Device info's Characteristics
      if characsUUIDS.contains(CBUUID(data: thisCharacteristic.uuid.data)) {
        MBTBluetoothLEHelper.deviceInfoCharacteristic.append(thisCharacteristic)
      }
      
      // Device State's Characteristics
      if MBTBluetoothLEHelper.deviceBatteryStatusUUID == CBUUID(data: thisCharacteristic.uuid.data) {
        MBTBluetoothLEHelper.deviceStateCharacteristic = thisCharacteristic
      }
      
      if MBTBluetoothLEHelper.headsetStatusUUID == CBUUID(data: thisCharacteristic.uuid.data)  {
        MBTBluetoothLEHelper.headsetStatusCharacteristic = thisCharacteristic
      }
      
      if MBTBluetoothLEHelper.mailBoxUUID == CBUUID(data: thisCharacteristic.uuid.data) {
        MBTBluetoothLEHelper.mailBoxCharacteristic = thisCharacteristic
      }
      if MBTBluetoothLEHelper.oadTransfertUUID  == CBUUID(data: thisCharacteristic.uuid.data) {
        MBTBluetoothLEHelper.oadTransfertCharacteristic = thisCharacteristic
      }
    }

    
    
    if counterServicesDiscover <= 0 && MBTBluetoothLEHelper.mailBoxCharacteristic != nil && MBTBluetoothLEHelper.deviceInfoCharacteristic.count == 4 {
      prepareDeviceWithInfo {
        self.requestUpdateBatteryLevel()
        self.timerFinalizeConnectionMelomind = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.requestUpdateBatteryLevel), userInfo: nil , repeats: false)
      }
    }
  }

  
  /// Get data values when they are updated.
  /// Invoked when you retrieve a specified characteristic’s value,
  /// or when the peripheral device notifies your app that
  /// the characteristic’s value has changed.
  /// Send them to AcquisitionManager.
  /// - Parameters:
  ///   - peripheral: The peripheral that the services belong to.
  ///   - service: The characteristic whose value has been retrieved.
  ///   - error: If an error occurred, the cause of the failure.
  func peripheral(_ peripheral: CBPeripheral,
                  didUpdateValueFor characteristic: CBCharacteristic,
                  error: Error?) {
    guard let notifiedData = characteristic.value,
      let _ = blePeripheral else {
        return
    }
    // Get the device information characteristics UUIDs.
    let characsUUIDS = MBTBluetoothLEHelper.getDeviceInfoCharacteristicsUUIDS()
    
    let uuidCharacteristic = CBUUID(data: characteristic.uuid.data)
    
    switch uuidCharacteristic {
    case MBTBluetoothLEHelper.brainActivityMeasurementUUID :
      DispatchQueue.main.async {
        [weak self] in
        if self?.isListeningToEEG ?? false {
          MBTClient.shared.eegAcqusitionManager.processBrainActivityData(notifiedData)
        }
      }
      
    case MBTBluetoothLEHelper.headsetStatusUUID :
      DispatchQueue.global(qos: .background).async {
        MBTClient.shared.deviceAcqusitionManager.processHeadsetStatus(characteristic)
      }
    case MBTBluetoothLEHelper.deviceBatteryStatusUUID :
      if processBatteryLevel {
        MBTClient.shared.deviceAcqusitionManager.processDeviceBatteryStatus(characteristic)
      } else {
        prettyPrint(log.ble("peripheral didUpdateValueFor characteristic - fake finalize connection"))
        processBatteryLevel = true
        if shouldUpdateDeviceExternalName() {
          if let name = getDeviceExternalName() {
            sendDeviceExternalName(name)
          } else {
            finalizeConnectionMelomind()
          }
        } else {
          finalizeConnectionMelomind()
        }
      }
    case let uuid where characsUUIDS.contains(uuid) :
      MBTClient.shared.deviceAcqusitionManager.processDeviceInformations(characteristic)
    case MBTBluetoothLEHelper.mailBoxUUID :
      stopTimerTimeOutA2DPConnection()
      if let data = characteristic.value {
        var bytesArray = [UInt8](repeating: 0, count: data.count)
        (data as NSData).getBytes(&bytesArray, length: data.count * MemoryLayout<UInt8>.size)
        switch MailBoxEvents.getMailBoxEvent(v: bytesArray[0]) {
        case .MBX_OTA_MODE_EVT :
          prettyPrint(log.ble("peripheral didUpdateValueFor characteristic - MBX_OTA_MODE_EVT bytesArray : \(bytesArray.description)"))
          if bytesArray[1] == 0x01 {
            OADState = .IN_PROGRESS
            eventDelegate?.onReadyToUpdate?()
            eventDelegate?.onProgressUpdate?(0.1)
            sendOADBuffer()
          } else {
            isOADInProgress = false
            OADState = .DISABLE
            blePeripheral?.setNotifyValue(false, for: MBTBluetoothLEHelper.mailBoxCharacteristic)
            startTimerUpdateBatteryLevel()
            let error = NSError(domain: "Bluetooth Manager", code: 913, userInfo: [NSLocalizedDescriptionKey : "OAD Error : Prepare OAD Transfer request fail"]) as Error
            eventDelegate?.onUpdateFailWithError?(error)
            prettyPrint(log.ble("peripheral didUpdateValueFor characteristic - "))
            prettyPrint(log.error(error as NSError))
          }
        case .MBX_OTA_IDX_RESET_EVT :
          prettyPrint(log.ble("peripheral didUpdateValueFor characteristic - MBX_OTA_IDX_RESET_EVT bytesArray : \(bytesArray.description)"))
          let dispatchWorkItem = DispatchWorkItem(qos: .default, flags: .barrier) {
            self.OADManager?.mProgInfo.iBlock = Int16((bytesArray[2] & 0xFF)) << 8 | Int16(bytesArray[1] & 0xFF)
          }
          
          DispatchQueue.global().async(execute: dispatchWorkItem)
        case .MBX_OTA_STATUS_EVT :
          prettyPrint(log.ble("peripheral didUpdateValueFor characteristic - MBX_OTA_STATUS_EVT bytesArray : \(bytesArray.description)"))
          if bytesArray[1] == 1 {
            stopTimerTimeOutOAD()
            OADState = .OAD_COMPLETE
            eventDelegate?.onProgressUpdate?(0.9)
            eventDelegate?.onUpdateComplete?()
          } else {
            let error = NSError(domain: "Bluetooth Manager", code: 914, userInfo: [NSLocalizedDescriptionKey : "OAD Error : OAD Transfer is not completed (MBX_OTA_STATUS_EVT)"]) as Error
            startTimerUpdateBatteryLevel()
            isOADInProgress = false
            OADState = .DISABLE
            eventDelegate?.onUpdateFailWithError?(error)
            prettyPrint(log.ble("peripheral didUpdateValueFor characteristic - "))
            prettyPrint(log.error(error as NSError))
          }
        case .MBX_CONNECT_IN_A2DP :
          let bytesResponse = bytesArray[1]
          let bytesArrayA2DPStatus = MailBoxA2DPResponse.getA2DPResponseFromUint8(bytesResponse)
          prettyPrint(log.ble("peripheral didUpdateValueFor characteristic - A2DP bytes:\(bytesArray.description)"))
          prettyPrint(log.ble("peripheral didUpdateValueFor characteristic - A2DP bits:\(bytesArrayA2DPStatus.description)"))

          if bytesArrayA2DPStatus.contains(.CMD_CODE_IN_PROGRESS) {
            prettyPrint(log.ble("peripheral didUpdateValueFor characteristic - A2DP in progress"))
          }
          if bytesArrayA2DPStatus.contains(.CMD_CODE_SUCCESS) {
            prettyPrint(log.ble("peripheral didUpdateValueFor characteristic - A2DP Connection Success"))
          } else {
            var error:Error?
            if bytesArrayA2DPStatus.contains(.CMD_CODE_FAILED_BAD_BDADDR) {
              error = NSError(domain: "Bluetooth Manager", code: 925, userInfo: [NSLocalizedDescriptionKey : "Failed to connect A2DP cause: BAD BDADDR"]) as Error
            } else if bytesArrayA2DPStatus.contains(.CMD_CODE_FAILED_ALREADY_CONNECTED) {
              error = NSError(domain: "Bluetooth Manager", code: 923, userInfo: [NSLocalizedDescriptionKey : "Failed to connect A2DP cause: A2DP is already connect to another device"]) as Error
            } else if bytesArrayA2DPStatus.contains(.CMD_CODE_LINKKEY_INVALID) {
              error = NSError(domain: "Bluetooth Manager", code: 922, userInfo: [NSLocalizedDescriptionKey : "Failed to connect A2DP cause: Unpaired A2DP"]) as Error
            } else if bytesArrayA2DPStatus.contains(.CMD_CODE_FAILED_TIME_OUT) {
              error = NSError(domain: "Bluetooth Manager", code: 924, userInfo: [NSLocalizedDescriptionKey : "Failed to connect A2DP cause: Time Out Connection"]) as Error
            }
            
            if let error = error {
              prettyPrint(log.ble("peripheral didUpdateValueFor characteristic - "))
              prettyPrint(log.error(error as NSError))
              if isOADInProgress {
                eventDelegate?.onUpdateFailWithError?(error)
              } else {
                eventDelegate?.onConnectionFailed?(error)
              }
              stopTimerTimeOutA2DPConnection()
              disconnect()
            }
          }
        case .MBX_SET_SERIAL_NUMBER:
          prettyPrint(log.ble("peripheral didUpdateValueFor characteristic - SET SERIAL NUMBER bytes:\(bytesArray.description)"))
          stopTimerSendExternalName()
          finalizeConnectionMelomind()
        default:
          prettyPrint(log.ble("peripheral didUpdateValueFor characteristic - Unknow MBX Response"))
        }
      }
    default:
      break
    }

    
  }
  
  
  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    
  }
  
  /// Check if the notification status changed.
  /// Invoked when the peripheral receives a request to start
  /// or stop providing notifications for a specified characteristic’s value.
  /// - Parameters:
  ///   - peripheral: The peripheral that the services belong to.
  ///   - service: The characteristic whose value has been retrieved.
  ///   - error: If an error occurred, the cause of the failure.
  /// Remark : Absence of this function causes the notifications not to register anymore.
  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateNotificationStateFor characteristic: CBCharacteristic,
    error: Error?) {
    //
    //    print("Did update notification for characteristic: \(characteristic.uuid.data)")
  }
}

//MARK: - Audio A2DP method

extension MBTBluetoothManager {
  
  
  /// Audio A2DP changing route output handler.
  /// - Parameter notif : The *notification* received when audio route output changed.
  @objc func audioChangedRoute(_ notif:Notification) {
    // Get the Reason why the audio route change
    guard let userInfo = notif.userInfo,
      let _ = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt
      //      ,let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue)
      else {
        return
    }
    
    //
    // Get the last audio output route used
    var lastOutput: AVAudioSessionPortDescription! = nil
    if let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
      lastOutput = previousRoute.outputs[0]
    }
    prettyPrint(log.ble("audioChangedRoute - LastOutput PortName : \(lastOutput.portName)"))
    // Get the actual route used
    if let output = getA2DPDeviceOutput(),
      let serialNumber = getSerialNumberFrom(deviceName: output.portName),
      let lastSerialNumber = getSerialNumberFrom(deviceName: lastOutput.portName),
      serialNumber != lastSerialNumber {
      
      let meloName = "\(BLE_DEVICE_NAME_PREFIX)\(serialNumber)"
      prettyPrint(log.ble("audioChangedRoute - NewOutput PortName : \(meloName)"))

      MBTBluetoothA2DPHelper.uid = output.uid
      // A2DP Audio is connected
      DispatchQueue.main.async {
        self.audioA2DPDelegate?.audioA2DPDidConnect?()
        if self.isConnected {
          if !self.isOADInProgress {
            if DeviceManager.connectedDeviceName == meloName {
              self.stopTimerTimeOutA2DPConnection()
              self.eventDelegate?.onConnectionEstablished?()
              self.startTimerUpdateBatteryLevel()
            } else {
              self.connectTo(meloName)
            }
          } else {
            if let _ = self.blePeripheral, self.isOADInProgress {
              prettyPrint(log.ble("audioChangedRoute - RequestDeviceInfo : deviceVersion -> \(String(describing:  DeviceManager.getCurrentDevice()?.deviceInfos?.firmwareVersion))"))
              prettyPrint(log.ble("audioChangedRoute - RequestDeviceInfo : OadVersion -> \(String(describing: self.OADManager?.fwVersion))"))
              if let currentDeviceInfo = DeviceManager.getCurrentDevice()?.deviceInfos , self.OADManager != nil && currentDeviceInfo.firmwareVersion?.contains(self.OADManager!.fwVersion) ?? false {
                self.eventDelegate?.onProgressUpdate?(1.0)
                self.isOADInProgress = false
                self.OADState = .DISABLE

              } else if self.OADState != .REBOOT_BLUETOOTH {
                let error = NSError(domain: "Bluetooth Manager", code: 915, userInfo: [NSLocalizedDescriptionKey : "OAD Error : headset firmware version does not match to the update"]) as Error
                self.isOADInProgress = false
                self.OADState = .DISABLE
                self.eventDelegate?.onUpdateFailWithError?(error)
                prettyPrint(log.ble("audioChangedRoute - "))
                prettyPrint(log.error(error as NSError))
              }
            } else {
              self.connectTo(meloName)
            }
          }
        } else {
          self.connectTo(meloName)
        }
      }
    } else if lastOutput != nil {
      MBTBluetoothA2DPHelper.uid = nil
      // MBT A2DP audio is disconnected
      DispatchQueue.main.async {
        self.audioA2DPDelegate?.audioA2DPDidDisconnect?()
      }
    }
  }
}
