//
//  EEGAcquisitionBuffer.swift
//  MyBrainTechnologiesSDKTests
//
//  Created by Mathilde Ressier on 29/05/2020.
//  Copyright © 2020 MyBrainTechnologies. All rights reserved.
//

import Foundation

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

  init(bufferSizeMax: Int) {
    self.packetBuffer = EEGRawPacketBuffer(bufferSizeMax: bufferSizeMax)
    self.previousIndex = 0
  }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  func add(data: Data) {
    guard data.count > 0 else { return }

    let packetValue = EEGRawPacket(data: data)
    let currentIndex = packetValue.packetIndex

    let missingPackets = Int32(currentIndex - previousIndex)

    if missingPackets > 1 {
      log.info("Lost \(missingPackets) packets")
      packetBuffer.add(value: 0xFF,
                       count: Int(missingPackets) * packetValue.valueLength)
    }

    previousIndex = currentIndex // SHOULD BE CLAMPED

    packetBuffer.add(bytes: packetValue.value)
  }

  /// Return packets that can be used if the buffer is full, else nil if the packet is not full yet.
  func getUsablePackets() -> [UInt8]? {
    guard packetBuffer.isFull else { return nil }

    return packetBuffer.flushBuffer()
  }
}
