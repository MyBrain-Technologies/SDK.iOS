import Foundation
import RealmSwift

/*******************************************************************************
 * Quality
 *
 * One quality value for one channel.
 *
 ******************************************************************************/
public class Quality: Object {

  /// Value property of the *Quality*.
  @objc public dynamic var value: Float = 0

  /// Special init with the value of *Quality*.
  public convenience init(data: Float) {
    self.init()
    self.value = data
  }
}
