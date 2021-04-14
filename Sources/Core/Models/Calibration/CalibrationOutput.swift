import Foundation

/*******************************************************************************
 * CalibrationOutput
 *
 * Structure returned by `MBT_ComputeCalibration` from C++.
 * Fields matchs the `CalibrationOutputKeys`.
 * See code here: https://github.com/mbt-administrator/Melomind.Algorithms
 *
 ******************************************************************************/

public struct CalibrationOutput {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  public let rawValues: [Float]
  public let relativeValues: [Float]
  public let smoothedValues: [Float]
  public let frequenciesHistory: [Float]
  public let errorValues: [Float]
  public let individualAlphaFrequency: [Float]

  /********************  Computed properties ********************/

  public var resultValue: Float? { return errorValues.first }

  public var error: CalibrationError? {
    guard let value = resultValue else { return nil }
    return CalibrationError(rawValue: Int(value))
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init() {
    self.rawValues = []
    self.relativeValues = []
    self.smoothedValues = []
    self.frequenciesHistory = []
    self.errorValues = []
    self.individualAlphaFrequency = []
  }
  
  init(object: [String: [Double]]) {
    self.rawValues = object["rawSnrCalib"]?.toFloat ?? []
    self.relativeValues = object["rawrelativeSnrCalib"]?.toFloat ?? []
    self.smoothedValues = object["snrCalib"]?.toFloat ?? []
    self.frequenciesHistory = object["histFrequencies"]?.toFloat ?? []
    self.errorValues = object["errorMsg"]?.toFloat ?? []
    self.individualAlphaFrequency = object["iafCalib"]?.toFloat ?? []
  }

}
