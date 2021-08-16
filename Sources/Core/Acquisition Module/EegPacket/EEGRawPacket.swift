import Foundation

struct EEGRawPacket: RawPacketProtocol {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  let rawValue: [UInt8]

  /// Index of a packet is stored in the two first value
  var packetIndex: Int16 {
    return Int16(rawValue[0] & 0xff) << 8 | Int16(rawValue[1] & 0xff)
  }

  var packetIndexValues: [UInt8] {
    return Array(rawValue.prefix(2))
  }

  /// Value of a packet is stored after the two first value (wich are `
  /// packetIndex` property)
  var packetValues: [UInt8] {
    return rawValue.suffix(rawValue.count - 2)
  }

  var packetValuesLength: Int {
    return packetValues.count
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(rawValue: [UInt8]) {
    self.rawValue = rawValue
  }

  init(data: Data) {
    self.rawValue = data.toUint8Array
  }

}

//==============================================================================
// MARK: - CustomStringConvertible
//==============================================================================

extension EEGRawPacket: CustomStringConvertible {

  var description: String {
    return """
    Receive packet. Index: \(packetIndex)
    Value length: \(packetValues.count)
    Value: \(packetValues)
    """
  }
}
