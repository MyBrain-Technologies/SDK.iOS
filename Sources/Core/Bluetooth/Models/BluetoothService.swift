import Foundation
import CoreBluetooth
// Good
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

  // Indus5
  case transparentService_i5 = "49535343-FE7D-4AE5-8FA9-9FAFD205E455"
  case rx_i5 = "49535343-1E4D-4BD9-BA61-23C647249616"
  case tx_i5 = "49535343-8841-43F4-A8D4-ECBE34729BB3"

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

//==============================================================================
// MARK: - Array extension for Bluetooth Service
//==============================================================================

extension Array where Element == BluetoothService {
  /// Return BluetoothServices uuids values
  var uuids: [CBUUID] {
    self.map({ $0.uuid })
  }
}


//protocol BluetoothAttributeProtocol {
//  var uuid: CBUUID { get }
//}
//
//enum Service: BluetoothAttributeProtocol {
//
//  case mybrain
//  case information
//
//  var uuid: CBUUID {
//    return CBUUID()
//  }
//}
