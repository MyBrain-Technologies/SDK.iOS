import Foundation

public struct DeviceAcquisitionInformation: Equatable, Codable {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  public let channelCount: Int

  /// The rate at which EEG data is being sent by the headset.
  public let sampleRate: Int

  /// An EEG Packet length.
  public let eegPacketSize: Int

  public let eegPacketMaxSize: Int

  /// Sample rate of the ims
  public let imsSampleRate: Int

  public let imsPacketMaxSize: Int

  public let imsAxisCount: Int

  public let electrodes: Electrodes

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(from indusVersion: IndusVersion) {
    let sampleByteSize = 2 // sample size
    switch indusVersion {
      case .indus2, .indus3:
        self.channelCount = 2
        self.sampleRate = 250
        self.eegPacketSize = 250
        self.eegPacketMaxSize = eegPacketSize * channelCount * sampleByteSize
        self.imsSampleRate = 100
        self.imsAxisCount = 3
        self.imsPacketMaxSize = imsSampleRate * imsAxisCount
        self.electrodes = Electrodes(acquisitions: [.p3, .p4],
                                     references: [.m1],
                                     grounds: [.m2])

      case .indus5:
        self.channelCount = 4
        self.sampleRate = 250
        self.eegPacketSize = 250
        self.eegPacketMaxSize = eegPacketSize * channelCount * sampleByteSize
        self.imsSampleRate = 100
        self.imsAxisCount = 3
        self.imsPacketMaxSize = imsSampleRate * imsAxisCount
        #warning("TODO: Check channel order")
        self.electrodes = Electrodes(acquisitions: [.p3, .p4, .af3, .af4],
                                     references: [.m1],
                                     grounds: [.m2])
        #warning("TODO: Use this instead?")
        // self.channelCount = electrodes.acquisitions.count
    }
  }

}
