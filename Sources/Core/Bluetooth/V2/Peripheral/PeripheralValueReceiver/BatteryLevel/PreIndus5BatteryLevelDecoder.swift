import Foundation

final class PreIndus5BatteryLevelDecoder: BatteryLevelDecoderProtocol {

  func decode(headsetBatteryValue: UInt8) -> Float? {
    let intValue = Int(headsetBatteryValue)
    switch intValue {
      case 0: return 0
      case 1: return 15
      case 2: return 30
      case 3: return 50
      case 4: return 65
      case 5: return 85
      case 6: return 100
      default: return nil
    }
  }

}
