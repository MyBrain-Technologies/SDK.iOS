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
    
    /// Singleton declaration
    static let shared = MBTSignalProcessingManager()
    
    /// Initalize MBT_MainQC to enable MBT_QualityChecker methods.
    func initializeQualityChecker() {
        // Getting connected MBTDevice *sampRate*.
        let sampRate = DeviceManager.getDeviceSampRate()
        // Calling bridge method to init mainQC.
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
//
//    
//    //Implementing MBT_CalibrationComputer
//    func computeSettingsFromCalibration(_ calibrationData: [[Float]], calibrationQualityValues: [[Float]], sampRate: Int, packetLength: Int) -> [String: Float] {
//        
//        //Transform the input data into the format needed by the Obj-C bridge
//        let nbChannels: Int = calibrationData.count
//        let nbDataPoints: Int = calibrationData[0].count
//        var dataArray = [Float]()
//        for dataForChannel in calibrationData {
//            dataArray += dataForChannel
//        }
//        
//        //Transform the quality data into the format needed by the Obj-C bridge
//        var qualityArray = [Float]()
//        for qualityForChannel in calibrationQualityValues {
//            qualityArray += qualityForChannel
//        }
//        
//        //Perform the computation
//        let parametersFromComputation = MBT_SignalProcessingObjC.computeCalibration(dataArray, signalQuality: qualityArray, sampRate: NSInteger(sampRate), packetLength: NSInteger(packetLength), nbChannels: NSInteger(nbChannels), nbDataPoints: NSInteger(nbDataPoints))
//        
//        //Return the quality values
//        let parameters = parametersFromComputation as! [String: Float]
//        return parameters
//    }
//    
//    
//    //Implementing MBT_RelaxIndexComputer
//    func computeRelaxIndex(_ sessionData: [[Float]], sessionQualityValues: [Float], parametersFromCalibration: [String: Float], sampRate: Int) -> Float {
//        
//        //Transform the input data into the format needed by the Obj-C bridge
//        let nbChannels: Int = sessionData.count
//        let nbDataPoints: Int = sessionData[0].count
//        var dataArray = [Float]()
//        for dataForChannel in sessionData {
//            dataArray += dataForChannel
//        }
//        
//        //Perform the computation
//        let relaxIndex = MBT_SignalProcessingObjC.computeRelaxIndex(dataArray, signalQuality: sessionQualityValues, parametersFromCalibration: parametersFromCalibration, sampRate: NSInteger(sampRate), windowType: "HAMMING", nbChannels: NSInteger(nbChannels), nbDataPoints: NSInteger(nbDataPoints))
//        return relaxIndex!.floatValue
//    }
//    
//    
//    //Implementing MBT_SessionAnalysisComputer
//    func analyseSession(_ sessionData: [[Float]], sessionQualityValues: [[Float]], parametersFromCalibration: [String : Float], relaxIndex: [Float], sampRate: Int, packetLength: Int) -> [String : Float] {
//        
//        //Transform the input data into the format needed by the Obj-C bridge
//        let nbChannels: Int = sessionData.count
//        let nbDataPoints: Int = sessionData[0].count
//        var dataArray = [Float]()
//        for dataForChannel in sessionData {
//            dataArray += dataForChannel
//        }
//        
//        //Transform the quality data into the format needed by the Obj-C bridge
//        var qualityArray = [Float]()
//        for qualityForChannel in sessionQualityValues {
//            qualityArray += qualityForChannel
//        }
//        
//        //Perform the computation
//        let sessionAnalysisValues = MBT_SignalProcessingObjC.computeSessionAnalysis(dataArray, signalQuality: qualityArray, parametersFromCalibration: parametersFromCalibration, relaxIndex: relaxIndex, sampRate: NSInteger(sampRate), packetLength: NSInteger(packetLength), nbChannels: NSInteger(nbChannels), nbDataPoints: NSInteger(nbDataPoints))
//        let sessionAnalysis = sessionAnalysisValues as! [String: Float]
//        return sessionAnalysis
//    }
