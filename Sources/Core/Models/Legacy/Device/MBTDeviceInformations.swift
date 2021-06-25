import Foundation
import RealmSwift

/// Device Informations model.
public class MBTDeviceInformations: Object {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// The commercial name of the device.
  @objc public dynamic var productName: String?

  /// The product specific serial number.
  @objc public dynamic var deviceId: String?

  /// The product hardware version.
  @objc public dynamic var hardwareVersion: String?

  /// The product firmware version.
  @objc public dynamic var firmwareVersion: String?

  /******************** Computed properties ********************/

  var indusVersion: IndusVersion? {
    guard let hardwareVersion = hardwareVersion else { return nil }
    return IndusVersion(fromHardwareVersion: hardwareVersion)
  }

  /// Allows to know if all properties have been initialized
  ///
  /// - Returns: A *Bool* instance which test if one of the four properties is nil
  var isDeviceInfoNotNil: Bool {
    return productName != nil
      && deviceId != nil
      && hardwareVersion != nil
      && firmwareVersion != nil
  }

  /******************** Conversion ********************/

  var melomindDeviceInformations: MelomindDeviceInformations {
    return MelomindDeviceInformations(productName: productName ?? "",
                                      hardwareVersion: hardwareVersion ?? "",
                                      firmwareVersion: firmwareVersion ?? "",
                                      uniqueDeviceIdentifier: deviceId ?? "")
  }

}
