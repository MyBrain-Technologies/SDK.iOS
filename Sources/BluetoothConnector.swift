import Foundation
import CoreBluetooth

/*******************************************************************************
 * BluetoothConnector
 *
 * Handle bluetooth connections
 *
 ******************************************************************************/
class BluetoothConnector {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Central Manager ********************/

  var centralManager: CBCentralManager!

  /******************** Melomind ********************/

  let melomindService = BluetoothService.myBrainService.uuid

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(centralManager: CBCentralManager) {
    self.centralManager = centralManager
  }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /******************** Scan ********************/

  func scanForMelomindConnections() {
    log.info("🧭 Start scanning for a melomind device")

    centralManager.scanForPeripherals(withServices: [melomindService],
                                      options: nil)
  }

  func stopScanningForConnections(on peripheral: CBPeripheral? = nil) {
    log.info("🧭 Stop scanning for a melomind device")

    centralManager.stopScan()

    guard let peripheral = peripheral else { return }

    centralManager.cancelPeripheralConnection(peripheral)
  }

  /******************** Connection ********************/

  func connect(to peripheral: CBPeripheral) {
    log.info("🧭 Connection to peripheral \(peripheral)")
    centralManager.connect(peripheral, options: nil)
  }

  // TODO: this methods should not be here
  func isMelomindDevice(deviceName: String, services: [CBUUID]) -> Bool {
    let hasMelomindService = services.contains(melomindService)

    let prefix = Constants.DeviceName.blePrefix
    let nameContainMelomindPrefix = deviceName.lowercased().starts(with: prefix)

    return hasMelomindService && nameContainMelomindPrefix
  }
}
