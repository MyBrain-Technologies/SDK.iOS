import Foundation

class OADProgressInfo {
  var iBytes: Int = 0
  var iBlock: Int16 = 0
  var nBlock: Int16 = 0

  /// Reset the ProgInfo
  ///
  /// - Parameters:
  ///   - mFileLength: A *Int* instance which is the size of mFileBuffer
  ///   - blockSize: A *Int* instance which is the size of one block send to Melomind
  func reset(_ mFileLength: Int, blockSize: Int) {
    iBytes = 0
    iBlock = 0
    let div = mFileLength / (blockSize)
    let rest = mFileLength % blockSize
    nBlock = Int16(div + (rest == 0 ? 0 : 1))
  }
}
