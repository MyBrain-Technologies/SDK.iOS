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
    log.verbose("🧭 Start scanning for a melomind device")

    let melomindService = [MelomindBluetoothPeripheral.melomindService]

    centralManager.scanForPeripherals(withServices: melomindService,
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
