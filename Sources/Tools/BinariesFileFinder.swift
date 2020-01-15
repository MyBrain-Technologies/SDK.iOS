import Foundation

class BinariesFileFinder {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Constants ********************/

  private let bundle: Bundle!

  /******************** Computed ********************/

  var binariesURL: [URL] {
    return bundle.urls(forResourcesWithExtension: "bin",
                       subdirectory: nil) ?? []
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(bundleIndentifier: String = "com.MyBrainTech.MyBrainTechnologiesSDK") {
    self.bundle = Bundle(identifier: bundleIndentifier)!
  }

  //----------------------------------------------------------------------------
  // MARK: - Binaries urls finder
  //----------------------------------------------------------------------------

  func binaries(forIndusVersion indus: IndusVersion) -> [URL] {
    let pattern = indus.binaryNameRegex

    return binariesURL.filter() { $0.relativeString.contains(regex: pattern) }
  }

  func getLastBinaryVersionFileName() -> String? {
    let sortedBinaries =
      binariesURL.sorted() { $0.relativeString < $1.relativeString }

    guard let lastBinaryVersion = sortedBinaries.last else { return nil }

    return lastBinaryVersion.relativeString.withoutExtension
  }

  func higherBinaryFilename(for device: MBTDevice) -> String? {
    guard let deviceIndusVersion = device.deviceInfos?.indusVersion else {
        return nil
    }

    return higherBinaryFilename(for: deviceIndusVersion)
  }

  func higherBinaryFilename(for indus: IndusVersion) -> String? {
    let indusBinaries = binariesURL.filter() {
      $0.relativePath.contains(regex: indus.binaryNameRegex)
    }

    let sortedBinaries = indusBinaries.sorted() {
      $0.relativeString < $1.relativeString
    }

    return sortedBinaries.last?.relativeString.withoutExtension
  }

  func binary(withFilename filename: String) -> String? {
    return bundle.path(forResource: filename,
                       ofType: Constants.binaryExtension)
  }

  //----------------------------------------------------------------------------
  // MARK: - Binaries filename interpret
  //----------------------------------------------------------------------------

  func getBinaryVersion(from filename: String) -> String? {
    let versionRegex = Constants.versionRegex
    return filename.firstMatch(regex: versionRegex)
  }
}
