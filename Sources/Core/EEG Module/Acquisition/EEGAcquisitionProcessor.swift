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
                                  hasQualityChecker: Bool) -> MBTEEGPacket {
    var eegPacket = MBTEEGPacket(channelsValues: values)
    if hasQualityChecker {
      eegPacket = addQualities(to: eegPacket)
      eegPacket = addModifiedValues(to: eegPacket)
    }
    return eegPacket
  }

  /// Add qualities from signal processing to an eeg packet
  private func addQualities(to eegPacket: MBTEEGPacket) -> MBTEEGPacket {
    #warning("TODO: Check")
    var buffer = Buffer()
    for channelData in eegPacket.channelsData {
      let dataArray = Array(channelData.values)
      buffer.append(dataArray)
    }

    let qualities =
      signalProcessor.computeQualityValue(buffer,
                                          sampleRate: sampletRate,
                                          eegPacketLength: eegPacketLength)
    eegPacket.addQualities(qualities)
    return eegPacket
  }

  /// Add EEG modified values from signal progression to an eeg packet
  private func addModifiedValues(to eegPacket: MBTEEGPacket) -> MBTEEGPacket {

    let correctedValues = signalProcessor.getModifiedEEGValues()

    eegPacket.setModifiedChannelsData(correctedValues,
                                      sampRate: sampletRate)
    return eegPacket
  }
}



class EEGAcquisitionProcessorV2 {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private let acquisitionBuffer: EEGAcquisitionBuffer

  private let eegPacketLength: Int

  private let channelCount: Int

  private let sampletRate: Int

  /******************** Dependency Injections ********************/

  private let signalProcessor: SignalProcessingManager

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(bufferSizeMax: Int,
       packetLength: Int,
       channelCount: Int,
       sampleRate: Int,
       signalProcessor: SignalProcessingManager) {
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
                                  hasQualityChecker: Bool) -> MBTEEGPacket {
    var eegPacket = MBTEEGPacket(channelsValues: values)
    if hasQualityChecker {
      eegPacket = addQualities(to: eegPacket)
      eegPacket = addModifiedValues(to: eegPacket)
    }
    return eegPacket
  }

  /// Add qualities from signal processing to an eeg packet
  private func addQualities(to eegPacket: MBTEEGPacket) -> MBTEEGPacket {
    #warning("TODO: Check")
    var buffer = Buffer()
    for channelData in eegPacket.channelsData {
      let dataArray = Array(channelData.values)
      buffer.append(dataArray)
    }

    let qualities =
      signalProcessor.computeQualityValue(buffer,
                                          sampleRate: sampletRate,
                                          eegPacketLength: eegPacketLength)
    eegPacket.addQualities(qualities)
    return eegPacket
  }

  /// Add EEG modified values from signal progression to an eeg packet
  private func addModifiedValues(to eegPacket: MBTEEGPacket) -> MBTEEGPacket {

    let correctedValues = signalProcessor.getModifiedEEGValues()

    eegPacket.setModifiedChannelsData(correctedValues,
                                      sampRate: sampletRate)
    return eegPacket
  }
}
