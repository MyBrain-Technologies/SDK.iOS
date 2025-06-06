import Foundation

//swiftlint:disable line_length

struct EEGAcquisitonRawPacketsToBuffer {
  struct SetSample {
    static let packets: [[UInt8]] = [
      [0, 0, 1, 1, 1],
      [0, 1, 2, 2, 2],
      [0, 2, 3, 3, 3],
      [0, 3, 4, 4, 4],
      [0, 4, 5, 5, 5]
    ]

    static let savedPacketsBy3: [[UInt8]] = [
      [1, 1, 1],
      [2, 2, 2],
      [3, 3, 3],
      [4, 4, 4],
      [5, 5, 5]
    ]

      static let savedPacketsBy4: [[UInt8]?] = [
        nil,
        [1, 1, 1, 2],
        [2, 2, 3, 3],
        [3, 4, 4, 4],
        nil
      ]

    static let savedPacketsBy6: [[UInt8]?] = [
      nil,
      [1, 1, 1, 2, 2, 2],
      nil,
      [3, 3, 3, 4, 4, 4],
      nil
    ]
  }

  struct SetSampleLostPackets {
    static let packets: [[UInt8]] = [
      [0, 0, 1, 1, 1],
      [0, 1, 2, 2, 2],
      [0, 2, 3, 3, 3],
      [0, 3, 4, 4, 4],
      [0, 5, 6, 6, 6]
    ]

    static let savedPacketsBy3: [[UInt8]] = [
      [1, 1, 1],
      [2, 2, 2],
      [3, 3, 3],
      [4, 4, 4],
      [0xFF, 0xFF, 0xFF],
      [6, 6, 6]
    ]

    static let savedPacketsBy4: [[UInt8]?] = [
      nil,
      [1, 1, 1, 2],
      [2, 2, 3, 3],
      [3, 4, 4, 4],
      [0xFF, 0xFF, 0xFF, 6]
    ]

    static let savedPacketsBy6: [[UInt8]?] = [
      nil,
      [1, 1, 1, 2, 2, 2],
      nil,
      [3, 3, 3, 4, 4, 4],
      [0xFF, 0xFF, 0xFF, 6, 6, 6]
    ]
  }

  struct Set1 {
    static let packets: [[UInt8]] = [
      [0, 0, 3, 234, 3, 234, 110, 19, 110, 19, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255],
      [0, 1, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255],
      [0, 2, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 98, 62, 98, 62, 6, 108, 6, 108, 201, 215, 201, 215, 175, 5, 175, 5, 140, 8, 140, 8, 128, 0, 128, 0, 128, 0, 128, 0],
      [0, 3, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0]
    ]

    static let savedPackets: [[UInt8]] = [
      [3, 234, 3, 234, 110, 19, 110, 19, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255],
      [127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255],
      [127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 127, 255, 98, 62, 98, 62, 6, 108, 6, 108, 201, 215, 201, 215, 175, 5, 175, 5, 140, 8, 140, 8, 128, 0, 128, 0, 128, 0, 128, 0],
      [128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0, 128, 0]
    ]
  }

  struct Set2 {
    static let packets: [[UInt8]] = [
      [6, 30, 0, 2, 4, 194, 0, 2, 4, 214, 0, 2, 4, 219, 0, 2, 4, 252, 0, 2, 5, 52, 0, 2, 5, 84, 0, 2, 5, 74, 0, 2, 5, 33, 0, 2, 5, 7, 0, 2, 4, 249],
      [6, 31, 0, 2, 4, 194, 0, 2, 4, 81, 0, 2, 3, 201, 0, 2, 3, 104, 0, 2, 3, 58, 0, 2, 3, 8, 0, 2, 2, 181, 0, 2, 2, 75, 0, 2, 1, 244, 0, 2, 1, 179],
      [6, 39, 255, 255, 255, 19, 255, 255, 254, 226, 255, 255, 254, 145, 255, 255, 254, 86, 255, 255, 254, 69, 255, 255, 254, 52, 255, 255, 254, 12, 255, 255, 253, 214, 255, 255, 253, 188, 255, 255, 253, 200]
    ]

    static let savedPacketsBy40: [[UInt8]] = [
      [0, 2, 4, 194, 0, 2, 4, 214, 0, 2, 4, 219, 0, 2, 4, 252, 0, 2, 5, 52, 0, 2, 5, 84, 0, 2, 5, 74, 0, 2, 5, 33, 0, 2, 5, 7, 0, 2, 4, 249],
      [0, 2, 4, 194, 0, 2, 4, 81, 0, 2, 3, 201, 0, 2, 3, 104, 0, 2, 3, 58, 0, 2, 3, 8, 0, 2, 2, 181, 0, 2, 2, 75, 0, 2, 1, 244, 0, 2, 1, 179],
      [UInt8](repeating: 0xFF, count: 40),
      [UInt8](repeating: 0xFF, count: 40),
      [UInt8](repeating: 0xFF, count: 40),
      [UInt8](repeating: 0xFF, count: 40),
      [UInt8](repeating: 0xFF, count: 40),
      [UInt8](repeating: 0xFF, count: 40),
      [UInt8](repeating: 0xFF, count: 40),
      [255, 255, 255, 19, 255, 255, 254, 226, 255, 255, 254, 145, 255, 255, 254, 86, 255, 255, 254, 69, 255, 255, 254, 52, 255, 255, 254, 12, 255, 255, 253, 214, 255, 255, 253, 188, 255, 255, 253, 200]
    ]

    static let savedPacketsBy400: [[UInt8]?] = [
      nil,
      nil,
      [0, 2, 4, 194, 0, 2, 4, 214, 0, 2, 4, 219, 0, 2, 4, 252, 0, 2, 5, 52, 0, 2, 5, 84, 0, 2, 5, 74, 0, 2, 5, 33, 0, 2, 5, 7, 0, 2, 4, 249,
      0, 2, 4, 194, 0, 2, 4, 81, 0, 2, 3, 201, 0, 2, 3, 104, 0, 2, 3, 58, 0, 2, 3, 8, 0, 2, 2, 181, 0, 2, 2, 75, 0, 2, 1, 244, 0, 2, 1, 179,
      255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 19, 255, 255, 254, 226, 255, 255, 254, 145, 255, 255, 254, 86, 255, 255, 254, 69, 255, 255, 254, 52, 255, 255, 254, 12, 255, 255, 253, 214, 255, 255, 253, 188, 255, 255, 253, 200]
    ]
  }
}
