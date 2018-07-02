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
    var centralManager : CBCentralManager?
    
    /// The BLE peripheral with which a connection has been established.
    var blePeripheral : CBPeripheral?
    
    /// A *Bool* indicating the connection status.
    /// - Remark: Sends a notification when changed (on *willSet*).
    var isConnected = false {
        willSet {
            eventDelegate?.onBluetoothStatusUpdate?(newValue)
        }
    }
    
    var isConnectedA2DP:Bool = {
        let output = AVAudioSession.sharedInstance().currentRoute.outputs.first
        
        if let deviceName = DeviceManager.connectedDeviceName {
            return output?.portName == deviceName && output?.portType == AVAudioSessionPortBluetoothA2DP
        }
        
        return false
    }()
    
    
//    var inc = 0
    
    // Time Out Timer
    var timerTimeOutConnection : Timer?
    var timerUpdateBatteryLevel: Timer?
    var timerTimeOutOAD: Timer?
    
    
    /// A *Bool* indicating if SDK is listening to EEG Headset notifications.
    var isListeningToEEG = false {
        didSet {
//            if isListeningToEEG {
//                stopTimerUpdateBatteryLevel()
//            } else {
//                startTimerUpdateBatteryLevel()
//            }
            self.blePeripheral?.setNotifyValue(
                isListeningToEEG,
                for: MBTBluetoothLEHelper.brainActivityMeasurementCharacteristic
            )
        }
    }
    
    /// A *Bool* indicating if SDK is listening to Saturation notifications.
    var isListeningToHeadsetStatus = false {
        didSet {
            self.blePeripheral?.setNotifyValue(
                isListeningToHeadsetStatus,
                for: MBTBluetoothLEHelper.headsetStatusCharacteristic
            )
        }
    }
    
    var isDownloadingFW = false
    
    var OADManager:MBTOADManager!
        
    /// The MBTBluetooth Event Delegate.
    weak var eventDelegate: MBTBluetoothEventDelegate?
    
    /// The MBT Audio A2DP Delegate.
    /// Tell developers when audio connect / disconnect
    weak var audioA2DPDelegate: MBTBluetoothA2DPDelegate?

    //MARK: - Connect and Disconnect MBT Headset Methods
    
    /// Intialize *centralManager*, *deviceName* and *eventDelegate*.
    /// - Parameters:
    ///     - deviceName : The name of the device to connect (Bluetooth profile).
    ///     - eventDelegate: The delegate which whill handle Bluetooth events.
    ///     - audioA2DPDelegate: The audio A2DP protocol delegate to monitor A2DP connection state. Can be nil.
    func connectTo(_ deviceName:String? = nil) {
        // Check if a current device is already saved in the DB, and delete it
        //DeviceManager.deleteCurrentDevice()
        if let _ = DeviceManager.connectedDeviceName {
            disconnect()
        }
        
        timerTimeOutConnection = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(connectionMelominTimeOut), userInfo: nil, repeats: false)
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        if #available(iOS 9.0, *) {
            if centralManager != nil && centralManager!.state == .poweredOn && !centralManager!.isScanning {
                centralManager!.scanForPeripherals(withServices: [MBTBluetoothLEHelper.myBrainServiceUUID], options: nil)
            }
        }

        if let deviceName = deviceName {
            DeviceManager.connectedDeviceName = deviceName
        }
        
    }
    
    /// Disconnect centralManager, and remove session's values.
    func disconnect() {
        centralManager?.stopScan()
        stopTimerUpdateBatteryLevel()
        MBTBluetoothLEHelper.brainActivityMeasurementCharacteristic = nil
        MBTBluetoothLEHelper.deviceStateCharacteristic = nil 
        isConnected = false
        if blePeripheral != nil {
            centralManager?.cancelPeripheralConnection(blePeripheral!)
        }
        centralManager?.delegate = nil
        centralManager = nil
        blePeripheral = nil
//        eventDelegate = nil
//        audioA2DPDelegate = nil
        // Remove current device saved
        //DeviceManager.deleteCurrentDevice()
        DeviceManager.connectedDeviceName = nil
        isDownloadingFW = false
    }
    
    func getDeviceNameA2DP() -> String? {
        if let output = AVAudioSession.sharedInstance().currentRoute.outputs.first, output.portType == AVAudioSessionPortBluetoothA2DP && output.portName.lowercased().range(of: "melo_") != nil {
            return output.portName
        }
        return nil
    }
    
    func stopTimerUpdateBatteryLevel() {
        if timerUpdateBatteryLevel != nil {
            timerUpdateBatteryLevel?.invalidate()
            timerUpdateBatteryLevel = nil
        }
    }
    
    func startTimerUpdateBatteryLevel() {
        if timerUpdateBatteryLevel != nil {
            timerUpdateBatteryLevel?.invalidate()
        }
        timerUpdateBatteryLevel = Timer.scheduledTimer(timeInterval: eventDelegate?.timeIntervalOnReceiveBattery?() ?? 5, target: self, selector: #selector(requestUpdateBatteryLevel), userInfo: nil, repeats: true)
    }
    
    
    func connectA2DP() {
        if audioA2DPDelegate != nil {
            let session = AVAudioSession.sharedInstance()
            let output = session.currentRoute.outputs.first
            
            if let deviceName = DeviceManager.connectedDeviceName, output?.portName == deviceName
                && output?.portType == AVAudioSessionPortBluetoothA2DP {
                // Save the UUID of the concerned headset
                MBTBluetoothA2DPHelper.uid = output?.uid
                // A2DP Audio is connected
                audioA2DPDelegate?.audioA2DPDidConnect?()
            } else {
                // Try to set Category to help device to connect
                // to the MBT A2DP profile
                
                do {
                    try session.setCategory(AVAudioSessionCategoryPlayback,
                                            with: AVAudioSessionCategoryOptions.allowBluetooth)
                } catch let error {
                    print("#57685 - [MyBrainTechnologiesSDK] Error while setting category for bluetooth : \(error)")
                }
                
//                if #available(iOS 10.0, *) {
//                    do {
//                        try session.setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault, options: AVAudioSessionCategoryOptions.allowBluetoothA2DP)
//                        //                            try session.setCategory(AVAudioSessionCategoryPlayback,
//                        //                                                    with: AVAudioSessionCategoryOptions.allowAirPlay)
//                    } catch let error {
//                        print("#57685 - [MyBrainTechnologiesSDK] Error while setting category for A2DP Bluetooth : \(error.localizedDescription)")
//                    }
//                } else {
//                    do {
//                        try session.setCategory(AVAudioSessionCategoryPlayback,
//                                                with: AVAudioSessionCategoryOptions.allowBluetooth)
//                    } catch let error {
//                        print("#57685 - [MyBrainTechnologiesSDK] Error while setting category for bluetooth : \(error)")
//                    }
//                }
            }
            
            // Register to Audio Session output / input changes
            // to monitor the A2DP connection status
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(audioChangedRoute(_:)),
                                                   name:Notification.Name.AVAudioSessionRouteChange,
                                                   object: nil)
        }
    }
    
    func getFileNameLatestVersionBin() -> String? {
        var fileNameLatestVersionBin:String? = nil

        let bundle = Bundle(identifier: "com.MyBrainTech.MyBrainTechnologiesSDK")
        
        if let currentFWVersion = DeviceManager.getCurrentDevice()?.deviceInfos?.firmwareVersion,
            let tabURLSBinary = bundle?.urls(forResourcesWithExtension: "bin", subdirectory: nil) {
            let tabURLSBinarySort = try? tabURLSBinary.sorted(by: {$0.relativeString < $1.relativeString})
            
            if let latestURLBinary = tabURLSBinarySort?.last {
                let fwVersion = latestURLBinary.relativeString.components(separatedBy: ".").first!.components(separatedBy: "-")[2]
                
                let newTabVersion = fwVersion.components(separatedBy: "_")
                let currTabVersion = currentFWVersion.components(separatedBy: ".")
                
                for i in 0 ..< 3 {
                    if let intNewCompVersion = Int(newTabVersion[i]) ,
                        let intCurrCompVersion = Int(currTabVersion[i]),
                        intNewCompVersion > intCurrCompVersion {
                        fileNameLatestVersionBin = latestURLBinary.relativeString.components(separatedBy: ".").first
                    }
                }
            }

        }
        
        
      
        
        return fileNameLatestVersionBin
    }
    func startTestOAD() {
        // Disconnect A2DP
        
        let bundle = Bundle(identifier: "com.MyBrainTech.MyBrainTechnologiesSDK")!
        let tabURLSBinary = bundle.urls(forResourcesWithExtension: "bin", subdirectory: nil)!
        let tabURLSBinarySort = try! tabURLSBinary.sorted(by: {$0.relativeString < $1.relativeString})
        
        
        
        OADManager = MBTOADManager(tabURLSBinarySort.first!.relativeString.components(separatedBy: ".").first!)
        
        print("install FW : \(OADManager.fwVersion)")
        
        stopTimerUpdateBatteryLevel()
        
        blePeripheral?.setNotifyValue(true, for: MBTBluetoothLEHelper.mailBoxCharacteristic)
        
        isDownloadingFW = true
        
        sendFWVersionPlusLength()
        
    }
    
    func startOAD() {
        // Disconnect A2DP
       
        timerTimeOutOAD = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(oadTransferTimeOut), userInfo: nil, repeats: false)
        
        if let fileName = getFileNameLatestVersionBin() {
            OADManager = MBTOADManager(fileName)
            
            stopTimerUpdateBatteryLevel()
            
            blePeripheral?.setNotifyValue(true, for: MBTBluetoothLEHelper.mailBoxCharacteristic)
            
            isDownloadingFW = true
            
            sendFWVersionPlusLength()
        } else {
            let error = NSError(domain: "OAD Transfer", code: 903, userInfo: [NSLocalizedDescriptionKey : "Bundle do not contains Firmware Version"]) as Error
            eventDelegate?.didOADFailWithError?(error)
            timerTimeOutOAD?.invalidate()
        }
        
     
    }
    
    func sendOADBuffer() {
        DispatchQueue.global().async {
            var oldProgress = -1
            while self.OADManager.mProgInfo.iBlock < self.OADManager.mOadBuffer.count {
                usleep(6000)
//                print(self.OADManager.mProgInfo.iBlock)
                self.blePeripheral?.writeValue(self.OADManager.getNextOADBufferData(), for: MBTBluetoothLEHelper.oadTransferCharacteristic, type: .withoutResponse)
                DispatchQueue.main.async {
                    let progress = Int(Float(self.OADManager.mProgInfo.iBlock) / Float(self.OADManager.mOadBuffer.count) * 100)
                    if progress != oldProgress {
                        
                        self.eventDelegate?.onProgressUpdate?(Float(progress + 12) / 120)
                        oldProgress = progress
                    }
                }
            }
        }
        
       
    }
    
    func sendFWVersionPlusLength() {
        var bytesArray = [UInt8](repeating: 0, count: 5)
        
        bytesArray[0] = MailBoxEvents.MBX_START_OTA_TXF.rawValue
        bytesArray[1] = OADManager.getFWVersionAsByteArray()[0]
        bytesArray[2] = OADManager.getFWVersionAsByteArray()[1]
        bytesArray[3] = ConversionUtils.loUInt16(v: OADManager.mProgInfo.nBlock)
        bytesArray[4] = ConversionUtils.hiUInt16(v: OADManager.mProgInfo.nBlock)
        
        blePeripheral?.writeValue( Data(bytes: bytesArray), for: MBTBluetoothLEHelper.mailBoxCharacteristic, type: .withResponse)
        self.eventDelegate?.onProgressUpdate?(0.05)

    }

    
    //MARK: Central Manager Delegate Methods
    
    /// Check status of BLE hardware. Invoked when the central 
    /// manager's state is update.
    /// - Parameters:
    ///     - central: The central manager whose state has changed.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Scan for peripherals if BLE is turned on
            centralManager?.scanForPeripherals(withServices: [MBTBluetoothLEHelper.myBrainServiceUUID], options: nil)
        }
        else {
            isConnected = false
            disconnect()
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
            if DeviceManager.connectedDeviceName == nil {
                DeviceManager.connectedDeviceName = nameOfDeviceFound
            }
            
            if DeviceManager.connectedDeviceName == nameOfDeviceFound  {
                // Stop scanning
                centralManager?.stopScan()
                // invalidate timerTimeOut
                timerTimeOutConnection?.invalidate()
                // Set as the peripheral to use and establish connection
                blePeripheral = peripheral

                blePeripheral?.delegate = self
                centralManager?.connect(peripheral, options: nil)
                DeviceManager.updateDeviceToMelomind()
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
        connectA2DP()
        MBTBluetoothLEHelper.deviceInfoCharacteristic.removeAll()
        isConnected = true
        peripheral.discoverServices(nil)
        
        if isDownloadingFW {
            DeviceManager.resetDeviceInfo()
            requestUpdateDeviceInfo()
        } else {
            eventDelegate?.onConnectionEstablished?()
        }
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
        if isDownloadingFW {
            eventDelegate?.onProgressUpdate?(0.95)
            centralManager?.connect(blePeripheral!, options: nil)
        } else {
            disconnect()
            isConnected = false
            
            if error != nil {
                eventDelegate?.onConnectionOff?(error)
            } else {
                central.scanForPeripherals(withServices: nil, options: nil)
            }
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
        eventDelegate?.onConnectionFailed?(error)
    }
    
    
    //MARK: - Timer Method
    
    // Method Call Time Out connection
    @objc func connectionMelominTimeOut() {
        centralManager?.stopScan()
        let error = NSError(domain: "Time Out", code: 901, userInfo: [NSLocalizedDescriptionKey : "Time Out Connection Melomind"]) as Error
        eventDelegate?.onConnectionFailed?(error)
    }
    
    @objc func oadTransferTimeOut() {
        centralManager?.stopScan()
        let error = NSError(domain: "Time Out", code: 902, userInfo: [NSLocalizedDescriptionKey : "Time Out OADTransfer"]) as Error
        eventDelegate?.didOADFailWithError?(error)
        timerTimeOutOAD?.invalidate()
    }
    
    //  Method Request Update Status Battery
    @objc func requestUpdateBatteryLevel() {
        if blePeripheral != nil && MBTBluetoothLEHelper.deviceStateCharacteristic != nil   {
            blePeripheral?.readValue(for: MBTBluetoothLEHelper.deviceStateCharacteristic)
        }
    }
    
    func requestUpdateDeviceInfo() {
        if blePeripheral != nil && MBTBluetoothLEHelper.deviceInfoCharacteristic.count != 0 {
            for characteristic in MBTBluetoothLEHelper.deviceInfoCharacteristic {
                blePeripheral?.readValue(for: characteristic)
            }
        }
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
            if MBTBluetoothLEHelper.brainActivityMeasurementUUID  == CBUUID(data: thisCharacteristic.uuid.data)  {
                // Enable Sensor Notification and read the current value
                MBTBluetoothLEHelper.brainActivityMeasurementCharacteristic = thisCharacteristic


            }
            
            // Device info's Characteristics
            if characsUUIDS.contains(CBUUID(data: thisCharacteristic.uuid.data)) {
                MBTBluetoothLEHelper.deviceInfoCharacteristic.append(thisCharacteristic)
                self.blePeripheral?.readValue(for: thisCharacteristic)
            }
            
            // Device State's Characteristics
            if MBTBluetoothLEHelper.deviceBatteryStatusUUID == CBUUID(data: thisCharacteristic.uuid.data) {
                MBTBluetoothLEHelper.deviceStateCharacteristic = thisCharacteristic
                startTimerUpdateBatteryLevel()

            }
            
            if MBTBluetoothLEHelper.headsetStatusUUID == CBUUID(data: thisCharacteristic.uuid.data)  {
                MBTBluetoothLEHelper.headsetStatusCharacteristic = thisCharacteristic
            }
            
            if MBTBluetoothLEHelper.mailBoxUUID == CBUUID(data: thisCharacteristic.uuid.data) {
                MBTBluetoothLEHelper.mailBoxCharacteristic = thisCharacteristic
            }
            if MBTBluetoothLEHelper.oadTransferUUID  == CBUUID(data: thisCharacteristic.uuid.data) {
                MBTBluetoothLEHelper.oadTransferCharacteristic = thisCharacteristic
            }
        }

        
        // Check if characteristics have been discovered and set
        if MBTBluetoothLEHelper.brainActivityMeasurementCharacteristic != nil {
            // Tell the event delegate that the connection is established
          
            
            MelomindEngine.main.eegAcqusitionManager.setUpWith(device: DeviceManager.getCurrentDevice()!)
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
        guard let notifiedData = characteristic.value else {
            return
        }
        // Get the device information characteristics UUIDs.
        let characsUUIDS = MBTBluetoothLEHelper.getDeviceInfoCharacteristicsUUIDS()
        
        let uuidCharacteristic = CBUUID(data: characteristic.uuid.data)
        
//        if uuidCharacteristic == MBTBluetoothLEHelper.brainActivityMeasurementUUID {
//            DispatchQueue.main.async {
//                [weak self] in
//                if self?.isListeningToEEG ?? false {
////                    print(self?.inc)
////                    self?.inc += 1
//                    MelomindEngine.eegAcqusitionManager.processBrainActivityData(notifiedData)
//                }
//            }
//        }
        
        switch uuidCharacteristic {
        case MBTBluetoothLEHelper.brainActivityMeasurementUUID :
            DispatchQueue.main.async {
                [weak self] in
                if self?.isListeningToEEG ?? false {
                    //                    print(self?.inc)
                    //                    self?.inc += 1
                    MelomindEngine.main.eegAcqusitionManager.processBrainActivityData(notifiedData)
                }
            }
            
        case MBTBluetoothLEHelper.headsetStatusUUID :
            DispatchQueue.global(qos: .background).async {
                MelomindEngine.main.deviceAcqusitionManager.processHeadsetStatus(characteristic)
            }
        case MBTBluetoothLEHelper.deviceBatteryStatusUUID :
            MelomindEngine.main.deviceAcqusitionManager.processDeviceBatteryStatus(characteristic)
        case let uuid where characsUUIDS.contains(uuid) :
            MelomindEngine.main.deviceAcqusitionManager.processDeviceInformations(characteristic)
            if let currentDeviceInfo = DeviceManager.getCurrentDevice()?.deviceInfos, isDownloadingFW && currentDeviceInfo.isDeviceInfoNotNil() {
                if currentDeviceInfo.firmwareVersion == OADManager.fwVersion {
                    eventDelegate?.onProgressUpdate?(1.0)
                    timerTimeOutOAD?.invalidate()

                    isDownloadingFW = false
                } else {
                    let error = NSError(domain: "OAD Transfer", code: 906, userInfo: [NSLocalizedDescriptionKey : "Incorrect headset firmware version "]) as Error
                    eventDelegate?.didOADFailWithError?(error)
                    timerTimeOutOAD?.invalidate()
                }
            }
        case MBTBluetoothLEHelper.mailBoxUUID :
            if let data = characteristic.value {
                var bytesArray = [UInt8](repeating: 0, count: data.count)
                (data as NSData).getBytes(&bytesArray, length: data.count * MemoryLayout<UInt8>.size)
                switch MailBoxEvents.getMailBoxEvent(v: bytesArray[0]) {
                case .MBX_OTA_MODE_EVT :
                    print("MBX_OTA_MODE_EVT bytesArray : \(bytesArray.description)")
                    if bytesArray[1] == 0x01 {
                        eventDelegate?.onDeviceReady?()
                        eventDelegate?.onProgressUpdate?(0.1)
                        sendOADBuffer()
                    } else {
                        isDownloadingFW = false
                        blePeripheral?.setNotifyValue(false, for: MBTBluetoothLEHelper.mailBoxCharacteristic)
                        startTimerUpdateBatteryLevel()
                        let error = NSError(domain: "OAD Transfer", code: 904, userInfo: [NSLocalizedDescriptionKey : "Prepare OAD Transfer request fail (MBX_OTA_MODE_EVT)"]) as Error
                        eventDelegate?.didOADFailWithError?(error)
                        timerTimeOutOAD?.invalidate()
                    }
                case .MBX_OTA_IDX_RESET_EVT :
                    print("MBX_OTA_IDX_RESET_EVT bytesArray : \(bytesArray.description)")
                 
                    DispatchQueue.global().async {
                        self.OADManager.mProgInfo.iBlock = Int16((bytesArray[2] & 0xFF)) << 8 | Int16(bytesArray[1] & 0xFF)
                    }
                    
                case .MBX_OTA_STATUS_EVT :
                    print("MBX_OTA_STATUS_EVT bytesArray : \(bytesArray.description)")
                    if bytesArray[1] == 1 {
                        eventDelegate?.onProgressUpdate?(0.9)
                        eventDelegate?.onOADComplete?()
                    } else {
                        let error = NSError(domain: "OAD Transfer", code: 905, userInfo: [NSLocalizedDescriptionKey : " Transfer is not completed (MBX_OTA_STATUS_EVT)"]) as Error
                        eventDelegate?.didOADFailWithError?(error)
                        timerTimeOutOAD?.invalidate()
                    }
                default:
                    print("Default")
                }
            }
        default:
            break
        }

        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
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
    @objc func audioChangedRoute(_ notif:Notification) {
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
            if let deviceName = DeviceManager.connectedDeviceName, output?.portName == deviceName
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
