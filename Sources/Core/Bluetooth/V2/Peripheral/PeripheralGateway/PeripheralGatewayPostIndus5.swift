import Foundation
import CoreBluetooth

class PeripheralGatewayPostIndus5: PeripheralGatewayProtocol {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Peripheral ********************/

  private let peripheral: CBPeripheral

  /******************** State ********************/

  enum IndusPost5PeripheralState {
    case characteristicDiscovering
    case pairing
    case deviceInformationDiscovering
    case mtuSizeRequesting
    case ready
  }

  private var state = IndusPost5PeripheralState.characteristicDiscovering {
    didSet {
      if state == .ready {
        handleStateIsReady()
      }
    }
  }

  var isReady: Bool {
    return state == .ready
  }

  /******************** PeripheralGatewayProtocol ********************/

  private let peripheralValueReceiver = PostIndus5PeripheralValueReceiver()

  private(set) var peripheralCommunicator: PeripheralCommunicable?

  private(set) var information: DeviceInformation? {
    didSet {
      guard let information = information else { return }
      delegate?.didConnect(deviceInformation: information)
    }
  }

  private let characteristicDiscoverer = CharacteristicDiscoverer()

  var allIndusServiceCBUUIDs: [CBUUID] {
    return MBTService.PostIndus5.allCases.uuids
  }

  let deviceInformationBuilder = DeviceInformationBuilder()

  /******************** Delegate ********************/

  weak var delegate: PeripheralDelegate?

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  required init(peripheral: CBPeripheral) {
    self.peripheral = peripheral
    setup()
  }

  private func setup() {
    setupCharacteristicsDiscoverer()
    setupDeviceInformationBuilder()
    setupPeripheralValueReceiver()
  }

  private func setupCharacteristicsDiscoverer() {
    characteristicDiscoverer.didDiscoverAllPostIndus5Characteristics = {
      [weak self] characteristicContainer in
      guard let self = self else { return }

      #warning("TODO: characteristicDiscoverer one callback giving peripheralCommunicator")
      self.peripheralCommunicator = PostIndus5PeripheralCommunicator(
        peripheral: self.peripheral,
        characteristicContainer: characteristicContainer
      )

      self.state = .pairing

      self.peripheralCommunicator?.requestPairing()
      // Continue after notification activated
    }
  }

  private func setupDeviceInformationBuilder() {
    deviceInformationBuilder.didBuild = { [weak self] deviceInformation in
      self?.information = deviceInformation

      if let information = self?.information { print(information) }

      self?.state = .mtuSizeRequesting
//      guard let mtuSize = UInt8(exactly: 47) else { return }
      self?.peripheralCommunicator?.write(mtuSize: 0x2F)
    }

    deviceInformationBuilder.didFail = { [weak self] error in
      // TODO Handle error
    }
  }

  private func setupPeripheralValueReceiver() {
    peripheralValueReceiver.delegate = self
  }

  //----------------------------------------------------------------------------
  // MARK: - State
  //----------------------------------------------------------------------------

  private func handleStateIsReady() {
    //      self?.peripheralCommunicator?.write(serialNumber: "2010100001")
    //      self?.peripheralCommunicator?.write(a2dpName: "MM2B200007")
  }

  //----------------------------------------------------------------------------
  // MARK: - Discoverer
  //----------------------------------------------------------------------------

  func discover(characteristic: CBCharacteristic) {
    characteristicDiscoverer.discover(characteristic: characteristic)
  }

  //----------------------------------------------------------------------------
  // MARK: - Commands
  //----------------------------------------------------------------------------

  func requestBatteryLevel() {
    guard state == .ready else { return }
    peripheralCommunicator?.readDeviceState()
  }

  //----------------------------------------------------------------------------
  // MARK: - Gateway
  //----------------------------------------------------------------------------

  func handleValueUpdate(for characteristic: CBCharacteristic, error: Error?) {
    peripheralValueReceiver.handleValueUpdate(for: characteristic, error: error)
  }

  func handleNotificationStateUpdate(for characteristic: CBCharacteristic,
                                     error: Error?) {
    peripheralValueReceiver.handleNotificationStateUpdate(for: characteristic,
                                                          error: error)
  }

  func handleValueWrite(for characteristic: CBCharacteristic,
                        error: Error?) {
    peripheralValueReceiver.handleValueWrite(for: characteristic, error: error)


  }

}

//==============================================================================
// MARK: - PeripheralValueReceiverDelegate
//==============================================================================

extension PeripheralGatewayPostIndus5: PeripheralValueReceiverDelegate {

  // START: Move to extension for default implementation

  func didUpdate(batteryLevel: Int) {
    print(batteryLevel)
//    didUpdateBatteryLevel?(batteryLevel)
    delegate?.didValueUpdate(BatteryLevel: batteryLevel)
  }

  func didUpdate(brainData: Data) {
    print(brainData)
//    didUpdateBrainData?(brainData)
    delegate?.didValueUpdate(BrainData: brainData)
  }

  func didUpdate(saturationStatus: Int) {
    print(saturationStatus)
//    didUpdateSaturationStatus?(saturationStatus)
    delegate?.didValueUpdate(SaturationStatus: saturationStatus)
  }

  // END: Move to extension for default implementation

  func didUpdate(productName: String) {
    guard state == .deviceInformationDiscovering else { return }
    deviceInformationBuilder.add(productName: productName)
  }

  func didUpdate(serialNumber: String) {
    guard state == .deviceInformationDiscovering else { return }
    deviceInformationBuilder.add(deviceId: serialNumber)
  }

  func didUpdate(firmwareVersion: String) {
    guard state == .deviceInformationDiscovering else { return }
    deviceInformationBuilder.add(firmwareVersion: firmwareVersion)
  }

  func didUpdate(hardwareVersion: String) {
    guard state == .deviceInformationDiscovering else { return }
    deviceInformationBuilder.add(hardwareVersion: hardwareVersion)
  }

  func didUpdate(mtuSize: Int) {
    state = .ready
  }

  func didRequestPairing() {
    log.verbose("Did resquest pairing")
    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
      self.peripheralCommunicator?.requestPairing()
    }
  }

  func didPair() {
    #warning("Move to Gateway level")
    state = .deviceInformationDiscovering
    peripheralCommunicator?.readDeviceInformation()
  }

  func didA2DPConnectionRequestSucceed() {
    print("Move to MBTPeripheral")
//    guard let information = information else { return }
//    let serialNumber = information.productName
//    let isA2dpConnected =
//      a2dpConnector.isConnected(currentDeviceSerialNumber: serialNumber)
//    guard isA2dpConnected else { return }
//    delegate?.didA2DPConnect()
  }

  func didFail(with error: Error) {
    print(error.localizedDescription)
  }

}
