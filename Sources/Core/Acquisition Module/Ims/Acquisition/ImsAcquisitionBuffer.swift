//
//  ImsAcquisitionBuffer.swift
//  MyBrainTechnologiesSDK
//
//  Created by Laurent on 14/08/2021.
//  Copyright © 2021 MyBrainTechnologies. All rights reserved.
//

import Foundation

// Handle missing packet during acquisition.

class ImsAcquisitionBuffer<RawPacketType: RawPacketProtocol> {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private var previousIndex: Int16

  private var packetBuffer: RawPacketBuffer

  /******************** Quick access properties ********************/

  var bufferSizeMax: Int = 300 {
    didSet {
      packetBuffer.bufferSizeMax = bufferSizeMax
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(bufferSizeMax: Int, lastIndex: Int16 = -1) {
    self.packetBuffer = RawPacketBuffer(bufferSizeMax: bufferSizeMax)
    self.previousIndex = lastIndex
  }

  //----------------------------------------------------------------------------
  // MARK: - Add a packet to the buffer
  //----------------------------------------------------------------------------

  /// Add a packet to the buffer. Missing packets are filled with 0xFF.
  func add(data: Data) {
    guard data.count > 0 else { return }

    let packetValue = RawPacketType(data: data)
    add(rawPacket: packetValue)
  }

  /// Add a packet to the buffer. Missing packets are filled with 0xFF.
  func add(rawPacketValue: [UInt8]) {
    let packetValue = RawPacketType(rawValue: rawPacketValue)
    add(rawPacket: packetValue)
  }

  /// Add a packet to the buffer. Missing packets are filled with 0xFF.
  func add(rawPacket: RawPacketProtocol) {
    //log.verbose(rawPacket)
    addMissingPackets(before: rawPacket)
    packetBuffer.add(bytes: rawPacket.packetValues)
  }

  //----------------------------------------------------------------------------
  // MARK: - Usable packets
  //----------------------------------------------------------------------------

  /// Return packets that can be used if the buffer is full, else nil if
  /// the packet is not full yet.
  func getUsablePackets() -> [UInt8]? {
    guard packetBuffer.isFull else { return nil }
    return packetBuffer.flushBuffer()
  }

  //----------------------------------------------------------------------------
  // MARK: - Missing packets
  //----------------------------------------------------------------------------

  /// Add missing packets between a packet and the last registered packet
  private func addMissingPackets(before packet: RawPacketProtocol) {
    let missingPackets = numberOfLostPackets(before: packet)

    guard missingPackets > 0 else { return }

    log.verbose("Lost \(missingPackets) packets")
    packetBuffer.add(value: 0xFF,
                     count: Int(missingPackets) * packet.packetValuesLength)
  }

  /// Return the number of packets missing between a packet and the last
  /// registered packet
  private func numberOfLostPackets(before packet: RawPacketProtocol) -> Int32 {
    if packet.packetIndex == 0 {
      previousIndex = 0
    }

    if previousIndex == -1 {
      previousIndex = packet.packetIndex - 1
    }

    /// When packet.packetIndex = Int16.min
    if previousIndex >= 32767 {
      previousIndex = 0
    }

    let missingPackets = Int32(packet.packetIndex - previousIndex)

    previousIndex = packet.packetIndex.clamped(min: 0, max: Int16.max)

    return missingPackets - 1
  }

}
