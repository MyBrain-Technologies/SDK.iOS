import Foundation

protocol Recorder {
  associatedtype DataType

  var  packets: [DataType] { get }

  func savePacket(_: DataType)
  func getLastPackets(_ n: Int) -> [DataType]?
  func removeAllPackets()
}
