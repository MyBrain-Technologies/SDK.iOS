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
