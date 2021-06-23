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
    return
//    assertionFailure("A2DP connection is not available for post indus 5.")
  }

  //----------------------------------------------------------------------------
  // MARK: - Read
  //----------------------------------------------------------------------------

  func readDeviceState() {
    let bytes = [MailboxCommand.batteryLevel.rawValue]
    sendMailBoxCommand(bytes: bytes)
  }

  func readDeviceInformation() {
    let deviceIdBytes = [MailboxCommand.deviceId.rawValue]
    let serialNumberBytes = [MailboxCommand.serialNumber.rawValue]
    let hardwareVersionBytes = [MailboxCommand.hardwareVersion.rawValue]
    let firmewareVersionBytes = [MailboxCommand.firmewareVersion.rawValue]
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

  #warning("CHECK. Seem to override product name")
  func write(a2dpName: String) {
    let serialNumberByteArray: [UInt8] = [
      MailboxCommand.setA2dpName.rawValue,
      0xAB,
      0x21
    ]
    let deviceName = serialNumberByteArray + [UInt8](a2dpName.utf8)
    sendMailBoxCommand(bytes: deviceName)
  }

  func write(deviceExternalName name: String) {
    #warning("Is a2dpName?")
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

  func write(mtuSize: UInt8) {
    let bytes = [
      MailboxCommand.mtuSize.rawValue,
      0x47
    ]
    sendMailBoxCommand(bytes: bytes)
  }

  //----------------------------------------------------------------------------
  // MARK: - Notify
  //----------------------------------------------------------------------------

  func notifyMailBox(value: Bool) {
    peripheral.setNotifyValue(
      value,
      for: characteristicContainer.rx
    )
  }

  func notifyBrainActivityMeasurement(value: Bool) {
    let bytes = value == true ?
      [MailboxCommand.startEeg.rawValue]
    : [MailboxCommand.stopEeg.rawValue]
    sendMailBoxCommand(bytes: bytes)
  }

  func notifyHeadsetStatus(value: Bool) {
    /// Not used for post indus5
  }

}
