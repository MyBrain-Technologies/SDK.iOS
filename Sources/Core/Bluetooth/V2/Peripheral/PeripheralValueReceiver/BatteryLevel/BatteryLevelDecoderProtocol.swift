import Foundation

protocol BatteryLevelDecoderProtocol {
  func decode(headsetBatteryValue: UInt8) -> Float?
}
