import Foundation

extension Int16 {

  var loUint8: UInt8 {
    return UInt8(self & 0xFF)
  }

  var hiUint16: UInt8 {
    return UInt8(self >> 8 )
  }
}
