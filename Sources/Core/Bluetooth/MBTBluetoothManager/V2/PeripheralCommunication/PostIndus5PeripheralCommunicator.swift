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
  // MARK: - Communication
  //----------------------------------------------------------------------------

  private func sendMailBoxCommand(bytes: [UInt8], withResponse: Bool = true) {
    let type: CBCharacteristicWriteType =
      withResponse == true ? .withResponse : .withoutResponse
    let dataToWrite = Data(bytes)
    peripheral.writeValue(dataToWrite,
                          for: characteristicContainer.tx,
                          type: type)
  }

  //----------------------------------------------------------------------------
  // MARK: - Connection
  //----------------------------------------------------------------------------

  func requestPairing() {
    peripheral.setNotifyValue(
      true,
      for: characteristicContainer.rx
    )
  }

  func requestConnectA2DP() {
    assertionFailure("A2DP connection is not available for post indus 5.")
  }

  //----------------------------------------------------------------------------
  // MARK: - Read
  //----------------------------------------------------------------------------

  func readDeviceState() {
    let bytes = [MailBoxEvents.batteryLevel.rawValue]
    sendMailBoxCommand(bytes: bytes)
  }

  func readDeviceInformation() {
    let deviceIdBytes = [MailBoxEvents.deviceId.rawValue]
    let serialNumberBytes = [MailBoxEvents.serialNumber.rawValue]
    let hardwareVersionBytes = [MailBoxEvents.hardwareVersion.rawValue]
    let firmewareVersionBytes = [MailBoxEvents.firmewareVersion.rawValue]
    let deviceInformationBytes = [deviceIdBytes,
                                  serialNumberBytes,
                                  hardwareVersionBytes,
                                  firmewareVersionBytes]
    for singleDeviceInformationBytes in deviceInformationBytes {
      sendMailBoxCommand(bytes: singleDeviceInformationBytes)
    }
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
    let bytes = value == true ?
      [MailBoxEvents.startEeg.rawValue]
    : [MailBoxEvents.stopEeg.rawValue]
    sendMailBoxCommand(bytes: bytes)
  }

  func notifyHeadsetStatus(value: Bool) {
    #warning("TODO")
    assertionFailure()
  }

}
