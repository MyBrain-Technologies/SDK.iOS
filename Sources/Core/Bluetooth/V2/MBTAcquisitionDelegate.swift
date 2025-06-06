import Foundation

public protocol MBTAcquisitionDelegate: AnyObject {
  func didUpdateBatteryLevel(_ batteryLevel: Float)

  /// Called when
  ///
  /// - Parameter status: A *Int* of the saturation headset
  /// - Remarks:
  /// 0 -> no saturation,
  /// 1 -> left side saturation,
  /// 2 -> right side Saturation
  /// 3 -> both side Saturation
  func didUpdateSaturationStatus(_ status: Int)

  /// Called to each EEG package sent by the BLE.
  /// - Parameter dataArray: *Dictionnary* of EEG data array.
  func didUpdateEEGData(_ eegPacket: MBTEEGPacket)

  func didUpdateEEGRawData(_ data: Data)

  func didUpdateImsData(_ imsPacket: MbtImsPacket)
}

extension MBTAcquisitionDelegate {

  func didUpdateBatteryLevel(_ batteryLevel: Float) { }

  func didUpdateSaturationStatus(_ status: Int) { }

  func didUpdateEEGData(_ eegPacket: MBTEEGPacket) { }

  func didUpdateEEGRawData(_ data: Data) { }

  func didUpdateImsData(_ imsPacket: MbtImsPacket) { }

}
