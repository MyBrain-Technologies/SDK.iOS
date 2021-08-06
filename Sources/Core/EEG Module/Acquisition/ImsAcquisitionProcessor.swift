import Foundation

class ImsAcquisitionProcessor {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private let packetLength: Int

  private let channelCount: Int

  private let sampletRate: Int

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(packetLength: Int, channelCount: Int = 3, sampletRate: Int) {
    self.packetLength = packetLength
    self.channelCount = channelCount
    self.sampletRate = sampletRate
  }


  //----------------------------------------------------------------------------
  // MARK: - Processes
  //----------------------------------------------------------------------------

//  func generateEmsPacket(fromData data: Data) -> MbtImsPacket {
////    acquisitionBuffer.add(data: data)
////    guard let packet = acquisitionBuffer.getUsablePackets() else { return nil }
////
////    let relaxIndexes =
////      EEGDeserializer.deserializeToRelaxIndex(bytes: packet,
////                                              numberOfElectrodes: channelCount)
////    let eegPacket = convertToEEGPacket(values: relaxIndexes,
////                                       hasQualityChecker: hasQualityChecker)
////
////    return eegPacket
//  }


}
