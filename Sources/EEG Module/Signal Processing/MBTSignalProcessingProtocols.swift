import Foundation
import RealmSwift

/// Protocol to call Quality Checker methods from the Objective-C++ bridge.
protocol MBTQualityComputer {

  /// Initalize MBT_MainQC to enable MBT_QualityChecker methods.
  func initializeQualityChecker() -> Bool

  /// Returns an array of "quality" values for a data matrix of an acquisition packet.
  /// - parameter data: The data matrix of the packet. Each row is a channel (no GPIOs)
  /// - returns: The array of computed "quality" values. Each value is the quality for a channel, in the same order as the row order in data.
  func computeQualityValue(_ data: List<ChannelDatas>) -> [Float]

  /// Delete MBT_MainQC instance once acquisition phase is over.
  func deinitQualityChecker()
}

protocol MBTCalibrationComputer {

  /// Computes the necessary information from the calibration data and returns it in a dictionary.
  /// - parameter calibrationData: The data matrix for the calibration acquisition. Each row is a channel (no GPIOs).
  /// - parameter calibrationQualityValues: The matrix of computed "quality" values. Each row is a channel (no GPIOs), each column is a packet.
  /// - parameter sampRate: The data sampling rate.
  /// - paremeter packetLength: The number of data points in a "packet".
  /// - returns: A dictionary with the parameters computed from the calibration data.
  func computeCalibration(_ packetsCount: Int) -> [String: [Float]]
}

protocol MBTRelaxIndexComputer {

  /// Computes and return the relaxation index for the "packet".
  /// - parameter sessionData: The data matrix for the session acquisition packet. Each row is a channel (no GPIOs).
  /// - parameter sessionQualityValues: The array of computed "quality" values. Each row is a channel (no GPIOs).
  /// - parameter parametersFromCalibration: A dictionary with the parameters computed from the calibration data.
  /// - parameter sampRate: The data sampling rate.
  /// - returns: The relaxation index for the packet.
  func computeRelaxIndex() -> Float?
}

protocol MBTSessionAnalysisComputer {

  /// Computes and return the results of the session analysis.
  /// - parameter sessionData: The data matrix for the session acquisition packet. Each row is a channel (no GPIOs).
  /// - parameter sessionQualityValues: The array of computed "quality" values. Each row is a channel (no GPIOs).
  /// - parameter parametersFromCalibration: A dictionary with the parameters computed from the calibration data.
  /// - parameter relaxIndex: The array of computed "relax index" values. Each value correspond to a session acquisition packet.
  /// - parameter sampRate: The data sampling rate.
  /// - paremeter packetLength: The number of data points in a "packet".
  /// - returns: A dictionnary with the output values for the session analysis
  func analyseSession(_ inputDataSNR: [Float], threshold: Float) -> [String: Float]
}
