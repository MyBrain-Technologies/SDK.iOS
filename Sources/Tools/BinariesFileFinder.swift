import Foundation

class BinariesFileFinder {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Constants ********************/

  private let bundle: Bundle!

  /******************** Computed ********************/

  /// List of all the binaries available in the project
  var binariesURL: [URL] {
    return bundle.urls(forResourcesWithExtension: "bin",
                       subdirectory: nil) ?? []
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(bundleIndentifier: String = Constants.bundleName) {
    self.bundle = Bundle(identifier: bundleIndentifier)!
  }

  //----------------------------------------------------------------------------
  // MARK: - Binaries urls finder
  //----------------------------------------------------------------------------

  /// Get list of binaries url in the project available for the given indus version
  func binaries(forIndusVersion indus: IndusVersion) -> [URL] {
    let pattern = indus.binaryNameRegex

    return binariesURL.filter() { $0.relativeString.contains(regex: pattern) }
  }

  /// Get the binary with the higher version compatible with the given device
  func higherBinaryFilename(for device: MBTDevice) -> String? {
    guard let deviceIndusVersion = device.deviceInfos?.indusVersion else {
        return nil
    }

    return higherBinaryFilename(for: deviceIndusVersion)
  }

  /// Get the binary with the higher version compatible with the given indus version
  func higherBinaryFilename(for indus: IndusVersion) -> String? {
    print(binariesURL)
    let indusBinaries = binariesURL.filter() {
      $0.relativePath.contains(regex: indus.binaryNameRegex)
    }

    let sortedBinaries = indusBinaries.sorted() {
      $0.relativeString < $1.relativeString
    }

    return sortedBinaries.last?.relativeString.withoutExtension
  }

  /// Get path of binary with filemame
  /// - Parameter filename: filename of the binary to found
  func binary(withFilename filename: String) -> String? {
    return bundle.path(forResource: filename,
                       ofType: Constants.binaryExtension)
  }

  //----------------------------------------------------------------------------
  // MARK: - Binaries filename interpret
  //----------------------------------------------------------------------------

  /// Extract version from a filename
  /// - Parameter filename: filename of the binary
  func getBinaryVersion(from filename: String) -> String? {
    let versionRegex = Constants.binaryVersionRegex
    return filename.firstMatch(regex: versionRegex)
  }
}
