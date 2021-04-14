//
//  MBTSignalProcessingManager.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 15/09/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import RealmSwift

/*******************************************************************************
 * MBTSignalProcessingManager
 *
 * Holds the current implementation of the signal processing protocols.
 *
 ******************************************************************************/
// GOOD
internal class MBTSignalProcessingManager: MBTQualityComputer {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Singleton ********************/

  /// Singleton declaration.
  static let shared = MBTSignalProcessingManager()

  /// Dictionnary to store calibration results.
  internal var calibrationComputed: CalibrationOutput?

  ///
  internal var sampRate: Int = 0

  ///
  internal var eegPacketLength: Int = 0

  internal var relaxIndexAlgorithm = MBTRelaxIndexAlgorithm.algorithm(
    fromSDKVersion: MBTQualityCheckerBridge.getVersion()!
  )

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  private init() {}

  /// Initalize MBT_MainQC to enable MBT_QualityChecker methods.
  func initializeQualityChecker(withSampleRate sampleRate: Float,
                                accuracy: Float = 0.85) -> Bool {
    MBTQualityCheckerBridge.initializeMainQualityChecker(sampleRate,
                                                         accuracy: 0.85)
    #warning("Remove result bool??")
    return true
  }

  /// Delete MBT_MainQC instance once acquisition phase is over.
  func deinitQualityChecker() {
    MBTQualityCheckerBridge.deInitializeMainQualityChecker()
  }

  //----------------------------------------------------------------------------
  // MARK: - Quality
  //----------------------------------------------------------------------------

  /// Compute datas in the *Quality Checker* and returns an array of *Quality*
  /// values for a data matrix of an acquisition packet.
  /// - parameter data: The data matrix of the packet. Each row is a channel
  /// (no GPIOs)
  /// - returns: The array of computed "quality" values. Each value is the
  /// quality for a channel, in the same order as the row order in data.
  func computeQualityValue(_ data: List<ChannelsData>) -> [Float] {
    guard let packetLength = data.first?.values.count else {
      return []
    }

    return EEGQualityProcessor.computeQualityValue(channelsData: data,
                                                   sampRate: sampRate,
                                                   packetLength: packetLength,
                                                   nbChannel: data.count)
  }

  func computeQualityValue(_ data: List<ChannelsData>,
                           sampRate: Int,
                           eegPacketLength: Int) -> [Float] {
    #warning("Why is it passed as parameter and the property being init here?")
    self.sampRate = sampRate
    self.eegPacketLength = eegPacketLength
    return computeQualityValue(data)
  }

  //----------------------------------------------------------------------------
  // MARK: - EEG
  //----------------------------------------------------------------------------

  /// Get an array of the modified EEG datas by the *Quality Checker*, and
  /// return it.
  /// - returns: The matrix of EEG datas (modified) by channel.
  func getModifiedEEGValues() -> [[Float]] {
    let newEEGValues = MBTQualityCheckerBridge.getModifiedEEGData()
    let newEEGValuesSwift = newEEGValues as? [[Float]] ?? [[]]

    return newEEGValuesSwift
  }

}

//==============================================================================
// MARK: - MBTCalibrationComputer
//==============================================================================

extension MBTSignalProcessingManager: MBTCalibrationComputer {

  /// Compute calibration from modified EEG Data and qualities,
  /// from the last complete packet until the *n* last packet.
  /// - Parameters:
  ///     - packetsCount: Number of packets to get, from the last one.
  /// - Returns: A dictionnary with calibration datas from the CPP Signal
  /// Processing.
  func computeCalibration(_ packetsCount: Int) -> CalibrationOutput? {
    let parameters =
      EEGCalibrationProcessor.computeCalibration(packetsCount: packetsCount)

    calibrationComputed = parameters

    return parameters
  }

}

//==============================================================================
// MARK: - MBTRelaxIndexComputer
//==============================================================================

extension MBTSignalProcessingManager: MBTRelaxIndexComputer {

  func computeRelaxIndex(eegPacketManager: EEGPacketManager = .shared,
                         forDevice device: MBTDevice) -> Float? {
    if calibrationComputed == nil { return 0 }

    let packetCount = Constants.EEGPackets.historySize
    let packets = eegPacketManager.getLastNPacketsComplete(packetCount)

    guard packets.count >= packetCount else { return 0 }

    let sampleRate = device.sampRate
    let channelCount = device.nbChannels

    return EEGToRelaxIndexProcessor.computeRelaxIndex(from: packets,
                                                      sampRate: sampleRate,
                                                      nbChannels: channelCount)
  }

}

//==============================================================================
// MARK: - MBTSessionAnalysisComputer
//==============================================================================

extension MBTSignalProcessingManager: MBTSessionAnalysisComputer {

  //Implementing MBT_SessionAnalysisComputer
  func analyseSession(_ inputDataSNR: [Float],
                      threshold: Float) -> [String: Float] {
    //Perform the computation
    let sessionAnalysisValues =
      MBTSNRStatisticsBridge.computeSessionStatistics(inputDataSNR,
                                                      threshold: threshold)
    let sessionAnalysis = sessionAnalysisValues as? [String: Float] ?? [:]
    return sessionAnalysis
  }

}

//==============================================================================
// MARK: - MBTMelomindAnalysis
//==============================================================================

extension MBTSignalProcessingManager {

  func resetSession() {
    MBTMelomindAnalysis.resetSession()
  }

}
