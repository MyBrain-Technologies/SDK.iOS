import Foundation

protocol MBTError: Error, CustomStringConvertible {
  var error: Error { get }
  var code: Int { get }
}

extension MBTError {
  var error: Error {
    let error = NSError(
      domain: "Bluetooth Manager",
      code: code,
      userInfo: [NSLocalizedDescriptionKey: localizedDescription]
    )
    return error as Error
  }

  var description: String {
    return localizedDescription
  }
}
