import Foundation

/*******************************************************************************
 * ImsDeserializer
 *
 * Deserialize ims values received from headset to usable values.
 *
 ******************************************************************************/

final class ImsDeserializer {

  typealias InputDataConverter = [[[UInt8]]]
  typealias OutputDataConverter = MbtImsPacket

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


  private let nonNegativeByte: UInt8 = 0
  private let negativeByte: UInt8 = 255

  private let axisCount: Int

  private let frameCount: Int

  init(axisCount: Int = 3, frameCount: Int = 2) {
    shiftTo32Bytes = 8 + 4
    checkSign = (0x80 << shiftTo32Bytes)
    negativeMask = (0xFFFFFFF << (32 - shiftTo32Bytes))
    positiveMask = (~negativeMask)
    divider = 2

    self.axisCount = axisCount
    self.frameCount = frameCount
  }

  //----------------------------------------------------------------------------
  // MARK: - Deserialize
  //----------------------------------------------------------------------------

  /// Deserialize uint8 values received from headset to X-Y-Z (float) uint8 values
  func deserialize(bytes: [UInt8], scaleValue: Float) -> OutputDataConverter? {
    let chunckedFrameBytes = bytes.chunked(into: frameCount)
    let chunckedCoordinatesBytes = chunckedFrameBytes.chunked(into: axisCount)
    return convert(from: chunckedCoordinatesBytes, scaleValue: scaleValue)
  }

  //----------------------------------------------------------------------------
  // MARK: - Convertor
  //----------------------------------------------------------------------------

  private func convert(from chunckedCoordinatesBytes: [[[UInt8]]],
               scaleValue: Float) -> OutputDataConverter? {
//    [[[213, 255], [210, 255], [241, 255]], [[213, 255], [211, 255], [241, 255]]]

    var coordinates = [MbtImsPacket.Coordinate]()
    for coordinatesBytes in chunckedCoordinatesBytes {
      guard (coordinatesBytes.count % axisCount) == 0,
            let coordinate = convert(from: coordinatesBytes,
                                           scaleValue: scaleValue) else {
        return nil
      }
      coordinates.append(coordinate)
    }

    return MbtImsPacket(coordinates: coordinates, scaleValue: scaleValue)
  }

  private func convert(from coordinatesBytes: [[UInt8]],
                       scaleValue: Float) -> MbtImsPacket.Coordinate? {
    //    [[213, 255], [210, 00], [241, 255]]
    var results = [Float]()
    for axis in coordinatesBytes {
      var result: Float
      if axis[1] == nonNegativeByte {
        result = Float(axis[0]) * scaleValue
      } else {
        let byteValue = axis[0]
        let correctorValue: UInt8 = 1
        let tmp = negativeByte - (byteValue - correctorValue)
        result = Float(tmp) * -1 * scaleValue
      }
      results.append(result)
    }

    guard results.count == axisCount else { return nil }
    let x = results[0]
    let y = results[1]
    let z = results[2]

    return MbtImsPacket.Coordinate(x, y, z)
  }

}
