import Foundation
import RealmSwift

struct EEGQualityProcessor {

  func computeQualityValue(channelsData data: List<ChannelsData>,
                           sampRate: Int,
                           packetLength: Int,
                           nbChannel: Int) -> [Float] {
    // Transform the input data into the format needed by the Obj-C++ bridge.
//    var dataArray = [Float]()
//    var nbNAN = 0

//    for channelDatas in data {
//      dataArray.append(contentsOf: channelDatas.values)
//      for channelData in channelDatas.values {
//        if channelData.isNaN {
//          nbNAN += 1
//        }
//
//        dataArray.append(channelData)
//      }
//    }

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
