import Foundation

class EEGAcquisitionProcessorV2 {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private let acquisitionBuffer: EEGAcquisitionBuffer

  private let eegPacketLength: Int

  private let channelCount: Int

  private let sampletRate: Int

  private let electrodeToChannelIndex: [ElectrodeLocation: Int]

  /******************** Dependency Injections ********************/

  private let signalProcessor: SignalProcessingManager

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(bufferSizeMax: Int,
       packetLength: Int,
       channelCount: Int,
       sampleRate: Int,
       electrodeToChannelIndex: [ElectrodeLocation: Int],
       signalProcessor: SignalProcessingManager) {
    self.acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: bufferSizeMax)
    self.eegPacketLength = packetLength
    self.channelCount = channelCount
    self.sampletRate = sampleRate
    self.signalProcessor = signalProcessor
    self.electrodeToChannelIndex = electrodeToChannelIndex
  }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  func getEEGPacket(fromData data: Data,
                    hasQualityChecker: Bool) -> MBTEEGPacket? {
    acquisitionBuffer.add(data: data)
    guard let packet = acquisitionBuffer.getUsablePackets() else { return nil }

    let relaxIndexes =
      EEGDeserializer.deserializeToRelaxIndex(bytes: packet,
                                              numberOfElectrodes: channelCount)
    let eegPacket = convertToEEGPacket(values: relaxIndexes,
                                       hasQualityChecker: hasQualityChecker)

    return eegPacket
  }

  /// Convert values from the acquisition to EEG Packets
  private func convertToEEGPacket(values: [[Float]],
                                  hasQualityChecker: Bool) -> MBTEEGPacket? {
    guard let eegPacket = MBTEEGPacket(
      buffer: values,
      electrodeToChannelIndex: electrodeToChannelIndex
    ) else {
      return nil
    }
    
    if hasQualityChecker {
      let qualities = generateQualities(from: eegPacket)
      eegPacket.addQualities(qualities)

      let modifiedValues = generateModifiedValues(from: eegPacket)
      eegPacket.setModifiedChannelsData(modifiedValues, sampRate: sampletRate)
    }
    return eegPacket
  }

  /// Get qualities from signal processing
  private func generateQualities(from eegPacket: MBTEEGPacket) -> [Float] {
    #warning("TODO: Check")
    var buffer = eegPacket.channelsData

    let qualities =
      signalProcessor.computeQualityValue(buffer,
                                          sampleRate: sampletRate,
                                          eegPacketLength: eegPacketLength)
    return qualities
  }

  /// Get Eeg modified values from signal progression
  private func generateModifiedValues(
    from eegPacket: MBTEEGPacket
  ) -> [[Float]] {
    let correctedValues = signalProcessor.getModifiedEEGValues()
    return correctedValues
  }
}
