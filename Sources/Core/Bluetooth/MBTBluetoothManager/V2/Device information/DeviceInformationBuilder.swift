import Foundation

class DeviceInformationBuilder {

  //----------------------------------------------------------------------------
  // MARK: - Error
  //----------------------------------------------------------------------------

  enum DeviceInformationBuilderError: Error {
    case missingDeviceInformation
    case unableToBuildDeviceInformation
  }

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
  // Information properties are `private` in order to prevent the client to have
  // partiel information during building.
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

  var didFail: ((Error) -> Void)?

  var didBuild: ((DeviceInformation) -> Void)?

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
      didFail?(DeviceInformationBuilderError.missingDeviceInformation)
      return
    }

    guard let deviceInformation =
            DeviceInformation(productName: productName,
                              deviceId: deviceId,
                              hardwareVersion: hardwareVersion,
                              firmwareVersion: firmwareVersion) else {
      didFail?(DeviceInformationBuilderError.unableToBuildDeviceInformation)
      return
    }

    didBuild?(deviceInformation)
  }

  private func reset() {
    productName = nil
    deviceId = nil
    hardwareVersion = nil
    firmwareVersion = nil
  }

}
