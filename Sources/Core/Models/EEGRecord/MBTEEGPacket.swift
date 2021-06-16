import Foundation
import RealmSwift

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

  /// Values updated by the *Quality Checker* as a flat map
  public var flattenModifiedChannelsData: [Float] {
    return Array(modifiedChannelsData.map() { $0.values }.joined())
  }

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

//==============================================================================
// MARK: - Array Extension
//==============================================================================

extension Array where Element == MBTEEGPacket {

  /// Flat all modified channel data into one float array
  func flattenModifiedChannelData() -> [Float] {
    let channelsData = self.map() { $0.flattenModifiedChannelsData }

    // swiftlint:disable:next syntactic_sugar
    let flattenChannelsData = Array<Float>(channelsData.joined())

    return flattenChannelsData
  }
}


//==============================================================================
// MARK: - V2
//==============================================================================

public class MBTEEGPacketV2 {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// The qualities stored in a list. The list size
  /// should be equal to the number of channels if there is
  /// a status channel. It's calculated by the Quality Checker
  /// and it indicates if the EEG datas are relevant or not.
  public var qualities = [Float]()

  /// The timestamp in milliseconds when this packet is created.
  let timestamp = Int(Date().timeIntervalSince1970 * 1000)

  /// The values from all channels.
  public var channelsData = Buffer()

  /// The values updated by the *Quality Checker* from all channels.
  public var modifiedChannelsData = Buffer()

  /// Values updated by the *Quality Checker* as a flat map
  public var flattenModifiedChannelsData: [Float] {
    return modifiedChannelsData.flattened
  }

  //----------------------------------------------------------------------------
  // MARK: - EEGPackets Methods
  //----------------------------------------------------------------------------

  /// Create an EEG packet from an array of values for channels
  /// Exemple:
  /// (first channel) [0]: [values for a channel]
  /// (second channel) [1]: [values for a second channel]
  /// ...
  public convenience init(buffer: Buffer) {
    self.init()
    self.channelsData = buffer
  }

  /// Add *Quality* values, calculated by the Quality Checker, to a *MBTEEGPacket*.
  func addQualities(_ qualities: [Float]) {
    self.qualities.append(contentsOf: qualities)
  }

  func setModifiedChannelsData(_ modifiedValues: [[Float]],
                               sampRate sampleRate: Int) {
    let buffer = modifiedValues.map { modifiedChannel -> [Float] in
      var channel = [Float]()
      let count = min(sampleRate, modifiedChannel.count)
      channel.append(contentsOf: modifiedChannel[0 ..< count])
      return channel
    }


    modifiedChannelsData.removeAll()
    modifiedChannelsData.append(contentsOf: buffer)
  }

}

//==============================================================================
// MARK: - Array Extension
//==============================================================================

extension Array where Element == MBTEEGPacketV2 {

  /// Flat all modified channel data into one float array
  func flattenModifiedChannelData() -> [Float] {
    let flattenedBuffers = self.map() { $0.flattenModifiedChannelsData }
    return flattenedBuffers.flatMap { $0 }
  }

}
