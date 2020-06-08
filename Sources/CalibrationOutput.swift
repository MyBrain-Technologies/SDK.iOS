import Foundation

public struct CalibrationOutput: Codable {

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

  /******************** Coding Keys ********************/

  enum CodingKeys: String, CodingKey {
    case rawValues = "rawSnrCalib"
    case relativeValues = "rawrelativeSnrCalib"
    case smoothedValues = "snrCalib"
    case frequenciesHistory = "histFrequencies"
    case errorValues = "errorMsg"
    case individualAlphaFrequency = "iafCalib"
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

}
