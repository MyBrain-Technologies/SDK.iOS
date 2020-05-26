import Foundation
import CoreBluetooth
import AVFoundation

// TEMP: LEGACY CODE
// swiftlint:disable type_body_length

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

  //swiftlint:disable weak_delegate
  let centralManagerDelegate = BluetoothCentralManagerDelegate()

  lazy var bluetoothConnector: BluetoothConnector = {
    let centralManager = CBCentralManager(delegate: self, // TEMP, should be CentralManagerDelegate after
                                          queue: nil)
    return BluetoothConnector(centralManager: centralManager)
  }()

  /******************** Timers ********************/

  lazy var timers: BluetoothTimers = {
    return BluetoothTimers(delegate: self)
  }()

  /******************** Legacy ********************/

  /// A *Bool* which indicate if the headset is connected or not to BLE and A2DP.
  /// - Remark: Sends a notification when changed (on *willSet*).
  var isConnected: Bool {

    let autoConnection =
      audioA2DPDelegate?.autoConnectionA2DPFromBLE?() ?? false
    let firmwareIsHigher =
      deviceFirmwareVersion(isHigherOrEqualThan: .a2dpFromHeadset)

    if autoConnection && firmwareIsHigher && isConnectedBLE {
      return DeviceManager.connectedDeviceName == getBLEDeviceNameFromA2DP()
    } else {
      return isConnectedBLE
    }
  }

  /// A *Bool* which indicate if the headset is connected or not to BLE and A2DP.
  /// - Remark: Sends a notification when changed (on *willSet*).
  var isConnectedBLE: Bool {
    return blePeripheral != nil
  }

  /// A *Bool* which indicate if the headset is connected or not to A2DP.
  var isConnectedA2DP: Bool = { MBTBluetoothManager.isA2DPConnected() }()

  /// Authorization given to access to bluetooth.
  var bluetoothAuthorization: BluetoothAuthorization = .undetermined

  var bluetoothState: BluetoothState = .undetermined

  /// A *Bool* which enable or disable headset EEG notifications.
  var isListeningToEEG = false {
    didSet {
      guard BluetoothDeviceCharacteristics.shared.brainActivityMeasurement != nil
        else { return }

      self.blePeripheral?.setNotifyValue(
        isListeningToEEG,
        for: BluetoothDeviceCharacteristics.shared.brainActivityMeasurement
      )
    }
  }

  /// A *Bool* which enable or disable headset saturation notifications.
  var isListeningToHeadsetStatus = false {
    didSet {
      guard BluetoothDeviceCharacteristics.shared.headsetStatus != nil
        else { return }

      self.blePeripheral?.setNotifyValue(
        isListeningToHeadsetStatus,
        for: BluetoothDeviceCharacteristics.shared.headsetStatus
      )
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
      if blePeripheral != nil {
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

  let bluetoothConnectionHistory = BluetoothConnectionHistory()

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
    if OADState == .connected, bluetoothConnectionHistory.isConnected {
      timers.stopBLEConnectionTimer()

      bluetoothConnector.scanForMelomindConnections()

      return
    }

    if blePeripheral != nil { disconnect() }

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
    isConnectedA2DP = false
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

    bluetoothConnector.stopScanningForConnections(on: blePeripheral)

    blePeripheral = nil
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
            isDeviceInfoNotNil = currentDeviceInfo.isDeviceInfoNotNil()
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
    if let deviceId = DeviceManager.getDeviceInfos()?.deviceId,
      let name = MBTQRCodeSerial(qrCodeisKey: false).value(for: deviceId) {
      return name
    }
    return nil
  }

  /// Send firmware version and the buffer length to the Melomind
  /// important: Event
  /// - onProgressUpdate
  func sendFWVersionPlusLength() {
    if let OADManager = OADManager {
      var bytesArray = [UInt8](repeating: 0, count: 5)

      bytesArray[0] = MailBoxEvents.startOTATFX.rawValue
      bytesArray[1] = OADManager.getFWVersionAsByteArray()[0]
      bytesArray[2] = OADManager.getFWVersionAsByteArray()[1]
      bytesArray[3] = OADManager.oadProgress.nBlock.loUint8
      bytesArray[4] = OADManager.oadProgress.nBlock.hiUint16

      blePeripheral?.writeValue(
        Data(bytesArray),
        for: BluetoothDeviceCharacteristics.shared.mailBox,
        type: .withResponse
      )
      eventDelegate?.onProgressUpdate?(0.05)
      OADState = .ready
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Read Characteristic Methods
  //----------------------------------------------------------------------------

  func sendDeviceExternalName(_ name: String) {
    timers.startSendExternalNameTimer()

    let serialNumberByteArray: [UInt8] = [
      MailBoxEvents.setSerialNumber.rawValue,
      0xAB,
      0x21
    ]
    let bytesArray = serialNumberByteArray + [UInt8](name.utf8)

    guard let characteristic =
      BluetoothDeviceCharacteristics.shared.mailBox else { return }

    blePeripheral?.setNotifyValue(true, for: characteristic)
    blePeripheral?.writeValue(Data(bytesArray),
                              for: characteristic,
                              type: .withResponse)
  }

  //  Method Request Update Status Battery
  func requestBatteryLevel() {
    guard let blePeripheral = blePeripheral,
      let characteristic = BluetoothDeviceCharacteristics.shared.deviceState else {
        return
    }

    blePeripheral.readValue(for: characteristic)
  }

  func requestUpdateDeviceInfo() {
    DeviceManager.resetDeviceInfo()

    guard let blePeripheral = blePeripheral else { return }

    for characteristic in BluetoothDeviceCharacteristics.shared.deviceInformations {
      blePeripheral.readValue(for: characteristic)
    }
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
