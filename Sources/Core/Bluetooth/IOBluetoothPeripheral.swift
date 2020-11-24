import Foundation
import CoreBluetooth

struct IOBluetoothPeripheral {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  var peripheral: CBPeripheral?

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(peripheral: CBPeripheral?) {
    self.peripheral = peripheral
  }

  //----------------------------------------------------------------------------
  // MARK: - Read
  //----------------------------------------------------------------------------

  func readDeviceState() {
    guard let deviceState =
      BluetoothDeviceCharacteristics.shared.deviceState else { return }
    peripheral?.readValue(for: deviceState)
  }

  func readDeviceInformations() {
    log.debug("Read device informations on \(peripheral?.name)")
    
    let informations = BluetoothDeviceCharacteristics.shared.deviceInformations

    informations.forEach() { peripheral?.readValue(for: $0) }
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

    peripheral?.writeValue(Data(deviceName),
                           for: BluetoothDeviceCharacteristics.shared.mailBox,
                           type: .withResponse)
  }

  func write(firmwareVersion: [UInt8], numberOfBlocks: Int16) {
    var firmwareVersionConverted = [UInt8](repeating: 0, count: 5)

    firmwareVersionConverted[0] = MailBoxEvents.startOTATFX.rawValue
    firmwareVersionConverted[1] = firmwareVersion[0]
    firmwareVersionConverted[2] = firmwareVersion[1]
    firmwareVersionConverted[3] = numberOfBlocks.loUint8
    firmwareVersionConverted[4] = numberOfBlocks.hiUint16

    peripheral?.writeValue(Data(firmwareVersionConverted),
                           for: BluetoothDeviceCharacteristics.shared.mailBox,
                           type: .withResponse)
  }

  func writeA2DPConnection() {
    let bytesArray: [UInt8] = [
      MailBoxEvents.a2dpConnection.rawValue,
      0x25,
      0xA2
    ]

    peripheral?.writeValue(Data(bytesArray),
                           for: BluetoothDeviceCharacteristics.shared.mailBox,
                           type: .withResponse)
  }

  func write(oadBuffer: [UInt8]) {
    peripheral?.writeValue(
      Data(oadBuffer),
      for: BluetoothDeviceCharacteristics.shared.oadTransfert,
      type: .withoutResponse
    )
  }

  //----------------------------------------------------------------------------
  // MARK: - Notify
  //----------------------------------------------------------------------------

  func notifyMailBox(value: Bool) {
    peripheral?.setNotifyValue(
      true,
      for: BluetoothDeviceCharacteristics.shared.mailBox
    )
  }

  func notifyBrainActivityMeasurement(value: Bool) {
    peripheral?.setNotifyValue(
      value,
      for: BluetoothDeviceCharacteristics.shared.brainActivityMeasurement
    )
  }

  func notifyHeadsetStatus(value: Bool) {
    peripheral?.setNotifyValue(
      value,
      for: BluetoothDeviceCharacteristics.shared.headsetStatus
    )
  }
}
