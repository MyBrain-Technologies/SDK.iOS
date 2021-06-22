import Foundation
import CoreBluetooth
// Good
struct MelomindBluetoothPeripheral {

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  static func isMelomindDevice(
    deviceName: String,
    blePrefix: String = Constants.DeviceName.blePrefix,
    services: [CBUUID]
  ) -> Bool {
    let melomindService = MBTService.PreIndus5.myBrain.uuid
    let hasMelomindService = services.contains(melomindService)

    let nameContainMelomindPrefix =
      deviceName.lowercased().starts(with: blePrefix)

    return hasMelomindService && nameContainMelomindPrefix
  }

  static func isQplusDevice(
    deviceName: String,
    blePrefix: String = Constants.DeviceName.blePrefix,
    serviceData: [CBUUID: Data]
  ) -> Bool {
    let nameHasQplusPrefix = deviceName.lowercased().starts(with: blePrefix)

    return nameHasQplusPrefix
  }

}
