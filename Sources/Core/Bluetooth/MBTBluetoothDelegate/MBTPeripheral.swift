//
//  MBTPeripheral.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by Ressier Mathilde on 24/11/2020.
//  Copyright © 2020 MyBrainTechnologies. All rights reserved.
//

import Foundation
import CoreBluetooth

class MBTPeripheral {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  let peripheral: CBPeripheral
  let advertisementData: [String: Any]
  let RSSI: NSNumber

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  internal init(peripheral: CBPeripheral,
                advertisementData: [String : Any],
                RSSI: NSNumber) {
    self.peripheral = peripheral
    self.advertisementData = advertisementData
    self.RSSI = RSSI
  }
}

//==============================================================================
// MARK: - Extension for Melomind
//==============================================================================

extension MBTPeripheral {

  var deviceName: String {
    get { return dataReader.localName ?? "" }
  }

  var deviceServices: [CBUUID] {
    get { return dataReader.uuidKeys ?? [] }
  }

  var isValidMelomindDevice: Bool {
    get {
      MelomindBluetoothPeripheral.isMelomindDevice(deviceName: deviceName,
                                                   services: deviceServices)
    }
  }

  private var dataReader: BluetoothAdvertisementDataReader {
    get { return BluetoothAdvertisementDataReader(data: advertisementData) }
  }

}
