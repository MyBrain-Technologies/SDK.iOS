import Foundation

class MBTOADManager {

  //----------------------------------------------------------------------------
  // MARK: - Constants
  //----------------------------------------------------------------------------

  private let blockSize = 18
  private let firmwareVersionOffset = 0x27C

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  ///The data of the Bin
  var mFileBuffer = [UInt8]()
  ///the Array of data in Array of OAD_BLOCK_SIZE
  var mOadBuffer = [[UInt8]]()
  ///The metadata of OAD Progress
  let oadProgress = OADProgressInfo()

  ///Length of the mFileBuffer
  var mFileLength:Int = 0
  ///Version of the binary
  var fwVersion: String

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  /// Init the OADManager which prepare for send the Binary to the Melomind
  ///
  /// - Parameter fileName: the file name of the binary
  init(_ fileName: String) {
    guard let filePath = BinariesFileFinder().binary(withFilename: fileName),
      let data = NSData(contentsOfFile: filePath) else {
      mFileLength = 0
      fwVersion = ""
      return
    }

    fwVersion = fileName.getVersionNumber(withSeparator: ".") ?? ""

    mFileBuffer = [UInt8](repeating: 0, count: data.length)

    data.getBytes(&mFileBuffer, length: data.length * MemoryLayout<UInt8>.size)

    mFileLength = mFileBuffer.count
    createBufferFromBinaryFile()
  }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /// Prepare the buffer and the progress info
  func createBufferFromBinaryFile() {
    var tempBuffer:[UInt8]

    oadProgress.reset(mFileLength, OAD_BLOCK_SIZE: blockSize)


    while oadProgress.iBlock < oadProgress.nBlock {
      tempBuffer = [UInt8]()
      tempBuffer.append(oadProgress.iBlock.loUint8)
      tempBuffer.append(oadProgress.iBlock.hiUint16)
      if (oadProgress.iBytes + blockSize) > mFileLength {
        let range = oadProgress.iBytes ..< mFileBuffer.count
        tempBuffer += [UInt8](mFileBuffer[range])

        while tempBuffer.count < blockSize + 2 {
          tempBuffer.append(UInt8(0xFF))
        }
      } else {
        let iBytes = oadProgress.iBytes
        tempBuffer += [UInt8](mFileBuffer[iBytes ..< iBytes + blockSize])
      }

      oadProgress.iBlock += 1
      oadProgress.iBytes += blockSize
      mOadBuffer.append(tempBuffer)
    }

    oadProgress.reset(mFileLength,OAD_BLOCK_SIZE: blockSize)
  }

  /// get the data to be send at the Melomind and increase the counter
  ///
  /// - Returns: A *Data* object which need to be send to the Melomind
  func getNextOADBufferData() -> Data {
    let block = mOadBuffer[Int(oadProgress.iBlock)]
    let data = Data(block)
    oadProgress.iBlock += 1
    return data
  }

  /// Get firmware version in octets
  ///
  /// - Returns: An Array of *UInt8* which is the firmware version in octets
  func getFWVersionAsByteArray() -> [UInt8] {
    var bytesArray = [UInt8]()
    for i in 0 ..< 2 {
      bytesArray.append(mFileBuffer[firmwareVersionOffset + i])
    }
    return bytesArray
  }
}
