import Foundation
import RealmSwift

/*******************************************************************************
 * EEGCalibrationProcessor
 *
 * Use last recorded packets to compute a calibration output.
 *
 ******************************************************************************/
struct EEGCalibrationProcessor {

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /// Use the last `packetsCount` packets to compute a calibration output value.
  static func computeCalibration(packetsCount: Int) -> CalibrationOutput? {
    guard let sampRate = DeviceManager.getDeviceSampRate(),
      let nbChannel = DeviceManager.getChannelsCount(),
      let packetLength = DeviceManager.getDeviceEEGPacketLength() else {
        return nil
    }

    // Get the last N packets.
    let packets = EEGPacketManager.shared.getLastNPacketsComplete(packetsCount)

    guard packets.count == packetsCount else { return nil }

    return computeCalibration(packets: packets,
                              sampRate: sampRate,
                              nbChannel: nbChannel,
                              packetLength: packetLength)
  }

  //----------------------------------------------------------------------------
  // MARK: - Tools
  //----------------------------------------------------------------------------

  /// Compute calibration value from packets modifiedChannelData and qualities values
  static private func computeCalibration(
    packets: [MBTEEGPacket],
    sampRate: Int,
    nbChannel: Int,
    packetLength: Int
  ) -> CalibrationOutput? {
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

    let output = decode(calibrationParameters: parametersFromComputation ?? [:])
    log.verbose(output as Any)

    return output
  }

  //----------------------------------------------------------------------------
  // MARK: - Decode calibration
  //----------------------------------------------------------------------------

  static func decode(
    calibrationParameters: [AnyHashable: Any]
  ) -> CalibrationOutput? {
    guard let parameters = calibrationParameters as? [String: [Double]],
      !parameters.isEmpty else {
      return nil
    }

    return CalibrationOutput(object: parameters)
  }

  //----------------------------------------------------------------------------
  // MARK: - Flatten arrays
  //----------------------------------------------------------------------------

  /// Return modified channel data values of packets as one array of values
  static func getFlattenModifiedChannelData(from packets: [MBTEEGPacket],
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
  static func getFlattenQualities(from packets: [MBTEEGPacket]) -> [Float] {
    let calibrationQualityValues = packets.map() { $0.qualities }
    let flattenQualities = calibrationQualityValues.joined()

    return Array(flattenQualities)
  }
}
