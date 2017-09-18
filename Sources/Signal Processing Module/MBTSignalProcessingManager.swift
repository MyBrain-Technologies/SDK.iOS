//
//  MBTSignalProcessingManager.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 15/09/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation

//Holds the current implementation of the signal processing protocols.
internal class MBTSignalProcessingManager: NSObject { //MBTQualityComputer, MBTCalibrationComputer, MBTRelaxIndexComputer, MBTSessionAnalysisComputer {
    
    /// Singleton declaration
    static let shared = MBTSignalProcessingManager()
    
    /// Instance of MBT_MainQC
//    var mainQC: MBT_MainQC?
    
    func initializeQualityChecker() {
//        MBTQualityCheckerBridge.initializeMainQualityChecker()
    }
    
//    //Implementing MBT_QualityComputer
//    func computeQualityValue(_ data: [[Float]], sampRate: Int) -> [Float] {
//        
//        //Transform the input data into the format needed by the Obj-C bridge
//        let nbChannels: Int = data.count
//        let nbDataPoints: Int = data[0].count
//        var dataArray = [Float]()
//        for dataForChannel in data {
//            dataArray += dataForChannel
//        }
//        
//        //Perform the computation
//        let qualities = MBT_SignalProcessingObjC.computeQuality(dataArray, sampRate: NSInteger(sampRate), nbChannels: NSInteger(nbChannels), nbDataPoints: NSInteger(nbDataPoints))
//        
//        //Return the quality values
//        let qualitySwift = qualities as! [Float]
//        return qualitySwift
//    }
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
}
