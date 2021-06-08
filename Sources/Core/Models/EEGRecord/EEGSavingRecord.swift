import Foundation

struct EEGRecordType: Codable {
  let recordType: MBTRecordType
  let source: MBTDataSource
  let dataType: MBTDataType
  let spVersion: String
}

struct EEGRecord: Codable {
  let recordID: String
  let recordingType: EEGRecordType
  let recordingTime: Int
  let nbPackets: Int
  let firstPacketId: Int
  let qualities: [[Float]]
  let channelData: [[Float?]]
  let statusData: [String] = []
  let recordingParameters: [String] = []
}

struct EEGSavingRecordContext: Codable {
  let ownerId: Int
  let riAlgo: String
}

struct EEGSavingRecordHeader: Codable {
  let deviceInfo: MelomindDeviceInformations
  let recordingNb: String = "0x03"
  let comments: [String]
  let sampRate: Int
  let eegPacketLength: Int
  let nbChannels: Int
  let acquisitionLocation: [String]
  let referencesLocation: [String]
  let groundsLocation: [String]
}

struct EEGSavingRecord: Codable {
  let uuidJsonFile: String = UUID().uuidString
  let context: EEGSavingRecordContext
  let header: EEGSavingRecordHeader
  let recording: EEGRecord

//  var toJSON: JSON? {
//    guard let recordData = try? JSONEncoder().encode(self),
//      let jsonObject = try? JSON(data: recordData) else { return nil }
//
//    return jsonObject
//  }

  var toJsonData: Data? {
    let jsonEncoder = JSONEncoder()
    if #available(iOS 13.0, *) {
      jsonEncoder.outputFormatting = [.withoutEscapingSlashes]
    }
    guard let encodedData = try? jsonEncoder.encode(self) else { return nil }
    return encodedData
  }

  var toJSONString: String? {
    guard let encodedData = toJsonData,
          let jsonString = String(data: encodedData, encoding: .utf8) else {
      return nil
    }
    return jsonString
  }


}
