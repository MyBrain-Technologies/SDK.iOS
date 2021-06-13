import Foundation

/// Manage Acquisition data from the MBT device connected.
/// Such as EEG, device info, battery level ...
internal class MBTEEGAcquisitionManager {

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  #warning("TODO: Remove shared")
  /// Singleton declaration
  static let shared = MBTEEGAcquisitionManager()

  /// The MBTBluetooth Event Delegate.
  weak var delegate: MBTEEGAcquisitionDelegate?

  /******************** Dependency injection ********************/

  let signalProcessor: MBTSignalProcessingManager = .shared

  // Use it as property instead of passing as argument in functions?
  let eegPacketManager: EEGPacketManager = .shared

  /******************** Convert and save eeg ********************/

  private var acquisitionProcessor: EEGAcquisitionProcessor?

  private let acquisisitonSaver = EEGAcquisitionSaver()

  /********************  Parameters ********************/

  /// Bool to know if developer wants to use QC or not.
  var shouldUseQualityChecker: Bool = false

  /// if the sdk record in DB EEGPacket
  var isRecording: Bool = false
  // didSet { EEGPacketManager.shared.removeAllEEGPackets() } if not paused

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  /// Set up the EEGAcquisitionManager
  func setUpWith(bufferSizeMax: Int,
                 packetLength: Int,
                 channelCount: Int,
                 sampleRate: Int) {
    acquisitionProcessor =
      EEGAcquisitionProcessor(bufferSizeMax: bufferSizeMax,
                              packetLength: packetLength,
                              channelCount: channelCount,
                              sampleRate: sampleRate,
                              signalProcessor: signalProcessor)

    #warning("How to remove the resetSession session here?")
    signalProcessor.resetSession()
  }

  //----------------------------------------------------------------------------
  // MARK: - Manage streaming datas methods.
  //----------------------------------------------------------------------------

  /// Method called by MelomindEngine when a new EEG streaming
  /// session has began. Method will make everything ready, acquisition side
  /// for the new session.
  func streamHasStarted(isUsingQualityChecker: Bool, sampleRate: Int) {
    // Start mainQualityChecker.
    guard isUsingQualityChecker else { return }

    shouldUseQualityChecker = signalProcessor.initializeQualityChecker(
      withSampleRate: Float(sampleRate)
    )
  }

  /// Method called by MelomindEngine when the current EEG streaming
  /// session has finished.
  func streamHasStopped() {
    // Dealloc mainQC.
    guard shouldUseQualityChecker else { return }

    shouldUseQualityChecker = false
    signalProcessor.deinitQualityChecker()
  }

