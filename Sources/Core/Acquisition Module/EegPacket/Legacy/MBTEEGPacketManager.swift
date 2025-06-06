import Foundation
import RealmSwift

/*******************************************************************************
 * EEGPacketManager
 *
 * *MBTEEGPacket* model DB Manager.
 *
 ******************************************************************************/

class EEGPacketManager {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Singleton ********************/

  static let shared = EEGPacketManager()

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  private init() { }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------
  /// Method to persist EEGPacket received in the Realm database.
  /// - Parameters:
  ///     - eegPacket: *MBTEEGPacket* freshly created, soon db-saved.
  /// - Returns: The *MBTEEGPacket* saved in Realm-db.
  func saveEEGPacket(_ eegPacket: MBTEEGPacket) {
    try? RealmManager.shared.realm.write {
      RealmManager.shared.realm.add(eegPacket)
    }
  }

  /// Get the last packet not complete.
  /// - Returns: The last saved *MBTEEGPacket*.
  func getLastPacket() -> MBTEEGPacket? {
    return getEEGPackets().last
  }

  /// Get last n *MBTEEGPackets* from the Realm DB.
  /// - Parameters:
  ///     - n: Number of *MBTEEGPackets* wanted.
  /// - Returns: The last n *MBTEEGPacket*.
  func getLastNPacketsComplete(_ n: Int) -> [MBTEEGPacket] {
    return [MBTEEGPacket](getEEGPackets().suffix(n))
  }

  /// Get all *MBTEEGPacket* saved in Realm DB.
  /// - Returns: All *MBTEEGPacket* db-saved from Realm query.
  func getEEGPackets() -> Results<MBTEEGPacket> {
    return RealmManager.shared.realm.objects(MBTEEGPacket.self)
  }

  // WHAT THE HELL
  func getEEGDatas(_ eegPackets: [MBTEEGPacket]) -> [[Float?]] {
     var eegDatas = [[Float?]]()
     for eegPacket in eegPackets {
       for channelNumber in 0 ..< eegPacket.channelsData.count {
         let channelData = eegPacket.channelsData[channelNumber]

         if eegDatas.count < channelNumber + 1 {
           eegDatas.append([Float?]())
         }

         for packetIndex in 0 ..< channelData.values.count {
           if channelData.values[packetIndex].isNaN {
             eegDatas[channelNumber].append(nil)
             log.info("Get JSON EEG data", context: Float.nan)
           } else {
             let value = channelData.values[packetIndex]
             eegDatas[channelNumber].append(value)
           }
         }
       }
     }

     let hasData = eegDatas.compactMap({
       $0.contains(Float.nan) || $0.contains(Float.signalingNaN)
     })

     log.info("Get JSON EEG data", context: hasData)

     return eegDatas
   }

  // PLEASE GOD SAVE ME FROM THAT
  func getQualities(_ eegPackets: [MBTEEGPacket]) -> [[Float]] {
    var qualities = [[Float]]()

    for eegPacket in eegPackets {
      for indexQuality in 0 ..< eegPacket.qualities.count {
        if qualities.count < indexQuality + 1 {
          qualities.append([Float]())
        }
        qualities[indexQuality].append(eegPacket.qualities[indexQuality])
      }
    }

    return qualities
  }

  /// Get an Array of getEEGPackets method and this array is independant of Results<MBTEEGPacket>
  ///
  /// - Returns: A *Array* instance of all EEGPackets
  func getArrayEEGPackets() -> [MBTEEGPacket] {
    var arrayEEGPackets = [MBTEEGPacket]()
    for eegPacket in getEEGPackets() {
      arrayEEGPackets.append(eegPacket)
    }
    return arrayEEGPackets
  }

  /// Delete all EEGPacket saved in Realm DB.
  func removeAllEEGPackets() {
    let packets = RealmManager.shared.realm.objects(MBTEEGPacket.self)

    try? RealmManager.shared.realm.write {
      RealmManager.shared.realm.delete(packets)
    }
  }

  /// Remove the array packets of DataBase
  ///
  /// - Parameter packets: A *Array* instance of packets to remove from DataBase
  func removePackets(_ packets: [MBTEEGPacket]) {
    try? RealmManager.shared.realm.write {
      RealmManager.shared.realm.delete(packets)
    }
  }

}




