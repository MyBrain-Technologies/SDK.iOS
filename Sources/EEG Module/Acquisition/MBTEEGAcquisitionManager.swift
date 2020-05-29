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

  /// Bool to know if developer wants to use QC or not.
  var shouldUseQualityChecker: Bool?

  /// Previous Index Data Blutooth
//  var previousIndex: Int16 = -1

  /// Buffer Data Byte
//  var buffByte = [UInt8]()

//  let packetBuffer = EEGRawPacketBuffer(bufferSizeMax: 250) //default value

  let acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: 250)

  /// if the sdk record in DB EEGPacket
  var isRecording: Bool = false

  var eegPacketLength = 0

  var nbChannels = 0

  var sampRate = 0

  /// Test Variable
  var timeIntervalPerf = Date().timeIntervalSince1970

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /// Set up the EEGAcquisitionManager
  ///
  /// - Parameter device: A *MBTDevice* of the connected Melomind
  func setUpWith(device: MBTDevice) {
    log.verbose("EEG PACKET LENGTH \(device.eegPacketLength)")
    acquisitionBuffer.bufferSizeMax = device.eegPacketLength * 2 * 2

    eegPacketLength = device.eegPacketLength
    nbChannels = device.nbChannels
    sampRate = device.sampRate
    MBTSignalProcessingManager.shared.resetSession()
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
      MBTSignalProcessingManager.shared.initializeQualityChecker()
  }

  /// Method called by MelomindEngine when the current EEG streaming
  /// session has finished.
  func streamHasStopped() {
    // Dealloc mainQC.
    guard let shouldUseQualityChecker = shouldUseQualityChecker,
      shouldUseQualityChecker else { return }

    self.shouldUseQualityChecker = false
    MBTSignalProcessingManager.shared.deinitQualityChecker()
  }

  /// Save the EEGPackets recorded
  ///
  /// - Parameters:
  ///   - idUser: A *Int* id of the connected user
  ///   - comments: An array of *String* contains Optional Comments
  ///   - completion: A block which execute after create the file or fail to create
  func saveRecordingOnFile(_ idUser: Int,
                           algo: String?,
                           comments: [String] = [],
                           completion: @escaping (URL?) -> Void) {
    guard let device = DeviceManager.getCurrentDevice() else {
      completion(nil)
      return
    }

    let deviceTSR = ThreadSafeReference(to: device)
    let packetToRemove = EEGPacketManager.getArrayEEGPackets()
    var packetsToSaveTSR = [ThreadSafeReference<MBTEEGPacket>]()
    let currentRecordInfo = MBTRecordInfo.init(
      MBTClient.shared.recordInfo.recordId,
      recordingType: MBTClient.shared.recordInfo.recordingType
    )
    log.info("Save recording on file", context: currentRecordInfo)

    for eegPacket in packetToRemove {
      packetsToSaveTSR.append(ThreadSafeReference(to: eegPacket))
    }

    DispatchQueue(label: "MelomindSaveProcess").async {
      let config = MBTRealmEntityManager.RealmManager.shared.config

      if let realm = try? Realm(configuration: config) {
        var resPacketsToSave = [MBTEEGPacket]()

        for eegPacket in packetsToSaveTSR {
          if let resEEGPacket = realm.resolve(eegPacket) {
            resPacketsToSave.append(resEEGPacket)
          }
        }

        if let resDevice = realm.resolve(deviceTSR),
          resPacketsToSave.count == packetsToSaveTSR.count {
          let jsonObject = self.getJSONRecord(resDevice,
                                              idUser: idUser,
                                              algo: algo,
                                              eegPackets: resPacketsToSave,
                                              recordInfo: currentRecordInfo,
                                              comments: comments)
          // Save JSON with EEG data received.
          let deviceId = resDevice.deviceInfos!.deviceId!
          let fileURL = RecordFileSaver.shared.saveRecord(jsonObject,
                                                          deviceId: deviceId,
                                                          userId: idUser)
          DispatchQueue.main.async {
            EEGPacketManager.removePackets(packetToRemove)
            completion(fileURL)
          }
        } else {
          DispatchQueue.main.async {
            completion(nil)
          }
        }
      } else {
        DispatchQueue.main.async {
          completion(nil)
        }
      }
    }
  }

  /// Method to manage a complete *MBTEEGPacket* From streamEEGPacket. Use *Quality Checker*
  /// on it if user asks for it, or just send it via the delegate.
  /// - Parameter eegPacket: A complete *MBTEEGPacket*.
  func manageCompleteStreamEEGPacket(_ datasArray: [[Float]]) {

    let packetComplete = MBTEEGPacket.createNewEEGPacket(arrayData: datasArray,
                                                         nbChannels: nbChannels)

    if let shouldUseQualityChecker = shouldUseQualityChecker,
      shouldUseQualityChecker {
      // Get caluclated qualities of the EEGPacket.
      // Add *qualities* in streamEEGPacket
      let qualities = MBTSignalProcessingManager.shared.computeQualityValue(
          packetComplete.channelsData,
          sampRate: self.sampRate,
          eegPacketLength: eegPacketLength
      )
      packetComplete.addQualities(qualities)

      // Get the EEG values modified by the `QC` according to the `Quality` values.
      let correctedValues =
        MBTSignalProcessingManager.shared.getModifiedEEGValues()
      packetComplete.addModifiedChannelsData(correctedValues,
                                             nbChannels: self.nbChannels,
                                             sampRate: self.sampRate)
    }
    let timeInterval = Date().timeIntervalSince1970

    log.verbose("receive EEG packet. Timer perf",
                context: timeInterval - self.timeIntervalPerf)

    self.delegate?.onReceivingPackage?(packetComplete)
    self.timeIntervalPerf = timeInterval

    if self.isRecording {
      EEGPacketManager.saveEEGPacket(packetComplete)
    }
  }

  /// Create the EEG JSON
  ///
  /// - Parameters:
  ///   - device: A *MBTDevice* of the connected Melomind
  ///   - idUser: A *Int* id of the connected user
  ///   - eegPackets: An array of *MBTEEGPacket* of the relaxIndexes
  ///   - recordInfo: A *MBTRecordInfo* of the session metadata
  ///   - comments: An array of *String* contains Optional Comments
  /// - Returns: return an instance of *JSON*
  func getJSONRecord(_ device: MBTDevice,
                     idUser: Int,
                     algo: String?,
                     eegPackets: [MBTEEGPacket],
                     recordInfo: MBTRecordInfo,
                     comments: [String] = []) -> JSON {
    var jsonContext = JSON()
    jsonContext["ownerId"].intValue = idUser

    if let algo = algo {
      jsonContext["riAlgo"].stringValue = algo
    }

    log.info("json context", context: jsonContext)

    var jsonRecord = JSON()
    jsonRecord["recordID"].stringValue = recordInfo.recordId.uuidString
    jsonRecord["recordingType"] = recordInfo.recordingType.getJsonRecordInfo()
    jsonRecord["recordingTime"].intValue = eegPackets.first?.timestamp ?? 0
    jsonRecord["nbPackets"].intValue = eegPackets.count
    jsonRecord["firstPacketId"].intValue = eegPackets.first != nil ?
      eegPackets.firstIndex(of: eegPackets.first! )! : 0
    jsonRecord["qualities"] = EEGPacketManager.getJSONQualities(eegPackets)
    jsonRecord["channelData"] = EEGPacketManager.getJSONEEGDatas(eegPackets)
    jsonRecord["statusData"].arrayObject = [Any]()
    jsonRecord["recordingParameters"].arrayObject = [Any]()

    // Create the session JSON.
    var jsonObject = JSON()
    jsonObject["uuidJsonFile"].stringValue = UUID().uuidString
    jsonObject["header"] = device.getJSON(comments)

    jsonObject["context"] = jsonContext
    jsonObject["recording"] = jsonRecord

    return jsonObject
  }

  //----------------------------------------------------------------------------
  // MARK: - Process Received data Methods.
  //----------------------------------------------------------------------------

