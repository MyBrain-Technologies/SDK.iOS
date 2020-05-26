import Foundation
import CoreBluetooth

struct MelomindBluetoothPeripheral {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  static let melomindService = BluetoothService.myBrainService.uuid

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  static func isMelomindDevice(deviceName: String, services: [CBUUID]) -> Bool {
    let hasMelomindService = services.contains(melomindService)

    let prefix = Constants.DeviceName.blePrefix
    let nameContainMelomindPrefix = deviceName.lowercased().starts(with: prefix)

    return hasMelomindService && nameContainMelomindPrefix
  }
}
