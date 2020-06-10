import Foundation

/*******************************************************************************
 * CalibrationError
 *
 * Error that can be returned by `MBT_ComputeCalibration` from C++.
 * See code here: https://github.com/mbt-administrator/Melomind.Algorithms
 *
 ******************************************************************************/
public enum CalibrationError: Int {
  case signalQualityTooBad = -2
  case badInput = -1
}

extension CalibrationError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .signalQualityTooBad:
      return "Cannot process with a signal quality too bad"
    case .badInput: return "Cannot process with bad inputs"
    }
  }
}
