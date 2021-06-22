import Foundation
import CoreBluetooth

protocol PeripheralValueReceiverProtocol: AnyObject {

  var delegate: PeripheralValueReceiverDelegate? { get set }

  func handleValueUpdate(for characteristic: CBCharacteristic, error: Error?)

  func handleNotificationStateUpdate(for characteristic: CBCharacteristic,
                                     error: Error?)

  func handleValueWrite(for characteristic: CBCharacteristic, error: Error?)
}
