import Foundation
import CoreBluetooth

enum BluetoothService: String, CaseIterable {
  case myBrainService = "0xB2A0"
  case brainActivityMeasurement = "0xB2A5"
  case deviceBatteryStatus = "0xB2A2"
  case headsetStatus = "0xB2A3"
  case oadTransfert = "0xB2A6"
  case mailBox = "0xB2A4"
  case deviceInfoService = "0x180A"
  case productName = "0x2A24"
  case serialNumber = "0x2A25"
  case hardwareRevision = "0x2A27"
  case firmwareRevision = "0x2A26"
  case audioSing = "0x110B"
  case remoteControl = "0x110C"

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Groups of characteristics ********************/

  static var deviceCharacteristics: [BluetoothService] {
    return [.productName,
            .serialNumber,
            .hardwareRevision,
            .firmwareRevision]
  }

  static var melomindServices: [BluetoothService] {
    return [.myBrainService, .deviceInfoService]
  }

  /******************** Additional informations ********************/

  var uuid: CBUUID {
    return CBUUID(string: rawValue)
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init?(uuid: CBUUID) {
    let service = BluetoothService.allCases.first(where: { $0.uuid == uuid })
    guard let currentService = service else { return nil }
    self = currentService
  }
}

extension Array where Element == BluetoothService {
  /// Return BluetoothServices uuids values
  var uuids: [CBUUID] {
    self.map({ $0.uuid })
  }
}
