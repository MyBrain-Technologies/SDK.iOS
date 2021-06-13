import Foundation

public struct DeviceAcquisitionInformation: Codable {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  public let channelCount: Int

  /// The rate at which EEG data is being sent by the headset.
  public let sampleRate: Int

  /// An EEG Packet length.
  public let eegPacketSize: Int

  public let eegPacketMaxSize: Int

  let electrodes: Electrodes

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(from indusVersion: IndusVersion) {
    switch indusVersion {
      case .indus2, .indus3:
        self.channelCount = 2
        self.sampleRate = 250
        self.eegPacketSize = 250
        self.eegPacketMaxSize = eegPacketSize * channelCount * 2
        self.electrodes = Electrodes(acquisitions: [.p3, .p4],
                                     references: [.m1],
                                     grounds: [.m2])

      case .indus5:
        #warning("TODO: Use real indus5 version")
        fatalError("Use real indus5 version")
        self.channelCount = 2
        self.sampleRate = 250
        self.eegPacketSize = 250
        self.eegPacketMaxSize = eegPacketSize * channelCount * 2
        self.electrodes = Electrodes(acquisitions: [.p3, .p4],
                                     references: [.m1],
                                     grounds: [.m2])
    }
  }

}
