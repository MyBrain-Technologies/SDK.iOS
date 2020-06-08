import Foundation
import RealmSwift

struct EEGQualityProcessor {

  static func computeQualityValue(channelsData data: List<ChannelsData>,
                                  sampRate: Int,
                                  packetLength: Int,
                                  nbChannel: Int) -> [Float] {
    let dataArray = Array(data.map() { $0.values }.joined())

    log.verbose("Compute quality value. Number of NaN values",
                context: dataArray.filter() { $0.isNaN }.count)

    // Perform the computation.
    let qualities =
      MBTQualityCheckerBridge.computeQuality(dataArray,
                                             sampRate: sampRate,
                                             nbChannels: nbChannel,
                                             packetLength: packetLength)

    // Return the quality values.
    let qualitySwift = qualities as? [Float] ?? []

    if qualitySwift.count < 2 {
      log.info("computeQualityValue - quality count inf à 2")
      log.info("computeQualityValue - nb channels", context: nbChannel)
      log.info("computeQualityValue - samp rate", context: sampRate)
      log.info("computeQualityValue - array count", context: dataArray.count)
      log.info("computeQualityValue - packet length", context: packetLength)
    }

    return qualitySwift
  }
}
