import Foundation
import RealmSwift

/*******************************************************************************
 * ChannelData
 *
 * One EEG value from one channel.
 *
 ******************************************************************************/
public class ChannelData: Object {
  /// Value property of a *Channel*.
  @objc public dynamic var value: Float = 0

  /// Special init with the value of *ChannelData*.
  public convenience init(data: Float) {
    self.init()
    self.value = data
  }
}

/*******************************************************************************
 * ChannelDatas
 *
 * All values from one channel.
 *
 ******************************************************************************/
public class ChannelDatas: Object {
  /// *RLMArray* of *ChannelData*.
  public let value = List<ChannelData>()
}
