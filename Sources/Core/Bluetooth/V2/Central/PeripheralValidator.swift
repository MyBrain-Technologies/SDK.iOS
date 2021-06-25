import Foundation
import CoreBluetooth

class PeripheralValidator {

  //----------------------------------------------------------------------------
  // MARK: - Melomind Validation
  //----------------------------------------------------------------------------

  func isMelomindPeripheral(advertisementData: [String: Any]) -> Bool {
    let dataReader = BluetoothAdvertisementDataReader(data: advertisementData)

    guard let deviceName = dataReader.localName,
          let services = dataReader.uuidKeys else {
      return false
    }

    return isMelomindPeripheral(deviceName: deviceName, services: services)
  }

  func isMelomindPeripheral(deviceName: String, services: [CBUUID]) -> Bool {
    let melomindService = MBTService.PreIndus5.myBrain.uuid
    let hasMelomindService = services.contains(melomindService)

    let blePrefix = Constants.DeviceName.blePrefix
    let nameContainMelomindPrefix =
      deviceName.lowercased().starts(with: blePrefix)

    return hasMelomindService && nameContainMelomindPrefix
  }

  //----------------------------------------------------------------------------
  // MARK: - Qp Device validation
  //----------------------------------------------------------------------------

  func isQplusPeripheral(advertisementData: [String: Any]) -> Bool {
    guard let deviceName =
            advertisementData[CBAdvertisementDataLocalNameKey] as? String else {
      return false
    }
//    let serviceData =
//      advertisementData[CBAdvertisementDataServiceDataKey]
//      as? [CBUUID: Data]

    return isQplusPeripheral(deviceName: deviceName)
  }

  func isQplusPeripheral(deviceName: String) -> Bool {
    let blePrefix =  Constants.DeviceName.blePrefix
    let nameHasQplusPrefix = deviceName.lowercased().starts(with: blePrefix)
    return nameHasQplusPrefix
  }


  //----------------------------------------------------------------------------
  // MARK: - MBT Device validation
  //----------------------------------------------------------------------------

  func isMbtPeripheral(advertisementData: [String: Any]) -> Bool {
    let isMelomindPeripheral =
      self.isMelomindPeripheral(advertisementData: advertisementData)
    let isQplusPeripheral =
      self.isQplusPeripheral(advertisementData: advertisementData)
    return isMelomindPeripheral || isQplusPeripheral
  }

}
