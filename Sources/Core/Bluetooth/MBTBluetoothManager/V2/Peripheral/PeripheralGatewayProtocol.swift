import Foundation
import CoreBluetooth

protocol PeripheralGatewayProtocol: AnyObject {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  var delegate: PeripheralValueDelegate? { get set }

//  var peripheralState: MBTPeripheralState { get }

  var peripheralCommunicator: PeripheralCommunicable? { get }

  var peripheralValueReceiver: PeripheralValueReceiverProtocol { get }

  var information: DeviceInformation? { get }

  var characteristicDiscoverer: CharacteristicDiscoverer { get }

  var allIndusServiceCBUUIDs: [CBUUID] { get }

  var deviceInformationBuilder: DeviceInformationBuilder { get }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(peripheral: CBPeripheral)

}
