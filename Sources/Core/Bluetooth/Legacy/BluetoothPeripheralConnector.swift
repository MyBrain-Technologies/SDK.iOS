import Foundation
import CoreBluetooth

/*******************************************************************************
 * BluetoothConnector
 *
 * Handle bluetooth connections
 *
 ******************************************************************************/
#warning("TODO: Remove")
class BluetoothPeripheralConnector {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Central Manager ********************/

  var centralManager: CBCentralManager

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

  // Will call `centralManager(_:didDiscover:advertisementData:rssi:)`
  func scanForMelomindConnections(
    melomindService: CBUUID = MelomindBluetoothPeripheral.melomindService
  ) {
    log.verbose("🧭 Start scanning for a melomind device")

    centralManager.scanForPeripherals(withServices: [melomindService],
                                      options: nil)
  }

  func stopScanningForConnections(on peripheral: CBPeripheral? = nil) {
    log.verbose("🧭 Stop scanning for a melomind device")

    centralManager.stopScan()

    guard let peripheral = peripheral else { return }

    centralManager.cancelPeripheralConnection(peripheral)
  }

  /******************** Connection ********************/

  func connect(to peripheral: CBPeripheral) {
    log.verbose("🧭 Connection to peripheral \(peripheral)")
    centralManager.connect(peripheral, options: nil)
  }
}
