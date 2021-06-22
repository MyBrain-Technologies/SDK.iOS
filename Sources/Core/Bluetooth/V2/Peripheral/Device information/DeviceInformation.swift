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
  public var hardwareVersion: HardwareVersion

  /// The product firmware version.
  public var firmwareVersion: String

  public var qrCode: String?

  /******************** Versioning ********************/

  public let indusVersion: IndusVersion

  public var formattedFirmwareVersion: FormatedVersion {
    assertionFailure("TODO: Check to use `firmwareVersion`")
    return FormatedVersion(string: firmwareVersion)
  }

  /******************** Acquisition ********************/

  public let acquisitionInformation: DeviceAcquisitionInformation

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init?(productName: String,
        deviceId: String,
        hardwareVersion: String,
        firmwareVersion: String) {
    guard let hardwareVersion =
            HardwareVersion(rawValue: hardwareVersion) else {
      return nil
    }

    self.init(productName: productName,
              deviceId: deviceId,
              hardwareVersion: hardwareVersion,
              firmwareVersion: firmwareVersion)
  }

  init(productName: String,
       deviceId: String,
       hardwareVersion: HardwareVersion,
       firmwareVersion: String) {
    self.productName = productName
    self.deviceId = deviceId
    self.hardwareVersion = hardwareVersion
    self.firmwareVersion = firmwareVersion
    self.indusVersion =
      HardwareIndusVersionConvertor.indusVersion(from: hardwareVersion)

    self.acquisitionInformation =
      DeviceAcquisitionInformation(from: indusVersion)
  }

  //----------------------------------------------------------------------------
  // MARK: - Versioning
  //----------------------------------------------------------------------------

  func isVersionUpToDate(oadFirmwareVersion: FormatedVersion) -> Bool {
    log.info("Device current firmware version", context: firmwareVersion)
    log.info("Expected firmware version", context: oadFirmwareVersion)
    return formattedFirmwareVersion == oadFirmwareVersion
  }

}
