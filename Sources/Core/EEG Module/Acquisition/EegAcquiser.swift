import Foundation

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
      eegPacketManager.removeAllEegPackets()
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
    return eegPacketManager.getLastPackets(count)
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
    let packets = eegPacketManager.eegPackets
    let qualities = eegPacketManager.qualities
    let channelData = eegPacketManager.eegData
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
          self?.eegPacketManager.removeAllEegPackets()
          completion(.success(url))

        case .failure(let error):
          if (error as? EEGAcquisitionSaverV2.EEGAcquisitionSaverError)
              == .unableToWriteFile {
            self?.eegPacketManager.removeAllEegPackets()
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
