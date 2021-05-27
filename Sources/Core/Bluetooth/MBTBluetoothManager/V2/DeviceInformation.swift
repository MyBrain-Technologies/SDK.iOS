import Foundation

public struct DeviceInformation: Codable {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// The commercial name of the device.
  public var productName: String

  /// The product specific serial number.
  public var deviceId: String

  /// The product hardware version.
  public var hardwareVersion: String

  /// The product firmware version.
  public var firmwareVersion: String

  var indusVersion: IndusVersion? {
    return IndusVersion(fromHardwareVersion: hardwareVersion)
  }

  var formattedFirmwareVersion: FormatedVersion {
    return FormatedVersion(string: firmwareVersion)
  }

}
