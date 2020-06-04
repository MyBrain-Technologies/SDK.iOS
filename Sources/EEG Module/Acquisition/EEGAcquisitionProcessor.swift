import Foundation

class EEGAcquisitionProcessor {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  let acquisitionBuffer: EEGAcquisitionBuffer

  let eegPacketLength: Int

  let nbChannels: Int

  let sampRate: Int

  /******************** Dependency Injections ********************/

  let signalProcessor: MBTSignalProcessingManager = .shared

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(bufferSizeMax: Int, packetLength: Int, nbChannels: Int, sampRate: Int) {
    self.acquisitionBuffer = EEGAcquisitionBuffer(bufferSizeMax: bufferSizeMax)
    self.eegPacketLength = packetLength
    self.nbChannels = nbChannels
    self.sampRate = sampRate
  }

  convenience init(device: MBTDevice) {
    self.init(bufferSizeMax: device.eegPacketLength * 2 * 2,
              packetLength: device.eegPacketLength,
              nbChannels: device.nbChannels,
              sampRate: device.sampRate)
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
                                              numberOfElectrodes: nbChannels)
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
      sampRate: sampRate,
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
                                      sampRate: sampRate)
    return eegPacket
  }
}
