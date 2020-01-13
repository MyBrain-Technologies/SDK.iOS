import Foundation

class BinariesFileFinder {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  let bundle = Bundle(identifier: "com.MyBrainTech.MyBrainTechnologiesSDK")!

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  var binaries: [URL] {
    return bundle.urls(forResourcesWithExtension: "bin",
                       subdirectory: nil) ?? []
  }

  func binaries(forIndusVersion indus: IndusVersion) -> [URL] {
    let pattern = indus.binaryNameRegex
    guard let regex = try? NSRegularExpression(pattern: pattern,
                                               options: []) else {
      return []
    }
    return binaries.filter() {
      let string = $0.relativeString
      let range = NSRange(location: 0, length: string.count)
      let matches = regex.matches(in: string, range: range)
      return matches.count > 0
    }
  }

  func getLastBinaryVersionFileName() -> String? {
    let sortedBinaries =
      binaries.sorted() { $0.relativeString < $1.relativeString }

    guard let latestURLBinary = sortedBinaries.last else { return nil }

    return latestURLBinary.relativeString.components(separatedBy: ".").first
  }
}

extension String {
  
}
