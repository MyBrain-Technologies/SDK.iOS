import Foundation

struct HardwareIndusVersionConvertor {

  //----------------------------------------------------------------------------
  // MARK: - Indus to hardware version
  //----------------------------------------------------------------------------

  #warning("TODO")

  //----------------------------------------------------------------------------
  // MARK: - Hardware to indus version
  //----------------------------------------------------------------------------

  static func indusVersion(
    from hardwareVersion: HardwareVersion
  ) -> IndusVersion {
    switch hardwareVersion {
      case .v_1_0_0: return IndusVersion.indus2
      case .v_1_1_0: return IndusVersion.indus3
      case .v_2_0_0, .v_2_1_0: return IndusVersion.indus5
    }
  }

  static func indusVersion(
    fromHardwareVersionString hardwareVersionString: String
  ) -> IndusVersion? {
    guard let hardwareVersion =
            HardwareVersion(rawValue: hardwareVersionString) else {
      return nil
    }
    return HardwareIndusVersionConvertor.indusVersion(from: hardwareVersion)
  }

}