  /// Save the EEGPackets recorded
  ///
  /// - Parameters:
  ///   - idUser: A *Int* id of the connected user
  ///   - comments: An array of *String* contains Optional Comments
  ///   - completion: A block which execute after create the file or fail to create
  func saveRecording(userId idUser: Int,
                     algo: String?,
                     comments: [String] = [],
                     device: MBTDevice,
                     recordingInformation: MBTRecordInfo,
                     recordFileSaver: RecordFileSaver,
                     completion: @escaping (URL?) -> Void) {
    let packets = eegPacketManager.getArrayEEGPackets()
    acquisisitonSaver.saveRecording(packets: packets,
                                    eegPacketManager: eegPacketManager,
                                    idUser: idUser,
                                    algo: algo,
                                    comments: comments,
                                    device: device,
                                    recordingInformation: recordingInformation,
                                    recordFileSaver: recordFileSaver) { url in
      completion(url)
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Process Received data Methods.
  //----------------------------------------------------------------------------

  /// Process the brain activty measurement received and return the processed
  /// data.
  /// - Parameters:
  ///     - data: *Data* received from MBT Headset EEGs.
  /// - Returns: *Dictionnary* with the packet Index (key: "packetIndex") and
  /// array of P3 and P4 samples arrays ( key: "packet" )
  func processBrainActivity(data: Data) {
    let packet = acquisitionProcessor?.getEEGPacket(
      fromData: data,
      hasQualityChecker: shouldUseQualityChecker
    )

    guard let eegPacket = packet else { return }

    self.delegate?.onReceivingPackage?(eegPacket)

    if isRecording {
      eegPacketManager.saveEEGPacket(eegPacket)
    }
  }

}











internal class EegAcquiser {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Processors ********************/

  private let signalProcessor: SignalProcessingManager

  private var acquisitionProcessor: EEGAcquisitionProcessorV2

  private let eegPacketManager = EEGPacketManagerV2()

  /******************** Convert and save eeg ********************/

  private let acquisisitonSaver = EEGAcquisitionSaverV2()

  /********************  Parameters ********************/

  /// Bool to know if developer wants to use QC or not.
  private(set) var hasQualityChecker: Bool = false

  /// if the sdk record in DB EEGPacket
  var isRecording: Bool = false {
   didSet {
    if isRecording {
      eegPacketManager.removeAllEEGPackets()
    }
   }
  }

  /******************** Delegate ********************/

  /// The MBTBluetooth Event Delegate.
  weak var delegate: MBTEEGAcquisitionDelegate?

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(bufferSizeMax: Int,
       packetLength: Int,
       channelCount: Int,
       sampleRate: Int,
       signalProcessor: SignalProcessingManager) {
    self.signalProcessor = signalProcessor
    acquisitionProcessor =
      EEGAcquisitionProcessorV2(bufferSizeMax: bufferSizeMax,
                                packetLength: packetLength,
                                channelCount: channelCount,
                                sampleRate: sampleRate,
                                signalProcessor: signalProcessor)
    setup()
  }

  private func setup() {
    signalProcessor.resetSession()
  }


  //==============================================================================
  // MARK: - Packets
  //==============================================================================

  func getLastPackets(count: Int) -> [MBTEEGPacket]? {
    return eegPacketManager.getLastNPacketsCompleteIfAvailable(count)
  }

  //----------------------------------------------------------------------------
  // MARK: - Manage streaming datas methods.
  //----------------------------------------------------------------------------

  /// Method called by MelomindEngine when a new EEG streaming
  /// session has began. Method will make everything ready, acquisition side
  /// for the new session.
  func startStream(isUsingQualityChecker: Bool, sampleRate: Int) {
    // Start mainQualityChecker.
    guard isUsingQualityChecker else { return }

    signalProcessor.initializeQualityChecker(withSampleRate: Float(sampleRate))
    hasQualityChecker = true
  }

  /// Method called by MelomindEngine when the current EEG streaming
  /// session has finished.
  func stopStream() {
    // Dealloc mainQC.
    guard hasQualityChecker else { return }

    hasQualityChecker = false
    signalProcessor.deinitQualityChecker()
  }

  /// Save the EEGPackets recorded
  ///
  /// - Parameters:
  ///   - idUser: A *Int* id of the connected user
  ///   - comments: An array of *String* contains Optional Comments
  ///   - completion: A block which execute after create the file or fail to
  ///   create
  func saveRecording(userId idUser: Int,
                     algo: String?,
                     comments: [String] = [],
                     device: DeviceInformation,
                     recordingInformation: MBTRecordInfo,
                     recordFileSaver: RecordFileSaver,
                     completion: @escaping (Result<URL, Error>) -> Void) {
    let packets = eegPacketManager.getArrayEEGPackets()
    let qualities = eegPacketManager.getQualities(packets)
    let channelData = eegPacketManager.getEEGDatas(packets)
    acquisisitonSaver.saveRecording(packets: packets,
                                    qualities: qualities,
                                    channelData: channelData,
                                    idUser: idUser,
                                    algo: algo,
                                    comments: comments,
                                    deviceInformation: device,
                                    recordingInformation: recordingInformation,
                                    recordFileSaver: recordFileSaver) {
      [weak self] result in
      switch result {
        case .success(let url):
          self?.eegPacketManager.removePackets(packets)
          completion(.success(url))

        case .failure(let error):
          if (error as? EEGAcquisitionSaverV2.EEGAcquisitionSaverError)
              == .unableToWriteFile {
            self?.eegPacketManager.removePackets(packets)
          }
          completion(.failure(error))
      }
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Process Received data Methods.
  //----------------------------------------------------------------------------

  /// Process the brain activty measurement received and return the processed
  /// data.
  /// - Parameters:
  ///     - data: *Data* received from MBT Headset EEGs.
  /// - Returns: *Dictionnary* with the packet Index (key: "packetIndex") and
  /// array of P3 and P4 samples arrays ( key: "packet" )
  func generateEegPacket(fromEegData eegData: Data) -> MBTEEGPacket? {
    guard let eegPacket =
      acquisitionProcessor.getEEGPacket(fromData: eegData,
                                        hasQualityChecker: hasQualityChecker)
    else {
      return nil
    }

    if isRecording {
      eegPacketManager.saveEEGPacket(eegPacket)
    }

    return eegPacket
  }

}
