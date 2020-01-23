import Foundation
import RealmSwift
import SwiftyJSON

/// Model to store data about the Headset connected.
public class MBTDevice: Object {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Database properties ********************/

  /// Device Name
  @objc dynamic public var deviceName: String = ""

  /// Device informations from MBT Headset Bluetooth LE.
  @objc dynamic public var deviceInfos: MBTDeviceInformations? = MBTDeviceInformations()

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
    return MBTQRCodeSerial(qrCodeisKey: false).value(for: deviceId)
  }

  var shouldUpdateFirmware: Bool {
    guard let deviceFirmwareVersion = deviceInfos?.firmwareVersion else {
      return false
    }

    guard let filename = BinariesFileFinder().higherBinaryFilename(for: self),
      let fileVersion = filename.versionNumber,
      let firmwareVersion = deviceFirmwareVersion.versionNumber else {
        return false
    }

    let fileVersionArray =
      fileVersion.components(separatedBy: Constants.versionSeparators)
    let deviceFWVersionArray =
      firmwareVersion.components(separatedBy: Constants.versionSeparators)

    return ArrayUtils().compareArrayVersion(
      arrayA: fileVersionArray,
      isGreaterThan: deviceFWVersionArray
      ) == 1
  }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /// Helper Function to get JSON
  ///
  /// - Parameter comments: user's comments
  /// - Returns: A *JSON* instance of MBTDevice
  internal func getJSON(_ comments: [String]) -> JSON {
    var jsonHeader = JSON()

    var finalsArrayComment = comments
    finalsArrayComment.insert("\(Date().timeIntervalSince1970)", at: 0)
    var acquisitions =  [String]()
    for acquisition in acquisitionLocations {
      acquisitions.append("\(acquisition.type.stringValue)")
    }

    jsonHeader["deviceInfo"] = deviceInfos!.getJSON()
    jsonHeader["recordingNb"].stringValue = "0x03"
    jsonHeader["comments"].arrayObject  = finalsArrayComment
    jsonHeader["sampRate"].intValue = sampRate
    jsonHeader["eegPacketLength"].intValue = eegPacketLength
    jsonHeader["nbChannels"].intValue  = nbChannels
    jsonHeader["acquisitionLocation"] = JSON(acquisitions)

    var stringReferencesLocations = [String]()
    for referencesLocation in referencesLocations {
      stringReferencesLocations.append(referencesLocation.type.stringValue)
    }
    jsonHeader["referencesLocation"] = JSON(stringReferencesLocations)

    var stringGroundsLocations = [String]()
    for groundsLocation in groundsLocations {
      stringGroundsLocations.append(groundsLocation.type.stringValue)
    }
    jsonHeader["groundsLocation"] = JSON(stringGroundsLocations)

    return jsonHeader
  }
}
