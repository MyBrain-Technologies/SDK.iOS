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
internal class MBTSignalProcessingManager { // MBTQualityComputer {

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
  func computeQualityValue(_ data: Buffer) -> [Float] {
    guard let packetLength = data.first?.count else { return [] }

    return EEGQualityProcessor.computeQualityValue(buffer: data,
                                                   sampleRate: sampRate,
                                                   packetLength: packetLength)
  }

  func computeQualityValue(_ data: Buffer,
                           sampleRate: Int,
                           eegPacketLength: Int) -> [Float] {
    #warning("Why is it passed as parameter and the property being init here?")
    self.sampRate = sampleRate
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

extension MBTSignalProcessingManager { //: MBTCalibrationComputer {

  /// Compute calibration from modified EEG Data and qualities,
  /// from the last complete packet until the *n* last packet.
  /// - Parameters:
  ///     - packetsCount: Number of packets to get, from the last one.
  /// - Returns: A dictionnary with calibration datas from the CPP Signal
  /// Processing.
  func computeCalibration(
    _ packetsCount: Int,
    sampleRate: Int,
    channelCount: Int,
    packetLength: Int,
    eegPacketManager: EEGPacketManager
  ) -> CalibrationOutput? {

    // Get the last N packets.
    let lastPackets = eegPacketManager.getLastNPacketsComplete(packetsCount)
    
    let parameters =
      EEGCalibrationProcessor.computeCalibration(packetsCount: packetsCount,
                                                 lastPackets: lastPackets,
                                                 packetLength: packetLength,
                                                 sampleRate: sampleRate,
                                                 channelCount: channelCount)

    calibrationComputed = parameters

    return parameters
  }

}

//==============================================================================
// MARK: - MBTRelaxIndexComputer
//==============================================================================

extension MBTSignalProcessingManager {//}: MBTRelaxIndexComputer {

  func computeRelaxIndex(eegPacketManager: EEGPacketManager,
                         sampleRate: Int,
                         channelCount: Int) -> Float? {
    if calibrationComputed == nil { return 0 }

    let packetCount = Constants.EEGPackets.historySize
    let packets = eegPacketManager.getLastNPacketsComplete(packetCount)

    guard packets.count >= packetCount else { return 0 }

    return EEGToRelaxIndexProcessor.computeRelaxIndex(from: packets,
                                                      sampRate: sampleRate,
                                                      nbChannels: channelCount)
  }

}

//==============================================================================
// MARK: - MBTSessionAnalysisComputer
//==============================================================================

extension MBTSignalProcessingManager { //: MBTSessionAnalysisComputer {

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









internal class SignalProcessingManager {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Singleton ********************/

  /// Dictionnary to store calibration results.
  internal var calibrationComputed: CalibrationOutput?

  ///
  internal var sampleRate: Int = 0

  ///
  internal var eegPacketLength: Int = 0

  internal var relaxIndexAlgorithm = MBTRelaxIndexAlgorithm.algorithm(
    fromSDKVersion: MBTQualityCheckerBridge.getVersion()!
  )

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init() {

  }

  /// Initalize MBT_MainQC to enable MBT_QualityChecker methods.
  func initializeQualityChecker(withSampleRate sampleRate: Float,
                                accuracy: Float = 0.85) {
    MBTQualityCheckerBridge.initializeMainQualityChecker(sampleRate,
                                                         accuracy: 0.85)
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
  func computeQualityValue(_ data: Buffer) -> [Float] {
    guard let packetLength = data.first?.count else { return [] }

    return EEGQualityProcessor.computeQualityValue(buffer: data,
                                                   sampleRate: sampleRate,
                                                   packetLength: packetLength)
  }

  func computeQualityValue(_ data: Buffer,
                           sampleRate: Int,
                           eegPacketLength: Int) -> [Float] {
    #warning("Why is it passed as parameter and the property being init here?")
    self.sampleRate = sampleRate
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

extension SignalProcessingManager {

  /// Compute calibration from modified EEG Data and qualities,
  /// from the last complete packet until the *n* last packet.
  /// - Parameters:
  ///     - packetsCount: Number of packets to get, from the last one.
  /// - Returns: A dictionnary with calibration datas from the CPP Signal
  /// Processing.
  func computeCalibration(
    of packets: [MBTEEGPacket],
    sampleRate: Int,
    channelCount: Int,
    packetLength: Int
  ) -> CalibrationOutput? {
    calibrationComputed =
      EEGCalibrationProcessor.computeCalibrationV2(lastPackets: packets,
                                                   packetLength: packetLength,
                                                   sampleRate: sampleRate,
                                                   channelCount: channelCount)
    return calibrationComputed
  }

}

//==============================================================================
// MARK: - MBTRelaxIndexComputer
//==============================================================================

extension SignalProcessingManager {

  func computeRelaxIndex(eegPacketManager: EEGPacketManagerV2,
                         sampleRate: Int,
                         channelCount: Int) -> Float? {
    if calibrationComputed == nil { return 0 }

    let packetCount = Constants.EEGPackets.historySize
    let packets = eegPacketManager.getLastNPacketsComplete(packetCount)

    guard packets.count >= packetCount else { return 0 }

    return EEGToRelaxIndexProcessor.computeRelaxIndex(from: packets,
                                                      sampRate: sampleRate,
                                                      nbChannels: channelCount)
  }

}

//==============================================================================
// MARK: - MBTSessionAnalysisComputer
//==============================================================================

extension SignalProcessingManager {

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

extension SignalProcessingManager {

  func resetSession() {
    MBTMelomindAnalysis.resetSession()
  }

}
