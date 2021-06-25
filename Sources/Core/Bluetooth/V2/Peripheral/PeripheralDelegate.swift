import Foundation

protocol PeripheralDelegate: AnyObject {

  func didValueUpdate(BrainData: Data)
  func didValueUpdate(BatteryLevel: Int)
  func didValueUpdate(SaturationStatus: Int)

  func didRequestA2DPConnection()
  func didA2DPConnect()
  func didA2DPDisconnect(error: Error?)

  func didConnect()

  func didConnect(deviceInformation: DeviceInformation)

  func didFail(error: Error)
  
}
