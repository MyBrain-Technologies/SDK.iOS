//
//  MBTBluetooth.swift
//  MBT_iOS_SDK
//
//  Created by Baptiste Rasschaert on 09/05/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import AVFoundation

public class MBTBluetooth {
    
    internal var manager: MBTBluetoothManager
    
    internal var audioA2DPDelegate: MBTBluetoothA2DPDelegate?
    
    ///////
    //MARK: - Init Method
    ///////
    public init() {
        manager = MBTBluetoothManager()
    }
    
    
    ///////
    //MARK: - Connect and Disconnect MBT Headset Methods/
    ///////
    func connectTo(_ deviceName:String,
                   with eventDelegate: MBTBluetoothEventDelegate,
                   and shouldConnectToAudio: Bool) {
        manager.connectTo(deviceName,
                          with: eventDelegate)
        
        if shouldConnectToAudio {
            let session = AVAudioSession.sharedInstance()
            let output = session.currentRoute.outputs.first
            
            if output?.portName == deviceName
                && output?.portType == AVAudioSessionPortBluetoothA2DP {
                // Save the UUID of the concerned headset
                MBTBluetoothA2DP.uid = output?.uid
                // A2DP Audio is connected
                audioA2DPDelegate?.audioA2DPDidConnect()
            } else {
                // Try to set Category to help device to connect 
                // to the Melomind A2DP profile
                do {
                    if #available(iOS 10.0, *) {
                        try session.setCategory(AVAudioSessionCategoryPlayback,
                                                with: AVAudioSessionCategoryOptions.allowBluetoothA2DP)
                    } else {
                        try session.setCategory(AVAudioSessionCategoryPlayback,
                                                with: AVAudioSessionCategoryOptions.allowBluetooth)
                    }
                } catch {
                    debugPrint("MyBrainTechnologiesSDK : error while setting category for bluetooth or ( is over iOS 10 ) A2DP Bluetooth with error : \(error)")
                }
            }
            
            // Register to Audio Session output / input changes
            // to monitor the A2DP connection status
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(changeRoute(_:)),
                                                   name:Notification.Name.AVAudioSessionRouteChange,
                                                   object: nil
            )
        }
    }
    
    public func connectToEEG(_ deviceName:String,
                          with eventDelegate: MBTBluetoothEventDelegate) {
        
        self.connectTo(deviceName, with: eventDelegate, and: false)
    }
    
    public func connectToEEGAndA2DP(_ deviceName:String,
                                    with eventDelegate: MBTBluetoothEventDelegate,
                                    and audioA2DPDelegate: MBTBluetoothA2DPDelegate) {
        self.audioA2DPDelegate = audioA2DPDelegate
        self.connectTo(deviceName, with: eventDelegate, and: true)
    }
    
    public func disconnect() {
        manager.disconnect()
    }
    
    
    
    ///////
    //MARK: - Audio A2DP changing route output handler
    ///////
    @objc func changeRoute(_ notif:Notification) {
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
                if output?.portName == String(manager.deviceName)
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
