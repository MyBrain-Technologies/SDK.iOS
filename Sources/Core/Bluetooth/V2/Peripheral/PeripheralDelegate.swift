import Foundation

protocol PeripheralDelegate: AnyObject {
  func didValueUpdate(batteryLevel: Int)
  func didValueUpdate(brainData: Data)
  func didValueUpdate(imsData: Data)
  func didValueUpdate(saturationStatus: Int)

  func didUpdate(sampleBufferSizeFromMtu: Int)

  func didRequestA2DPConnection()
  func didA2DPConnect()
  func didA2DPDisconnect(error: Error?)

  func didConnect()

  func didConnect(deviceInformation: DeviceInformation)

  func didFail(error: Error)
}
