import Foundation

final class PostIndus5BatteryLevelDecoder: BatteryLevelDecoderProtocol {

  func decode(headsetBatteryValue: UInt8) -> Float? {
    let intValue = Int(headsetBatteryValue)
    switch intValue {
      case 0, 1, 2, 3, 4: return 0
      case 5: return 12.5
      case 6: return 25
      case 7: return 37.5
      case 8: return 50
      case 9: return 62.5
      case 10: return 75
      case 11: return 87.5
      case 12: return 100
      default: return nil
    }
  }

}
