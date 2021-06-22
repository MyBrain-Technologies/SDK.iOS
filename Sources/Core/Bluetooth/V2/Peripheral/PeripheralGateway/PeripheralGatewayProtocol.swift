import Foundation
import CoreBluetooth

//protocol MBTPeripheralState { }
//
//enum Indus2And3PeripheralState: MBTPeripheralState {
//  case characteristicDiscovering
//  case pairing
//  case deviceInformationDiscovering
//  case a2dpRequesting
//  case ready
//}

protocol PeripheralGatewayProtocol: AnyObject {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  var delegate: PeripheralDelegate? { get set }

  var isReady: Bool { get }
//  var peripheralState: MBTPeripheralState { get }

  #warning("Use interface to hide it.")
  var peripheralCommunicator: PeripheralCommunicable? { get }

//  var peripheralValueReceiver: PeripheralValueReceiverProtocol { get }

  var information: DeviceInformation? { get }

//  var characteristicDiscoverer: CharacteristicDiscoverer { get }

  var allIndusServiceCBUUIDs: [CBUUID] { get }

  var deviceInformationBuilder: DeviceInformationBuilder { get }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(peripheral: CBPeripheral)

  //----------------------------------------------------------------------------
  // MARK: - Device information
  //----------------------------------------------------------------------------

  func setQRCode(_ qrCode: String)

  //----------------------------------------------------------------------------
  // MARK: - Discoverer
  //----------------------------------------------------------------------------

  func discover(characteristic: CBCharacteristic)

  //----------------------------------------------------------------------------
  // MARK: - Gateway
  //----------------------------------------------------------------------------

  func handleValueUpdate(for characteristic: CBCharacteristic, error: Error?)

  func handleNotificationStateUpdate(for characteristic: CBCharacteristic,
                                     error: Error?)

  func handleValueWrite(for characteristic: CBCharacteristic, error: Error?)

}
