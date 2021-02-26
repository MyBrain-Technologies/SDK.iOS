import Foundation
import CoreBluetooth
import AVFoundation

enum MBTFirmwareVersion: String {
  case a2dpFromHeadset = "1.6.7"
  case registerExternalName = "1.7.1"
}

/// Manage for the SDK the MBT Headset Bluetooth Part (connection/deconnection).
internal class MBTBluetoothManager: NSObject {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// Singleton declaration
  static let shared = MBTBluetoothManager()

  /******************** Delegate ********************/

  /// The MBTBluetooth Event Delegate.
  weak var eventDelegate: MBTBluetoothEventDelegate?

  /// The MBT Audio A2DP Delegate.
  /// Tell developers when audio connect / disconnect
  weak var audioA2DPDelegate: MBTBluetoothA2DPDelegate?

  /******************** Connection ********************/

  lazy var bluetoothConnector: BluetoothPeripheralConnector = {
    let centralManager = CBCentralManager(delegate: self, queue: nil)
    return BluetoothPeripheralConnector(centralManager: centralManager)
  }()

  lazy var peripheralIO: IOBluetoothPeripheral = {
    return IOBluetoothPeripheral(peripheral: nil)
  }()

  /******************** Timers ********************/

  lazy var timers: BluetoothTimers = {
    return BluetoothTimers(delegate: self)
  }()

  /******************** Legacy ********************/

  /// A *Bool* which indicate if the headset is connected or not to BLE and A2DP.
  /// - Remark: Sends a notification when changed (on *willSet*).
  var isAudioAndBLEConnected: Bool {
    let autoConnection =
      audioA2DPDelegate?.autoConnectionA2DPFromBLE?() ?? false
    let firmwareIsHigher =
      deviceFirmwareVersion(isHigherOrEqualThan: .a2dpFromHeadset)

    if autoConnection && firmwareIsHigher && isBLEConnected {
      guard let connectedDeviceName = DeviceManager.connectedDeviceName,
        let bleDeviceName = getBLEDeviceNameFromA2DP() else { return false }

      return connectedDeviceName == bleDeviceName
    } else {
      return isBLEConnected
    }
  }

  /// A *Bool* which indicate if the headset is connected or not to BLE and A2DP.
  var isBLEConnected: Bool {
    return peripheralIO.peripheral != nil
  }

  /// Authorization given to access to bluetooth.
  var bluetoothAuthorization: BluetoothAuthorization = .undetermined

  var bluetoothState: BluetoothState = .undetermined

  /// A *Bool* which enable or disable headset EEG notifications.
  var isListeningToEEG = false {
    didSet {
      peripheralIO.notifyBrainActivityMeasurement(value: isListeningToEEG)
    }
  }

  /// A *Bool* which enable or disable headset saturation notifications.
  var isListeningToHeadsetStatus = false {
    didSet {
      peripheralIO.notifyHeadsetStatus(value: isListeningToHeadsetStatus)
    }
  }

  /// Flag switch to the first reading charasteristic to finalize Connection
  /// or to process the receiving Battery Level
  var processBatteryLevel: Bool = false

  /// An object that manages and advertises peripheral services exposed by this app.
  /// Use for BLE authorizations.
  var peripheralManager: CBPeripheralManager?

  /// The BLE peripheral with which a connection has been established.
  var blePeripheral: CBPeripheral? {
    didSet {
      if isBLEConnected {
        eventDelegate?.onHeadsetStatusUpdate?(true)
      } else {
        eventDelegate?.onHeadsetStatusUpdate?(false)
      }
    }
  }

  /// A counter which allows to know if all the characteristics have been discovered
  var counterServicesDiscover = 0 {
    didSet {
      log.verbose("🆕 Services discovered count: \(counterServicesDiscover)")
    }
  }

  let bluetoothStatesHistory = BluetoothStateHistory()

  /// Flag OAD is enable
  var isOADInProgress = false

