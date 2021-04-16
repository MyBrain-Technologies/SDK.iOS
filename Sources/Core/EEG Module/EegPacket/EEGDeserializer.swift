import Foundation

/*******************************************************************************
 * EEGDeserializer
 *
 * Deserialize eeg values received from headset to relax index usable values.
 *
 ******************************************************************************/
// Good
struct EEGDeserializer {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Constantes to get EEG values from bluetooth ********************/

  static private let shiftTo32Bytes: Int32 = 8 + 4
  static private let checkSign: Int32 = (0x80 << shiftTo32Bytes)
  static private let negativeMask: Int32 = (0xFFFFFFF << (32 - shiftTo32Bytes))
  static private let positiveMask: Int32 = (~negativeMask)
  static private let divider = 2

  /// Constants to decode eeg values to float relax indexes values
  static private let voltageADS1299: Float = (0.286 * pow(10, -6)) / 8

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /// Deserialize uint8 values received from headset to relax indexes (float) values
  static func deserializeToRelaxIndex(
    bytes: [UInt8],
    numberOfElectrodes: Int = 2
  ) -> [[Float]] {
    let bytesConvertedTo32 = convert24to32Bit(bytes: bytes)

    let desamplifiedValues = removeAmplification(values: bytesConvertedTo32)

    let electrodesArray =
      spreadBetweenElectrodes(values: desamplifiedValues,
                              numberOfElectrodes: numberOfElectrodes)

    return electrodesArray
  }

  //----------------------------------------------------------------------------
  // MARK: - Tools
  //----------------------------------------------------------------------------

  /// Spread eeg values between number of electrodes.
  static func spreadBetweenElectrodes(values: [Float],
                                      numberOfElectrodes: Int) -> [[Float]] {
    let electrodesArray = values.spread(numberOfArrays: numberOfElectrodes)
      { index, _ in index % numberOfElectrodes }
    return electrodesArray
  }

  /// Convert a list of bytes on 24 bit to 32 bit values
  static func convert24to32Bit(bytes: [UInt8]) -> [Int32] {
    var values = [Int32]()

    for i in 0 ..< bytes.count / divider  {
      let temp = convert24to32Bit(bytes: bytes, at: divider * i)
      values.append(temp)
    }

    return values
  }

  /// Convert a 24 bit values to 32 bit value. Uses two uint8 value to create a 32 bit value.
  static func convert24to32Bit(bytes: [UInt8], at index: Int) -> Int32 {
    var temp: Int32 = 0x00000000

    temp = (Int32(bytes[index] & 0xFF) << shiftTo32Bytes)
      | Int32(bytes[index + 1] & 0xFF) << (shiftTo32Bytes - 8)

    let isNegative = (temp & checkSign) > 0
    temp = isNegative ? Int32(temp | negativeMask) : Int32(temp & positiveMask)
    return temp
  }

  /// Decode eeg value by removing amplification
  static func removeAmplification(values: [Int32]) -> [Float] {
    return values.map() { Float($0) * voltageADS1299 }
  }
}
