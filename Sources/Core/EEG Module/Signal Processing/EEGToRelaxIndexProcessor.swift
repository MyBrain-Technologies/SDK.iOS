import Foundation

/*******************************************************************************
 * EEGToRelaxIndexProcessor
 *
 * Convert EEG packets to a relax index value.
 *
 ******************************************************************************/
struct EEGToRelaxIndexProcessor {

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /// Compute a relax index value from last received packets packets
  static func computeRelaxIndex() -> Float? {
    let packetCount = Constants.EEGPackets.historySize
    let packets = EEGPacketManager.shared.getLastNPacketsComplete(packetCount)

    guard packets.count >= packetCount else { return 0 }

    guard let sampRate = DeviceManager.getDeviceSampRate(),
      let nbChannels = DeviceManager.getChannelsCount() else {
        return nil
    }

    return computeRelaxIndex(from: packets,
                             sampRate: sampRate,
                             nbChannels: nbChannels)
  }

  /// Compute relax index with given packets using the RelaxIndexBridge (obj C)
  private static func computeRelaxIndex(from packets: [MBTEEGPacket],
                                        sampRate: Int,
                                        nbChannels: Int) -> Float {
    let dataArray = packets.flattenModifiedChannelData()

    let lastPacket = packets[packets.count - 1]
    let qualities = Array(lastPacket.qualities)

    let relaxIndex =
      MBTRelaxIndexBridge.computeRelaxIndex(dataArray,
                                            sampRate: sampRate,
                                            nbChannels: nbChannels,
                                            lastPacketQualities: qualities)
    return relaxIndex
  }
}
