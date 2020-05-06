import Foundation

/*******************************************************************************
 * MBTBluetoothEventDelegate
 *
 * Event handler of the MBT Headset.
 *
 ******************************************************************************/
@objc public protocol MBTBluetoothEventDelegate:class {

  /// Called when the bluetooth state change
  ///
  /// - Parameter isBluetoothOn: A *Bool* Value which is true if the bluetooth device is PowerOn and false if is PowerOff
  @objc optional func onBluetoothStateChange(_ isBluetoothOn:Bool)

  /// Called when the headset has been connected
  /// before the services and characteristics exploration.
  @objc optional func onConnectionEstablished()

  /// Called each time the BLE status change.
  /// With a *Bool* informing if headset is connected or not
  /// to the iDevice.
  /// - Parameter isConnected : A *Bool* Value which is true if Melomind is connected in BLE and false if not.
  @objc optional func onHeadsetStatusUpdate(_ isConnected:Bool)

  /// Called if the SDK can't connect to the MBT Headset,
  /// with the error.
  /// - Parameter error : A *Error* object which describe the cause of the failure (Core Bluetooth error) during the connection.
  @objc optional func onConnectionFailed(_ error: Error?)

  /// Called when the headset lost connection.
  /// - Parameter error : A *Error* object which describe the cause of the deconnection, can be a core Bluetooth error or MyBrainTechnologiesSDK error.
  @objc optional func onConnectionBLEOff(_ error: Error?)

  /// Called when initiate timerUpdateBatteryLevel
  /// returns -> schedules timerUpdateBatteryLevel with this timeInterval
  @objc optional func timeIntervalOnReceiveBattery() -> TimeInterval

  /// Called after the connection in BLE of the Melomind if the Melomind need to be up date
  @objc optional func onNeedToUpdate()

  /// Called when respond from the Melomind that it is ready to receive the binary
  @objc optional func onReadyToUpdate()

  /// Called for each Step of the update and during the sending
  ///
  /// - Parameter progress: A *Float* Value between 0 and 1 which represents the advance of the update
  @objc optional func onProgressUpdate(_ progress:Float)

  /// Called if the MyBrainTechnologie need the update of the Bluetooth Device
  @objc optional func requireToRebootBluetooth()

  /// Called if the Bluetooth Device reboot
  @objc optional func onRebootBluetooth()

  /// Called if the Update Finish
  @objc optional func onUpdateComplete()

  /// Called When the Update process fail
  ///
  /// - Parameter status: *Int* give status fail
  /// 0 : CurrentVersion > Latest Bin Version
  /// 1 : OTA_MODE_EVT FAIL (0)
  /// 2 : OTA_STATUS_EVT FAIL (0)
  /// 3 : After Melomind Reboot, Latest Bin Version > CurrentVersion
  @objc optional func onUpdateFailWithError (_ error: Error)
}
