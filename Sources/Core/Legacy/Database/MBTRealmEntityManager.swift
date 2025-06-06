import Foundation
import RealmSwift

/*******************************************************************************
 * MBTRealmEntityManager
 *
 * Class to manage the structure to create entities manager.
 *
 ******************************************************************************/

/// Structure declaration to create DB Entity managers.
class RealmManager {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Singleton ********************/

  static let shared = RealmManager()

  /******************** Realm ********************/

  let realm: Realm
  var config: Realm.Configuration

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  private init() {
    // swiftlint:disable:next force_try
    let documentDirectory = try! FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: false
    )
    let path = "MyBrainTechnologieSDKDB.realm"
    let url = documentDirectory.appendingPathComponent(path)

    config = Realm.Configuration()
    config.deleteRealmIfMigrationNeeded = true
    config.fileURL = url
    config.schemaVersion = 1
    config.shouldCompactOnLaunch = { totalBytes, usedBytes in
      // totalBytes refers to the size of the file on disk in bytes
      // (data + free space)
      // usedBytes refers to the number of bytes used by data in the file

      // Compact if the file is over 100MB in size and less than 50% 'used'
      let oneHundredMB = 100 * 1024 * 1024
      return (totalBytes > oneHundredMB)
        && (Double(usedBytes) / Double(totalBytes)) < 0.5
    }

    // swiftlint:disable:next force_try
    realm = try! Realm(configuration: config)
  }
}

