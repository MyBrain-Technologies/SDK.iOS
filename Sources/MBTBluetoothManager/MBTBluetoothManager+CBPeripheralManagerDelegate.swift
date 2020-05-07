import Foundation
import CoreBluetooth

extension MBTBluetoothManager: CBPeripheralManagerDelegate {
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    if #available(iOS 13.0, *) {
      bluetoothAuthorization =
        BluetoothAuthorization(authorization: peripheral.authorization,
                               state: peripheral.state)
    } else {
      bluetoothAuthorization = BluetoothAuthorization(state: peripheral.state)
    }

    bluetoothState = BluetoothState(state: peripheral.state)
  }
}
