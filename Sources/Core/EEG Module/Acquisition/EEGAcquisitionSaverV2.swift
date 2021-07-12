import Foundation

class EEGAcquisitionSaverV2 {

  //----------------------------------------------------------------------------
  // MARK: - Error
  //----------------------------------------------------------------------------

  enum EEGAcquisitionSaverError: Error {
    case realmUnable
    case badPacketNumber
    case invalidJson
    case unableToWriteFile
  }

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  let saveThreadName = "MelomindSaveProcess"

  //----------------------------------------------------------------------------
  // MARK: - Saving
  //----------------------------------------------------------------------------

  /// Save the EEGPackets recorded
  ///
  /// - Parameters:
  ///   - idUser: A *Int* id of the connected user
  ///   - comments: An array of *String* contains Optional Comments
  ///   - completion: A block which execute after create the file or fail to create
  func saveRecording(packets: [MBTEEGPacket],
                     qualities: [[Float]],
                     channelData: [[Float?]],
                     idUser: Int,
                     algorithm: MBTRelaxIndexAlgorithm?,
                     comments: [String] = [],
                     deviceInformation: DeviceInformation,
                     recordingInformation: MBTRecordInfo,
                     recordFileSaver: RecordFileSaver,
                     completion: @escaping (Result<URL, Error>) -> Void) {
//    let packetsReferences = packets.map() { ThreadSafeReference(to: $0) }

    DispatchQueue(label: saveThreadName).async {

//      guard let realm = try? Realm(configuration: self.realmConfig) else {
//        log.error("Cannot get realm instance")
//        DispatchQueue.main.async {
//          completion(.failure(EEGAcquisitionSaverError.realmUnable))
//        }
//        return
//      }

//      let savedPackets = packetsReferences.compactMap() { realm.resolve($0) }

//      guard savedPackets.count == packetsReferences.count else {
//          log.error("PB with realm or bad number on packet to save ?")
//          DispatchQueue.main.async {
//            completion(.failure(EEGAcquisitionSaverError.badPacketNumber))
//          }
//          return
//      }

//      let currentRecordInfo = MBTClient.shared.recordInfo

      #warning("TODO: Check packets is same as savedPackets")
      let savingRecord =
        self.getEEGSavingRecord(
          deviceInformation: deviceInformation,
          idUser: idUser,
          algorithm: algorithm,
          eegPackets: packets,
          qualities: qualities,
          channelData: channelData,
          recordInfo: recordingInformation,
          comments: comments
        )

      guard let jsonObject = savingRecord.toJSONString else {
          log.error("Cannot encore saving record object to JSON")
          DispatchQueue.main.async {
            completion(.failure(EEGAcquisitionSaverError.invalidJson))
          }
          return
      }

      // Save JSON with EEG data received.
      let deviceId = deviceInformation.deviceId

      // RecordFileSaver.shared
      let fileURL = recordFileSaver.saveRecord(jsonString: jsonObject,
                                               deviceId: deviceId,
                                               userId: idUser)
      DispatchQueue.main.async {
        guard let fileURL = fileURL else {
          completion(.failure(EEGAcquisitionSaverError.unableToWriteFile))
          return
        }
        completion(.success(fileURL))
      }
    }
  }

  private func getEEGSavingRecord(deviceInformation: DeviceInformation,
                                  idUser: Int,
                                  algorithm: MBTRelaxIndexAlgorithm?,
                                  eegPackets: [MBTEEGPacket],
                                  qualities: [[Float]],
                                  channelData: [[Float?]],
                                  recordInfo: MBTRecordInfo,
                                  comments: [String] = []) -> EEGSavingRecord {
    let context = EEGSavingRecordContext(ownerId: idUser,
                                         riAlgo: algorithm?.rawValue ?? "")

    let record = EEGRecord(
      recordID: recordInfo.recordId.uuidString,
      recordingType: recordInfo.recordingType.eegRecordType,
      recordingTime: eegPackets.first?.timestamp ?? 0,
      nbPackets: eegPackets.count,
      firstPacketId: 0,
      qualities: qualities,
      channelData: channelData
    )

    let header = generateRecordHeader(deviceInformation: deviceInformation,
                                      comments: comments)

    let savingRecord = EEGSavingRecord(context: context,
                                       header: header,
                                       recording: record)

    return savingRecord
  }

  private func generateRecordHeader(
    deviceInformation: DeviceInformation,
    comments: [String]
  ) -> EEGSavingRecordHeader {
    let deviceInfo = MelomindDeviceInformations(
      productName: deviceInformation.productName,
      hardwareVersion: deviceInformation.hardwareVersion.rawValue,
      firmwareVersion: deviceInformation.firmwareVersion,
      uniqueDeviceIdentifier: deviceInformation.deviceId
    )

    let commentWithDate = ["\(Date().timeIntervalSince1970)"] + comments
    let electrodes = deviceInformation.acquisitionInformation.electrodes

    return EEGSavingRecordHeader(
      deviceInfo: deviceInfo,
      comments: commentWithDate,
      sampRate: deviceInformation.acquisitionInformation.sampleRate,
      eegPacketLength: deviceInformation.acquisitionInformation.eegPacketSize,
      nbChannels: deviceInformation.acquisitionInformation.channelCount,
      acquisitionLocation: electrodes.acquisitions.map { $0.stringValue },
      referencesLocation: electrodes.references.map { $0.stringValue },
      groundsLocation: electrodes.grounds.map { $0.stringValue }
    )
  }

}
