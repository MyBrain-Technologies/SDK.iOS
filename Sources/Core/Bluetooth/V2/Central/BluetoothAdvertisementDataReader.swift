import Foundation
import CoreBluetooth

// Good

struct BluetoothAdvertisementDataReader {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Raw data ********************/

  private var data: [String: Any]

  /******************** Read data ********************/

  var localName: String? {
    return data[CBAdvertisementDataLocalNameKey] as? String
  }

  var uuidKeys: [CBUUID]? {
    return data[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(data: [String: Any]) {
    self.data = data
  }

}
