import Foundation
import CoreBluetooth

class PeripheralValidator {

  //----------------------------------------------------------------------------
  // MARK: - Validation
  //----------------------------------------------------------------------------

  func isMelomindPeripheral(advertisementData: [String: Any]) -> Bool {
    let dataReader = BluetoothAdvertisementDataReader(data: advertisementData)

    guard let newDeviceName = dataReader.localName,
          let newDeviceServices = dataReader.uuidKeys else {
      return false
    }

//    print(newDeviceServices)
//    if newDeviceServices.first?.uuidString == "B2A0" {
//      print("advertisementData Pre indus 5")
//    }
//    for data in advertisementData {
//      print(data.key)
//    }

    let isMelomindDevice = MelomindBluetoothPeripheral.isMelomindDevice(
      deviceName: newDeviceName,
      services: newDeviceServices
    )

    return isMelomindDevice
  }

  func isQplusPeripheral(advertisementData: [String: Any]) -> Bool {
    let dataReader = BluetoothAdvertisementDataReader(data: advertisementData)

    guard let deviceName =
            advertisementData[CBAdvertisementDataLocalNameKey] as? String,
          let serviceData =
            advertisementData[CBAdvertisementDataServiceDataKey]
            as? [CBUUID: Data]
    else {
      return false
    }
    
    let isQplusDevice = MelomindBluetoothPeripheral.isQplusDevice(
      deviceName: deviceName,
      blePrefix: "melo_",
      serviceData: serviceData
    )

    return isQplusDevice
  }

  func isMbtPeripheral(advertisementData: [String: Any]) -> Bool {
    let isMelomindPeripheral =
      self.isMelomindPeripheral(advertisementData: advertisementData)
    let isQplusPeripheral =
      self.isQplusPeripheral(advertisementData: advertisementData)
    return isMelomindPeripheral || isQplusPeripheral
  }

}
