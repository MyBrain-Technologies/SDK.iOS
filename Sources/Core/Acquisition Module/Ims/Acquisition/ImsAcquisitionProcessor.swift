import Foundation

class ImsAcquisitionProcessor {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private let acquisitionBuffer: ImsAcquisitionBuffer<ImsRawPacket>

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
    self.acquisitionBuffer =
      ImsAcquisitionBuffer<ImsRawPacket>(bufferSizeMax: bufferSizeMax)
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
    acquisitionBuffer.add(data: data)
    guard let packet = acquisitionBuffer.getUsablePackets() else {
      return nil
    }

    let coordinateBytes = deserializer.deserializeToXYZ(bytes: packet)
    return convertToImsPacket(values: coordinateBytes)
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
