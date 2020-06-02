import Foundation

/*******************************************************************************
 * EEGAcquisitionBuffer
 *
 * Buffer to stack headset acquisition values.
 * Specify a size to the buffer so it will return the buffer only when it's full.
 *
 ******************************************************************************/
class EEGAcquisitionBuffer {

  private var previousIndex: Int16
  private var packetBuffer: EEGRawPacketBuffer

  /******************** Quick access properties ********************/

  var bufferSizeMax: Int = 250 {
    didSet { packetBuffer.bufferSizeMax = bufferSizeMax }
  }

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(bufferSizeMax: Int, lastIndex: Int16 = -1) {
    self.packetBuffer = EEGRawPacketBuffer(bufferSizeMax: bufferSizeMax)
    self.previousIndex = lastIndex
  }

  //----------------------------------------------------------------------------
  // MARK: - Add a packet to the buffer
  //----------------------------------------------------------------------------

  /// Add a packet to the buffer. Missing packets are filled with 0xFF.
  func add(data: Data) {
    guard data.count > 0 else { return }

    let packetValue = EEGRawPacket(data: data)
    add(rawPacket: packetValue)
  }

  /// Add a packet to the buffer. Missing packets are filled with 0xFF.
  func add(rawPacketValue: [UInt8]) {
    let packetValue = EEGRawPacket(rawValue: rawPacketValue)
    add(rawPacket: packetValue)
  }

  /// Add a packet to the buffer. Missing packets are filled with 0xFF.
  func add(rawPacket: EEGRawPacket) {
    log.verbose("Receive packet. Index: \(rawPacket.packetIndex)")
    log.verbose("Value length: \(rawPacket.value.count)")
    log.verbose("Value: \(rawPacket.value)")
    addMissingPackets(before: rawPacket)

    // SHOULD BE CLAMPED between 0 and Int16.max
    previousIndex = rawPacket.packetIndex

    packetBuffer.add(bytes: rawPacket.value)
  }

  //----------------------------------------------------------------------------
  // MARK: - Usable packets
  //----------------------------------------------------------------------------

  /// Return packets that can be used if the buffer is full, else nil if the packet is not full yet.
  func getUsablePackets() -> [UInt8]? {
    guard packetBuffer.isFull else { return nil }

    return packetBuffer.flushBuffer()
  }

  //----------------------------------------------------------------------------
  // MARK: - Missing packets
  //----------------------------------------------------------------------------

  /// Add missing packets between a packet and the last registered packet
  private func addMissingPackets(before packet: EEGRawPacket) {
    let missingPackets = numberOfLostPackets(before: packet)

    guard missingPackets > 0 else { return }

    log.verbose("Lost \(missingPackets) packets")
    packetBuffer.add(value: 0xFF,
                     count: Int(missingPackets) * packet.valueLength)
  }

  /// Return the number of packets missing between a packet and the last registered packet
  private func numberOfLostPackets(before packet: EEGRawPacket) -> Int32 {
    let expectedIndex = previousIndex + 1

    let missingPackets = Int32(packet.packetIndex - expectedIndex)
    return missingPackets
  }
}
