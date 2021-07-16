import Foundation

protocol PeripheralDelegate: AnyObject {

  #warning("TODO: Remove upercases")
  func didValueUpdate(brainData: Data)
  func didValueUpdate(batteryLevel: Int)
  func didValueUpdate(saturationStatus: Int)

  func didUpdate(sampleBufferSizeFromMtu: Int)

  func didRequestA2DPConnection()
  func didA2DPConnect()
  func didA2DPDisconnect(error: Error?)

  func didConnect()

  func didConnect(deviceInformation: DeviceInformation)

  func didFail(error: Error)
  
}
