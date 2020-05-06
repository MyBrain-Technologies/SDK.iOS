import Foundation
import CoreBluetooth

/*******************************************************************************
 * MBTDeviceAcquisitionManager
 *
 * Manage Acquisition data from the MBT device connected.
 * Such as EEG, device info, battery level ...
 *
 ******************************************************************************/
internal class MBTDeviceAcquisitionManager: NSObject {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// Singleton declaration
  static let shared = MBTDeviceAcquisitionManager()

  /// The MBTBluetooth Event Delegate.
  weak var delegate: MBTDeviceAcquisitionDelegate?

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /// Process the Device Information data
  /// - Parameter data : *Data* received from Device info MBT Headset.
  func processDeviceInformations(_ characteristic: CBCharacteristic) {
    let data = characteristic.value!
    let count = 8
    var bytesArray = [UInt8](repeating: 0, count: count)
    (data as NSData).getBytes(&bytesArray,
                              length: count * MemoryLayout<UInt8>.size)

    guard let dataString = String(data: data, encoding: .ascii) else {
      return
    }

    // Init a MBTDevice instance with the connected headset
    let deviceInfos = MBTDeviceInformations()

    switch CBUUID(data: characteristic.uuid.data) {
    case BluetoothService.productName.uuid:
      deviceInfos.productName = dataString
    case BluetoothService.serialNumber.uuid:
      deviceInfos.deviceId = dataString
    case BluetoothService.hardwareRevision.uuid:
      deviceInfos.hardwareVersion = dataString
    case BluetoothService.firmwareRevision.uuid:
      deviceInfos.firmwareVersion = dataString
    default:
      return
    }

    // Saving the new connected device in the DB.
    DeviceManager.updateDeviceInformations(deviceInfos)
  }

  /// Process the BatteryLevel data
  /// - Parameter data : *Data* received from Device info MBT Headset.
  func processDeviceBatteryStatus(_ characteristic: CBCharacteristic) {
    if characteristic.value != nil && DeviceManager.getCurrentDevice() != nil {
      let tabByte = [UInt8](characteristic.value!)
      if tabByte.count > 0 {
        let batteryLevel = Int(tabByte[0])
        DeviceManager.updateDeviceBatteryLevel(batteryLevel)
        delegate?.onReceivingBatteryLevel?(batteryLevel)
      }
    }
  }

  /// Process the headset status : OffSet or Saturation
  ///
  /// - Parameter characteristic:A *Data* received from status info Melomind.
  func processHeadsetStatus(_ characteristic: CBCharacteristic) {
    guard let value = characteristic.value else { return }

    let tabByte = [UInt8](value)

    guard tabByte[0] == 1 else { return }

    DispatchQueue.main.async { [weak self] in
      self?.delegate?.onReceivingSaturationStatus?(Int(tabByte[1]))
    }
  }

}
