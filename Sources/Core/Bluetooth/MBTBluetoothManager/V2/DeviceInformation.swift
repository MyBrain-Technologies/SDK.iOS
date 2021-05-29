import Foundation

#warning("Is public useful?")
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

  /******************** Versioning ********************/

  public var indusVersion: IndusVersion? {
    return IndusVersion(fromHardwareVersion: hardwareVersion)
  }

  public var formattedFirmwareVersion: FormatedVersion {
    assertionFailure("TODO: Check to use `firmwareVersion`")
    return FormatedVersion(string: firmwareVersion)
  }

  /******************** Acquisition ********************/

  public let channelCount: Int

  /// The rate at which EEG data is being sent by the headset.
  public let sampleRate: Int

  /// An EEG Packet length.
  public let eegPacketSize: Int

//  let acquisitionElectrodes: AcquisitionElectrodes

  //----------------------------------------------------------------------------
  // MARK: - Versioning
  //----------------------------------------------------------------------------

  func isVersionUpToDate(oadFirmwareVersion: FormatedVersion) -> Bool {
    log.info("Device current firmware version", context: firmwareVersion)
    log.info("Expected firmware version", context: oadFirmwareVersion)
    return formattedFirmwareVersion == oadFirmwareVersion
  }

}

//struct AcquisitionElectrodes {
//  /// Locations of the acquisition electrodes.
//  let acquisitionLocations = [MBTAcquistionLocation]()
//
//  /// Locations of the references for an electrode.
//  let referencesLocations = [MBTAcquistionLocation]()
//
//  /// Locations of the ground electrodes.
//  let groundsLocations = [MBTAcquistionLocation]()
//}
