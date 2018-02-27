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



/// Manage for the SDK the MBT Headset Bluetooth Part (connection/deconnection).
internal class MBTBluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate  {
    
    /// Singleton declaration
    static let shared = MBTBluetoothManager()

    /// The BLE central manager.
    var centralManager : CBCentralManager!
    
    /// The BLE peripheral with which a connection has been established.
    var blePeripheral : CBPeripheral!
    
    /// A *Bool* indicating the connection status.
    /// - Remark: Sends a notification when changed (on *willSet*).
    var isConnected = false {
        willSet {
            eventDelegate.onBluetoothStatusUpdate?(newValue)
        }
    }
    
    // Time Out Timer
    var timerTimeOut : Timer!
    var timerUpdateBatteryLevel: Timer!
    
    /// A *Bool* indicating if SDK is listening to EEG Headset notifications.
    var isListeningToEEG = false {
        didSet {
            self.blePeripheral.setNotifyValue(
                isListeningToEEG,
                for: MBTBluetoothLEHelper.brainActivityMeasurementCharacteristic
            )
        }
    }
    
    /// The headset bluetooth profile name to connect to.
    var deviceName: String! {
        didSet {
            if audioA2DPDelegate != nil {
                let session = AVAudioSession.sharedInstance()
                let output = session.currentRoute.outputs.first
                if output?.portName == String(deviceName)
                    && output?.portType == AVAudioSessionPortBluetoothA2DP {
                    // Save the UUID of the concerned headset
                    MBTBluetoothA2DPHelper.uid = output?.uid
                    // A2DP Audio is connected
                    audioA2DPDelegate?.audioA2DPDidConnect?()
                } else {
                    // Try to set Category to help device to connect
                    // to the MBT A2DP profile
                    if #available(iOS 10.0, *) {
                        do {
                            try session.setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault, options: AVAudioSessionCategoryOptions.allowBluetoothA2DP)
                            //                            try session.setCategory(AVAudioSessionCategoryPlayback,
                            //                                                    with: AVAudioSessionCategoryOptions.allowAirPlay)
                        } catch let error {
                            print("[MyBrainTechnologiesSDK] Error while setting category for A2DP Bluetooth : \(error.localizedDescription)")
                        }
                    } else {
                        do {
                            try session.setCategory(AVAudioSessionCategoryPlayback,
                                                    with: AVAudioSessionCategoryOptions.allowBluetooth)
                        } catch let error {
                            print("[MyBrainTechnologiesSDK] Error while setting category for bluetooth : \(error)")
                        }
                    }
                }
                
                // Register to Audio Session output / input changes
                // to monitor the A2DP connection status
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(audioChangedRoute(_:)),
                                                       name:Notification.Name.AVAudioSessionRouteChange,
                                                       object: nil)
            }
        }
    }
    
    /// The MBTBluetooth Event Delegate.
    var eventDelegate: MBTBluetoothEventDelegate!
    
    /// The MBT Audio A2DP Delegate.
    /// Tell developers when audio connect / disconnect
    var audioA2DPDelegate: MBTBluetoothA2DPDelegate?
    

    //MARK: - Connect and Disconnect MBT Headset Methods
    
    /// Intialize *centralManager*, *deviceName* and *eventDelegate*.
    /// - Parameters:
    ///     - deviceName : The name of the device to connect (Bluetooth profile).
    ///     - eventDelegate: The delegate which whill handle Bluetooth events.
    ///     - audioA2DPDelegate: The audio A2DP protocol delegate to monitor A2DP connection state. Can be nil.
    public func connectTo(_ deviceName:String? = nil,
                          with eventDelegate: MBTBluetoothEventDelegate,
                          and audioA2DPDelegate: MBTBluetoothA2DPDelegate?) {
        // Check if a current device is already saved in the DB, and delete it
        DeviceManager.deleteCurrentDevice()
        
        self.audioA2DPDelegate = audioA2DPDelegate
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.stopScan()
        centralManager.scanForPeripherals(withServices: [MBTBluetoothLEHelper.myBrainServiceUUID], options: nil)
        timerTimeOut = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(connectionMelominTimeOut), userInfo: nil, repeats: false)
        
        if let deviceName = deviceName {
            self.deviceName = deviceName
        }
        self.eventDelegate = eventDelegate        
        // Check if should launch audio process to help the A2DP connection
        
    }
    
    /// Disconnect centralManager, and remove session's values.
    public func disconnect() {
        centralManager.cancelPeripheralConnection(blePeripheral)
        centralManager = nil
        blePeripheral = nil
        eventDelegate = nil
        audioA2DPDelegate = nil
        
        // Remove current device saved
        DeviceManager.deleteCurrentDevice()
    }
    
    
    
    //MARK: Central Manager Delegate Methods
    
    /// Check status of BLE hardware. Invoked when the central 
    /// manager's state is update.
    /// - Parameters:
    ///     - central: The central manager whose state has changed.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state.hashValue == CBCentralManagerState.poweredOn.hashValue {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripherals(withServices: nil, options: nil)
        }
        else {
            isConnected = false
        }
    }
    
    /// Check out the discovered peripherals to find the right device.
    /// Invoked when the central manager discovers a peripheral while scanning.
    /// - Parameters:
    ///     - central: The central manager providing the update.
    ///     - peripheral: The discovered peripheral.
    ///     - advertisementData: A dictionary containing any advertisement data.
    ///     - RSSI: The current received signal strength indicator (RSSI) of the peripheral, in decibels.
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber)
    {
        guard let nameOfDeviceFound = advertisementData[CBAdvertisementDataLocalNameKey] as? String else { return }
        
        
        if let array = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? Array<CBUUID>,
            array.contains(MBTBluetoothLEHelper.myBrainServiceUUID) && nameOfDeviceFound.lowercased().range(of: "melo_") != nil {
            if self.deviceName == nil {
                self.deviceName = nameOfDeviceFound
            }
            
            if self.deviceName == nameOfDeviceFound  {
                // Stop scanning
                self.centralManager.stopScan()
                // invalidate timerTimeOut
                self.timerTimeOut.invalidate()
                // Set as the peripheral to use and establish connection
                self.blePeripheral = peripheral
                self.blePeripheral.delegate = self
                self.centralManager.connect(peripheral, options: nil)
            }
        }
    }
    
    /// Discover services of the peripheral.
    /// Invoked when a connection is successfully created with a peripheral.
    /// - Parameters:
    ///     - central: The central manager providing this information.
    ///     - peripheral: The peripheral that has been connected to the system.
    func centralManager(_ central: CBCentralManager,
                                    didConnect peripheral: CBPeripheral)
    {
        isConnected = true
        peripheral.discoverServices(nil)
    }
    
    /// If disconnected by error, start searching again,
    /// else let event delegate know that headphones
    /// are disconnected.
    /// Invoked when an existing connection with a peripheral is torn down.
    /// - Parameters:
    ///     - central: The central manager providing this information.
    ///     - peripheral: The peripheral that has been disconnected.
    ///     - error: If an error occurred, the cause of the failure.
    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?)
    {
        isConnected = false
        
        if error != nil {
            eventDelegate.onConnectionOff?(error)
        } else {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    /// If connection failed, call the event delegate
    /// with the error.
    /// Invoked when the central manager fails to create a connection with a peripheral.
    /// - Parameters:
    ///     - central: The central manager providing this information.
    ///     - peripheral: The peripheral that failed to connect.
    ///     - error: The cause of the failure.
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        
        eventDelegate.onConnectionFailed?(error)
    }
    
    
    //MARK: - Timer Method
    
    // Method Call Time Out
    @objc func connectionMelominTimeOut() {
        centralManager.stopScan()
        let error = NSError(domain: "Time Out", code: 999, userInfo: [NSLocalizedDescriptionKey : "Time Out Connection Melomind"]) as Error
        eventDelegate.onConnectionFailed!(error)
    }
    
    //  Method Request Update Status Battery
    @objc func requestUpdateBatteryLevel() {
        blePeripheral.readValue(for: MBTBluetoothLEHelper.deviceStateCharacteristic)
    }
    
    //MARK: CBPeripheral Delegate Methods
    
    /// Check if the service discovered is a valid Service.
    /// Invoked when you discover the peripheral’s available services.
    /// - Parameters:
    ///     - peripheral: The peripheral that the services belong to.
    ///     - error: If an error occurred, the cause of the failure.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Check all the services of the connecting peripheral.
        for service in peripheral.services! {
            let currentService = service as CBService
            // Get the MyBrainService and Device info UUID
            let servicesUUID = MBTBluetoothLEHelper.getServicesUUIDs()
            
            // Check if manager should look at this service characteristics
            if servicesUUID.contains(CBUUID(data: service.uuid.data)) {
                peripheral.discoverCharacteristics(nil, for: currentService)
            }
        }
    }
    
    /// Enable notification and sensor for desired characteristic of valid service.
    /// Invoked when you discover the characteristics of a specified service.
    /// - Parameters:
    ///     - peripheral: The peripheral that the services belong to.
    ///     - service: The service that the characteristics belong to.
    ///     - error: If an error occurred, the cause of the failure.
    func peripheral(_ peripheral: CBPeripheral,
                                didDiscoverCharacteristicsFor service: CBService,
                                error: Error?) {
        // Get the device information characteristics UUIDs.
        let characsUUIDS = MBTBluetoothLEHelper.getDeviceInfoCharacteristicsUUIDS()
        
        // check the uuid of each characteristic to find config and data characteristics
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            // MyBrainService's Characteristics
            if CBUUID(data: thisCharacteristic.uuid.data) == MBTBluetoothLEHelper.brainActivityMeasurementUUID {
                // Enable Sensor Notification and read the current value
                MBTBluetoothLEHelper.brainActivityMeasurementCharacteristic = thisCharacteristic
            }
            
            // Device info's Characteristics
            if characsUUIDS.contains(CBUUID(data: thisCharacteristic.uuid.data)) {
                self.blePeripheral.readValue(for: thisCharacteristic)
            }
            
            // Device State's Characteristics
            if MBTBluetoothLEHelper.deviceStateUUID == CBUUID(data: thisCharacteristic.uuid.data) {
                MBTBluetoothLEHelper.deviceStateCharacteristic = thisCharacteristic
                timerUpdateBatteryLevel = Timer.scheduledTimer(timeInterval: eventDelegate.timeIntervalOnReceiveBattery?() ?? 5, target: self, selector: #selector(requestUpdateBatteryLevel), userInfo: nil, repeats: true)
            }
            
            if MBTBluetoothLEHelper.deviceNameUUID == CBUUID(data: thisCharacteristic.uuid.data)  {
                blePeripheral.readValue(for: thisCharacteristic)
            }
        }

        
        // Check if characteristics have been discovered and set
        if MBTBluetoothLEHelper.brainActivityMeasurementCharacteristic != nil {
            // Tell the event delegate that the connection is established
            eventDelegate.onConnectionEstablished?()
        }
    }

    
    /// Get data values when they are updated.
    /// Invoked when you retrieve a specified characteristic’s value, 
    /// or when the peripheral device notifies your app that
    /// the characteristic’s value has changed.
    /// Send them to AcquisitionManager.
    /// - Parameters:
    ///     - peripheral: The peripheral that the services belong to.
    ///     - service: The characteristic whose value has been retrieved.
    ///     - error: If an error occurred, the cause of the failure.
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        let notifiedData = characteristic.value!
        // Get the device information characteristics UUIDs.
        let characsUUIDS = MBTBluetoothLEHelper.getDeviceInfoCharacteristicsUUIDS()
        
        switch CBUUID(data: characteristic.uuid.data) {
        case MBTBluetoothLEHelper.brainActivityMeasurementUUID:
            MelomindEngine.acqusitionManager.processBrainActivityData(notifiedData)
        case let uuid where characsUUIDS.contains(uuid) :
            MelomindEngine.acqusitionManager.processDeviceInformations(characteristic)
        case MBTBluetoothLEHelper.deviceStateUUID :
            MelomindEngine.acqusitionManager.processDeviceBatteryStatus(characteristic)
        default:
            break
        }
      
        
    }
    
    /// Check if the notification status changed.
    /// Invoked when the peripheral receives a request to start 
    /// or stop providing notifications for a specified characteristic’s value.
    /// - Parameters:
    ///     - peripheral: The peripheral that the services belong to.
    ///     - service: The characteristic whose value has been retrieved.
    ///     - error: If an error occurred, the cause of the failure.
    /// Remark : Absence of this function causes the notifications not to register anymore.
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: Error?) {
        //
//        print("Did update notification for characteristic: \(characteristic.uuid.data)")
    }
    
    
    
    
    //MARK: - Audio A2DP method
    
    /// Audio A2DP changing route output handler.
    /// - Parameter notif : The *notification* received when audio route output changed.
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
                MBTBluetoothA2DPHelper.uid = output?.uid
                // A2DP Audio is connected
                audioA2DPDelegate?.audioA2DPDidConnect?()
            }
        case .oldDeviceUnavailable:
            // if the old device is the MBT headset
            if lastOutput?.uid == MBTBluetoothA2DPHelper.uid {
                // Erase the A2DP audio uid saved
                MBTBluetoothA2DPHelper.uid = nil
                // MBT A2DP audio is disconnected
                audioA2DPDelegate?.audioA2DPDidDisconnect?()
            }
        default: ()
        }
    }
}
