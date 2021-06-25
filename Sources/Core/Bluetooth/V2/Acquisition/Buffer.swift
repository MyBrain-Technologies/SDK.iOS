import Foundation

public typealias Buffer = [[Float]]

public extension Buffer {

  var flattened: [Float] {
    return self.flatMap { $0 }
  }

  var channelCount: Int {
    return self.count
  }

  func channel(at index: Int) -> [Float]? {
    guard index < channelCount else { return nil }
    return self[index]
  }

}
