//
//  MBTEEGPacket.swift
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 29/06/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire

/// Model to store processed data of an EEG Packet.
public class MBTEEGPacket: Object {
    
    /// The qualities stored in a list. The list size
    /// should be equal to the number of channels if there is
    /// a status channel.
    let qualities = List<Quality>()
    
    /// The timestamp in milliseconds when this packet is created.
    dynamic var timestamp: Int = Int(NSDate().timeIntervalSince1970)
    
    /// The values from all channels.
    let channelsData = List<ChannelDatas>()
    
    /// The packet index of the recording session.
    var packetIndex: Int = 0
}

//MARK: -
/// One quality value for one channel.
class Quality: Object {
    /// Value property of the *Quality*.
    dynamic var value: Float = 0
}

/// One value from one channel.
class ChannelData: Object {
    /// Value property of a *Channel*.
    dynamic var value: Float = 0
    
    /// Special init with the value of *ChannelData*.
    convenience init(data: Float) {
        self.init()
        self.value = data
    }
}

/// All values from one channel.
class ChannelDatas: Object {
    /// *RLMArray* of *ChannelData*.
    let value = List<ChannelData>()
}


//MARK: -
/// *MBTEEGPacket* model DB Manager.
class EEGPacketManager: RealmEntityManager {
    
    /// Method to persist EEGPacket received in the Realm database.
    class func saveEEGPacket(_ eegPacket: MBTEEGPacket) {
        try! RealmManager.realm.write {
            RealmManager.realm.add(eegPacket)
        }
    }
    
    /// Remove all EEGPacket saved in Realm DB.
    class func removeAllEEGPackets() {
        let packets = RealmManager.realm.objects(MBTEEGPacket.self)
        
        try! RealmManager.realm.write {
            RealmManager.realm.delete(packets)
        }
    }
    
    /// Build the JSON with the EEG session data.
    class func getJSONFromEEGSession() -> Data? {
        let eegPackets = RealmManager.realm.objects(MBTEEGPacket.self)
        
        if eegPackets.count == 0 {
            return nil
        }
        
        let device = DeviceManager.getCurrentDevice()
        
        var acquisitions: [String] = Array()
        for acquisition in device.acquisitionLocations {
            acquisitions.append("\(acquisition.type.rawValue)")
        }
        
        // Get datas per channel.
        var channel1: [Float] = Array()
        var channel2: [Float] = Array()
        for eegPacket in eegPackets {
            for channelData in eegPacket.channelsData.first!.value {
                channel1.append(channelData.value)
            }
            
            for channelData in eegPacket.channelsData.last!.value {
                channel2.append(channelData.value)
            }
        }
        
        // Create the session JSON.
        let jsonObject: [String: Any] = [
            "uuidJsonFile": UUID().uuidString,
            "header": [
                "deviceInfo": [
                    "productName": device.productName!,
                    "hardwareVersion": device.hardwareVersion!,
                    "firmwareVersion": device.firmwareVersion!,
                    "uniqueDeviceIdentifier": device.deviceId!
                ],
                "recordingNB": "0x14",
                "comments": [],
                "eegPacketLength": device.eegPacketLength,
                "sampRate": device.sampRate,
                "nbChannels": device.nbChannels,
                "acquisitionLocation": acquisitions,
                "referencesLocation": [
                    "\(device.referencesLocations.first!.type.rawValue)"
                ],
                "groundsLocation": [
                    "\(device.groundsLocations.first!.type.rawValue)"
                ]
            ],
            "recording": [
                "recordID": 123,
                "recordingType": [
                    "recordType": "RAWDATA",
                    "spVersion": "0.0.0",
                    "source": "DEFAULT",
                    "dataType": "DEFAULT"
                ],
                "recordingTime": eegPackets.first!.timestamp,
                "nbPackets": eegPackets.count,
                "firstPacketId": eegPackets.first!.packetIndex,
                "qualities": [[],[]],
                "channelData": [
                    channel1,
                    channel2
                ],
                "statusData": []
            ]
        ]
        
        // Transform the array in JSON.
        do {
            let json = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            EEGPacketManager.saveJSONOnDevice(json)
            return json
        } catch _ {
            debugPrint("JSON failure")
            
            return nil
        }
    }
    
    /// Save the JSON on the iDevice.
    class func saveJSONOnDevice(_ json:Data) {
        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor:nil,
                create:false
            )
            let fileName:String = UUID().uuidString + ".json"
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            // Saving JSON in device.
            try json.write(to: fileURL)
            print("json saved here : \(json)")
            
            // Then delete all MBTEEGPacket saved.
            EEGPacketManager.removeAllEEGPackets()
            
            // Send JSON to BrainWeb.
            EEGPacketManager.sendJSONToBrainWeb(fileURL)
            
        } catch {
            debugPrint(error)
        }
    }
    
    /// Send JSON to medical BrainWeb server.
    class func sendJSONToBrainWeb(_ fileURL: URL) {
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(fileURL, withName: "eeg")
        },
            to: "https://ingest.dev.mybraintech.com/medical-test/eeg",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }
}
