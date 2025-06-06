import Foundation

/*******************************************************************************
 * MBTEEGPacket
 *
 * Model to store processed data of an EEG Packet.
 *
 ******************************************************************************/

public class MBTEEGPacket {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// The qualities stored in a list. The list size
  /// should be equal to the number of channels if there is
  /// a status channel. It's calculated by the Quality Checker
  /// and it indicates if the EEG datas are relevant or not.
  public private(set) var qualities = [Float]()

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

  public let electrodeToChannelIndex: [ElectrodeLocation: Int]

  //----------------------------------------------------------------------------
  // MARK: - EEGPackets Methods
  //----------------------------------------------------------------------------

  /// Create an EEG packet from an array of values for channels
  /// Exemple:
  /// (first channel) [0]: [values for a channel]
  /// (second channel) [1]: [values for a second channel]
  /// ...
  public init?(buffer: Buffer,
               electrodeToChannelIndex: [ElectrodeLocation: Int]) {
    guard buffer.count == electrodeToChannelIndex.count else { return nil }
    self.channelsData = buffer
    self.electrodeToChannelIndex = electrodeToChannelIndex
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

  func getChannel(of electrode: ElectrodeLocation) -> [Float]? {
    guard let channelIndex = electrodeToChannelIndex[electrode] else {
      return nil
    }
    return channelsData[channelIndex]
  }

  func getModifiedChannel(of electrode: ElectrodeLocation) -> [Float]? {
    guard let channelIndex = electrodeToChannelIndex[electrode] else {
      return nil
    }
    return modifiedChannelsData[channelIndex]
  }

}

//==============================================================================
// MARK: - Array Extension
//==============================================================================

extension Array where Element == MBTEEGPacket {

  /// Flat all modified channel data into one float array
  func flattenModifiedChannelData() -> [Float] {
    let flattenedBuffers = self.map() { $0.flattenModifiedChannelsData }
    return flattenedBuffers.flatMap { $0 }
  }

}
