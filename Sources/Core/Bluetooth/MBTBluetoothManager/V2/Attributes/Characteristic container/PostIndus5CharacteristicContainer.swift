import Foundation
import CoreBluetooth

struct PostIndus5CharacteristicContainer {

  var tx: CBCharacteristic

  var rx: CBCharacteristic

  /// The *characteristic* of the mail box
  var mailBox: CBCharacteristic

}
