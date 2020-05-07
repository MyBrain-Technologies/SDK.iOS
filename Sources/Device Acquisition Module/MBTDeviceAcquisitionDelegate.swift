import Foundation

/*******************************************************************************
 * MBTDeviceAcquisitionDelegate
 *
 * Manage the acquisition data communication outside the SDK.
 *
 ******************************************************************************/
@objc public protocol MBTDeviceAcquisitionDelegate: class {

  /// Called when receiving batteryLevel from BLE
  ///
  /// - Parameter battery level: *batteryLevel* received.
  @objc optional func onReceivingBatteryLevel(_ levelBattery: Int)

  /// Called when
  ///
  /// - Parameter status: A *Int* of the saturation headset
  /// - Remarks:
  /// 0 -> no saturation,
  /// 1 -> left side saturation,
  /// 2 -> right side Saturation
  /// 3 -> both side Saturation
  @objc optional func onReceivingSaturationStatus(_ status: Int)
}
