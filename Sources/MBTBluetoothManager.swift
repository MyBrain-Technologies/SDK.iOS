//
//  MBTBluetoothManager.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 11/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import CoreBluetooth

/**
 * Notification Keys
 */
let BLEConnectionStatusChanged = "MBT.BLEConnectionStatusChangedNotificationKey"
let BLEDataSampleReceived = "MBT.BLEDataSampleReceivedNotificationKey"
let BLELeadOffChanged = "MBT.BLELeadOffChangedNotificationKey"
let BLEBatteryLevel = "MBT.BLEBatteryLevelNotificationKey"


internal class MBTBluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate  {
    /**
     * The BLE central manager.
     */
    var centralManager : CBCentralManager!
    
    /**
     * The BLE peripheral with which a connection has been established.
     */
    var blePeripheral : CBPeripheral!
    
    /**
     * A boolean indicating the connection status. Sends a notification when changed.
     */
    var isConnected = false {
        willSet {
            eventDelegate.onBluetoothStatusUpdate(newValue)
        }
    }
    
    var deviceName: NSString!
    var eventDelegate: MBTBluetoothEventDelegate!
    var servicesUUID: [CBUUID]!
    
    
    
    
    public func connectTo(_ deviceName:String,
                          with eventDelegate: MBTBluetoothEventDelegate,
                          and servicesUUID:[CBUUID]) {
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        self.deviceName = NSString(string: deviceName)
        self.eventDelegate = eventDelegate
        self.servicesUUID = servicesUUID
    }
    
    public func disconnect() {
        centralManager.cancelPeripheralConnection(blePeripheral)
        centralManager = nil
        blePeripheral = nil
    }
    
    
    
    /**
     * Check status of BLE hardware.
     */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state.hashValue == CBCentralManagerState.poweredOn.hashValue {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripherals(withServices: nil, options: nil)
        }
        else {
            isConnected = false
        }
    }
    
    /**
     * Check out the discovered peripherals to find the right device.
     */
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber)
    {
        let nameOfDeviceFound =
            (advertisementData as NSDictionary).object(
                forKey: CBAdvertisementDataLocalNameKey) as? NSString
        
        if (nameOfDeviceFound == self.deviceName) {
            
            // Stop scanning
            self.centralManager.stopScan()
            // Set as the peripheral to use and establish connection
            self.blePeripheral = peripheral
            self.blePeripheral.delegate = self
            self.centralManager.connect(peripheral, options: nil)
        }
    }
    
    /**
     * Discover services of the peripheral.
     */
    func centralManager(_ central: CBCentralManager,
                                    didConnect peripheral: CBPeripheral)
    {
        isConnected = true
        peripheral.discoverServices(nil)
    }
    
    /**
     * If disconnected by error, start searching again.
     */
    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?)
    {
        isConnected = false
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    /**
     * Called if connection failed.
     */
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?)
    {
        print("connection Fail")
    }
    
    
    /**
     * Check if the service discovered is a valid Service.
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Check all the services of the connecting peripheral.
        for service in peripheral.services! {
            let currentService = service as CBService
            // Check if manager should look at this service characteristics
            if servicesUUID.contains(CBUUID(data: service.uuid.data)) {
                peripheral.discoverCharacteristics(nil, for: currentService)
            }
        }
    }
    
    /**
     * Enable notification and sensor for desired characteristic of valid service.
     */
    func peripheral(_ peripheral: CBPeripheral,
                                didDiscoverCharacteristicsFor service: CBService,
                                error: Error?)
    {
        print("Did discover characteristics")
    }
    
    /**
     * Check if the notification status changed. -Absence of this function causes the notifications not to register anymore.-
     */
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: Error?)
    {
        
    }
    
    // Get data values when they are updated
    func peripheral(_ peripheral: CBPeripheral,
                                didUpdateValueFor characteristic: CBCharacteristic,
                                error: Error?)
    {
        
    }
}
