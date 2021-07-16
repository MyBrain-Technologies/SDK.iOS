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

  var isReady: Bool { get }

  /******************** Information ********************/

  var information: DeviceInformation? { get }

  var deviceInformationBuilder: DeviceInformationBuilder { get }

  /******************** Delegate ********************/

  var delegate: PeripheralDelegate? { get set }

  /******************** A2dp ********************/

  var isA2dpConnected: Bool { get }

  var ad2pName: String? { get }

  #warning("Use interface to hide it.")
  var peripheralCommunicator: PeripheralCommunicable? { get }

//  var peripheralValueReceiver: PeripheralValueReceiverProtocol { get }

  var allIndusServiceCBUUIDs: [CBUUID] { get }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(peripheral: CBPeripheral)

  //----------------------------------------------------------------------------
  // MARK: - Discoverer
  //----------------------------------------------------------------------------

  func discover(characteristic: CBCharacteristic)

  //----------------------------------------------------------------------------
  // MARK: - Commands
  //----------------------------------------------------------------------------

  func requestBatteryLevel()

  //----------------------------------------------------------------------------
  // MARK: - Gateway
  //----------------------------------------------------------------------------

  func handleValueUpdate(for characteristic: CBCharacteristic, error: Error?)

  func handleNotificationStateUpdate(for characteristic: CBCharacteristic,
                                     error: Error?)

  func handleValueWrite(for characteristic: CBCharacteristic, error: Error?)

}
