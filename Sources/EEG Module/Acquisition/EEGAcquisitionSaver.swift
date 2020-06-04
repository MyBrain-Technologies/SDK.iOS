import Foundation
import RealmSwift

/*******************************************************************************
 * EEGAcquisitionSaver
 *
 * Save packets from acquisition into a file
 * Legacy code - not tested
 *
 ******************************************************************************/
class EEGAcquisitionSaver {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private lazy var realm: Realm? = {
    let config = MBTRealmEntityManager.RealmManager.shared.config

    return try? Realm(configuration: config)
  }()

  let saveThreadName = "MelomindSaveProcess"

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /// Save the EEGPackets recorded
  ///
  /// - Parameters:
  ///   - idUser: A *Int* id of the connected user
  ///   - comments: An array of *String* contains Optional Comments
  ///   - completion: A block which execute after create the file or fail to create
  func saveRecording(packets: [MBTEEGPacket],
                     idUser: Int,
                     algo: String?,
                     comments: [String] = [],
                     completion: @escaping (URL?) -> Void) {
    guard let device = DeviceManager.getCurrentDevice() else {
      completion(nil)
      return
    }

    let deviceReference = ThreadSafeReference(to: device)
    let packetsReferences = packets.map() { ThreadSafeReference(to: $0) }

    DispatchQueue(label: saveThreadName).async {

      guard let realm = self.realm else {
        log.error("Cannot get realm instance")
        DispatchQueue.main.async { completion(nil) }
        return
      }

      let savedPackets = packetsReferences.compactMap() { realm.resolve($0) }

      guard let savedDevice = realm.resolve(deviceReference),
        savedPackets.count == packetsReferences.count else {
          log.error("PB with realm or bad number on packet to save ?")
          DispatchQueue.main.async { completion(nil) }
          return
      }

      let currentRecordInfo = MBTClient.shared.recordInfo
      log.info("Save recording on file", context: currentRecordInfo)

      let savingRecord = self.getEEGSavingRecord(savedDevice,
                                                 idUser: idUser,
                                                 algo: algo,
                                                 eegPackets: savedPackets,
                                                 recordInfo: currentRecordInfo,
                                                 comments: comments)

      guard let jsonObject = savingRecord.toJSON else {
          log.error("Cannot encore saving record object to JSON")
          DispatchQueue.main.async { completion(nil) }
          return
      }

      // Save JSON with EEG data received.
      let deviceId = savedDevice.deviceInfos!.deviceId!
      let fileURL = RecordFileSaver.shared.saveRecord(jsonObject,
                                                      deviceId: deviceId,
                                                      userId: idUser)
      DispatchQueue.main.async {
        EEGPacketManager.removePackets(packets)
        completion(fileURL)
      }
    }
  }

  private func getEEGSavingRecord(_ device: MBTDevice,
                                  idUser: Int,
                                  algo: String?,
                                  eegPackets: [MBTEEGPacket],
                                  recordInfo: MBTRecordInfo,
                                  comments: [String] = []) -> EEGSavingRecord {
    let context = EEGSavingRecordContext(ownerId: idUser, riAlgo: algo ?? "")

    let record = EEGRecord(
      recordID: recordInfo.recordId.uuidString,
      recordingType: recordInfo.recordingType.eegRecordType,
      recordingTime: eegPackets.first?.timestamp ?? 0,
      nbPackets: eegPackets.count,
      firstPacketId: 0,
      qualities: EEGPacketManager.getQualities(eegPackets),
      channelData: EEGPacketManager.getEEGDatas(eegPackets)
    )

    let header = device.getAsRecordHeader(comments: comments)

    let savingRecord = EEGSavingRecord(context: context,
                                       header: header,
                                       recording: record)

    return savingRecord
  }
}
