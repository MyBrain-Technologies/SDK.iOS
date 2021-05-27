import Foundation
import CoreBluetooth

enum MBTCharacteristic {

  enum PreIndus5: String, CaseIterable, MBTAttributeProtocol {

    //--------------------------------------------------------------------------
    // MARK: - Cases
    //--------------------------------------------------------------------------

    case productName = "0x2A24"
    case serialNumber = "0x2A25"
    case hardwareRevision = "0x2A27"
    case firmwareRevision = "0x2A26"
    case brainActivityMeasurement = "0xB2A5"
    case deviceBatteryStatus = "0xB2A2"
    case headsetStatus = "0xB2A3"
    case oadTransfert = "0xB2A6"
    case mailBox = "0xB2A4"

    //--------------------------------------------------------------------------
    // MARK: - MBTAttributeProtocol
    //--------------------------------------------------------------------------

    init?(uuid: CBUUID) {
      let foundCharacteristic =
        MBTCharacteristic.PreIndus5.allCases.first(where: { $0.uuid == uuid })
      guard let characteristic = foundCharacteristic else { return nil }
      self = characteristic
    }

    var uuid: CBUUID {
      return CBUUID(string: self.rawValue)
    }

  }

  enum PostIndus5: String, CaseIterable, MBTAttributeProtocol {

    //--------------------------------------------------------------------------
    // MARK: - Cases
    //--------------------------------------------------------------------------

    case transparentService_i5 = "49535343-FE7D-4AE5-8FA9-9FAFD205E455"
    case rx = "49535343-1E4D-4BD9-BA61-23C647249616"
    case tx = "49535343-8841-43F4-A8D4-ECBE34729BB3"

    //--------------------------------------------------------------------------
    // MARK: - MBTAttributeProtocol
    //--------------------------------------------------------------------------

    init?(uuid: CBUUID) {
      let foundCharacteristic =
        MBTCharacteristic.PostIndus5.allCases.first(where: { $0.uuid == uuid })
      guard let characteristic = foundCharacteristic else { return nil }
      self = characteristic
    }

    var uuid: CBUUID {
      return CBUUID(string: self.rawValue)
    }
  }

}
