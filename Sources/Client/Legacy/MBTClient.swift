import Foundation

/*******************************************************************************
 * MBTClient
 *
 * MBT engine to implement to work with the headset.
 *
 ******************************************************************************/
public class MBTClient {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// Singleton of MBTClient
  public static let shared: MBTClient = MBTClient()

  /******************** Managers ********************/

  /// Init a MBTBluetoothManager, which deals with
  /// the MBT headset bluetooth.
  internal let bluetoothManager: MBTBluetoothManager = .shared

  /// Init a MBTEEGAcquisitionManager, which deals with
  /// data from the MBT Headset.
  internal let eegAcquisitionManager: MBTEEGAcquisitionManager = .shared

  /// Init a MBTDeviceAcquisitionManager, which deals with
  /// data from the MBT Headset.
  internal let deviceAcquisitionManager: MBTDeviceAcquisitionManager = .shared

  /// Init a MBTSignalProcessingManager, which deals with
  /// the Signal Processing Library (via the bridge).
  internal let signalProcessingManager: MBTSignalProcessingManager = .shared

  /******************** Acquisition ********************/

  internal var recordInfo: MBTRecordInfo = MBTRecordInfo()

  public var isEegAcqusitionRecordingPaused: Bool {
    set { eegAcquisitionManager.isRecording = newValue }
    get { return eegAcquisitionManager.isRecording }
  }

  /// Legacy called history_size. Number of eegpackets used to compute some dark informations
  /// on the C++ algorithms.
  public let acquisitionhistorySize = Constants.EEGPackets.historySize

  /******************** Bluetooth ********************/

  public var isBluetoothOn: Bool {
    return bluetoothManager.bluetoothStatesHistory.isPoweredOn
  }

  public var isConnected: Bool {
    return bluetoothManager.isAudioAndBLEConnected
  }

  public var bluetoothAuthorization: BluetoothAuthorization {
    return bluetoothManager.bluetoothAuthorization
  }

  public var bluetoothState: BluetoothState {
    return bluetoothManager.bluetoothState
  }

  /******************** Delegates ********************/

  public weak var bluetoothEventDelegate: MBTBluetoothEventDelegate? {
    didSet { bluetoothManager.eventDelegate = bluetoothEventDelegate }
  }

  public weak var bluetoothAudioA2DPDelegate: MBTBluetoothA2DPDelegate? {
    didSet { bluetoothManager.audioA2DPDelegate = bluetoothAudioA2DPDelegate }
  }

  public weak var eegAcqusitionDelegate: MBTEEGAcquisitionDelegate? {
    didSet { eegAcquisitionManager.delegate = eegAcqusitionDelegate }
  }

