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
}
