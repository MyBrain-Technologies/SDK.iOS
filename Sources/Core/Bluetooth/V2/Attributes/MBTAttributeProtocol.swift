import Foundation
import CoreBluetooth

protocol MBTAttributeProtocol {
  var uuid: CBUUID { get }
  init?(uuid: CBUUID)
}

extension Array where Element: MBTAttributeProtocol {
  /// Return BluetoothServices uuids values
  var uuids: [CBUUID] {
    self.map({ $0.uuid })
  }
}

protocol MBTCharacteristicProtocol: MBTAttributeProtocol {
  static var readCharacteristics: [Self] { get }
  static var writeCharacteristics: [Self] { get }
}
