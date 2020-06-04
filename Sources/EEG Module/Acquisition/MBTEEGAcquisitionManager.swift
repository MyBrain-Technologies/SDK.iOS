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
    let packets = EEGPacketManager.getArrayEEGPackets()
    acquisisitonSaver.saveRecording(packets: packets,
                                    idUser: idUser,
                                    algo: algo,
                                    comments: comments,
                                    completion: { completion($0) })

//    guard let device = DeviceManager.getCurrentDevice() else {
//      completion(nil)
//      return
//    }
//
//    let deviceTSR = ThreadSafeReference(to: device)
//    let packetToRemove = EEGPacketManager.getArrayEEGPackets()
//    var packetsToSaveTSR = [ThreadSafeReference<MBTEEGPacket>]()
//
//    for eegPacket in packetToRemove {
//      packetsToSaveTSR.append(ThreadSafeReference(to: eegPacket))
//    }
//
//    DispatchQueue(label: "MelomindSaveProcess").async {
//      let config = MBTRealmEntityManager.RealmManager.shared.config
//
//      guard let realm = try? Realm(configuration: config) else {
//        log.error("Cannot get realm instance")
//        DispatchQueue.main.async { completion(nil) }
//        return
//      }
//
//      var resPacketsToSave = [MBTEEGPacket]()
//
//      for eegPacket in packetsToSaveTSR {
//        if let resEEGPacket = realm.resolve(eegPacket) {
//          resPacketsToSave.append(resEEGPacket)
//        }
//      }
//
//      guard
//        let resDevice = realm.resolve(deviceTSR),
//        resPacketsToSave.count == packetsToSaveTSR.count else {
//          log.error("PB with realm or bad number on packet to save ?")
//          DispatchQueue.main.async { completion(nil) }
//          return
//      }
//
//      let currentRecordInfo = MBTRecordInfo.init(
//        MBTClient.shared.recordInfo.recordId,
//        recordingType: MBTClient.shared.recordInfo.recordingType
//      )
//      log.info("Save recording on file", context: currentRecordInfo)
//
//      let savingRecord = self.getEEGSavingRecord(resDevice,
//                                                 idUser: idUser,
//                                                 algo: algo,
//                                                 eegPackets: resPacketsToSave,
//                                                 recordInfo: currentRecordInfo,
//                                                 comments: comments)
//
//      guard let jsonObject = savingRecord.toJSON else {
//          log.error("Cannot encore saving record object to JSON")
//          DispatchQueue.main.async { completion(nil) }
//          return
//      }
//
//      // Save JSON with EEG data received.
//      let deviceId = resDevice.deviceInfos!.deviceId!
//      let fileURL = RecordFileSaver.shared.saveRecord(jsonObject,
//                                                      deviceId: deviceId,
//                                                      userId: idUser)
//      DispatchQueue.main.async {
//        EEGPacketManager.removePackets(packetToRemove)
//        completion(fileURL)
//      }
//    }
//  }
//
//  private func getEEGSavingRecord(_ device: MBTDevice,
//                                  idUser: Int,
//                                  algo: String?,
//                                  eegPackets: [MBTEEGPacket],
//                                  recordInfo: MBTRecordInfo,
//                                  comments: [String] = []) -> EEGSavingRecord {
//    let context = EEGSavingRecordContext(ownerId: idUser, riAlgo: algo ?? "")
//
//    let record = EEGRecord(
//      recordID: recordInfo.recordId.uuidString,
//      recordingType: recordInfo.recordingType.eegRecordType,
//      recordingTime: eegPackets.first?.timestamp ?? 0,
//      nbPackets: eegPackets.count,
//      firstPacketId: 0,
//      qualities: EEGPacketManager.getQualities(eegPackets),
//      channelData: EEGPacketManager.getEEGDatas(eegPackets)
//    )
//
//    let header = device.getAsRecordHeader(comments: comments)
//
//    let savingRecord = EEGSavingRecord(context: context,
//                                       header: header,
//                                       recording: record)
//
//    return savingRecord
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
      EEGPacketManager.saveEEGPacket(eegPacket)
    }
  }

}
