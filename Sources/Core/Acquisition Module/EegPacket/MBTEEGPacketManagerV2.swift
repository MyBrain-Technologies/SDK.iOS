import Foundation

class EEGPacketManagerV2 {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private(set) var eegPackets = [MBTEEGPacket]()

  /******************** Array getters ********************/

  var eegData: [[Float?]] {
    var eegDatas = [[Float?]]()
    for eegPacket in eegPackets {
      for channelNumber in 0 ..< eegPacket.channelsData.count {
        let channelData = eegPacket.channelsData[channelNumber]

        if eegDatas.count < channelNumber + 1 {
          eegDatas.append([Float?]())
        }

        for packetIndex in 0 ..< channelData.count {
          if channelData[packetIndex].isNaN {
            eegDatas[channelNumber].append(nil)
            log.info("Get JSON EEG data", context: Float.nan)
          } else {
            let value = channelData[packetIndex]
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
  var qualities: [[Float]] {
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

  //----------------------------------------------------------------------------
  // MARK: - Create
  //----------------------------------------------------------------------------

  /// Method to persist EEGPacket received in the Realm database.
  /// - Parameters:
  ///     - eegPacket: *MBTEEGPacket* freshly created, soon db-saved.
  /// - Returns: The *MBTEEGPacket* saved in Realm-db.
  func saveEEGPacket(_ eegPacket: MBTEEGPacket) {
    eegPackets.append(eegPacket)
  }

  //----------------------------------------------------------------------------
  // MARK: - Read
  //----------------------------------------------------------------------------

  /// Get last n *MBTEEGPackets* from the Realm DB.
  /// - Parameters:
  ///     - n: Number of *MBTEEGPackets* wanted.
  /// - Returns: The last n *MBTEEGPacket*.
  func getLastPackets(_ n: Int) -> [MBTEEGPacket]? {
    guard eegPackets.count >= n else { return nil }
    return [MBTEEGPacket](eegPackets.suffix(n))
  }

  //----------------------------------------------------------------------------
  // MARK: - Delete
  //----------------------------------------------------------------------------

  /// Delete all EEGPacket saved in Realm DB.
  func removeAllEegPackets() {
    eegPackets.removeAll()
  }

}
