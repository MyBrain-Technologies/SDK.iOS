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

  public typealias Quality = Float

  /// The qualities stored in a list. The list size
  /// should be equal to the number of channels if there is
  /// a status channel. It's calculated by the Quality Checker
  /// and it indicates if the EEG datas are relevant or not.
  public var qualities = List<Quality>()

  /// The timestamp in milliseconds when this packet is created.
  @objc public dynamic var timestamp = Int(Date().timeIntervalSince1970 * 1000)

  /// The values from all channels.
  public var channelsData = List<ChannelsData>()

  /// The values updated by the *Quality Checker* from all channels.
  public var modifiedChannelsData = List<ChannelsData>()

  //----------------------------------------------------------------------------
  // MARK: - EEGPackets Methods
  //----------------------------------------------------------------------------

  /// Create an EEG packet from an array of values for channels
  /// Exemple:
  /// (first channel) [0]: [values for a channel]
  /// (second channel) [1]: [values for a second channel]
  /// ...
  public convenience init(channelsValues: [[Float]]) {
    self.init()

    let channels = channelsValues.map() { values -> ChannelsData in
      let channel = ChannelsData()
      channel.values.append(objectsIn: values)
      return channel
    }

    self.channelsData.append(objectsIn: channels)
  }

  /// Add *Quality* values, calculated by the Quality Checker, to a *MBTEEGPacket*.
  func addQualities(_ qualities: [Quality]) {
    self.qualities.append(objectsIn: qualities)
  }

  func setModifiedChannelsData(_ modifiedValues: [[Float]],
                               sampRate: Int) {
    let channelDatas = modifiedValues.map() { channelValues -> ChannelsData in
      let data = ChannelsData()
      let count = min(sampRate, channelValues.count)

      data.values.append(objectsIn: channelValues[0 ..< count])
      return data
    }

    modifiedChannelsData.removeAll()
    modifiedChannelsData.append(objectsIn: channelDatas)
  }
}
