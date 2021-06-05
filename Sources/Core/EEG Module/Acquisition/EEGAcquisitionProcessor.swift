import Foundation
// Good
class EEGAcquisitionProcessor {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private let acquisitionBuffer: EEGAcquisitionBuffer

  private let eegPacketLength: Int

  private let channelCount: Int

  private let sampletRate: Int

  /******************** Dependency Injections ********************/

  private let signalProcessor: MBTSignalProcessingManager

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(bufferSizeMax: Int,
       packetLength: Int,
       channelCount: Int,
       sampleRate: Int,
       signalProcessor: MBTSignalProcessingManager) {
    self.acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: bufferSizeMax)
    self.eegPacketLength = packetLength
    self.channelCount = channelCount
    self.sampletRate = sampleRate
    self.signalProcessor = signalProcessor
  }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  func getEEGPacket(fromData data: Data,
                    checkQuality: Bool) -> MBTEEGPacket? {
    acquisitionBuffer.add(data: data)
    guard let packet = acquisitionBuffer.getUsablePackets() else {
      return nil
    }

    let relaxIndexes =
      EEGDeserializer.deserializeToRelaxIndex(bytes: packet,
                                              numberOfElectrodes: channelCount)
    let eegPacket = convertToEEGPacket(values: relaxIndexes,
                                       checkQuality: checkQuality)

    return eegPacket
  }

  /// Convert values from the acquisition to EEG Packets
  private func convertToEEGPacket(values: [[Float]],
                                  checkQuality: Bool) -> MBTEEGPacket {
    var eegPacket = MBTEEGPacket(channelsValues: values)
    eegPacket = addQualities(to: eegPacket, checkQuality: checkQuality)
    eegPacket = addModifiedValues(to: eegPacket, checkQuality: checkQuality)
    return eegPacket
  }

  /// Add qualities from signal processing to an eeg packet
  private func addQualities(to eegPacket: MBTEEGPacket,
                            checkQuality: Bool) -> MBTEEGPacket {
    guard checkQuality else { return eegPacket }

    let qualities = signalProcessor.computeQualityValue(
      eegPacket.channelsData,
      sampleRate: sampletRate,
      eegPacketLength: eegPacketLength
    )
    eegPacket.addQualities(qualities)
    return eegPacket
  }

  /// Add EEG modified values from signal progression to an eeg packet
  private func addModifiedValues(to eegPacket: MBTEEGPacket,
                                 checkQuality: Bool) -> MBTEEGPacket {
    guard checkQuality else { return eegPacket }

    let correctedValues = signalProcessor.getModifiedEEGValues()

    eegPacket.setModifiedChannelsData(correctedValues,
                                      sampRate: sampletRate)
    return eegPacket
  }
}
