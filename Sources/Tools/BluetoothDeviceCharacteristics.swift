import CoreBluetooth

/*******************************************************************************
 * MBTBluetoothLEHelper
 *
 * Help MBTBluetoothManager to manage Bluetooth Low Energy ( BLE ).
 *
 ******************************************************************************/
struct BluetoothDeviceCharacteristics {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  static var shared = BluetoothDeviceCharacteristics()

  /******************** Device characteristics ********************/

  var deviceInformations = [CBCharacteristic]()

  /// The *characteristic* of the Measurement service.
  var brainActivityMeasurement: CBCharacteristic!

  /// The Device state characteristic of the myBrain service.
  var deviceState: CBCharacteristic!

  /// The *characteristic* of the Headset Status
  var headsetStatus: CBCharacteristic!

  /// The *characteristic* of the mail box
  var mailBox: CBCharacteristic!

  /// The *characteristic* of the OAD transfert
  var oadTransfert: CBCharacteristic!

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  private init() {}

  //----------------------------------------------------------------------------
  // MARK: - Update
  //----------------------------------------------------------------------------

  mutating func update(with characteristics: [CBCharacteristic]) {
    for serviceCharacteristic in characteristics {
      let characteristic = serviceCharacteristic as CBCharacteristic
      BluetoothDeviceCharacteristics.shared.update(with: characteristic)
    }
  }

  mutating func update(with characteristic: CBCharacteristic) {
    guard let service = BluetoothService(uuid: characteristic.uuid) else {
      return
    }

    switch service {
    case .brainActivityMeasurement: brainActivityMeasurement = characteristic
    case .deviceBatteryStatus: deviceState = characteristic
    case .headsetStatus: headsetStatus = characteristic
    case .mailBox: mailBox = characteristic
    case .oadTransfert: oadTransfert = characteristic
    default:
      let deviceCharacteristics = BluetoothService.deviceCharacteristics.uuids
      if deviceCharacteristics.contains(characteristic.uuid) {
        deviceInformations.append(characteristic)
      }
    }
  }
}
