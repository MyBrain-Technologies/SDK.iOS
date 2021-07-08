import Foundation

/*******************************************************************************
 * MBTClientV2
 *
 * MBT engine to implement to work with the headset.
 *
 ******************************************************************************/

#warning("RENAME `Acquiser` to `acquirer`")
#warning("TODO: Move EegKpis from melomind here!")

public class MBTClientV2 {

  //----------------------------------------------------------------------------
  // MARK: - Error
  //----------------------------------------------------------------------------

  enum SDKError: Error {
    case noConnectedHeadset
    case noEegAcquiser
  }

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// Singleton of MBTClient
  public static let shared: MBTClientV2 = MBTClientV2()

  /******************** Managers ********************/

  /// Init a MBTBluetoothManager, which deals with
  /// the MBT headset bluetooth.
  internal let bluetoothManager = MBTBluetoothManagerV2()

  /// Init a MBTEEGAcquisitionManager, which deals with data from the Headset.
  internal var eegAcquiser: EegAcquiser?

  /// Init a MBTSignalProcessingManager, which deals with
  /// the Signal Processing Library (via the bridge).
  internal let signalProcessingManager = SignalProcessingManager()

  /******************** Acquisition ********************/

  internal var recordInfo: MBTRecordInfo = MBTRecordInfo()

  public var isEegAcqusitionRecordingPaused: Bool {
    set { eegAcquiser?.isRecording = newValue }
    get { return eegAcquiser?.isRecording ?? false }
  }

  /// Legacy called history_size. Number of eegpackets used to compute some
  /// dark informations on the C++ algorithms.
  public let acquisitionhistorySize = Constants.EEGPackets.historySize

  /******************** Recording ********************/

  private(set) var recordingType: MBTRecordType?

  /******************** Analyzer ********************/

  private let analyzer = Analyzer()

  /******************** Bluetooth ********************/

  public var isBluetoothOn: Bool {
    // or bluetoothManager.authorization
    return bluetoothManager.state == .poweredOn
  }

  public var isConnected: Bool {
    return bluetoothManager.hasConnectedDevice
  }

  public var isA2dpConnected: Bool {
    return bluetoothManager.hasA2dpConnectedDevice
  }

  public var bluetoothAuthorization: BluetoothAuthorization {
    return bluetoothManager.authorization
  }

  public var bluetoothState: BluetoothState {
    return bluetoothManager.state
  }

  /// BLE device Name of connected melomind, nil otherwise.
  public var deviceNameBLE: String? {
    #warning("TO check")
    return deviceInformation?.productName
  }

  /// A2DP device Name of connected melomind (A2DP), nil otherwise.
  public var deviceNameA2DP: String? {
    return bluetoothManager.currentDeviceA2DPName
  }

  /// Device information of the current connected headset.
  public var deviceInformation: DeviceInformation? {
    return bluetoothManager.currentDeviceInformation
  }

  /// Getter for Device Name of the MBT headset.
  ///
  /// - Returns: A *String* instance of the device's name, or nil if no instance
  /// yet.
  public var deviceName: String? {
    #warning("TO check")
    return deviceInformation?.productName
  }

  internal var isListeningToEEG: Bool {
    set { bluetoothManager.isListeningToEEG = newValue }
    get { return bluetoothManager.isListeningToEEG }
  }

  #warning("TO EVALUATE")
//  public var batteryLevelUpdateInterval: TimeInterval? {
//    didSet {
//      //  /// Stop the batteryLevel Event
//      //  public func stopReceiveBatteryLevelEvent() {
//      //    guard DeviceManager.connectedDeviceName != nil else { return }
//      //    bluetoothManager.timers.stopBatteryLevelTimer()
//      //  }
//      //
//      //  /// Start the batteryLevel Event
//      //  public func startReceiveBatteryLevelEvent() {
//      //    guard DeviceManager.connectedDeviceName != nil else { return }
//      //    bluetoothManager.startBatteryLevelTimer()
//      //  }
//    }
//  }

  /******************** Delegates ********************/

  public weak var bleDelegate: MBTBLEBluetoothDelegate?
//  {
//    didSet { bluetoothManager.bleDelegate = bleDelegate }
//  }

  public weak var a2dpDelegate: MBTA2DPBluetoothDelegate? {
    didSet { bluetoothManager.a2dpDelegate = a2dpDelegate }
  }

  public weak var acquisitionDelegate: MBTAcquisitionDelegate?

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  private init() {
    #if DEBUG
    initLog(logToFile: false, isDebugMode: true)
    #else
    initLog(logToFile: false, isDebugMode: false)
    #endif
    setup()
  }

  private func setup() {
    setupBluetoothManager()
  }

