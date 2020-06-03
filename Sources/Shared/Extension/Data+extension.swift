import Foundation

extension Data {

  /// Convert the current data object to an array of Uint8 values
  var toUint8Array: [UInt8] {
    var bytesArray = [UInt8](repeating: 0, count: count)

    (self as NSData).getBytes(&bytesArray,
                              length: count * MemoryLayout<UInt8>.size)
    return bytesArray
  }
}
