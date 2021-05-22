import Foundation

public struct DeviceInformation {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// The commercial name of the device.
  public var productName: String?

  /// The product specific serial number.
  public var deviceId: String?

  /// The product hardware version.
  public var hardwareVersion: String?

  /// The product firmware version.
  public var firmwareVersion: String?

  /******************** Computed properties ********************/

  var indusVersion: IndusVersion? {
    guard let hardwareVersion = hardwareVersion else { return nil }
    return IndusVersion(fromHardwareVersion: hardwareVersion)
  }

  /// Allows to know if all properties have been initialized
  ///
  /// - Returns: A *Bool* instance which test if one of the four properties is
  /// nil
  var isDeviceInfoNotNil: Bool {
    return productName != nil
      && deviceId != nil
      && hardwareVersion != nil
      && firmwareVersion != nil
  }

  /******************** Conversion ********************/

  var melomindDeviceInformation: MelomindDeviceInformations {
    return MelomindDeviceInformations(productName: productName ?? "",
                                      hardwareVersion: hardwareVersion ?? "",
                                      firmwareVersion: firmwareVersion ?? "",
                                      uniqueDeviceIdentifier: deviceId ?? "")
  }

}
