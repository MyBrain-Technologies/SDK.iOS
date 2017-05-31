//
//  MBTBluetoothManager.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 11/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import CoreBluetooth
import AVFoundation



// Manager for the SDK of the Bluetooth Part of the MBT Headset.
internal class MBTBluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate  {

    //The BLE central manager.
    var centralManager : CBCentralManager!
    
    // The BLE peripheral with which a connection has been established.
    var blePeripheral : CBPeripheral!
    
    // A boolean indicating the connection status. Sends a notification when changed.
    var isConnected = false {
        willSet {
            eventDelegate.onBluetoothStatusUpdate(newValue)
        }
    }
    
    // A boolean indicating if SDK is listening to EEG Headset notifications.
    var isListeningToEEG = false {
        didSet {
            self.blePeripheral.setNotifyValue(
                isListeningToEEG,
                for: MBTBluetoothLE.brainActivityMeasurementCharacteristic
            )
        }
    }
    
    // The headset bluetooth profile name to connect to.
    var deviceName: NSString!
    
    // The MBTBluetooth Event Delegate.
    var eventDelegate: MBTBluetoothEventDelegate!
    
    // The MBT Audio A2DP Delegate.
    // Tell developers when audio connect / disconnect
    var audioA2DPDelegate: MBTBluetoothA2DPDelegate? {
        didSet {
            if audioA2DPDelegate != nil {
                let session = AVAudioSession.sharedInstance()
                let output = session.currentRoute.outputs.first
                if output?.portName == String(deviceName)
                    && output?.portType == AVAudioSessionPortBluetoothA2DP {
                    // Save the UUID of the concerned headset
                    MBTBluetoothA2DP.uid = output?.uid
                    // A2DP Audio is connected
                    audioA2DPDelegate?.audioA2DPDidConnect()
                } else {
                    // Try to set Category to help device to connect
                    // to the MBT A2DP profile
                    do {
                        if #available(iOS 10.0, *) {
                            try session.setCategory(AVAudioSessionCategoryPlayback,
                                                    with: AVAudioSessionCategoryOptions.allowBluetoothA2DP)
                        } else {
                            try session.setCategory(AVAudioSessionCategoryPlayback,
                                                    with: AVAudioSessionCategoryOptions.allowBluetooth)
                        }
                    } catch {
                        debugPrint("MyBrainTechnologiesSDK : error while setting category for bluetooth or ( if over iOS 10 ) A2DP Bluetooth with error : \(error)")
                    }
                }
                
                // Register to Audio Session output / input changes
                // to monitor the A2DP connection status
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(audioChangedRoute(_:)),
                                                       name:Notification.Name.AVAudioSessionRouteChange,
                                                       object: nil
                )
            }
        }
    }
    
    
    
    
    ///////////////////////////////////////////////////////
    //                                                   //
    //MARK: - Connect and Disconnect MBT Headset Methods //
    //                                                   //
    ///////////////////////////////////////////////////////
    
    public func connectTo(_ deviceName:String,
                          with eventDelegate: MBTBluetoothEventDelegate,
                          and audioA2DPDelegate: MBTBluetoothA2DPDelegate?) {
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        self.deviceName = NSString(string: deviceName)
        self.eventDelegate = eventDelegate
        
        // Check if should launch audio process to help the A2DP connection
        guard let audioDelegate = audioA2DPDelegate else {
            return
        }
        self.audioA2DPDelegate = audioDelegate
    }
    
    public func disconnect() {
        centralManager.cancelPeripheralConnection(blePeripheral)
        centralManager = nil
        blePeripheral = nil
        eventDelegate = nil
        audioA2DPDelegate = nil
    }
    
    
    ///////////////////////////////////////////////////////
    //                                                   //
    //MARK: Central Manager Delegate Methods             //
    //                                                   //
    ///////////////////////////////////////////////////////
    
    // Check status of BLE hardware.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state.hashValue == CBCentralManagerState.poweredOn.hashValue {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripherals(withServices: nil, options: nil)
        }
        else {
            isConnected = false
        }
    }
    
    // Check out the discovered peripherals to find the right device.
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
    
    // Discover services of the peripheral.
    func centralManager(_ central: CBCentralManager,
                                    didConnect peripheral: CBPeripheral)
    {
        isConnected = true
        peripheral.discoverServices(nil)
        
        // Tell the event delegate that the connection is established
        eventDelegate.onConnectionEstablished()
    }
    
    // If disconnected by error, start searching again,
    // else let event delegate know that headphones
    // are disconnected
    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?)
    {
        isConnected = false
        
        if error != nil {
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            eventDelegate.onConnectionOff(error)
        }
    }
    
    // If connection failed, call the event delegate
    // with the error.
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        
        eventDelegate.onConnectionFailed(error)
    }
    
    
    ///////////////////////////////////////////////////////
    //                                                   //
    //MARK: CBPeripheral Delegate Methods                //
    //                                                   //
    ///////////////////////////////////////////////////////
    
    // Check if the service discovered is a valid Service.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Check all the services of the connecting peripheral.
        for service in peripheral.services! {
            let currentService = service as CBService
            // Get the MyBrainService and Device info UUID
            let servicesUUID = MBTBluetoothLE.getServicesUUIDs()
            
            // Check if manager should look at this service characteristics
            if servicesUUID.contains(CBUUID(data: service.uuid.data)) {
                peripheral.discoverCharacteristics(nil, for: currentService)
            }
        }
    }
    
    // Enable notification and sensor for desired characteristic of valid service.
    func peripheral(_ peripheral: CBPeripheral,
                                didDiscoverCharacteristicsFor service: CBService,
                                error: Error?) {
        
        // check the uuid of each characteristic to find config and data characteristics
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            // MyBrainService's Characteristics
            if CBUUID(data: thisCharacteristic.uuid.data) == MBTBluetoothLE.brainActivityMeasurementUUID {
                // Enable Sensor Notification and read the current value
                MBTBluetoothLE.brainActivityMeasurementCharacteristic = thisCharacteristic
            }
            // Device info's Characteristics
            if CBUUID(data: thisCharacteristic.uuid.data) == MBTBluetoothLE.deviceInfoServiceUUID {
                self.blePeripheral.readValue(for: thisCharacteristic)
            }
        }
    }

    
    // Get data values when they are updated
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        
        let notifiedData = characteristic.value!
        
        switch CBUUID(data: characteristic.uuid.data) {
        case MBTBluetoothLE.brainActivityMeasurementUUID:
            let dataArray = MBTBluetoothLE.processBrainActivityData(notifiedData)
            eventDelegate?.onReceivingPackage(dataArray)
        case MBTBluetoothLE.deviceInfoServiceUUID:
            MBTBluetoothLE.processDeviceInformations(notifiedData)
        default:
            break
        }
    }
    
    // Check if the notification status changed. 
    // NB: Absence of this function causes the notifications not to register anymore.
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: Error?) {
        
        print("Did update notification for characteristic: \(characteristic.uuid.data)")
    }
    
    
    
    
    /////////////////////////////////////////////////////
    //                                                 //
    //MARK: - Audio A2DP changing route output handler //
    //                                                 //
    /////////////////////////////////////////////////////
    
    func audioChangedRoute(_ notif:Notification) {
        // Get the Reason why the audio route change
        guard let userInfo = notif.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSessionRouteChangeReason(rawValue:reasonValue) else {
                return
        }
        // Get the last audio output route used
        var lastOutput: AVAudioSessionPortDescription! = nil
        if let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
            lastOutput = previousRoute.outputs[0]
        }
        // Get the actual route used
        let session = AVAudioSession.sharedInstance()
        let output = session.currentRoute.outputs.first
        
        
        switch reason {
        case .newDeviceAvailable:
            if output?.portName == String(deviceName)
                && output?.portType == AVAudioSessionPortBluetoothA2DP {
                // Save the UUID of the concerned headset
                MBTBluetoothA2DP.uid = output?.uid
                // A2DP Audio is connected
                audioA2DPDelegate?.audioA2DPDidConnect()
            }
        case .oldDeviceUnavailable:
            // if the old device is the MBT headset
            if lastOutput?.uid == MBTBluetoothA2DP.uid {
                // Erase the A2DP audio uid saved
                MBTBluetoothA2DP.uid = nil
                // MBT A2DP audio is disconnected
                audioA2DPDelegate?.audioA2DPDidDisconnect()
            }
        default: ()
        }
    }
}
