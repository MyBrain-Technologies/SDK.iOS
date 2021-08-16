import Foundation

extension Array {

  /// Spread array content into several array
  /// - Parameters:
  ///   - numberOfArrays: Number of new arrays expected
  ///   - arraySelector: Closure taking the index and the value of an element, to return the index of
  ///   the new array where it should be.
  func spread(numberOfArrays: Int,
              arraySelector: ((Int, Element) -> Int)) -> [[Element]] {
    var newArray = [[Element]](repeating: [], count: numberOfArrays)

    for (index, value) in self.enumerated() {
      let index = arraySelector(index, value)

      guard index < numberOfArrays else { continue }

      newArray[index].append(value)
    }

    return newArray
  }

  func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}

extension Array where Element == Double {
  var toFloat: [Float] {
    return map() { Float($0) }
  }
}
