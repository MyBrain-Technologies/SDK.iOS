import Foundation
import RealmSwift
import SwiftyJSON

/*******************************************************************************
 * MBTEEGPacket
 *
 * Model to store processed data of an EEG Packet.
 *
 ******************************************************************************/
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
  class func createNewEEGPacket(_ nbChannels: Int) -> MBTEEGPacket {
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
  ///     - qualities: Array of *Quality* by channel.
  ///     - eegPacket: The *MBTEEGPacket* to add the *Quality* values to.
  func addQualities(_ qualities: [Float]) {
    for qualityFloat in qualities {
      let quality = Quality(data: qualityFloat)
      self.qualities.append(quality)
    }
  }

  /// Update the *ChannelData* values with the corrected values received
  /// from the Quality Checker.
  /// - Parameters:
  ///     - eegPacket: The *MBTEEGPacket* to update the EEG values.
  ///     - modifiedValues: Array of the corrected values, by channel.
  func addModifiedChannelsData(_ modifiedValues: [[Float]],
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
