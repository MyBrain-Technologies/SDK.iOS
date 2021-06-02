import Foundation

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

}
