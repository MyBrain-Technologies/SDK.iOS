import Foundation
import CoreBluetooth

enum MBTService {

  enum PreIndus5: String, CaseIterable, MBTAttributeProtocol {

    //--------------------------------------------------------------------------
    // MARK: - Cases
    //--------------------------------------------------------------------------

    case deviceInformation = "0x180A"
    case myBrain = "0xB2A0"


    //--------------------------------------------------------------------------
    // MARK: - MBTAttributeProtocol
    //--------------------------------------------------------------------------

    init?(uuid: CBUUID) {
      let foundService =
        MBTService.PreIndus5.allCases.first(where: { $0.uuid == uuid })
      guard let service = foundService else { return nil }
      self = service
    }

    var uuid: CBUUID {
      return CBUUID(string: self.rawValue)
    }

  }

  enum PostIndus5: String, CaseIterable, MBTAttributeProtocol {

    //--------------------------------------------------------------------------
    // MARK: - Cases
    //--------------------------------------------------------------------------

    case transparent = "49535343-FE7D-4AE5-8FA9-9FAFD205E455"

    //--------------------------------------------------------------------------
    // MARK: - MBTAttributeProtocol
    //--------------------------------------------------------------------------

    init?(uuid: CBUUID) {
      let foundService =
        MBTService.PostIndus5.allCases.first(where: { $0.uuid == uuid })
      guard let service = foundService else { return nil }
      self = service
    }

    var uuid: CBUUID {
      return CBUUID(string: self.rawValue)
    }
  }

}
