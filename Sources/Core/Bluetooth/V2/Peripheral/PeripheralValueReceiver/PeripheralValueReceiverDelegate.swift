import Foundation

protocol PeripheralValueReceiverDelegate: AnyObject {
  func didUpdate(batteryLevel: Int)
  func didUpdate(brainData: Data)
  func didUpdate(saturationStatus: Int)

  func didUpdate(productName: String)
  func didUpdate(serialNumber: String)
  func didUpdate(firmwareVersion: String)
  func didUpdate(hardwareVersion: String)

  func didA2DPConnectionRequestSucceed()

  func didRequestPairing()
  func didPair()

  func didFail(with error: Error)
}