  private func setupBluetoothManager() {
    bluetoothManager.bleDelegate = self
    bluetoothManager.acquisitionDelegate = self

//    if let deviceName = bluetoothManager.getBLEDeviceNameFromA2DP(),
//      !bluetoothManager.isAudioAndBLEConnected {
//      bluetoothManager.connectTo(deviceName)
//    }
//
//    bluetoothManager.didReceiveBrainData = { [weak self] brainData in
//      self?.eegAcquisitionManager.processBrainActivity(data: brainData)
//    }
//
//    bluetoothManager.didReceiveHeadsetStatus = { [weak self] characteristic in
//      self?.deviceAcquisitionManager.processHeadsetStatus(characteristic)
//    }


  }

  private func update(from deviceInformation: DeviceInformation) {
    let acquisitionInformation = deviceInformation.acquisitionInformation

    eegAcquiser = EegAcquiser(
      bufferSizeMax: acquisitionInformation.eegPacketMaxSize,
      packetLength: acquisitionInformation.eegPacketSize,
      channelCount: deviceInformation.acquisitionInformation.channelCount,
      sampleRate: deviceInformation.acquisitionInformation.sampleRate,
      signalProcessor: signalProcessingManager
    )

  }

  //----------------------------------------------------------------------------
  // MARK: - Bluetooth connections
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

//  /// NOT USED
//  public func connectEEG(_ deviceName: String? = nil,
//                         withDelegate delegate: MelomindEngineDelegate) {
//    setEEGDelegate(delegate)
//    bluetoothManager.startScanning()
//  }
//
//  /// Connect to the audio part of the MBT Headset (using the A2DP
//  /// bluetooth protocol).
//  /// - Remark: Audio can't be connected from code. User has to connect to it
//  /// through.
//  /// - Remark: deviceName is optional if deviceName isn't provided the
//  /// MelomindEngine will connect to the first headset detected
//  /// settings, on the first time is using it.
//  /// - Parameters:
//  ///   - delegate: The Melomind Engine Delegate which allow communication with
//  ///   the Headset.
//  public func connectEEGAndA2DP(_ deviceName: String? = nil,
//                                withDelegate delegate: MelomindEngineDelegate) {
//    setEEGAndA2DPDelegate(delegate)
//    bluetoothManager.startScanning()
//  }

  /// Start the bluetooth connection process.
  /// - Parameters:
  ///   - named: The name of the device to connect (Bluetooth profile).
  public func connectToBlueetooth(named deviceName: String? = nil) {
    bluetoothManager.startScanning()
  }

  /// Disconnect the iDevice from the headset
  /// - Remark: The audio can't be disconnect from code.
  public func cancelConnection() {
    bluetoothManager.disconnect()
  }

  //----------------------------------------------------------------------------
  // MARK: - Bluetooth commands
  //----------------------------------------------------------------------------

  /// Ask to read BatteryStatus
  /// - Remark: Data will be provided through the MelomineEngineDelegate.
  public func readBatteryStatus() {
    bluetoothManager.requestBatteryLevel()
  }

  #warning("QRCode or serialNumber ??????")
//  /// GET A2DP Device Name for an unpaired device (not connected in A2DP).
//  ///
//  /// - Returns: A *String* instance of A2DP device Name for an unpaired device
//  /// or nil if no melomind is connected in BLE.
//  public func getUnpairedDeviceNameA2DP() -> String? {
//    return bluetoothManager.getA2DPDeviceNameFromBLE()
//  }

//  /// Get the QRCode of the current connected device
//  ///
//  /// - Returns: A *String* instance of connected device's QR Code
//  public func getDeviceQrCode() -> String? {
//    return DeviceManager.deviceQrCode
//  }
//
//  public func getDeviceSerialNumber(fromQrCode qrCode: String) -> String? {
//    return qrCode.serialNumberFomQRCode
//  }
//
//  public func setQrCodeAndSerialNumber(qrCode: String, serialNumber: String) {
//    #warning("TODO: remove singleton")
//    // DeviceManager.getCurrentDevice()?.setQrCodeAndSerialNumber(
//    MBTQRCodeSerial.shared.setQrCodeAndSerialNumber(qrCode: qrCode,
//                                                    serialNumber: serialNumber)
//  }

//  #warning("TODO: Remove")
//  /// Get the latest battery level saved in DB.
//  ///
//  /// - Returns: A *Int* instance of latest battery level saved in DB or nil if
//  /// no melomind is connected (BLE).
//  public func getBatteryLevel() -> Int? {
//    return DeviceManager.getCurrentDevice()?.batteryLevel
//  }


