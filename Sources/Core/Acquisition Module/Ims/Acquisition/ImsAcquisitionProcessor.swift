import Foundation

class ImsAcquisitionProcessor {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private let acquisitionBuffer: ImsAcquisitionBuffer<ImsRawPacket>

  private let converter = ImsDataConverter()

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
    let mbtImsPacket = converter.convert(from: coordinateBytes)
    return mbtImsPacket
  }

  private func generateCoordinateValue(from bytes: [UInt8]) -> Float {
    return 0.0
  }


}
