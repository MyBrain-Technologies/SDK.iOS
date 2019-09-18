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

internal class MBTSignalProcessingManager: MBTQualityComputer {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Singleton ********************/

  /// Singleton declaration.
  static let shared = MBTSignalProcessingManager()

  /// Dictionnary to store calibration results.
  internal var calibrationComputed: [String: [Float]]!

  ///
  internal var sampRate:Int = 0

  ///
  internal var eegPacketLength:Int = 0

  ///
  internal var version = MBTQualityCheckerBridge.getVersion()
  
  internal var relaxIndexAlgorithm = MBTRelaxIndexAlgorithm.algorithm(
    fromSDKVersion: MBTQualityCheckerBridge.getVersion()!
  )

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  /// Initalize MBT_MainQC to enable MBT_QualityChecker methods.
  func initializeQualityChecker() -> Bool {
    // Getting connected MBTDevice *sampRate*.
    guard let sampRate = DeviceManager.getDeviceSampRate() else { return false }
    MBTQualityCheckerBridge.initializeMainQualityChecker(Float(sampRate),
                                                         accuracy: 0.85)
    return true
  }

  /// Delete MBT_MainQC instance once acquisition phase is over.
  func deinitQualityChecker() {
    MBTQualityCheckerBridge.deInitializeMainQualityChecker()
  }


  /// Compute datas in the *Quality Checker* and returns an array of *Quality*
  /// values for a data matrix of an acquisition packet.
  /// - parameter data: The data matrix of the packet. Each row is a channel
  /// (no GPIOs)
  /// - returns: The array of computed "quality" values. Each value is the
  /// quality for a channel, in the same order as the row order in data.
  func computeQualityValue(_ data: List<ChannelDatas>) -> [Float] {
    //        print("computeQualityValue")
    // Getting connected MBTDevice *sampRate*.
    //        let sampRate = Int(DeviceManager.getDeviceSampRate())

    // Transform the input data into the format needed by the Obj-C++ bridge.
    let nbChannels: Int = data.count
    let nbDataPoints: Int = data.first!.value.count
    var dataArray = [Float]()
    var nbNAN = 0
    for channelDatas in data {
      for channelData in channelDatas.value {
        if channelData.value.isNaN {
          nbNAN += 1
        }

        dataArray.append(channelData.value)
      }
    }

    prettyPrint(
      log.ln("computeQualityValue - NB NAN dataArray Quality: \(nbNAN)")
    )

    // Perform the computation.
    let qualities =
      MBTQualityCheckerBridge.computeQuality(dataArray,
                                             sampRate: sampRate,
                                             nbChannels: nbChannels,
                                             nbDataPoints: nbDataPoints)

    // Return the quality values.
    let qualitySwift = qualities as! [Float]

    if qualitySwift.count < 2 {
      prettyPrint(log.ln("computeQualityValue - Quality Cound inf à 2"))
      prettyPrint(log.ln("computeQualityValue - NBChannel : \(nbChannels)"))
      prettyPrint(log.ln("computeQualityValue - sampRate : \(sampRate)"))
      prettyPrint(
        log.ln("computeQualityValue - dataArray Count : \(dataArray.count)")
      )
      prettyPrint(
        log.ln("computeQualityValue - nbDataPoints : \(nbDataPoints)")
      )
    }

    return qualitySwift
  }

  func computeQualityValue(_ data: List<ChannelDatas>,
                           sampRate:Int,
                           eegPacketLength:Int) -> [Float] {
    self.sampRate = sampRate
    self.eegPacketLength = eegPacketLength
    return computeQualityValue(data)
  }