//  private func getPreviousIndex(fromCurrentIndex index: Int16) -> Int16 {
//    if index == 0 || previousIndex >= Int16.max {
//      return 0
//    }
//
//    if previousIndex == -1 {
//      return index - 1
//    }
//
//    return previousIndex
//  }

//  private func completeByteBuffer

  /// Process the brain activty measurement received and return the processed data.
  /// - Parameters:
  ///     - data: *Data* received from MBT Headset EEGs.
  /// - Returns: *Dictionnary* with the packet Index (key: "packetIndex") and array of
  ///     P3 and P4 samples arrays ( key: "packet" )
  func processBrainActivityData(_ data: Data) {

    acquisitionBuffer.add(data: data)

    guard let packet = acquisitionBuffer.getUsablePackets() else {
      return
    }

    let relaxIndexes = EEGDeserializer.deserializeToRelaxIndex(bytes: packet)
    self.manageCompleteStreamEEGPacket(relaxIndexes)


//    let packetValue = EEGRawPacket(data: data)
//    let currentIndex = packetValue.packetIndex
//
//    previousIndex = getPreviousIndex(fromCurrentIndex: currentIndex)
//
//    let diff = Int32(currentIndex - previousIndex)

//    if diff != 1 {
//      log.info("Process brain activity data. Diff is", context: diff)
//    }

    // START TO COMPLETE BUFF BYTE

    // Complete buffer with missing packets
//    if diff != 1 && diff > 0 { // diff > 1
//      log.info("Process brain activity data. Lost packets", context: diff)
//      log.verbose("Add \(Int(diff) * (packetValue.valueLength)) 0xFF byte")
//      for _ in 0 ..< diff {
//        for _ in 0 ..< packetValue.valueLength {
//          buffByte.append(0xFF)
//        }
//      }
//    }

//    if diff > 1 {
//      log.info("Lost packets during EEG Acquisition. Diff is :", context: diff)
//      packetBuffer.add(value: 0xFF, count: Int(diff) * packetValue.valueLength)
//    }
//
//    packetBuffer.add(bytes: packetValue.value)
//    log.verbose("BUFF BYTES ARRAY (count: \(buffByte.count)) - \(buffByte.map { "\($0)" } )")

    // Append content of the current packet to the buffer
//    buffByte += bytesArray.suffix(bytesArray.count - 2) // take all except two first

//    log.verbose("BUFF BYTES ARRAY (count: \(buffByte.count)) - \(buffByte.map { "\($0)" } )")

    // update index to the current one
//    previousIndex = currentIndex

    // CHECK FOR LIMIT OF BUFFER

//    let limitBuffCount = eegPacketLength * 2 * 2

//    if packetBuffer.isFull {
//      let packet = packetBuffer.flushBuffer()
//      let relaxIndexes = EEGDeserializer.deserializeToRelaxIndex(bytes: packet)
//      self.manageCompleteStreamEEGPacket(relaxIndexes)
//    }

//    if buffByte.count >= limitBuffCount {
//
//      var byteArray = [UInt8]()
//      for _ in 0 ... (limitBuffCount - 1)  { // flush the buff byte when the limit is reached.
//        byteArray.append(buffByte.removeFirst())
//      }
//
////      log.verbose("OUTPUT BYTES ARRAY (count: \(buffByte.count)) - \(bytesArray.map { "\($0)" } )")
//
//      // convert the flushed buffer to relax indexes
//      let relaxIndexes =
//        EEGDeserializer.deserializeToRelaxIndex(bytes: byteArray)
//      self.manageCompleteStreamEEGPacket(relaxIndexes)
//
//    }
  }
}
