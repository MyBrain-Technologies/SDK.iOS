import Foundation

public protocol MBTA2DPBluetoothDelegate: AnyObject {

  /// Called when the MBT Headset request an audio A2DP connection.
  func didRequestA2DPConnection()
  
  /// Called when the MBT Headset audio A2DP get connected.
  func didAudioA2DPConnect()

  /// Called when the MBT Headset audio A2DP lost connection.
  func didAudioA2DPDisconnect(error: Error?)

}

public extension MBTA2DPBluetoothDelegate {

  func didRequestA2DPConnection() {}

  func didAudioA2DPConnect() {}

  func didAudioA2DPDisconnect(error: Error?) {}

}
