import Foundation

public protocol MBTA2DPBluetoothDelegate: class {

  /// Called when the MBT Headset audio A2DP get connected.
  func didAudioA2DPConnect()

  /// Called when the MBT Headset audio A2DP lost connection.
  func didAudioA2DPDisconnect(error: Error?)

}

public extension MBTA2DPBluetoothDelegate {

  func didAudioA2DPConnect() {}

  func didAudioA2DPDisconnect(error: Error?) {}

}
