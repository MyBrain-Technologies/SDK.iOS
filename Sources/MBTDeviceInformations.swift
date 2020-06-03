import Foundation
import SwiftyJSON
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

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  var toCodable: MelomindDeviceInformations {
    return MelomindDeviceInformations(productName: productName ?? "",
                                      hardwareVersion: hardwareVersion ?? "",
                                      firmwareVersion: firmwareVersion ?? "",
                                      uniqueDeviceIdentifier: deviceId ?? "")
  }

  /// Convert object to JSON
  ///
  /// - Returns: A *JSON* instance of MBTDeviceInformations
//  func getJSON() -> JSON {
//    var jsonDevice = JSON()
//
//    jsonDevice["productName"].stringValue = productName ?? ""
//    jsonDevice["hardwareVersion"].stringValue = hardwareVersion ?? ""
//    jsonDevice["firmwareVersion"].stringValue = firmwareVersion ?? ""
//    jsonDevice["uniqueDeviceIdentifier"].stringValue = deviceId ?? ""
//
//    return jsonDevice
//  }

  /// Allows to know if all properties have been initialized
  ///
  /// - Returns: A *Bool* instance which test if one of the four properties is nil
  func isDeviceInfoNotNil() -> Bool {
    return productName != nil
      && deviceId != nil
      && hardwareVersion != nil
      && firmwareVersion != nil
  }
}
