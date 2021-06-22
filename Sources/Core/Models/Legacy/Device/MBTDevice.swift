import Foundation
import RealmSwift

/// Model to store data about the Headset connected.
public class MBTDevice: Object {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Database properties ********************/

  /// Device Name
  @objc dynamic public var deviceName: String = ""

  /// Device informations from MBT Headset Bluetooth LE.
  @objc dynamic public var deviceInfos: MBTDeviceInformations? =
    MBTDeviceInformations()

  /// The number of active channels in the device.
  @objc dynamic var nbChannels: Int = 0

  /// The rate at which EEG data is being sent by the headset.
  @objc dynamic var sampRate: Int = 0

  /// An EEG Packet length.
  @objc dynamic var eegPacketLength: Int = 0

  @objc dynamic var batteryLevel: Int = 0

  /// Locations of the acquisition electrodes.
  let acquisitionLocations = List<MBTAcquistionLocation>()

  /// Locations of the references for an electrode.
  let referencesLocations = List<MBTAcquistionLocation>()

  /// Locations of the ground electrodes.
  let groundsLocations = List<MBTAcquistionLocation>()

  /******************** Computed properties ********************/

  var qrCode: String? {
    guard let deviceId = deviceInfos?.deviceId else { return nil }
    return MBTQRCodeSerial.shared.qrCode // MBTQRCodeSerial(qrCodeisKey: false).value(for: deviceId)
  }

  var shouldUpdateFirmware: Bool {
    guard let deviceFirmwareVersion = deviceInfos?.firmwareVersion else {
      return false
    }

    guard let indusVersion = deviceInfos?.indusVersion,
          let filename =
            BinariesFileFinder().higherBinaryFilename(for: indusVersion),
      let fileVersion = filename.versionNumber,
      let firmwareVersion = deviceFirmwareVersion.versionNumber else {
        return false
    }

    let fileFirmwareVersion = FormatedVersion(string: fileVersion)
    let currentFirmwareVersion = FormatedVersion(string: firmwareVersion)

    return fileFirmwareVersion != currentFirmwareVersion
  }


  /******************** Bridge ********************/

  var deviceInformation: DeviceInformation? {
    guard let productName = deviceInfos?.productName,
          let deviceId = deviceInfos?.deviceId,
          let hardwareVersionString = deviceInfos?.hardwareVersion,
          let hardwareVersion =
            HardwareVersion(rawValue: hardwareVersionString),
          let firmwareVersion = deviceInfos?.firmwareVersion
          else {
      return nil
    }

    return DeviceInformation(productName: productName,
                             deviceId: deviceId,
                             hardwareVersion: hardwareVersion,
                             firmwareVersion: firmwareVersion)
  }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  private func getCommentsWithDate(_ comments: [String]) -> [String] {
    return ["\(Date().timeIntervalSince1970)"] + comments
  }

  func getAsRecordHeader(comments: [String]) -> EEGSavingRecordHeader {
    return EEGSavingRecordHeader(
      deviceInfo: deviceInfos!.melomindDeviceInformations,
      comments: getCommentsWithDate(comments),
      sampRate: sampRate,
      eegPacketLength: eegPacketLength,
      nbChannels: nbChannels,
      acquisitionLocation: acquisitionLocations.map() { $0.type.stringValue },
      referencesLocation: referencesLocations.map() { $0.type.stringValue },
      groundsLocation: groundsLocations.map() { $0.type.stringValue }
    )
  }

}
