//
//  PeripheralGatewayPreIndus5.swift
//  MyBrainTechnologiesSDK
//
//  Created by Laurent on 22/06/2021.
//  Copyright © 2021 MyBrainTechnologies. All rights reserved.
//

import Foundation
import CoreBluetooth

class PeripheralGatewayPreIndus5: PeripheralGatewayProtocol {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Peripheral ********************/

  private let peripheral: CBPeripheral

  /******************** State ********************/

  enum Indus2And3PeripheralState {
    case characteristicDiscovering
    case pairing
    case deviceInformationDiscovering
    case a2dpRequesting
    case ready
  }

  private var state = Indus2And3PeripheralState.characteristicDiscovering

  var isReady: Bool {
    return state == .ready
  }

  /******************** PeripheralGatewayProtocol ********************/

  private let peripheralValueReceiver = PreIndus5PeripheralValueReceiver()

  private(set) var peripheralCommunicator: PeripheralCommunicable?

  private(set) var information: DeviceInformation? {
    didSet {
      guard let information = information else { return }
      delegate?.didConnect(deviceInformation: information)
    }
  }

  private let characteristicDiscoverer = CharacteristicDiscoverer()

  var allIndusServiceCBUUIDs: [CBUUID] {
    return MBTService.PreIndus5.allCases.uuids
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
    characteristicDiscoverer.didDiscoverAllPreIndus5Characteristics = {
      [weak self] characteristicContainer in
      guard let self = self else { return }

      #warning("TODO: characteristicDiscoverer one callback giving peripheralCommunicator")
      self.peripheralCommunicator = PreIndus5PeripheralCommunicator(
        peripheral: self.peripheral,
        characteristicContainer: characteristicContainer
      )

      self.state = .pairing
      self.peripheralCommunicator?.requestPairing()
    }
  }

  private func setupDeviceInformationBuilder() {
    deviceInformationBuilder.didBuild = { [weak self] deviceInformation in
      self?.information = deviceInformation

      if let information = self?.information {
        print(information)
      }

      self?.state = .a2dpRequesting
      self?.peripheralCommunicator?.requestConnectA2DP()
    }

    deviceInformationBuilder.didFail = { [weak self] error in
      // TODO Handle error
    }
  }

  private func setupPeripheralValueReceiver() {
    peripheralValueReceiver.delegate = self
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
    if state == .pairing {
      peripheralValueReceiver.handlePairingValudUpdate(for: characteristic,
                                                       error: error)
    } else {
      peripheralValueReceiver.handleValueUpdate(for: characteristic,
                                                error: error)
    }
  }

  func handleNotificationStateUpdate(for characteristic: CBCharacteristic,
                                     error: Error?) {
    peripheralValueReceiver.handleNotificationStateUpdate(for: characteristic,
                                                          error: error)
  }

  func handleValueWrite(for characteristic: CBCharacteristic,
                        error: Error?) {
    peripheralValueReceiver.handleValueWrite(for: characteristic, error: error)

    state = .ready
  }

}

//==============================================================================
// MARK: - PeripheralValueReceiverDelegate
//==============================================================================

extension PeripheralGatewayPreIndus5: PeripheralValueReceiverDelegate {

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

  func didUpdate(sampleBufferSizeFromMtu: Int) {
    assertionFailure("Mtu should not be changed in Melomind.")
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
