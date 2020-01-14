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

class ArrayUtils {

  func compareArrayVersion(arrayA: [String],
                           isGreaterThan arrayB: [String]) -> Int {
    let coeffArrayA =
      Int(arrayA[0])! * 10000 + Int(arrayA[1])! * 100 + Int(arrayA[2])!

    let coeffArrayB =
      Int(arrayB[0])! * 10000 + Int(arrayB[1])! * 100 + Int(arrayB[2])!

    if coeffArrayA > coeffArrayB {
      return 1
    }

    if coeffArrayA < coeffArrayB {
      return -1
    }

    return 0

  }
}