  public weak var deviceAcqusitionDelegate: MBTDeviceAcquisitionDelegate? {
    didSet { deviceAcquisitionManager.delegate = deviceAcqusitionDelegate }
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  private init() {
    if let deviceName = bluetoothManager.getBLEDeviceNameFromA2DP(),
      !bluetoothManager.isAudioAndBLEConnected {
      bluetoothManager.connectTo(deviceName)
    }

    initLog(logToFile: false, isDebugMode: false)

    setupBluetoothManager()
  }

  private func setupBluetoothManager() {
    bluetoothManager.didReceiveBrainData = { [weak self] brainData in
      self?.eegAcquisitionManager.processBrainActivity(data: brainData)
    }

    bluetoothManager.didReceiveHeadsetStatus = { [weak self] characteristic in
      self?.deviceAcquisitionManager.processHeadsetStatus(characteristic)
    }

    
  }

  //----------------------------------------------------------------------------
  // MARK: - Connections
  //----------------------------------------------------------------------------

  /// Connect to bluetooth LE profile of the MBT headset.
  /// BLE deals with EEG, but also OAD, device information,
  /// battery, etc.
  /// - Remark: deviceName is optional if deviceName isn't provided the
  /// MelomindEngine will connect to the first headset detected
  /// - Parameters:
  ///   - deviceName: The device Name Headset which be connect to the BLE
  ///   - delegate: The Melomind Engine Delegate which allow communication with
  ///   the Headset.

  /// NOT USED
  public func connectEEG(_ deviceName: String? = nil,
                         withDelegate delegate: MelomindEngineDelegate) {
    setEEGDelegate(delegate)
    bluetoothManager.connectTo(deviceName)
  }

  /// Connect to the audio part of the MBT Headset (using the A2DP
  /// bluetooth protocol).
  /// - Remark: Audio can't be connected from code. User has to connect to it
  /// through.
  /// - Remark: deviceName is optional if deviceName isn't provided the
  /// MelomindEngine will connect to the first headset detected
  /// settings, on the first time is using it.
  /// - Parameters:
  ///   - delegate: The Melomind Engine Delegate which allow communication with
  ///   the Headset.
  public func connectEEGAndA2DP(_ deviceName: String? = nil,
                                withDelegate delegate: MelomindEngineDelegate) {
    setEEGAndA2DPDelegate(delegate)
    bluetoothManager.connectTo(deviceName)
  }

  /// Start the bluetooth connection process.
  /// - Parameters:
  ///   - named: The name of the device to connect (Bluetooth profile).
  public func connectToBlueetooth(named deviceName: String? = nil) {
    bluetoothManager.connectTo(deviceName)
  }

  /// Disconnect the iDevice from the headset
  /// - Remark: The audio can't be disconnect from code.
  public func cancelConnection() {
    bluetoothManager.disconnect()
  }

  //----------------------------------------------------------------------------
  // MARK: - Getters
  //----------------------------------------------------------------------------

  // TODO: Use computed variables instead.

  /// Get BLE device Name.
  ///
  /// - Returns: A *String* instance of BLE device Name or nil if no melomind is
  /// connected (BLE).
  public func getDeviceNameBLE() -> String? {
     return bluetoothManager.getBLEDeviceNameFromA2DP()
  }

  /// Get A2DP device Name.
  ///
  /// - Returns: A *String* instance of A2DP device Name or nil if no melomind
  /// is connected (A2DP).
  public func getDeviceNameA2DP() -> String? {
    return bluetoothManager.getA2DPDeviceName()
  }

  /// GET A2DP Device Name for an unpaired device (not connected in A2DP).
  ///
  /// - Returns: A *String* instance of A2DP device Name for an unpaired device
  /// or nil if no melomind is connected in BLE.
  public func getUnpairedDeviceNameA2DP() -> String? {
    return bluetoothManager.getA2DPDeviceNameFromBLE()
  }

  /// Get the QRCode of the current connected device
  ///
  /// - Returns: A *String* instance of connected device's QR Code
  public func getDeviceQrCode() -> String? {
    return DeviceManager.deviceQrCode
  }

  public func getDeviceSerialNumber(fromQrCode qrCode: String) -> String? {
    return qrCode.serialNumberFomQRCode
  }

  public func setQrCodeAndSerialNumber(qrCode: String, serialNumber: String) {
    #warning("TODO: remove singleton")
    // DeviceManager.getCurrentDevice()?.setQrCodeAndSerialNumber(
    MBTQRCodeSerial.shared.setQrCodeAndSerialNumber(qrCode: qrCode,
                                                    serialNumber: serialNumber)
  }

  #warning("TODO: Remove")
  /// Get the latest battery level saved in DB.
  ///
  /// - Returns: A *Int* instance of latest battery level saved in DB or nil if
  /// no melomind is connected (BLE).
  public func getBatteryLevel() -> Int? {
    return DeviceManager.getCurrentDevice()?.batteryLevel
  }

  /// Getter for device informations of the MBT headset.
  /// - Returns: A *MBTDeviceInformations* instance of the connected headset if
  /// no melomind is connected (BLE).
  public func getDeviceInformations() -> MBTDeviceInformations? {
    return DeviceManager.deviceInformation
  }

  /// Getter for Device Name of the MBT headset.
  ///
  /// - Returns: A *String* instance of the device's name, or nil if no instance
  /// yet.
  public func getDeviceName() -> String? {
    return DeviceManager.connectedDeviceName
  }

  /// Getter Names of all regitered devices.
  /// - Returns: A *[String]* instance of array of deviceName.
  public func getRegisteredDevices() -> [MBTDevice] {
    var tabDeviceName = [MBTDevice]()

    for device in DeviceManager.registeredDevices {
      tabDeviceName.append(device)
    }

    return tabDeviceName
  }

  //----------------------------------------------------------------------------
  // MARK: - JSON EEG
  //----------------------------------------------------------------------------

  /// Send JSON File
  public func sendEEGFile(_ urlFile: URL,
                          baseUrl: String,
                          removeFile: Bool,
                          accessTokens: String) {
    BrainwebRequest.shared.accessTokens = accessTokens
    BrainwebRequest.shared.sendJSON(urlFile, baseURL: baseUrl) { success in
      guard success && removeFile else { return }
      RecordFileSaver.shared.removeRecord(at: urlFile)
    }
  }

  /// Save the DB recording on file  ///
  /// - Parameters:
  ///   - idUser: A *Int* instance of the id user
  ///   - comments: A *[String]* instance of comments
  ///   - completion: A *URL* instance of the saved file, or nil if file is not
  ///   created and save
  public func saveRecordingOnFile(_ idUser: Int,
                                  algo: String? = nil,
                                  comments: [String] = [String](),
                                  completion: @escaping (URL?) -> Void) {
    guard let device = DeviceManager.getCurrentDevice() else {
      log.error("Current device not found")
      completion(nil)
      return
    }

    eegAcquisitionManager.saveRecording(
      userId: idUser,
      algo: algo,
      comments: comments,
      device: device,
      recordingInformation: recordInfo,
      recordFileSaver: RecordFileSaver.shared,
      completion: completion
    )
  }

  //----------------------------------------------------------------------------
  // MARK: - Setters
  //----------------------------------------------------------------------------

  // TODO: Use variable.

  /// Set delegate to EEGAcquistionManager, DeviceAcquisitionManager &
  /// BluetoothManager (event Delegate).
  ///
  /// - Parameter delegate:  new delegate listening Melomind Engine Delegate.
  public func setEEGDelegate(_ delegate: MelomindEngineDelegate) {
    // Add the Acquisition delegate to the Acquisition manager
    initAcquisitionManager(with: delegate)

    // Add the BluetoothEventDelegate and A2DPDelegate
    bluetoothManager.eventDelegate = delegate
  }

  /// Set delegate to EEGAcquistionManager, DeviceAcquisitionManager &
  /// BluetoothManager (eventDelegate & audioA2DPDelegate).
  ///
  /// - Parameter delegate:  new delegate listening Melomind Engine Delegate.
  public func setEEGAndA2DPDelegate(_ delegate: MelomindEngineDelegate) {
    // Add the Acquisition delegate to the Acquisition manager

    initAcquisitionManager(with: delegate)

    // Add the BluetoothEventDelegate and A2DPDelegate
    bluetoothManager.eventDelegate = delegate
    bluetoothManager.audioA2DPDelegate = delegate
  }

  //----------------------------------------------------------------------------
  // MARK: - BluetoothManager
  //----------------------------------------------------------------------------

  /// Ask to read BatteryStatus
  /// - Remark: Data will be provided through the MelomineEngineDelegate.
  public func readBatteryStatus() {
    guard DeviceManager.connectedDeviceName != nil else { return }
//    bluetoothManager.requestUpdateBatteryLevel()
    bluetoothManager.requestBatteryLevel()
  }

  /// Stop the batteryLevel Event
  public func stopReceiveBatteryLevelEvent() {
    guard DeviceManager.connectedDeviceName != nil else { return }
    bluetoothManager.timers.stopBatteryLevelTimer()
  }

  /// Start the batteryLevel Event
  public func startReceiveBatteryLevelEvent() {
    guard DeviceManager.connectedDeviceName != nil else { return }
    bluetoothManager.startBatteryLevelTimer()
  }

  //----------------------------------------------------------------------------
  // MARK: - Acquisition Manager
  //----------------------------------------------------------------------------

  /// Add delegate to Acquisition Manager.
  /// - Parameters:
  ///   - delegate: The Melomind Engine Delegate to get Headset datas.
  internal func initAcquisitionManager(with delegate: MelomindEngineDelegate) {
    eegAcquisitionManager.delegate = delegate
    deviceAcquisitionManager.delegate = delegate
  }

  /// Start saving EEGPacket on DB  /// - Parameters:
  ///   - newRecord: Create a new recordId on the JSON File
  ///   - recordingType: Change the session's type
  @discardableResult
  public func startRecording(
    _ newRecord: Bool,
    recordingType: MBTRecordingType = MBTRecordingType()
  ) -> UUID? {
    EEGPacketManager.shared.removeAllEEGPackets()
    guard DeviceManager.connectedDeviceName != nil else { return nil }

    if newRecord {
      recordInfo = MBTRecordInfo()
      recordInfo.recordingType = recordingType
    } else {
      recordInfo.recordingType = recordingType
    }

    eegAcquisitionManager.isRecording = true

    return recordInfo.recordId
  }

  /// Stop saving EEGPacket on DB
  public func stopRecording() {
    guard DeviceManager.connectedDeviceName != nil else { return }
    eegAcquisitionManager.isRecording = false
  }

  /// Start streaming EEG Data from MyBrainActivity Characteristic.
  /// Start streaming headSet Data from HeadsetStatus Characteristic.
  /// - Remark: Data will be provided through the MelomineEngineDelegate.
  public func startStream(_ shouldUseQualityChecker: Bool) {
    guard let currentDevice = DeviceManager.getCurrentDevice() else { return }
    eegAcquisitionManager.streamHasStarted(
      isUsingQualityChecker: shouldUseQualityChecker,
      sampleRate: currentDevice.sampRate
    )
    bluetoothManager.isListeningToEEG = true
    bluetoothManager.isListeningToHeadsetStatus = true
  }

  /// Stop streaming EEG Data to MelomineEngineDelegate.
  /// Stop streaming headSet Data from MelomindEngineDelegate.
  /// - Remark: a JSON will be created with all the MBTEEGPacket.
  public func stopStream() {
//    bluetoothManager.isListeningToHeadsetStatus = false
    bluetoothManager.isListeningToEEG = false
    eegAcquisitionManager.streamHasStopped()
  }

  //----------------------------------------------------------------------------
  // MARK: - OAD
  //----------------------------------------------------------------------------

  /// Start the OAD process
  public func startOADTransfer() {
    bluetoothManager.startOAD(withDevice: DeviceManager.getCurrentDevice())
  }

  /// To know if a new headset firmware version is available.
  /// Asynchrone fonction call a block completion with an boolean argument.
  /// - Parameter completion: block completion call after getting melomind info.
  /// with boolean argument.
  public func isMelomindNeedToBeUpdate() -> Bool? {
    return DeviceManager.getCurrentDevice()?.shouldUpdateFirmware
  }

  //----------------------------------------------------------------------------
  // MARK: - Upload
  //----------------------------------------------------------------------------

  /// Remove a specific Device.
  /// parameters:
  ///   - deviceName: The Device name which will be remove from DB.
  public func removeDevice(_ deviceName: String) -> Bool {
    return DeviceManager.removeDevice(deviceName)
  }

  //----------------------------------------------------------------------------
  // MARK: - Signal Processing Manager
  //----------------------------------------------------------------------------

  /// Compute calibration with the last 'n' complete packets.
  /// - Parameters:
  ///   - n: Number of complete packets to take to compute the calibration.
  /// - Returns: A dictionnary received by the Signal Processing library.
  public func computeCalibration(
    onNumberOfPackets numberOfPackets: Int
  ) -> CalibrationOutput? {
    let eegPacketsCount = EEGPacketManager.shared.getEEGPackets().count

    guard let currentDevice = DeviceManager.getCurrentDevice(),
      eegPacketsCount >= numberOfPackets else {
      return nil
    }

    return signalProcessingManager.computeCalibration(
      numberOfPackets,
      sampleRate: currentDevice.sampRate,
      channelCount: currentDevice.nbChannels,
      packetLength: currentDevice.eegPacketLength,
      eegPacketManager: EEGPacketManager.shared
    )
  }

  /// computeRelaxIndex
  ///
  /// - Returns: RelaxIndex
  public func computeRelaxIndex() -> Float? {
    let eegPacketCount = EEGPacketManager.shared.getEEGPackets().count

    #warning("Condition is not the same as inside `computeRelaxIndex`. Here: getEEGPackets().count, return nil. Inside: lastPackets.count, return 0")
    let isEegPacketsCountHigherThanHistorySize =
      eegPacketCount >= Constants.EEGPackets.historySize

    guard isEegPacketsCountHigherThanHistorySize,
          let currentDevice = DeviceManager.getCurrentDevice() else {
      return nil
    }

    return signalProcessingManager.computeRelaxIndex(
      eegPacketManager: .shared,
      sampleRate: currentDevice.sampRate,
      channelCount: currentDevice.nbChannels
    )
  }

  /// ComputeSessionStatistics
  public func computeSessionStatistics(_ inputSNR: [Float],
                                       threshold: Float) -> [String: Float] {
    guard DeviceManager.connectedDeviceName != nil, inputSNR.count > 3 else {
      return [:]
    }
    return signalProcessingManager.analyseSession(inputSNR,
                                                  threshold: threshold)
  }

}