  /// Get an array of the modified EEG datas by the *Quality Checker*, and
  /// return it.
  /// - returns: The matrix of EEG datas (modified) by channel.
  func getModifiedEEGValues() -> [[Float]] {
    let newEEGValues = MBTQualityCheckerBridge.getModifiedEEGData()
    let newEEGValuesSwift = newEEGValues as! [[Float]]

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
  func computeCalibration(_ packetsCount: Int) -> [String: [Float]] {
    guard let sampRate = DeviceManager.getDeviceSampRate(),
      let nbChannel = DeviceManager.getChannelsCount(),
      let packetLength = DeviceManager.getDeviceEEGPacketLength() else {
        return [String: [Float]]()
    }

    // Get the last N packets.
    let packets = EEGPacketManager.getLastNPacketsComplete(packetsCount)

    if packets.count != packetsCount {
      return [String: [Float]]()
    }

    var calibrationData = [List<ChannelDatas>]()
    for i in 0 ..< packetsCount {
      calibrationData.append(packets[i].modifiedChannelsData)
    }

    var calibrationQualityValues = [List<Quality>]()
    for j in 0 ..< packetsCount {
      calibrationQualityValues.append(packets[j].qualities)
    }

    // Transform the input data into the format needed by the Obj-C bridge
    var dataArray = [Float]()
    for listChannelData in calibrationData {
      for i in 0 ..< nbChannel {
        let data = listChannelData[i].value
        for j in 0 ..< packetLength {
          dataArray.append(data[j].value)
        }
      }
    }

    // Transform the quality data into the format needed by the Obj-C bridge
    var qualityArray = [Float]()
    for qualityList in calibrationQualityValues {
      for qualityForChannel in qualityList {
        qualityArray.append(qualityForChannel.value)
      }
    }

    // Perform the computation.
    let parametersFromComputation =
      MBTCalibrationBridge.computeCalibration(dataArray,
                                              qualities: qualityArray,
                                              packetLength: packetLength,
                                              packetsCount: packetsCount,
                                              sampRate: sampRate)
    // Transform results in a Swift format.
    let parameters = parametersFromComputation as! [String: [Float]]
    // Save the results.
    calibrationComputed = parameters
    // Return the quality values in a Swift format.
    return parameters
  }
}

//==============================================================================
// MARK: - MBTRelaxIndexComputer
//==============================================================================

extension MBTSignalProcessingManager: MBTRelaxIndexComputer {

  //Implementing MBT_RelaxIndexComputer
  func computeRelaxIndex() -> Float? {

    // Get the last N packets.
    let packets =
      EEGPacketManager.getLastNPacketsComplete(MBTClient.HISTORY_SIZE)

    if packets.count < MBTClient.HISTORY_SIZE || calibrationComputed == nil {
      return 0
    }

    guard let sampRate = DeviceManager.getDeviceSampRate(),
      let nbChannels = DeviceManager.getChannelsCount() else {
        return nil
    }

    var arrayModifiedChannelData = [List<ChannelDatas>]()
    for i in 0 ..< packets.count {
      arrayModifiedChannelData.append(packets[i].modifiedChannelsData)
    }

    // Transform the input data into the format needed by the Obj-C bridge
    var dataArray = [Float]()
    for listChannelData in arrayModifiedChannelData {
      for datasForChannel in listChannelData {
        for data in datasForChannel.value {
          dataArray.append(data.value)
        }
      }
    }

    //Perform the computation
    let relaxIndex =
      MBTRelaxIndexBridge.computeRelaxIndex(dataArray,
                                            sampRate: sampRate,
                                            nbChannels: nbChannels)
    return relaxIndex
  }

}

//==============================================================================
// MARK: - MBTSessionAnalysisComputer
//==============================================================================

extension MBTSignalProcessingManager: MBTSessionAnalysisComputer {

  //Implementing MBT_SessionAnalysisComputer
  func analyseSession(_ inputDataSNR:[Float],
                      threshold:Float) -> [String:Float] {
    //Perform the computation
    let sessionAnalysisValues =
      MBTSNRStatisticsBridge.computeSessionStatistics(inputDataSNR,
                                                      threshold: threshold)
    let sessionAnalysis = sessionAnalysisValues as! [String: Float]
    return sessionAnalysis
  }

}

//==============================================================================
// MARK: - MBTMelomindAnalysis
//==============================================================================

extension MBTSignalProcessingManager {

  var sessionMeanAlphPower: Float {
    return MBTMelomindAnalysis.sessionMeanAlphPower()
  }

  var sessionMeanRelativeAlphaPower: Float {
    return MBTMelomindAnalysis.sessionMeanRelativeAlphaPower()
  }

  var sessionConfidence: Float {
    return MBTMelomindAnalysis.sessionConfidence()
  }

  var sessionAlphaPowers: [Float] {
    return MBTMelomindAnalysis.sessionAlphaPowers().filter { $0 is Float }
      as! [Float]
  }

  var sessionRelativeAlphaPowers: [Float] {
    return
      MBTMelomindAnalysis.sessionRelativeAlphaPowers().filter { $0 is Float }
        as! [Float]
  }

  var sessionQualities: [Float] {
    return 
      MBTMelomindAnalysis.sessionQualities().filter { $0 is Float } as! [Float]
  }

}