  //----------------------------------------------------------------------------
  // MARK: - Network
  //----------------------------------------------------------------------------

//  /// Send JSON File
//  public func sendEEGFile(_ urlFile: URL,
//                          baseUrl: String,
//                          removeFile: Bool,
//                          accessTokens: String) {
//    BrainwebRequest.shared.accessTokens = accessTokens
//    BrainwebRequest.shared.sendJSON(urlFile, baseURL: baseUrl) { success in
//      guard success && removeFile else { return }
//      RecordFileSaver.shared.removeRecord(at: urlFile)
//    }
//  }

  //----------------------------------------------------------------------------
  // MARK: - Saving
  //----------------------------------------------------------------------------

  /// Save the DB recording on file  ///
  /// - Parameters:
  ///   - idUser: A *Int* instance of the id user
  ///   - comments: A *[String]* instance of comments
  ///   - completion: A *URL* instance of the saved file, or nil if file is not
  ///   created and save
  public func saveRecordingOnFile(
    idUser: Int,
    algo: String? = nil,
    comments: [String] = [String](),
    completion: @escaping (Result<URL, Error>) -> Void
  ) {
    guard let deviceInformation = deviceInformation else {
      log.error("Current device not found")
      completion(.failure(SDKError.noConnectedHeadset))
      return
    }

    guard let eegAcquiser = eegAcquiser else {
      log.error("eegAcquisitionManager not found")
      completion(.failure(SDKError.noEegAcquiser))
      return
    }

    eegAcquiser.saveRecording(userId: idUser,
                              algo: algo,
                              comments: comments,
                              device: deviceInformation,
                              recordingInformation: recordInfo,
                              recordFileSaver: .shared,
                              completion: completion)
  }

  public func removeRecord(at url: URL) {
    RecordFileSaver.shared.removeRecord(at: url)
  }

  //----------------------------------------------------------------------------
  // MARK: - Acquisition Manager
  //----------------------------------------------------------------------------

    /// Start streaming EEG Data from MyBrainActivity Characteristic.
    /// Start streaming headSet Data from HeadsetStatus Characteristic.
    /// - Remark: Data will be provided through the MelomineEngineDelegate.
    public func startStream(shouldUseQualityChecker: Bool) -> Bool {
      guard isConnected,
            let deviceInformation = deviceInformation,
            let eegAcquiser = eegAcquiser
      else {
        return false
      }

      eegAcquiser.startStream(
        isUsingQualityChecker: shouldUseQualityChecker,
        sampleRate: deviceInformation.acquisitionInformation.sampleRate
      )
      bluetoothManager.isListeningToEEG = true
      bluetoothManager.isListeningToHeadsetStatus = true
      return true
    }

    /// Stop streaming EEG Data to MelomineEngineDelegate.
    /// Stop streaming headSet Data from MelomindEngineDelegate.
    /// - Remark: a JSON will be created with all the MBTEEGPacket.
    public func stopStream() {
      bluetoothManager.isListeningToHeadsetStatus = false
      bluetoothManager.isListeningToEEG = false
      eegAcquiser?.stopStream()
    }

  /// Start saving EEGPacket on DB  /// - Parameters:
  ///   - newRecord: Create a new recordId on the JSON File
  ///   - recordingType: Change the session's type
  @discardableResult
  public func startRecording(
    asNewRecord newRecord: Bool,
    recordingType: MBTRecordingType = MBTRecordingType()
  ) -> UUID? {
    guard isConnected, let eegAcquiser = eegAcquiser else { return nil }
    
    if newRecord {
      recordInfo = MBTRecordInfo()
      recordInfo.recordingType = recordingType
    } else {
      recordInfo.recordingType = recordingType
    }

    eegAcquiser.isRecording = true

    return recordInfo.recordId
  }

  /// Stop saving EEGPacket on DB
  public func stopRecording() {
    guard isConnected else { return }
    eegAcquiser?.isRecording = false
  }

//  //----------------------------------------------------------------------------
//  // MARK: - OAD
//  //----------------------------------------------------------------------------
//
//  /// Start the OAD process
//  public func startOADTransfer() {
//    bluetoothManager.startOAD(withDevice: DeviceManager.getCurrentDevice())
//  }
//
  #warning("TODO: Use ")
//  /// To know if a new headset firmware version is available.
//  /// Asynchrone fonction call a block completion with an boolean argument.
//  /// - Parameter completion: block completion call after getting melomind info.
//  /// with boolean argument.
//  public func isMelomindNeedToBeUpdate() -> Bool? {
//    return DeviceManager.getCurrentDevice()?.shouldUpdateFirmware
//  }
//
  //----------------------------------------------------------------------------
  // MARK: - Signal Processing Manager
  //----------------------------------------------------------------------------

  // Calibration

