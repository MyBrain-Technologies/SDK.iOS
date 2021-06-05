import Foundation

public typealias Buffer = [[Float]]

public extension Buffer {

  var flattened: [Float] {
    return self.flatMap { $0 }
  }

}
