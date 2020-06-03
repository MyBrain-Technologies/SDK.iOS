import Foundation
import RealmSwift

/*******************************************************************************
 * ChannelDatas
 *
 * All values from one channel.
 *
 ******************************************************************************/
public class ChannelsData: Object {
  /// *RLMArray* of *ChannelData*.
  public let values = List<Float>()
}