  /// Compute calibration with the last 'n' complete packets.
  /// - Parameters:
  ///   - n: Number of complete packets to take to compute the calibration.
  /// - Returns: A dictionnary received by the Signal Processing library.
  public func computeCalibration(
    onNumberOfPackets numberOfPackets: Int
  ) -> CalibrationOutput? {
    guard let eegPackets = eegAcquiser?.getLastPackets(count: numberOfPackets),
          let deviceAcquisitionInformation =
                  deviceInformation?.acquisitionInformation else {
      return nil
    }

    return signalProcessingManager.computeCalibration(
      of: eegPackets,
      sampleRate: deviceAcquisitionInformation.sampleRate,
      channelCount: deviceAcquisitionInformation.channelCount,
      packetLength: deviceAcquisitionInformation.eegPacketSize
    )
  }

  // Exercise, Resting state

  /// computeRelaxIndex
  ///
  /// - Returns: RelaxIndex
  public func computeRelaxIndex() -> Float? {
    let packetCount = Constants.EEGPackets.historySize
    guard let deviceInformation = deviceInformation,
          let eegPackets = eegAcquiser?.getLastPackets(count: packetCount)
    else {
      return nil
    }

    return signalProcessingManager.computeRelaxIndex(
      eegPackets: eegPackets,
      sampleRate: deviceInformation.acquisitionInformation.sampleRate,
      channelCount: deviceInformation.acquisitionInformation.channelCount
    )
  }

  /// ComputeSessionStatistics
  public func computeSessionStatistics(snrValues: [Float],
                                       threshold: Float) -> [String: Float] {
    guard isConnected else { return [:] }
    return signalProcessingManager.analyseSession(snrValues: snrValues,
                                                  threshold: threshold)
  }

}

//==============================================================================
// MARK: - MBTBluetoothAcquisitionDelegate
//==============================================================================

extension MBTClientV2: MBTBluetoothAcquisitionDelegate {

  public func didUpdateBatteryLevel(_ levelBattery: Int) {
    acquisitionDelegate?.didUpdateBatteryLevel(levelBattery)
  }

  public func didUpdateSaturationStatus(_ status: Int)  {
    acquisitionDelegate?.didUpdateSaturationStatus(status)
  }

  public func didUpdateEEGRawData(_ data: Data) {
    acquisitionDelegate?.didUpdateEEGRawData(data)

    guard let eegPacket =
            eegAcquiser?.generateEegPacket(fromEegData: data) else {
      return
    }

    acquisitionDelegate?.didUpdateEEGData(eegPacket)
  }

}

//==============================================================================
// MARK: - MBTBLEBluetoothDelegate
//==============================================================================

extension MBTClientV2: MBTBLEBluetoothDelegate {

  public func didUpdateSampleBufferSize(sampleBufferSize: Int) {
    bleDelegate?.didUpdateSampleBufferSize(sampleBufferSize: sampleBufferSize)
  }


  public func didBluetoothStateChange(isBluetoothOn: Bool) {
    bleDelegate?.didBluetoothStateChange(isBluetoothOn: isBluetoothOn)
  }

  public func didConnect() {
    bleDelegate?.didConnect()
  }

  public func didConnect(deviceInformation: DeviceInformation) {
    update(from: deviceInformation)
    bleDelegate?.didConnect(deviceInformation: deviceInformation)
  }

  public func didConnectionFail(error: Error?) {
    bleDelegate?.didConnectionFail(error: error)
  }

  public func didDisconnect(error: Error?) {
    bleDelegate?.didDisconnect(error: error)
  }

}

//==============================================================================
// MARK: - Analysis
//==============================================================================

extension MBTClientV2 {

  /// Get the mean alpha power of the current session.
  /// Also populates sessionConfidence() data.
  public var sessionMeanAlphaPower: Float {
    return analyzer.sessionMeanAlphaPower
  }

  public var sessionMeanRelativeAlphaPower: Float {
    return analyzer.sessionMeanRelativeAlphaPower
  }

  /// Get the confidence rate of the current session.
  public var sessionConfidence: Float {
    return analyzer.sessionConfidence
  }

  /// Get the alpha powers of the current session.
  public var sessionAlphaPowers: [Float] {
    return analyzer.sessionAlphaPowers
  }

  /// Get the relative alpha powers of the current session.
  public var sessionRelativeAlphaPowers: [Float] {
    return analyzer.sessionRelativeAlphaPowers
  }

  /// Get qualities of the current session.
  /// Qualities are multiplexed by channels ([q1c1,q1c2,q2c1,q2c2,q3c1,...])
  /// CALL AFTER `sessionMeanAlphaPower` or `sessionMeanRelativeAlphaPower`.
  public var sessionQualities: [Float] {
    return analyzer.sessionQualities
  }

}
