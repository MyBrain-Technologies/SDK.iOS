import CoreBluetooth

/*******************************************************************************
 * MBTBluetoothLEHelper
 *
 * Help MBTBluetoothManager to manage Bluetooth Low Energy ( BLE ).
 *
 ******************************************************************************/
struct MBTBluetoothLEHelper {
  static var deviceInfoCharacteristic = [CBCharacteristic]()

  /// The *characteristic* of the Measurement service.
  static var brainActivityMeasurementCharacteristic: CBCharacteristic!

  /// The Device state characteristic of the myBrain service.
  static var deviceStateCharacteristic: CBCharacteristic!

  /// The *characteristic* of the Headset Status
  static var headsetStatusCharacteristic: CBCharacteristic!

  /// The *characteristic* of the mail box
  static var mailBoxCharacteristic: CBCharacteristic!

  /// The *characteristic* of the OAD transfert
  static var oadTransfertCharacteristic: CBCharacteristic!

  //----------------------------------------------------------------------------
  // MARK: - Bluetooth Low Energy Methods
  //----------------------------------------------------------------------------

  /// Getter of Bluetooth LE Services UUIDs.
  /// - Returns : *Array* of BLE services UUIDs.
  static func getServicesUUIDs() -> [CBUUID] {
    return [BluetoothService.myBrainService.uuid,
            BluetoothService.deviceInfoService.uuid]
  }

  /// Getter of BLE device informations characteristics UUIDs.
  /// - Returns : *Array* of device information characteristics UUIDs.
  static func getDeviceInfoCharacteristicsUUIDS() -> [CBUUID] {
    return [BluetoothService.productName.uuid,
            BluetoothService.serialNumber.uuid,
            BluetoothService.hardwareRevision.uuid,
            BluetoothService.firmwareRevision.uuid]
  }
}
