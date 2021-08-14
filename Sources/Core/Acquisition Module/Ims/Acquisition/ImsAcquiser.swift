//
//  ImsAcquiser.swift
//  MyBrainTechnologiesSDK
//
//  Created by Laurent on 13/08/2021.
//  Copyright © 2021 MyBrainTechnologies. All rights reserved.
//

import Foundation

internal class ImsAcquiser {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Processors ********************/

  private var acquisitionProcessor: ImsAcquisitionProcessor

  var fullScaleMode: ImsFullScaleMode = ._2

  /******************** Recording ********************/

  private let recorder = ImsRecorder()

  var isRecording = false {
    didSet {
      if isRecording {
        recorder.removeAllPackets()
      }
    }
  }

  /******************** Convert and save eeg ********************/

  private let acquisisitonSaver = EEGAcquisitionSaverV2()

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(bufferSizeMax: Int,
       packetLength: Int,
       channelCount: Int = 3,
       sampleRate: Int,
       electrodeToChannelIndex: [ElectrodeLocation: Int]) {

    acquisitionProcessor =
      ImsAcquisitionProcessor(
        bufferSizeMax: bufferSizeMax,
        packetLength: packetLength,
        channelCount: channelCount,
        sampleRate: sampleRate,
        electrodeToChannelIndex: electrodeToChannelIndex
      )
  }

  //==============================================================================
  // MARK: - Packets
  //==============================================================================

  func getLastPackets(count: Int) -> [MbtImsPacket]? {
    return recorder.getLastPackets(count)
  }

  //----------------------------------------------------------------------------
  // MARK: - Manage streaming datas methods.
  //----------------------------------------------------------------------------

  /// Method called by MelomindEngine when a new EEG streaming
  /// session has began. Method will make everything ready, acquisition side
  /// for the new session.
  func startStream() {
  }

  /// Method called by MelomindEngine when the current EEG streaming
  /// session has finished.
  func stopStream() {
  }

//  /// Save the EEGPackets recorded
//  ///
//  /// - Parameters:
//  ///   - idUser: A *Int* id of the connected user
//  ///   - comments: An array of *String* contains Optional Comments
//  ///   - completion: A block which execute after create the file or fail to
//  ///   create
//  func saveRecording(userId idUser: Int,
//                     algorithm: MBTRelaxIndexAlgorithm?,
//                     comments: [String] = [],
//                     device: DeviceInformation,
//                     recordingInformation: MBTRecordInfo,
//                     recordFileSaver: RecordFileSaver,
//                     completion: @escaping (Result<URL, Error>) -> Void) {
//    let packets = eegPacketManager.eegPackets
//    let qualities = eegPacketManager.qualities
//    let channelData = eegPacketManager.eegData
//    acquisisitonSaver.saveRecording(packets: packets,
//                                    qualities: qualities,
//                                    channelData: channelData,
//                                    idUser: idUser,
//                                    algorithm: algorithm,
//                                    comments: comments,
//                                    deviceInformation: device,
//                                    recordingInformation: recordingInformation,
//                                    recordFileSaver: recordFileSaver) {
//      [weak self] result in
//      switch result {
//        case .success(let url):
//          self?.eegPacketManager.removeAllEegPackets()
//          completion(.success(url))
//
//        case .failure(let error):
//          if (error as? EEGAcquisitionSaverV2.EEGAcquisitionSaverError)
//              == .unableToWriteFile {
//            self?.eegPacketManager.removeAllEegPackets()
//          }
//          completion(.failure(error))
//      }
//    }
//  }

  //----------------------------------------------------------------------------
  // MARK: - Process Received data Methods.
  //----------------------------------------------------------------------------

  func processIms(from imsData: Data) -> MbtImsPacket? {
    guard let packet =
            acquisitionProcessor.generateImsPacket(from: imsData) else {
      return nil
    }

    if isRecording {
      recorder.savePacket(packet)
    }

    return packet
  }

}
