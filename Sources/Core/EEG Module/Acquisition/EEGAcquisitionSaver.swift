import Foundation
import RealmSwift

/*******************************************************************************
 * EEGAcquisitionSaver
 *
 * Save packets from acquisition into a file
 * Legacy code - not tested
 *
 ******************************************************************************/
// GOOD
class EEGAcquisitionSaver {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  var realmConfig: Realm.Configuration {
    return RealmManager.shared.config
  }

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
                     eegPacketManager: EEGPacketManager,
                     idUser: Int,
                     algo: String?,
                     comments: [String] = [],
                     device: MBTDevice,
                     recordingInformation: MBTRecordInfo,
                     recordFileSaver: RecordFileSaver,
                     completion: @escaping (URL?) -> Void) {
//    guard let device = DeviceManager.getCurrentDevice() else {
//      completion(nil)
//      return
//    }

    let deviceReference = ThreadSafeReference(to: device)
    let packetsReferences = packets.map() { ThreadSafeReference(to: $0) }

    DispatchQueue(label: saveThreadName).async {

      guard let realm = try? Realm(configuration: self.realmConfig) else {
        log.error("Cannot get realm instance")
        DispatchQueue.main.async { completion(nil) }
        return
      }

      let savedPackets = packetsReferences.compactMap() { realm.resolve($0) }
      let resolvedDevice = realm.resolve(deviceReference)

      guard let savedDevice = resolvedDevice,
        savedPackets.count == packetsReferences.count else {
          log.error("PB with realm or bad number on packet to save ?")
          DispatchQueue.main.async { completion(nil) }
          return
      }

//      let currentRecordInfo = MBTClient.shared.recordInfo

      let savingRecord =
        self.getEEGSavingRecord(savedDevice,
                                idUser: idUser,
                                algo: algo,
                                eegPackets: savedPackets,
                                eegPacketManager: eegPacketManager,
                                recordInfo: recordingInformation,
                                comments: comments)

      guard let jsonObject = savingRecord.toJSON else {
          log.error("Cannot encore saving record object to JSON")
          DispatchQueue.main.async { completion(nil) }
          return
      }

      // Save JSON with EEG data received.
      guard let deviceId = savedDevice.deviceInfos?.deviceId else {
        log.error("Cannot get deviceId")
        DispatchQueue.main.async { completion(nil) }
        return
      }

      // RecordFileSaver.shared
      let fileURL = recordFileSaver.saveRecord(jsonObject,
                                               deviceId: deviceId,
                                               userId: idUser)
      DispatchQueue.main.async {
        eegPacketManager.removePackets(packets)
        completion(fileURL)
      }
    }
  }

  private func getEEGSavingRecord(_ device: MBTDevice,
                                  idUser: Int,
                                  algo: String?,
                                  eegPackets: [MBTEEGPacket],
                                  eegPacketManager: EEGPacketManager,
                                  recordInfo: MBTRecordInfo,
                                  comments: [String] = []) -> EEGSavingRecord {
    let context = EEGSavingRecordContext(ownerId: idUser, riAlgo: algo ?? "")

    let record = EEGRecord(
      recordID: recordInfo.recordId.uuidString,
      recordingType: recordInfo.recordingType.eegRecordType,
      recordingTime: eegPackets.first?.timestamp ?? 0,
      nbPackets: eegPackets.count,
      firstPacketId: 0,
      qualities: eegPacketManager.getQualities(eegPackets),
      channelData: eegPacketManager.getEEGDatas(eegPackets)
    )

    let header = device.getAsRecordHeader(comments: comments)

    let savingRecord = EEGSavingRecord(context: context,
                                       header: header,
                                       recording: record)

    return savingRecord
  }
}

//==============================================================================
// MARK: - EEGAcquisitionSaverV2
//==============================================================================

class EEGAcquisitionSaverV2 {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  var realmConfig: Realm.Configuration {
    return RealmManager.shared.config
  }

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
                     eegPacketManager: EEGPacketManagerV2,
                     idUser: Int,
                     algo: String?,
                     comments: [String] = [],
                     device: MBTDevice,
                     recordingInformation: MBTRecordInfo,
                     recordFileSaver: RecordFileSaver,
                     completion: @escaping (URL?) -> Void) {
//    guard let device = DeviceManager.getCurrentDevice() else {
//      completion(nil)
//      return
//    }

    let deviceReference = ThreadSafeReference(to: device)
    let packetsReferences = packets.map() { ThreadSafeReference(to: $0) }

    DispatchQueue(label: saveThreadName).async {

      guard let realm = try? Realm(configuration: self.realmConfig) else {
        log.error("Cannot get realm instance")
        DispatchQueue.main.async { completion(nil) }
        return
      }

      let savedPackets = packetsReferences.compactMap() { realm.resolve($0) }
      let resolvedDevice = realm.resolve(deviceReference)

      guard let savedDevice = resolvedDevice,
        savedPackets.count == packetsReferences.count else {
          log.error("PB with realm or bad number on packet to save ?")
          DispatchQueue.main.async { completion(nil) }
          return
      }

//      let currentRecordInfo = MBTClient.shared.recordInfo

      let savingRecord =
        self.getEEGSavingRecord(savedDevice,
                                idUser: idUser,
                                algo: algo,
                                eegPackets: savedPackets,
                                eegPacketManager: eegPacketManager,
                                recordInfo: recordingInformation,
                                comments: comments)

      guard let jsonObject = savingRecord.toJSON else {
          log.error("Cannot encore saving record object to JSON")
          DispatchQueue.main.async { completion(nil) }
          return
      }

      // Save JSON with EEG data received.
      guard let deviceId = savedDevice.deviceInfos?.deviceId else {
        log.error("Cannot get deviceId")
        DispatchQueue.main.async { completion(nil) }
        return
      }

      // RecordFileSaver.shared
      let fileURL = recordFileSaver.saveRecord(jsonObject,
                                               deviceId: deviceId,
                                               userId: idUser)
      DispatchQueue.main.async {
        eegPacketManager.removePackets(packets)
        completion(fileURL)
      }
    }
  }

  private func getEEGSavingRecord(_ device: MBTDevice,
                                  idUser: Int,
                                  algo: String?,
                                  eegPackets: [MBTEEGPacket],
                                  eegPacketManager: EEGPacketManagerV2,
                                  recordInfo: MBTRecordInfo,
                                  comments: [String] = []) -> EEGSavingRecord {
    let context = EEGSavingRecordContext(ownerId: idUser, riAlgo: algo ?? "")

    let record = EEGRecord(
      recordID: recordInfo.recordId.uuidString,
      recordingType: recordInfo.recordingType.eegRecordType,
      recordingTime: eegPackets.first?.timestamp ?? 0,
      nbPackets: eegPackets.count,
      firstPacketId: 0,
      qualities: eegPacketManager.getQualities(eegPackets),
      channelData: eegPacketManager.getEEGDatas(eegPackets)
    )

    let header = device.getAsRecordHeader(comments: comments)

    let savingRecord = EEGSavingRecord(context: context,
                                       header: header,
                                       recording: record)

    return savingRecord
  }
}
