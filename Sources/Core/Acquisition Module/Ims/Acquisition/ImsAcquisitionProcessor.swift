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

  var fullScaleMode: ImsFullScaleMode = ._2
  
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

    let scaleValue = fullScaleMode.rawValue
    let imsPacket = deserializer.deserialize(bytes: packet,
                                                   scaleValue: scaleValue)
    return imsPacket
  }


}
