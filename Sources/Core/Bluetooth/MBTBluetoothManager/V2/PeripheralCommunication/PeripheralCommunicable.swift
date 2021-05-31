import Foundation

protocol PeripheralCommunicable {

  //----------------------------------------------------------------------------
  // MARK: - Connections
  //----------------------------------------------------------------------------

  func requestPairing()

  func requestConnectA2DP()

  //----------------------------------------------------------------------------
  // MARK: - Read
  //----------------------------------------------------------------------------

  func readDeviceState()

  func readDeviceInformation()

  //----------------------------------------------------------------------------
  // MARK: - Write
  //----------------------------------------------------------------------------

  func write(deviceExternalName name: String)

  func write(firmwareVersion: [UInt8], numberOfBlocks: Int16)

  func writeA2DPConnection()

  func write(oadBuffer: [UInt8])

  //----------------------------------------------------------------------------
  // MARK: - Notify
  //----------------------------------------------------------------------------

  func notifyMailBox(value: Bool)

  func notifyBrainActivityMeasurement(value: Bool)

  func notifyHeadsetStatus(value: Bool)

}
