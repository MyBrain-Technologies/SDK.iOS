import Foundation
// Good
class EEGRawPacketBuffer {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private(set) var buffer: [UInt8]

  var bufferSizeMax: Int

  var isFull: Bool  {
    return buffer.count >= bufferSizeMax
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(bufferSizeMax: Int) {
    self.buffer = []
    self.bufferSizeMax = bufferSizeMax
  }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  func add(bytes: [UInt8]) {
    buffer.append(contentsOf: bytes)
  }

  func add(value: UInt8, count: Int) {
    let content = [UInt8](repeating: value, count: count)
    buffer.append(contentsOf: content)
  }

  func flushBuffer() -> [UInt8] {
    let range = 0 ..< min(buffer.count, bufferSizeMax)
    let content = buffer[range]

    buffer.removeSubrange(range)

    return Array(content)
  }
}