  /// OAD State (Enum: OADStateType)
  var OADState: OADStateType = .disable {
    didSet {
      if OADState == .disable {
        timers.stopOADTimer()
      }
    }
  }

  var OADManager: MBTOADManager?

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  override init() {
    super.init()
    connectA2DP()
    initBluetoothManager()
  }

  //----------------------------------------------------------------------------
  // MARK: - Internal properties
  //----------------------------------------------------------------------------

  private let binariesFinder = BinariesFileFinder()

  //----------------------------------------------------------------------------
  // MARK: - Connect/Disconnect Methods
  //----------------------------------------------------------------------------

  /// Start the connection process.
  /// - Parameters:
  ///   - deviceName: The name of the device to connect (Bluetooth profile).
  func connectTo(_ deviceName: String? = nil) {
    if OADState == .connected, bluetoothStatesHistory.isPoweredOn {
      timers.stopBLEConnectionTimer()
      bluetoothConnector.scanForMelomindConnections()
      return
    }

    if isBLEConnected { disconnect() }

    initBluetoothManager()

    DeviceManager.connectedDeviceName = deviceName ?? ""

    timers.startBLEConnectionTimer()
  }

  /// Initialise or Re-initialise the BluetoothManager [Prepare all variable for the connection]
  func initBluetoothManager() {
    // Download Init
    isOADInProgress = false
    OADState = .disable

    // Connection Init
    counterServicesDiscover = 0
//    isConnectedA2DP = false
    isListeningToEEG = false
    isListeningToHeadsetStatus = false
    processBatteryLevel = false

    bluetoothConnector.centralManager = CBCentralManager(delegate: self,
                                                         queue: nil)

    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)

    DeviceManager.connectedDeviceName = nil

