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

  /******************** Versioning ********************/

  public let indusVersion: IndusVersion

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

//  /// Locations of the acquisition electrodes.
//  let acquisitionLocations: [ElectrodeLocation]
//
//  /// Locations of the references for an electrode.
//  let referencesLocations: [ElectrodeLocation]
//
//  /// Locations of the ground electrodes.
//  let groundsLocations: [ElectrodeLocation]


//  // Acquisition Electrodes
//  let acquisition1 = MBTAcquistionLocation()
//  acquisition1.type = .p3
//  let acquisition2 = MBTAcquistionLocation()
//  acquisition2.type = .p4
//
//  // Reference Electrode
//  let reference = MBTAcquistionLocation()
//  reference.type = .m1
//
//  // Ground Electrode
//  let ground = MBTAcquistionLocation()
//  ground.type = .m2

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

//  init(productName: String,
//       deviceId: String,
//       hardwareVersion: HardwareVersion,
//       firmwareVersion: String,
//       channelCount: Int,
//       sampleRate: Int,
//       eegPacketSize: Int) {
//    self.productName = productName
//    self.deviceId = deviceId
//    self.hardwareVersion = hardwareVersion
//    self.firmwareVersion = firmwareVersion
//    self.channelCount = channelCount
//    self.sampleRate = sampleRate
//    self.eegPacketSize = eegPacketSize
//
//    self.indusVersion =
//      HardwareIndusVersionConvertor.indusVersion(from: hardwareVersion)
//  }

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

    #warning("TODO: Use builder from indusVersion: build(from: indusVersion)")
    switch indusVersion {
      case .indus2, .indus3:
        self.channelCount = 2
        self.sampleRate = 250
        self.eegPacketSize = 250
      case .indus5:
        #warning("TODO: Use real indus5 version")
        fatalError("Use real indus5 version")
        self.channelCount = 2
        self.sampleRate = 250
        self.eegPacketSize = 250
    }

  }

  #warning("TODO")
//  init(productName: String,
//       deviceId: String,
//       firmwareVersion: String
//       hardwareVersion: HardwareVersion) {
//    // hardwareVersion -> IndusVersion
//  }

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
