import Foundation
import RealmSwift
import SwiftyJSON

/*******************************************************************************
 * EEGPacketManager
 *
 * *MBTEEGPacket* model DB Manager.
 *
 ******************************************************************************/
class EEGPacketManager: MBTRealmEntityManager {

  /// Method to persist EEGPacket received in the Realm database.
  /// - Parameters:
  ///     - eegPacket : *MBTEEGPacket* freshly created, soon db-saved.
  /// - Returns: The *MBTEEGPacket* saved in Realm-db.
  class func saveEEGPacket(_ eegPacket: MBTEEGPacket) {
    try? RealmManager.shared.realm.write {
      RealmManager.shared.realm.add(eegPacket)
    }
  }

  /// Get the last packet not complete.
  /// - Returns: The last saved *MBTEEGPacket*.
  class func getLastPacket() -> MBTEEGPacket? {
    return getEEGPackets().last
  }

  /// Get last n *MBTEEGPackets* from the Realm DB.
  /// - Parameters:
  ///     - n : Number of *MBTEEGPackets* wanted.
  /// - Returns : The last n *MBTEEGPacket*.
  class func getLastNPacketsComplete(_ n:Int) -> [MBTEEGPacket] {
    return [MBTEEGPacket](EEGPacketManager.getEEGPackets().suffix(n))
  }

  /// Get all *MBTEEGPacket* saved in Realm DB.
  /// - Returns: All *MBTEEGPacket* db-saved from Realm query.
  class func getEEGPackets() -> Results<MBTEEGPacket> {
    return RealmManager.shared.realm.objects(MBTEEGPacket.self)
  }

  /// Get EEGPackets in JSON Object
  ///
  /// - Parameter eegPackets: An Array of *MBTEEGPacket*
  /// - Returns: A *JSON* instance which contains the array of *MBTEEGPacket*
  class func getJSONEEGDatas(_ eegPackets:[MBTEEGPacket]) -> JSON {
    var eegDatas = [[Float?]]()
    for eegPacket in eegPackets {
      for channelNumber in 0 ..< eegPacket.channelsData.count {
        let channelData = eegPacket.channelsData[channelNumber]

        if eegDatas.count < channelNumber + 1 {
          eegDatas.append([Float?]())
        }

        for packetIndex in 0 ..< channelData.value.count {
          if channelData.value[packetIndex].value.isNaN {
            eegDatas[channelNumber].append(nil)
            log.info("Get JSON EEG data", context: Float.nan)
          } else {
            let value = channelData.value[packetIndex].value
            eegDatas[channelNumber].append(value)
          }
        }
      }
    }

    let hasData = eegDatas.compactMap({
      $0.contains(Float.nan) || $0.contains(Float.signalingNaN)
    })

    log.info("Get JSON EEG data", context: hasData)

    return JSON(eegDatas)
  }

  /// Get qualities of EEGPackets in JSON Object
  ///
  /// - Parameter eegPackets: An Array of *MBTEEGPacket*
  /// - Returns: A *JSON* instance which contains the qualities of an array of *MBTEEGPacket*
  class func getJSONQualities(_ eegPackets:[MBTEEGPacket]) -> JSON {
    var qualities = [[Float]]()
    for eegPacket in eegPackets {
      for indexQuality in 0 ..< eegPacket.qualities.count {
        if qualities.count < indexQuality + 1 {
          qualities.append([Float]())
        }
        qualities[indexQuality].append(eegPacket.qualities[indexQuality].value)
      }
    }

    return JSON(qualities)
  }

  /// Get an Array of getEEGPackets method and this array is independant of Results<MBTEEGPacket>
  ///
  /// - Returns: A *Array* instance of all EEGPackets
  class func getArrayEEGPackets() -> [MBTEEGPacket] {
    var arrayEEGPackets = [MBTEEGPacket]()
    for eegPacket in EEGPacketManager.getEEGPackets() {
      arrayEEGPackets.append(eegPacket)
    }
    return arrayEEGPackets
  }

  /// Delete all EEGPacket saved in Realm DB.
  class func removeAllEEGPackets() {
    let packets = RealmManager.shared.realm.objects(MBTEEGPacket.self)

    try? RealmManager.shared.realm.write {
      RealmManager.shared.realm.delete(packets)
    }
  }

  /// Remove the array packets of DataBase
  ///
  /// - Parameter packets: A *Array* instance of packets to remove from DataBase
  class func removePackets(_ packets:[MBTEEGPacket]) {
    try? RealmManager.shared.realm.write {
      RealmManager.shared.realm.delete(packets)
    }
  }

}