    // Characteristic Init
    BluetoothDeviceCharacteristics.shared.brainActivityMeasurement = nil
    BluetoothDeviceCharacteristics.shared.deviceState = nil
    BluetoothDeviceCharacteristics.shared.deviceInformations.removeAll()
  }

  /// Disconnect centralManager, and remove session's values.
  func disconnect() {
    timers.stopAllTimers()

    bluetoothConnector.stopScanningForConnections(
      on: peripheralIO.peripheral
    )

    peripheralIO.peripheral = nil
  }

  /// Finalize the connection
  func finalizeConnectionMelomind() {
    timers.stopFinalizeConnectionMelomindTimer()

    guard let currentDevice = DeviceManager.getCurrentDevice() else {
      let error = DeviceError.notConnected.error
      log.info("📲 Cannot get current device informations", context: error)

      eventDelegate?.onConnectionFailed?(error)
      return
    }

    MBTClient.shared.eegAcquisitionManager.setUpWith(device: currentDevice)

    if !isOADInProgress {
      timers.stopBLEConnectionTimer()

      if shouldRequestA2DPConnection() {
        requestConnectA2DP()
      } else {
        eventDelegate?.onConnectionEstablished?()
        startBatteryLevelTimer()
      }
    } else {
      if shouldRequestA2DPConnection() {
        requestConnectA2DP()
      } else {
        isOADInProgress = false
        OADState = .disable

        guard isDeviceVersionUpToDate() else {
          let error = FirmwareError.versionInvalidAfterUpdate.error
          log.error("📲 Device version is not up to date", context: error)

          eventDelegate?.onUpdateFailWithError?(error as Error)
          return
        }

        eventDelegate?.onProgressUpdate?(1.0)
      }
    }
  }

  private func isDeviceVersionUpToDate() -> Bool {
    let currentDevice = DeviceManager.getCurrentDevice()

    guard let fwVersionNumber =
      currentDevice?.deviceInfos?.firmwareVersion?.versionNumber,
      let oadFwVersionNumber =
      self.OADManager?.fwVersion.versionNumber else { return false }

    let deviceFwVersion = FormatedVersion(string: fwVersionNumber)
    let oadFwVersion = FormatedVersion(string: oadFwVersionNumber)

    log.info("Device current firmware version", context: deviceFwVersion)
    log.info("Expected firmware version", context: oadFwVersion)

    return deviceFwVersion == oadFwVersion
  }

  /// Run the completion after the device infos is available with a time out
  ///
  /// - important: Event
  /// - onConnectionFailed: 917 | "Time out getting device infos"
  /// - Parameter completion: the block to execute after getting the device infos
  func prepareDeviceWithInfo(completion: @escaping () -> Void) {
    requestUpdateDeviceInfo()

    DispatchQueue.global().async {
      var isDeviceInfoNotNil = false
      var indexLoop = 0.0
      while !isDeviceInfoNotNil {
        log.verbose("sleeping")
        usleep(500000)
        DispatchQueue.main.sync {
          if let currentDevice = DeviceManager.getCurrentDevice(),
            let currentDeviceInfo = currentDevice.deviceInfos {
            isDeviceInfoNotNil = currentDeviceInfo.isDeviceInfoNotNil
          }
        }

        indexLoop += 0.5
        guard indexLoop <= 120 else {
          let error = DeviceError.retrieveInfoTimeOut.error
          log.error("Timeout on retrieving device informations", context: error)

          self.eventDelegate?.onConnectionFailed?(error)

          self.disconnect()
          return
        }
      }

      DispatchQueue.main.sync {
        if let currentDevice = DeviceManager.getCurrentDevice(),
          currentDevice.shouldUpdateFirmware {
          self.eventDelegate?.onNeedToUpdate?()
        }

        completion()
      }
    }
  }

  // MARK: - External Name / Product Name methods

  internal func shouldUpdateDeviceExternalName() -> Bool {
    let productName = DeviceManager.getDeviceInfos()?.productName
    return productName == Constants.defaultProductName
      && deviceFirmwareVersion(isHigherOrEqualThan: .registerExternalName)
  }

  internal func getDeviceExternalName() -> String? {
    if let _ = DeviceManager.getDeviceInfos()?.deviceId,
       let name = MBTQRCodeSerial.shared.qrCode { // MBTQRCodeSerial(qrCodeisKey: false).value(for: deviceId) {
      return name
    }
    return nil
  }

  /// Send firmware version and the buffer length to the Melomind
  /// important: Event
  /// - onProgressUpdate
  func sendFWVersionPlusLength() {
    guard let OADManager = OADManager else { return }

    peripheralIO.write(
      firmwareVersion: OADManager.getFWVersionAsByteArray(),
      numberOfBlocks: OADManager.oadProgress.nBlock
    )

    eventDelegate?.onProgressUpdate?(0.05)
    OADState = .ready
  }

  //----------------------------------------------------------------------------
  // MARK: - Read Characteristic Methods
  //----------------------------------------------------------------------------

  func sendDeviceExternalName(_ name: String) {
    timers.startSendExternalNameTimer()

    peripheralIO.notifyMailBox(value: true)
    peripheralIO.write(deviceExternalName: name)
  }

  //  Method Request Update Status Battery
  func requestBatteryLevel() {
    peripheralIO.readDeviceState()
  }

  func requestUpdateDeviceInfo() {
    DeviceManager.resetDeviceInfo()

    peripheralIO.readDeviceInformations()
  }

  /// Compare the firmware version to determine if it's equal or higher to another version
  ///
  /// - Returns: A *Bool* value which is true if the firmware version is same or higher than
  /// the parameter
  internal func deviceFirmwareVersion(
    isHigherOrEqualThan version: MBTFirmwareVersion
  ) -> Bool {
    guard let deviceFWVersion =
      DeviceManager.getCurrentDevice()?.deviceInfos?.firmwareVersion else {
        return false
    }

    let versionToCompare = FormatedVersion(string: version.rawValue)
    let currentVersion = FormatedVersion(string: deviceFWVersion)

    return currentVersion >= versionToCompare
  }
}
