import Foundation

class ImsAcquisitionProcessor {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private let acquisitionBuffer: ImsAcquisitionBuffer<ImsRawPacket>

  private let deserializer = ImsDeserializer()

  private let bufferSizeMax: Int

  private let packetLength: Int

  private let channelCount: Int

  private let sampleRate: Int

  private let electrodeToChannelIndex: [ElectrodeLocation: Int]

  var fullScaleMode: ImsFullScaleMode = ._2

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(bufferSizeMax: Int,
       packetLength: Int,
       channelCount: Int = 3,
       sampleRate: Int,
       electrodeToChannelIndex: [ElectrodeLocation: Int]) {
    let bufferSize = 100 * 3 // 100Hz, 3 samples (x,y,z)
    self.acquisitionBuffer =
      ImsAcquisitionBuffer<ImsRawPacket>(bufferSizeMax: bufferSize)// bufferSizeMax)
    self.bufferSizeMax = 100 // bufferSizeMax
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
