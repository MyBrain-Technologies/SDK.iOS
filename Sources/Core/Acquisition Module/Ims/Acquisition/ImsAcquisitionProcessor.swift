import Foundation

class ImsAcquisitionProcessor {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private let bufferSizeMax: Int

  private let packetLength: Int

  private let channelCount: Int

  private let sampleRate: Int

  private let electrodeToChannelIndex: [ElectrodeLocation: Int]

  private let deserializer = ImsDeserializer()

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(bufferSizeMax: Int,
       packetLength: Int,
       channelCount: Int = 3,
       sampleRate: Int,
       electrodeToChannelIndex: [ElectrodeLocation: Int]) {
    self.bufferSizeMax = bufferSizeMax
    self.packetLength = packetLength
    self.channelCount = channelCount
    self.sampleRate = sampleRate
    self.electrodeToChannelIndex = electrodeToChannelIndex
  }

  //----------------------------------------------------------------------------
  // MARK: - Processes
  //----------------------------------------------------------------------------

  func generateImsPacket(from data: Data) -> MbtImsPacket? {
    let imsRawPacket = ImsRawPacket(data: data)
    let coordinateBytes =
      deserializer.deserializeToXYZ(bytes: imsRawPacket.packetValues)
    return convertToImsPacket(values: coordinateBytes)
//    acquisitionBuffer.add(data: data)
//    guard let packet = acquisitionBuffer.getUsablePackets() else { return nil }
//
//    let relaxIndexes =
//      EEGDeserializer.deserializeToRelaxIndex(bytes: packet,
//                                              numberOfElectrodes: channelCount)
//    let eegPacket = convertToEEGPacket(values: relaxIndexes,
//                                       hasQualityChecker: hasQualityChecker)
//
//    return eegPacket
  }

  private func convertToImsPacket(values: [[[UInt8]]]) -> MbtImsPacket? {
    guard values.count == 3 else { return nil }
    let xIndex = 0
    let yIndex = 1
    let zIndex = 2

//    IMS
//    [213, 255, 210, 255, 241, 255, 213, 255, 211, 255, 241, 255]
//    Chunked IMS
//    [[213, 255], [210, 255], [241, 255], [213, 255], [211, 255], [241, 255]]
//    Spreaded IMS
//    [[[213, 255], [213, 255]], [[210, 255], [211, 255]], [[241, 255], [241, 255]]]
    let xBytes = values[xIndex]

    return MbtImsPacket(x: 1, y: 1, z: 1)
  }

  private func generateCoordinateValue(from bytes: [UInt8]) -> Float {
    return 0.0
  }


}
