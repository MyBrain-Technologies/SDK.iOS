import Foundation

// Temporary file

class ConversionUtils {

  static func loUInt16(v:Int16) -> UInt8 {
    return UInt8(v & 0xFF)
  }

  static func hiUInt16(v:Int16) -> UInt8 {
    return UInt8(v >> 8 )
  }
}
