import Foundation

/*******************************************************************************
 * MailBoxA2DPResponse
 *
 * Mail Box Response of A2DP Connection
 *
 ******************************************************************************/
// Good
enum MailBoxA2DPResponse: UInt8, CaseIterable {
  case inProgress = 0x01
  case failedBadAdress = 0x02
  case failedAlreadyConnected = 0x04
  case failedTimeout = 0x08
  case linkKeyInvalid = 0x10
  case success = 0x80

  static func getA2DPResponse(from uint8: UInt8) -> [MailBoxA2DPResponse] {
    let arrayResponse = allCases.filter() {
      uint8 & $0.rawValue == $0.rawValue
    }

    return arrayResponse
  }
}
