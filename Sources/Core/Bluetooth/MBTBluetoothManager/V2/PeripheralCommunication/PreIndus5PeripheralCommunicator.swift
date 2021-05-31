import Foundation
import CoreBluetooth

class PreIndus5PeripheralCommunicator: PeripheralCommunicable {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Peripheral ********************/

  private let peripheral: CBPeripheral

  private let characteristicContainer: PreIndus5CharacteristicContainer

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  required init(peripheral: CBPeripheral,
                characteristicContainer: PreIndus5CharacteristicContainer) {
    self.peripheral = peripheral
    self.characteristicContainer = characteristicContainer
  }

  //----------------------------------------------------------------------------
  // MARK: - Connections
  //----------------------------------------------------------------------------

  func requestPairing() {
    readDeviceState()
  }

  func requestConnectA2DP() {
    #warning("TODO: Do this or cancel request")
    if characteristicContainer.mailBox.isNotifying {
      notifyMailBox(value: true)
    }

    writeA2DPConnection()
  }

  //----------------------------------------------------------------------------
  // MARK: - Read
  //----------------------------------------------------------------------------

  func readDeviceState() {
    peripheral.readValue(for: characteristicContainer.deviceState)
  }

  func readDeviceInformation() {
    let deviceInformations = characteristicContainer.deviceInformations
    deviceInformations.forEach() { peripheral.readValue(for: $0) }
  }

  //----------------------------------------------------------------------------
  // MARK: - Write
  //----------------------------------------------------------------------------

  func write(deviceExternalName name: String) {
    let serialNumberByteArray: [UInt8] = [
      MailBoxEvents.setSerialNumber.rawValue,
      0xAB,
      0x21
    ]
    let deviceName = serialNumberByteArray + [UInt8](name.utf8)

    let dataToWrite = Data(deviceName)
    peripheral.writeValue(dataToWrite,
                          for: characteristicContainer.mailBox,
                          type: .withResponse)
  }

  func write(firmwareVersion: [UInt8], numberOfBlocks: Int16) {
    var firmwareVersionConverted = [UInt8](repeating: 0, count: 5)

    firmwareVersionConverted[0] = MailBoxEvents.startOTATFX.rawValue
    firmwareVersionConverted[1] = firmwareVersion[0]
    firmwareVersionConverted[2] = firmwareVersion[1]
    firmwareVersionConverted[3] = numberOfBlocks.loUint8
    firmwareVersionConverted[4] = numberOfBlocks.hiUint16

    let dataToWrite = Data(firmwareVersionConverted)
    peripheral.writeValue(dataToWrite,
                          for: characteristicContainer.mailBox,
                          type: .withResponse)
  }

  func writeA2DPConnection() {
    let bytes: [UInt8] = [
      MailBoxEvents.a2dpConnection.rawValue,
      0x25,
      0xA2
    ]

    let dataToWrite = Data(bytes)
    peripheral.writeValue(dataToWrite,
                          for: characteristicContainer.mailBox,
                          type: .withResponse)
  }

  func write(oadBuffer: [UInt8]) {
    let oadBufferData = Data(oadBuffer)
    peripheral.writeValue(
      oadBufferData,
      for: characteristicContainer.oadTransfert,
      type: .withoutResponse
    )
  }

  //----------------------------------------------------------------------------
  // MARK: - Notify
  //----------------------------------------------------------------------------

  func notifyMailBox(value: Bool) {
    peripheral.setNotifyValue(
      true,
      for: characteristicContainer.mailBox
    )
  }

  func notifyBrainActivityMeasurement(value: Bool) {
    peripheral.setNotifyValue(
      value,
      for: characteristicContainer.brainActivityMeasurement
    )
  }

  func notifyHeadsetStatus(value: Bool) {
    peripheral.setNotifyValue(
      value,
      for: characteristicContainer.headsetStatus
    )
  }

}
