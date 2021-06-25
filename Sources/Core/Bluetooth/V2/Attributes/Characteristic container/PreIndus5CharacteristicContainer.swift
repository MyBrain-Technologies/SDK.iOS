import Foundation
import CoreBluetooth

struct PreIndus5CharacteristicContainer {

  var productName: CBCharacteristic

  var serialNumber: CBCharacteristic

  var hardwareRevision: CBCharacteristic

  var firmwareRevision: CBCharacteristic

  /// The *characteristic* of the Measurement service.
  var brainActivityMeasurement: CBCharacteristic

  /// The Device state characteristic of the myBrain service.
  var deviceState: CBCharacteristic

  /// The *characteristic* of the Headset Status
  var headsetStatus: CBCharacteristic

  /// The *characteristic* of the mail box
  var mailBox: CBCharacteristic

  /// The *characteristic* of the OAD transfert
  var oadTransfert: CBCharacteristic

  var deviceInformations: [CBCharacteristic] {
    return [
      productName,
      serialNumber,
      hardwareRevision,
      firmwareRevision
    ]
  }

}
