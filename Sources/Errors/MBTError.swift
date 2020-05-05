import Foundation

protocol MBTError: Error {
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
}
