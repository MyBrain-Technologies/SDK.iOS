import Foundation

public protocol MBTBLEBluetoothDelegate: AnyObject {

  /// Called when the bluetooth state change
  ///
  /// - Parameter isBluetoothOn: A *Bool* Value which is true if the bluetooth
  /// device is PowerOn and false if is PowerOff
  func didBluetoothStateChange(isBluetoothOn: Bool)

  /// Called when the headset has been connected after the services and
  /// characteristics exploration.
  func didConnect()

  func didConnect(deviceInformation: DeviceInformation)

  /// Called if the SDK can't connect to the MBT Headset,
  /// with the error.
  /// - Parameter error: A *Error* object which describe the cause of the
  /// failure (Core Bluetooth error) during the connection.
  func didConnectionFail(error: Error?) // func onConnectionFailed(_ error: Error?)


  /// Called when the headset lost connection.
  /// - Parameter error: A *Error* object which describe the cause of the
  /// deconnection, can be a core Bluetooth error or MBT error.
  func didDisconnect(error: Error?)

}

public extension MBTBLEBluetoothDelegate {

  func didBluetoothStateChange(isBluetoothOn: Bool) {}

  func didConnect() {}

  func didConnect(deviceInformation: DeviceInformation) { }

  func didConnectionFail(error: Error?) {}

  func didDisconnect(error: Error?) {}

}
