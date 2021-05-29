import Foundation

class DeviceInformationBuilder {

  //----------------------------------------------------------------------------
  // MARK: - Typealias
  //----------------------------------------------------------------------------

  typealias DeviceInformationBuildResult = (productName: String,
                                            deviceId: String,
                                            hardwareVersion: String,
                                            firmwareVersion: String)

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //
  // Information properties are `private(set)` in order to prevent the client
  // to set them to nul and shouldn't have partiel information during building.
  //----------------------------------------------------------------------------

  /// The commercial name of the device.
  private var productName: String? {
    didSet {
      buildIfPossible()
    }
  }

  /// The product specific serial number.
  private var deviceId: String? {
    didSet {
      buildIfPossible()
    }
  }

  /// The product hardware version.
  private var hardwareVersion: String? {
    didSet {
      buildIfPossible()
    }
  }

  /// The product firmware version.
  private var firmwareVersion: String? {
    didSet {
      buildIfPossible()
    }
  }

  /******************** Build ********************/

  private var isReadyToBuild: Bool {
    guard productName != nil,
          deviceId != nil,
          hardwareVersion != nil,
          firmwareVersion != nil else {
      return false
    }

    return true
  }

  /******************** Callback ********************/

  var didFail: (() -> Void)?

  var didBuild: ((DeviceInformationBuildResult) -> Void)?

  //----------------------------------------------------------------------------
  // MARK: - Build
  //----------------------------------------------------------------------------

  func add(productName: String) {
    self.productName = productName
  }

  func add(deviceId: String) {
    self.deviceId = deviceId
  }

  func add(hardwareVersion: String) {
    self.hardwareVersion = hardwareVersion
  }

  func add(firmwareVersion: String) {
    self.firmwareVersion = firmwareVersion
  }

  private func buildIfPossible() {
    if isReadyToBuild {
      build()
    }
  }

  private func build() {
    guard let productName = productName,
          let deviceId = deviceId,
          let hardwareVersion = hardwareVersion,
          let firmwareVersion = firmwareVersion else {
      didFail?()
      return
    }
    let result = (productName, deviceId, hardwareVersion, firmwareVersion)
    didBuild?(result)
  }

  private func reset() {
    productName = nil
    deviceId = nil
    hardwareVersion = nil
    firmwareVersion = nil
  }

}
