import Foundation
import RealmSwift

/// Electrode location model.
class MBTAcquistionLocation: Object {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// Value (in the enum) of the electrode, for Realm.
  @objc fileprivate dynamic var rawType = -1

  /// Human Readable value of an electrode location.
  var type: ElectrodeLocation {
    get { return ElectrodeLocation(rawValue: rawType)! }
    set { rawType = newValue.rawValue }
  }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /// Properties to ignore (Realm won't persist these).
  override public static func ignoredProperties() -> [String] {
    return ["type"]
  }
}
