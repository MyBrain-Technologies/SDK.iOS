//
//  MBTSignalProcessingManager.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 15/09/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import RealmSwift

/// Holds the current implementation of the signal processing protocols.
internal class MBTSignalProcessingManager: MBTQualityComputer {
    
    /// Singleton declaration.
    static let shared = MBTSignalProcessingManager()
    
    /// Dictionnary to store calibration results.
    internal var calibrationComputed: [String: [Float]]!
    
    
    
    /// Initalize MBT_MainQC to enable MBT_QualityChecker methods.
    func initializeQualityChecker()  {
        // Getting connected MBTDevice *sampRate*.
        let sampRate = DeviceManager.getDeviceSampRate()
        MBTQualityCheckerBridge.initializeMainQualityChecker(sampRate, accuracy: 0.85)
    }
    
    /// Delete MBT_MainQC instance once acquisition phase is over.
    func deinitQualityChecker() {
        MBTQualityCheckerBridge.deInitializeMainQualityChecker()
    }
    
    /// Compute datas in the *Quality Checker* and returns an array of *Quality* values
    /// for a data matrix of an acquisition packet.
    /// - parameter data: The data matrix of the packet. Each row is a channel (no GPIOs)
    /// - returns: The array of computed "quality" values. Each value is the quality for a channel, in the same order as the row order in data.
    func computeQualityValue(_ data: List<ChannelDatas>) -> [Float] {
        
        // Getting connected MBTDevice *sampRate*.
        let sampRate = Int(DeviceManager.getDeviceSampRate())
        
        // Transform the input data into the format needed by the Obj-C++ bridge.
        let nbChannels: Int = data.count
        let nbDataPoints: Int = data.first!.value.count
        var dataArray = [Float]()
        
        for channelDatas in data {
            for channelData in channelDatas.value {
                dataArray.append(channelData.value)
            }
        }
        
        // Perform the computation.
        let qualities = MBTQualityCheckerBridge.computeQuality(dataArray,
                                                               sampRate: sampRate,
                                                               nbChannels: nbChannels,
                                                               nbDataPoints: nbDataPoints)
        // Return the quality values.
        let qualitySwift = qualities as! [Float]
        return qualitySwift
    }
    
    /// Get an array of the modified EEG datas by the *Quality Checker*, and return it.
    /// - returns: The matrix of EEG datas (modified) by channel.
    func getModifiedEEGValues() -> [[Float]] {
        let newEEGValues = MBTQualityCheckerBridge.getModifiedEEGData()
        let newEEGValuesSwift = newEEGValues as! [[Float]]
        
        return newEEGValuesSwift
    }
}

extension MBTSignalProcessingManager: MBTCalibrationComputer {
    
    /// Compute calibration from modified EEG Data and qualities,
    /// from the last complete packet until the *n* last packet.
    /// - Parameters:
    ///     - packetsCount: Number of packets to get, from the last one.
    /// - Returns: A dictionnary with calibration datas from the CPP Signal Processing.
    func computeCalibration(_ packetsCount: Int) -> [String: [Float]] {
        let packetLength = DeviceManager.getDeviceEEGPacketLength()
        let sampRate = Int(DeviceManager.getDeviceSampRate())
        
        // Get the last N packets.
        let packets = EEGPacketManager.getLastNPacketsComplete(packetsCount)
        
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
            for datasForChannel in listChannelData {
                for data in datasForChannel.value {
                    dataArray.append(data.value)
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
        let parametersFromComputation = MBTCalibrationBridge.computeCalibration(dataArray,
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

extension MBTSignalProcessingManager: MBTRelaxIndexComputer {
    //Implementing MBT_RelaxIndexComputer
    func computeRelaxIndex() -> Float {
        
        // Get the last N packets.
        let packets = EEGPacketManager.getLastNPacketsComplete(4)
        
        let sampRate = Int(DeviceManager.getDeviceSampRate())
        let nbChannels: Int = DeviceManager.getChannelsCount()
        
        var calibrationData = [List<ChannelDatas>]()
        for i in 0 ..< packets.count {
            calibrationData.append(packets[i].modifiedChannelsData
            )
        }
        
        // Transform the input data into the format needed by the Obj-C bridge
        var dataArray = [Float]()
        for listChannelData in calibrationData {
            for datasForChannel in listChannelData {
                for data in datasForChannel.value {
                    dataArray.append(data.value)
                }
            }
        }
        
        //Perform the computation
        let relaxIndex = MBTRelaxIndexBridge.computeRelaxIndex(dataArray,
                                                               sampRate: sampRate,
                                                               nbChannels: nbChannels)
        return relaxIndex
    }
}

extension MBTSignalProcessingManager: MBTSessionAnalysisComputer {
    //Implementing MBT_SessionAnalysisComputer
    func analyseSession(_ inputDataSNR:[Float], threshold:Float) -> [String:Float] {
        //Perform the computation
        let sessionAnalysisValues = MBTSNRStatisticsBridge.computeSessionStatistics(inputDataSNR, threshold: threshold)
        let sessionAnalysis = sessionAnalysisValues as! [String: Float]
        return sessionAnalysis
    }
}
