import Foundation
import CoreBluetooth

enum BluetoothService {
  case myBrainService
  case brainActivityMeasurement
  case deviceBatteryStatus
  case headsetStatus
  case oadTransfert
  case mailBox
  case deviceInfoService
  case productName
  case serialNumber
  case hardwareRevision
  case firmwareRevision

  var uuid: CBUUID {
    switch self {
    case .myBrainService: return  CBUUID(string: "0xB2A0")
    case .brainActivityMeasurement: return CBUUID(string: "0xB2A5")
    case .deviceBatteryStatus: return CBUUID(string: "0xB2A2")
    case .headsetStatus: return CBUUID(string: "0xB2A3")
    case .oadTransfert: return CBUUID(string: "0xB2A6")
    case .mailBox: return CBUUID(string: "0xB2A4")
    case .deviceInfoService: return CBUUID(string: "0x180A")
    case .productName: return CBUUID(string: "0x2A24")
    case .serialNumber: return CBUUID(string: "0x2A25")
    case .hardwareRevision: return CBUUID(string: "0x2A27")
    case .firmwareRevision: return CBUUID(string: "0x2A26")
    }
  }
}
