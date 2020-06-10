import Foundation

/// Delegate to know if audio A2DP just connected or disconnected.
@objc public protocol MBTBluetoothA2DPDelegate: class {

  /// Called when the MBT Headset audio A2DP get connected.
  @objc optional func audioA2DPDidConnect()
  /// Called when the MBT Headset audio A2DP lost connection.
  @objc optional func audioA2DPDidDisconnect()

  /// Called to know if the Bluetooth Manager will try to connect A2DP from the BLE
  @objc optional func autoConnectionA2DPFromBLE() -> Bool
}
