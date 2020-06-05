import Foundation
import RealmSwift

/*******************************************************************************
 * EEGCalibrationProcessor
 *
 * 
 *
 ******************************************************************************/
struct EEGCalibrationProcessor {

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  func computeCalibration(packetsCount: Int) -> [String: [Float]] {
    guard let sampRate = DeviceManager.getDeviceSampRate(),
      let nbChannel = DeviceManager.getChannelsCount(),
      let packetLength = DeviceManager.getDeviceEEGPacketLength() else {
        return [:]
    }

    // Get the last N packets.
    let packets = EEGPacketManager.shared.getLastNPacketsComplete(packetsCount)

    guard packets.count == packetsCount else { return [String: [Float]]() }

    return computeCalibration(packets: packets,
                              sampRate: sampRate,
                              nbChannel: nbChannel,
                              packetLength: packetLength)
  }

  //----------------------------------------------------------------------------
  // MARK: - Tools
  //----------------------------------------------------------------------------

  /// Compute calibration value from packets modifiedChannelData and qualities values
  func computeCalibration(packets: [MBTEEGPacket],
                          sampRate: Int,
                          nbChannel: Int,
                          packetLength: Int) -> [String: [Float]] {
    let qualityArray = getFlattenQualities(from: packets)
    let dataArray = getFlattenModifiedChannelData(from: packets,
                                                  packetLength: packetLength,
                                                  nbChannels: nbChannel)

    let parametersFromComputation =
      MBTCalibrationBridge.computeCalibration(dataArray,
                                              qualities: qualityArray,
                                              packetLength: packetLength,
                                              packetsCount: packets.count,
                                              sampRate: sampRate)

    let parameters = parametersFromComputation as? [String: [Float]] ?? [:]
    log.verbose(parameters)

    return parameters
  }

  /// Return modified channel data values of packets as one array of values
  func getFlattenModifiedChannelData(from packets: [MBTEEGPacket],
                                     packetLength: Int,
                                     nbChannels: Int) -> [Float] {
    let modifiedChannelData = packets.map() {
      Array($0.modifiedChannelsData.prefix(nbChannels))
    }

    // Transform the input data into the format needed by the Obj-C bridge
    var dataArray = [Float]()
    for channelsData in modifiedChannelData {
      for i in 0 ..< nbChannels {
        let values = channelsData[i].values.prefix(packetLength)
        dataArray.append(contentsOf: values)
      }
    }

    return dataArray
  }

  /// Return qualities of all packets as one array of qualities
  func getFlattenQualities(from packets: [MBTEEGPacket]) -> [Float] {
    let calibrationQualityValues = packets.map() { $0.qualities }
    let flattenQualities = calibrationQualityValues.joined()

    return Array(flattenQualities)
  }
}
