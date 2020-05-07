import Foundation
import SwiftyJSON

/*******************************************************************************
 * MBTJSONHelper
 *
 * Helper to create and manage a JSON file (kwak format) with the session data.
 *
 ******************************************************************************/

struct MBTJSONHelper {

  //----------------------------------------------------------------------------
  // MARK: - File
  //----------------------------------------------------------------------------

  /// Get File Name for a Record
  ///
  /// - Parameters:
  ///   - idUser: A *Int* id of the connected user
  ///   - idDevice: A *Int* id of the connected melomind
  /// - Returns: Return the file name
  static func getFileName(_ idUser: Int,
                          withIdDevice idDevice: String) -> String {
    let date = Date()
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "yyyy-MM-dd--HH:mm:ss"
    let projectName =
      Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String ?? ""
    let deviceName = "melo_" + idDevice
    let stringIdUser = "\(idUser)"

    let fileName = "eegPacketsRecording"
      + "_" + dateFormater.string(from: date)
      + "_" + projectName
      + "_" + deviceName
      + "_" + stringIdUser
      + ".json"

    return fileName
  }

  /// Remove the file
  ///
  /// - Parameter urlFile: A *URL* of the file to remove
  /// - Returns: Return the boolean if success or fail
  @discardableResult
  static func removeFile(_ urlFile: URL) -> Bool {
    do {
      try FileManager.default.removeItem(atPath: urlFile.path)
    } catch {
      log.error("Can't remove file", context: urlFile.path)
      return false
    }

    return true
  }

  //----------------------------------------------------------------------------
  // MARK: - Save
  //----------------------------------------------------------------------------

  /// Save the JSON in a File.
  ///
  /// - Parameters:
  ///   - json: A *JSON* of the Session
  ///   - idDevice: A *Int* id of the Melomind Connected
  ///   - idUser: A *Int* id of the User Connected
  ///   - completion: A block which is execute after save the file or if it fail
  /// - Returns: return the URL of the file saved or nil if it fail
  static func saveJSONOnDevice(_ json: JSON,
                               idDevice: String,
                               idUser: Int,
                               with completion: () -> Void) -> URL? {
    let fileManager = FileManager.default

    do {
      // Getting the url to save the json.
      let documentDirectory = try fileManager.url(for: .documentDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: nil,
                                                  create: false)

      let eegPacketJSONRecordingsPath =
        documentDirectory.appendingPathComponent("eegPacketJSONRecordings")

      if !fileManager.fileExists(atPath: eegPacketJSONRecordingsPath.path) {
        try fileManager.createDirectory(at: eegPacketJSONRecordingsPath,
                                        withIntermediateDirectories: true,
                                        attributes: nil)
      }

      let fileName: String =
        MBTJSONHelper.getFileName(idUser, withIdDevice: idDevice)

      let fileURL = eegPacketJSONRecordingsPath.appendingPathComponent(fileName)

      // Saving JSON in device.
      try json.rawString([.castNilToNSNull: true])?.write(to: fileURL,
                                                          atomically: true,
                                                          encoding: .utf8)
      log.info("Save JSON on device at", context: fileURL)
      completion()
      return fileURL
    } catch {
      log.error("Cannot save JSON on device", context: error)
    }

    return nil
  }

}
