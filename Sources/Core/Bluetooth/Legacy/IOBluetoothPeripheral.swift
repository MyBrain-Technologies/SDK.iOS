import Foundation
import CoreBluetooth

struct IOBluetoothPeripheral {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  #warning("TODO: Add eventDelegate")
  var peripheral: CBPeripheral?
//  {
//    didSet {
//      let statusUpdate = peripheral != nil ? true : false
//      eventDelegate?.onHeadsetStatusUpdate?(statusUpdate)
//    }
//  }

  private let bluetoothDeviceCharacteristics: BluetoothDeviceCharacteristics

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(
    peripheral: CBPeripheral?,
    bluetoothDeviceCharacteristics: BluetoothDeviceCharacteristics = .shared
  ) {
    self.peripheral = peripheral
    self.bluetoothDeviceCharacteristics = bluetoothDeviceCharacteristics
  }

  //----------------------------------------------------------------------------
  // MARK: - Read
  //----------------------------------------------------------------------------

  func readDeviceState() {
    guard let deviceState = bluetoothDeviceCharacteristics.deviceState else {
      return
    }
    peripheral?.readValue(for: deviceState)
  }

  func readDeviceInformations() {
    let informations = bluetoothDeviceCharacteristics.deviceInformations

    informations.forEach() { peripheral?.readValue(for: $0) }
  }

  //----------------------------------------------------------------------------
  // MARK: - Write
  //----------------------------------------------------------------------------

  func write(deviceExternalName name: String) {
    let serialNumberByteArray: [UInt8] = [
      MailboxCommand.setSerialNumber.rawValue,
      0xAB,
      0x21
    ]
    let deviceName = serialNumberByteArray + [UInt8](name.utf8)

    peripheral?.writeValue(Data(deviceName),
                           for: bluetoothDeviceCharacteristics.mailBox,
                           type: .withResponse)
  }

  func write(firmwareVersion: [UInt8], numberOfBlocks: Int16) {
    var firmwareVersionConverted = [UInt8](repeating: 0, count: 5)

    firmwareVersionConverted[0] = MailboxCommand.startOTATFX.rawValue
    firmwareVersionConverted[1] = firmwareVersion[0]
    firmwareVersionConverted[2] = firmwareVersion[1]
    firmwareVersionConverted[3] = numberOfBlocks.loUint8
    firmwareVersionConverted[4] = numberOfBlocks.hiUint16

    peripheral?.writeValue(Data(firmwareVersionConverted),
                           for: bluetoothDeviceCharacteristics.mailBox,
                           type: .withResponse)
  }

  func writeA2DPConnection() {
    let bytesArray: [UInt8] = [
      MailboxCommand.a2dpConnection.rawValue,
      0x25,
      0xA2
    ]

    peripheral?.writeValue(Data(bytesArray),
                           for: bluetoothDeviceCharacteristics.mailBox,
                           type: .withResponse)
  }

  func write(oadBuffer: [UInt8]) {
    peripheral?.writeValue(
      Data(oadBuffer),
      for: bluetoothDeviceCharacteristics.oadTransfert,
      type: .withoutResponse
    )
  }

  //----------------------------------------------------------------------------
  // MARK: - Notify
  //----------------------------------------------------------------------------

  func notifyMailBox(value: Bool) {
    peripheral?.setNotifyValue(
      true,
      for: bluetoothDeviceCharacteristics.mailBox
    )
  }

  func notifyBrainActivityMeasurement(value: Bool) {
    peripheral?.setNotifyValue(
      value,
      for: bluetoothDeviceCharacteristics.brainActivityMeasurement
    )
  }

  func notifyHeadsetStatus(value: Bool) {
    peripheral?.setNotifyValue(
      value,
      for: bluetoothDeviceCharacteristics.headsetStatus
    )
  }
}
