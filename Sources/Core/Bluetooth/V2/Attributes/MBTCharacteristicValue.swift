import Foundation

enum MBTCharacteristicValue {
  case productName(value: String)
  case serialNumber(value: String)
  case hardwareRevision(value: String)
  case firmwareRevision(value: String)
  case brainActivity(value: Data)
  case batteryLevel(value: Int)
  case headsetStatus(value: Int)
}
