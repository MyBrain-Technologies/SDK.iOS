import Foundation

struct RecordFileNameBuilder {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Filename related properties ********************/

  private let dateFormatter: DateFormatter = {
    let format = DateFormatter()
    format.dateFormat = "yyyy-MM-dd--HH:mm:ss"
    return format
  }()

  private let projectName: String = {
    guard let dictionary = Bundle.main.infoDictionary,
      let projectName = dictionary[kCFBundleNameKey as String] as? String else {
        return ""
    }
    return projectName
  }()

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  func build(userId: Int, deviceId: String) -> String {
    let device = "melo_" + deviceId
    let user = "\(userId)"

    let fileName = Constants.EEGPackets.recordFilename
      + "_" + dateFormatter.string(from: Date())
      + "_" + projectName
      + "_" + device
      + "_" + user
      + ".json"

    return fileName
  }
}
