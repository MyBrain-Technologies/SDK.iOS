import Foundation
import CoreBluetooth

class PostIndus5PeripheralCommunicator: PeripheralCommunicable {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Peripheral ********************/

  private let peripheral: CBPeripheral

  private let characteristicContainer: PostIndus5CharacteristicContainer

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  required init(peripheral: CBPeripheral,
                characteristicContainer: PostIndus5CharacteristicContainer) {
    self.peripheral = peripheral
    self.characteristicContainer = characteristicContainer
  }

  //----------------------------------------------------------------------------
  // MARK: - Read
  //----------------------------------------------------------------------------

  func readDeviceState() {
    #warning("TODO")
    assertionFailure()
  }

  func readDeviceInformation() {
    #warning("TODO")
    assertionFailure()
  }

  //----------------------------------------------------------------------------
  // MARK: - Write
  //----------------------------------------------------------------------------

  func write(deviceExternalName name: String) {
    #warning("TODO")
    assertionFailure()
  }

  func write(firmwareVersion: [UInt8], numberOfBlocks: Int16) {
    #warning("TODO")
    assertionFailure()
  }

  func writeA2DPConnection() {
    #warning("TODO")
    assertionFailure()
  }

  func write(oadBuffer: [UInt8]) {
    #warning("TODO")
    assertionFailure()
  }

  //----------------------------------------------------------------------------
  // MARK: - Notify
  //----------------------------------------------------------------------------

  func notifyMailBox(value: Bool) {
    #warning("TODO")
    assertionFailure()
  }

  func notifyBrainActivityMeasurement(value: Bool) {
    #warning("TODO")
    assertionFailure()
  }

  func notifyHeadsetStatus(value: Bool) {
    #warning("TODO")
    assertionFailure()
  }

}
