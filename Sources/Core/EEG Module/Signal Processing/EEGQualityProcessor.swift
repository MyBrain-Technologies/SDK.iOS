import Foundation

/*******************************************************************************
 * EEGQualityProcessor
 *
 * Compute a quality value
 *
 ******************************************************************************/
// GOOD
struct EEGQualityProcessor {

  /// Compute a quality value for `buffer`.
  /// Quality value is used to know if a signal is good enough to be used (as a
  /// relax index or calibration,...)
  static func computeQualityValue(buffer: Buffer,
                                  sampleRate: Int,
                                  packetLength: Int) -> [Float] {
    let channelCount = buffer.count
    let flattenedBuffer = buffer.flattened

    let nanCount = flattenedBuffer.filter() { $0.isNaN }.count
    log.verbose("Compute quality value. Number of NaN values",
                context: nanCount)

    // Perform the computation.
    let qualities =
      MBTQualityCheckerBridge.computeQuality(flattenedBuffer,
                                             sampRate: sampleRate,
                                             nbChannels: channelCount,
                                             packetLength: packetLength)

    // Return the quality values.
    let qualitySwift = qualities as? [Float] ?? []

    if qualitySwift.count < 2 {
      log.info("computeQualityValue - quality count inf à 2")
      log.info("computeQualityValue - nb channels", context: channelCount)
      log.info("computeQualityValue - samp rate", context: sampleRate)
      log.info("computeQualityValue - array count",
               context: flattenedBuffer.count)
      log.info("computeQualityValue - packet length", context: packetLength)
    }

    return qualitySwift
  }
  
}
