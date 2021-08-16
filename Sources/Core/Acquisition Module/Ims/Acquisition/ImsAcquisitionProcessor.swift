import Foundation

class ImsAcquisitionProcessor {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private let acquisitionBuffer: ImsAcquisitionBuffer<ImsRawPacket>

  private let deserializer = ImsDeserializer()

  private let bufferSizeMax: Int

  private let channelCount: Int

  private let sampleRate: Int

  var fullScaleMode: ImsFullScaleMode = ._2

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(bufferSizeMax: Int,
       channelCount: Int,
       sampleRate: Int) {
    let bufferSize = 100 * 3 // 100Hz, 3 samples (x,y,z)
    self.acquisitionBuffer =
      ImsAcquisitionBuffer<ImsRawPacket>(bufferSizeMax: bufferSizeMax)
    self.bufferSizeMax = bufferSizeMax
    self.channelCount = channelCount
    self.sampleRate = sampleRate
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
