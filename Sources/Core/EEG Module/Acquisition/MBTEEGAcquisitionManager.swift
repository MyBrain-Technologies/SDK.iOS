import Foundation
import CoreBluetooth
import RealmSwift
import SwiftyJSON

/// Manage Acquisition data from the MBT device connected.
/// Such as EEG, device info, battery level ...
internal class MBTEEGAcquisitionManager: NSObject  {

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /// Singleton declaration
  static let shared = MBTEEGAcquisitionManager()

  /// The MBTBluetooth Event Delegate.
  weak var delegate: MBTEEGAcquisitionDelegate?

  /******************** Dependency injection ********************/

  let signalProcessor: MBTSignalProcessingManager = .shared

  /******************** Convert and save eeg ********************/

  var acquisitionProcessor: EEGAcquisitionProcessor?

  let acquisisitonSaver = EEGAcquisitionSaver()

  /********************  Parameters ********************/

  /// Bool to know if developer wants to use QC or not.
  var shouldUseQualityChecker: Bool = false

  /// if the sdk record in DB EEGPacket
  var isRecording: Bool = false

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /// Set up the EEGAcquisitionManager
  ///
  /// - Parameter device: A *MBTDevice* of the connected Melomind
  func setUpWith(device: MBTDevice) {
    acquisitionProcessor = EEGAcquisitionProcessor(device: device)
    signalProcessor.resetSession()
  }

  //----------------------------------------------------------------------------
  // MARK: - Manage streaming datas methods.
  //----------------------------------------------------------------------------

  /// Method called by MelomindEngine when a new EEG streaming
  /// session has began. Method will make everything ready, acquisition side
  /// for the new session.
  func streamHasStarted(_ useQualityChecker: Bool) {
    // Start mainQualityChecker.
    guard useQualityChecker else { return }

    shouldUseQualityChecker =
      signalProcessor.initializeQualityChecker()
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
  func saveRecording(_ idUser: Int,
                     algo: String?,
                     comments: [String] = [],
                     completion: @escaping (URL?) -> Void) {
    let packets = EEGPacketManager.shared.getArrayEEGPackets()
    let eegPacketManager = EEGPacketManager.shared
    guard let device = DeviceManager.getCurrentDevice() else {
      log.error("Current device not found")
      completion(nil)
      return
    }
    let recordingInformation = MBTClient.shared.recordInfo
    let recordFileSaver = RecordFileSaver.shared

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

  /// Process the brain activty measurement received and return the processed data.
  /// - Parameters:
  ///     - data: *Data* received from MBT Headset EEGs.
  /// - Returns: *Dictionnary* with the packet Index (key: "packetIndex") and array of
  ///     P3 and P4 samples arrays ( key: "packet" )
  func processBrainActivity(data: Data) {
    let packet = acquisitionProcessor?.getEEGPacket(
      fromData: data,
      checkQuality: shouldUseQualityChecker
    )

    guard let eegPacket = packet else { return }

    self.delegate?.onReceivingPackage?(eegPacket)

    if isRecording {
      EEGPacketManager.shared.saveEEGPacket(eegPacket)
    }
  }

}
