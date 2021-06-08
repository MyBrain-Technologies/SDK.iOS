import Foundation

/*******************************************************************************
 * RecordFileSaver
 *
 * Save, create and delete record file
 *
 ******************************************************************************/
struct RecordFileSaver {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Shared ********************/

  static let shared = RecordFileSaver()

  /******************** Dependency Injections ********************/

  private let fileManager: FileManager

  /******************** Paths and directories ********************/

  private let documentDirectory: URL!
  private let recordsDirectory: URL!

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(fileManager: FileManager = .default,
       directoryName: String = Constants.EEGPackets.recordDirectory) {
    self.fileManager = fileManager
    self.documentDirectory = try? fileManager.url(for: .documentDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: nil,
                                                  create: false)
    self.recordsDirectory =
      documentDirectory.appendingPathComponent(directoryName)
  }

  //----------------------------------------------------------------------------
  // MARK: - Record Directory
  //----------------------------------------------------------------------------

  /// Check if the directory used to save records exists
  var isRecordsDirectoryExists: Bool {
    return fileManager.fileExists(atPath: recordsDirectory.path)
  }

  /// Create the directory used to save records
  func createRecordsDirectory() {
    guard isRecordsDirectoryExists == false else { return }

    log.verbose("Create record directory", context: recordsDirectory.path)

    do {
      try fileManager.createDirectory(at: recordsDirectory,
                                      withIntermediateDirectories: true,
                                      attributes: nil)
    } catch {
      log.error("Cannot create directory", context: error)
    }
  }

  /// Remove the directory used to save records
  func removeRecordsDirectory() {
    log.verbose("Remove record directory", context: recordsDirectory.path)

    do {
      try fileManager.removeItem(at: recordsDirectory)
    } catch {
      log.error("Cannot remove directory", context: error)
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Save Record
  //----------------------------------------------------------------------------

  /// Save a string in the record directory with `name` as filename
  func saveRecord(_ content: String, at name: String) -> URL? {
    if isRecordsDirectoryExists == false {
      createRecordsDirectory()
    }

    let filename = recordsDirectory.appendingPathComponent(name)

    log.verbose("Save record in file", context: filename)

    do {
      try content.write(to: filename, atomically: true, encoding: .utf8)
      return filename
    } catch {
      log.error("Cannot write content to file", context: error)
      return nil
    }
  }

  /// Save a json in the record directory with `name` as filename
//  func saveRecord(_ json: JSON, at name: String) -> URL? {
//    guard let content = json.rawString([.castNilToNSNull: true]) else {
//      log.error("Cannot convert json to raw string", context: json)
//      return nil
//    }
//
//    return saveRecord(content, at: name)
//  }

  /// Save a json in the record directory, building a custom filename with the
  /// devide id and the user id
  func saveRecord(jsonString: String, deviceId: String, userId: Int) -> URL? {
    let filename = RecordFileNameBuilder().build(userId: userId,
                                                 deviceId: deviceId)

    let savedRecordPath = saveRecord(jsonString, at: filename)
    return savedRecordPath
  }

  //----------------------------------------------------------------------------
  // MARK: - Remove Record
  //----------------------------------------------------------------------------

  /// Remove a record file with its filename
  func removeRecord(at filename: String) {
    log.verbose("Remove record from file", context: filename)

    do {
      try fileManager.removeItem(atPath: filename)
    } catch {
      log.error("Can't remove file", context: error)
    }
  }

  /// Remove a record file with its url
  func removeRecord(at url: URL) {
    removeRecord(at: url.path)
  }

  //----------------------------------------------------------------------------
  // MARK: - Get records
  //----------------------------------------------------------------------------

  /// Return all records url in the record directory
  func getSavedRecords() -> [URL] {
    do {
      let files = try fileManager.contentsOfDirectory(
        at: recordsDirectory,
        includingPropertiesForKeys: nil,
        options: .skipsHiddenFiles
      )
      return files
    } catch {
      log.error("Cannot get recorded json", context: error)
      return []
    }
  }
}
