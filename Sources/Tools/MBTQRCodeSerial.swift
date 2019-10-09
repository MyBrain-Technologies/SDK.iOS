import Foundation

public class MBTQRCodeSerial: NSObject {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private static var serialFile = "qrcodeSerial"

  private var qrCodesTable: [String:String] = [:]

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  public convenience init(qrCodeisKey: Bool = true) {
    self.init()
    let identifier = "com.MyBrainTech.MyBrainTechnologiesSDK"
    let ressource = MBTQRCodeSerial.serialFile
    guard let bundle = Bundle(identifier: identifier),
      let filepath = bundle.path(forResource: ressource, ofType: "csv") else {
        return
    }

    let data = CSVConverter.data(fromFile: filepath,
                                 lineSeparator: "\n",
                                 columnSeparator: ",")
    for pair in data {
      let qrCode = pair[0]
      let serialNumber = pair[1]
      if qrCodeisKey {
        qrCodesTable[qrCode] = serialNumber
      } else {
        qrCodesTable[serialNumber] = qrCode
      }
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Getter
  //----------------------------------------------------------------------------

  public func value(for key: String) -> String? {
    return qrCodesTable[key]
  }

}
