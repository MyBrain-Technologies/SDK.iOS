import Foundation

extension Comparable {

  func clamped(min minimum: Self, max maximum: Self) -> Self {
    var valid = min(self, maximum)
    valid = max(valid, minimum)
    return valid
  }

  mutating func clamp(min minimum: Self, max maximum: Self) {
    self = self.clamped(min: minimum, max: maximum)
  }
}
