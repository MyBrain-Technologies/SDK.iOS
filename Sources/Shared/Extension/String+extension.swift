import Foundation

extension String {

  //----------------------------------------------------------------------------
  // MARK: - Filename
  //----------------------------------------------------------------------------

  var withoutExtension: String {
    let separator = "."

    var components = self.components(separatedBy: separator)
    if components.count > 1 {
      _ = components.removeLast()
    }

    return components.joined(separator: separator)
  }

  var versionNumber: String? {
    let indusVersionRegex = #"(\d+[_.]){2}\d+"# // was Constants.versionRegex
    return firstMatch(regex: indusVersionRegex)
  }

  func getVersionNumber(withSeparator separator: Character) -> String? {
    return Constants.versionSeparators.reduce(versionNumber) {
      result, character in
      let newResult = result?.replacingOccurrences(of: "\(character)",
                                                   with: "\(separator)")
      return newResult
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - QR Code
  //----------------------------------------------------------------------------

  var isQrCode: Bool {
    return isQrCodeBatch1
      || isQrCodeBatch2
      || isQrCodeBatch3
      || isQrCodeBatch4
      || isQrCodeFSK
      || isQrCodeBatch5
  }

  var isQrCodeBatch1: Bool {
    return starts(with: Constants.DeviceName.qrCodePrefix)
      && count == Constants.DeviceName.qrCodeLength
  }

  var isQrCodeBatch2: Bool {
    return starts(with: Constants.DeviceName.qrCodePrefixBatch2)
      && count == Constants.DeviceName.qrCodeBatch2Length
  }

  var isQrCodeBatch3: Bool {
    return starts(with: Constants.DeviceName.qrCodePrefixBatch3)
      && count == Constants.DeviceName.qrCodeBatch3Length
  }

  var isQrCodeBatch4: Bool {
    return starts(with: Constants.DeviceName.qrCodePrefixBatch4)
      && count == Constants.DeviceName.qrCodeBatch4Length
  }

  var isQrCodeFSK: Bool {
    return starts(with: Constants.DeviceName.qrCodePrefixFSK)
      && count == Constants.DeviceName.qrCodeFSKLength
  }

  var isQrCodeBatch5: Bool {
    return starts(with: Constants.DeviceName.qrCodePrefixBatch5)
      && count == Constants.DeviceName.qrCodeBatch5Length
  }

  //----------------------------------------------------------------------------
  // MARK: - Serial Number
  //----------------------------------------------------------------------------

  var serialNumberFomQRCode: String? {
    let qrCode = self
//    if isQrCodeBatch2 {
//      qrCode.append(Constants.DeviceName.qrCodeBatch2EndCharacter)
//    }
    return MBTQRCodeSerial.shared.serialNumber //MBTQRCodeSerial(qrCodeisKey: true).value(for: qrCode)
  }

  var serialNumberFromDeviceName: String? {
    if isQrCode {
      return serialNumberFomQRCode
    } else {
      let values = components(separatedBy: "_")
      return values.count > 1 ? values.last : nil
    }
  }
}

extension String {

  //----------------------------------------------------------------------------
  // MARK: - Regex
  //----------------------------------------------------------------------------

  func matches(regex: String,
               options: NSRegularExpression.Options = []) -> [String] {
    guard let regex = try? NSRegularExpression(pattern: regex,
                                               options: options) else {
                                                return []
    }

    let string = self as NSString
    let range = NSRange(location: 0, length: self.count)
    let matches = regex.matches(in: self, range: range)
    return matches.map() { string.substring(with: $0.range) }
  }

  func contains(regex: String,
                options: NSRegularExpression.Options = []) -> Bool {
    return matches(regex: regex, options: options).count > 0
  }

  func firstMatch(regex: String,
                  options: NSRegularExpression.Options = []) -> String? {
    return matches(regex: regex, options: options).first
  }
}
