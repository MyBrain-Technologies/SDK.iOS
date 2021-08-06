import Foundation

/*******************************************************************************
 * ImsDeserializer
 *
 * Deserialize ims values received from headset to usable values.
 *
 ******************************************************************************/

final class ImsDeserializer {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private let shiftTo32Bytes: Int32
  private let checkSign: Int32
  private let negativeMask: Int32
  private let positiveMask: Int32
  private let divider: Int

  /// Constants to decode eeg values to float relax indexes values
  private let voltageADS1299: Float = (0.286 * pow(10, -6)) / 8.0

  private let axisCount: Int

  init(axisCount: Int = 3) {
    shiftTo32Bytes = 8 + 4
    checkSign = (0x80 << shiftTo32Bytes)
    negativeMask = (0xFFFFFFF << (32 - shiftTo32Bytes))
    positiveMask = (~negativeMask)
    divider = 2

    self.axisCount = axisCount
  }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /// Deserialize uint8 values received from headset to X-Y-Z (float) uint8 values
  func deserializeToXYZ(bytes: [UInt8]) -> [[[UInt8]]] {
    let chunckedBytes = bytes.chunked(into: 2)
    let spreadedBytes = chunckedBytes.spread(numberOfArrays: axisCount) {
      index, _ in index % axisCount
    }

    return spreadedBytes
  }

}
