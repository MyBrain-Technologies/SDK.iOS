import Foundation

public protocol MBTBluetoothAcquisitionDelegate: AnyObject {

  func didUpdateBatteryLevel(_ levelBattery: Float)

  /// Called when
  ///
  /// - Parameter status: A *Int* of the saturation headset
  /// - Remarks:
  /// 0 -> no saturation,
  /// 1 -> left side saturation,
  /// 2 -> right side Saturation
  /// 3 -> both side Saturation
  func didUpdateSaturationStatus(_ status: Int)

  func didUpdateEEGRawData(_ data: Data)

  func didUpdateImsData(_ data: Data)

}

public extension MBTBluetoothAcquisitionDelegate {

  func didUpdateBatteryLevel(_ levelBattery: Float) { }

  func didUpdateSaturationStatus(_ status: Int)  { }

  func didUpdateEEGRawData(_ data: Data) { }

}
