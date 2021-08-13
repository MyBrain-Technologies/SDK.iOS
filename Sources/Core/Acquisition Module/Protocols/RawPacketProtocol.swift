//
//  RawPacketProtocol.swift
//  MyBrainTechnologiesSDK
//
//  Created by Laurent on 14/08/2021.
//  Copyright © 2021 MyBrainTechnologies. All rights reserved.
//

import Foundation

protocol RawPacketProtocol {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  var rawValue: [UInt8] { get }

  var packetIndex: Int16 { get }

  var packetIndexValues: [UInt8] { get }

  var packetValues: [UInt8] { get }

  var packetValuesLength: Int { get }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(rawValue: [UInt8])

  init(data: Data)

}

//==============================================================================
// MARK: - CustomStringConvertible
//==============================================================================

//extension CustomStringConvertible where Self: RawPacket  {
//
//  var description: String {
//    return """
//    Receive packet. Index: \(packetIndex)
//    Value length: \(packetValues.count)
//    Value: \(packetValues)
//    """
//  }
//}
