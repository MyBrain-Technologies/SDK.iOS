import Foundation
import RealmSwift
import SwiftyJSON

//MARK: - MBTEEGPacket

/// Model to store processed data of an EEG Packet.
public class MBTEEGPacket: Object {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// The qualities stored in a list. The list size
  /// should be equal to the number of channels if there is
  /// a status channel. It's calculated by the Quality Checker
  /// and it indicates if the EEG datas are relevant or not.
  public var qualities = List<Quality>()

  /// The timestamp in milliseconds when this packet is created.
  @objc public  dynamic var timestamp = Int(Date().timeIntervalSince1970 * 1000)

  /// The values from all channels.
  public var channelsData = List<ChannelDatas>()

  /// The values updated by the *Quality Checker* from all channels.
  public var modifiedChannelsData = List<ChannelDatas>()

  //----------------------------------------------------------------------------
  // MARK: - EEGPackets Methods
  //----------------------------------------------------------------------------

  /// Create a new MBTEEGPacket
  ///
  /// - Returns: A new *MBTEEGPacket* instance which channelsData are set up
  class func createNewEEGPacket(_ nbChannels:Int) -> MBTEEGPacket {
    let newPacket = MBTEEGPacket()
    for _ in 0 ..< nbChannels {
      newPacket.channelsData.append(ChannelDatas())
    }
    return newPacket
  }

  /// Create a EEGPacket with *[[Float]]* of data
  ///
  /// - Parameters:
  ///   - arrayData: A *[[FLoat]]* instance of data
  ///   - nbChannels: A *Int* instance of number channel
  /// - Returns: A new *MBTEEGPacket* instance which is set up with arrayData
  class func createNewEEGPacket(arrayData: [[Float]],
                                nbChannels: Int) -> MBTEEGPacket {
    let newPacket = MBTEEGPacket.createNewEEGPacket(nbChannels)
    let count = min(nbChannels, arrayData.count)

    for index in 0 ..< count {
      for sample in arrayData[index] {
        newPacket.channelsData[index].value.append(ChannelData(data: sample))
      }
    }

    return newPacket
  }

  /// Add *Quality* values, calculated by the Quality Checker, to a *MBTEEGPacket*.
  /// - Parameters:
  ///     - qualities : Array of *Quality* by channel.
  ///     - eegPacket : The *MBTEEGPacket* to add the *Quality* values to.
  func addQualities(_ qualities:[Float]) {
    for qualityFloat in qualities {
      let quality = Quality(data:qualityFloat)
      self.qualities.append(quality)
    }
  }

  /// Update the *ChannelData* values with the corrected values received
  /// from the Quality Checker.
  /// - Parameters:
  ///     - eegPacket : The *MBTEEGPacket* to update the EEG values.
  ///     - modifiedValues : Array of the corrected values, by channel.
  func addModifiedChannelsData(_ modifiedValues:[[Float]],
                               nbChannels: Int,
                               sampRate: Int) {
    //        print("addModifiedChannelsData")
    // Add the updated values to the packet copy.
    for indexChannel in 0 ..< nbChannels {
      let channelDatas = ChannelDatas()
      for indexPacketValue in 0 ..< sampRate {
        if indexChannel < modifiedValues.count
          && indexPacketValue < modifiedValues[indexChannel].count {
          let data = modifiedValues[indexChannel][indexPacketValue]
          channelDatas.value.append(ChannelData(data: data))
        }
      }
      self.modifiedChannelsData.append(channelDatas)
    }
  }
}

//==============================================================================
// MARK: - Quality
//==============================================================================

/*******************************************************************************
 * Quality
 *
 * One quality value for one channel.
 *
 ******************************************************************************/
public class Quality: Object {

  /// Value property of the *Quality*.
  @objc public dynamic var value: Float = 0

  /// Special init with the value of *Quality*.
  public convenience init(data: Float) {
    self.init()
    self.value = data
  }
}

/*******************************************************************************
 * ChannelData
 *
 * One EEG value from one channel.
 *
 ******************************************************************************/
public class ChannelData: Object {
  /// Value property of a *Channel*.
  @objc public dynamic var value: Float = 0

  /// Special init with the value of *ChannelData*.
  public convenience init(data: Float) {
    self.init()
    self.value = data
  }
}

/*******************************************************************************
 * ChannelDatas
 *
 * All values from one channel.
 *
 ******************************************************************************/
public class ChannelDatas: Object {
  /// *RLMArray* of *ChannelData*.
  public let value = List<ChannelData>()
}

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
