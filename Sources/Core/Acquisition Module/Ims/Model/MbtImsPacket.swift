import Foundation

public class MbtImsPacket {

  public typealias Coordinate = (x: Float, y: Float, z: Float)

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// The timestamp in milliseconds when this packet is created.
  public let timestamp = Int(Date().timeIntervalSince1970 * 1000)

  /// Scale value used during the acquisition.
  public let scaleValue: Float

  /******************** Coordinate ********************/

  public let coordinates: [Coordinate]

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  public init?(with rawCordinates: [[Float]], scaleValue: Float) {
    var coordinates = [Coordinate]()
    for rawCoordinate in rawCordinates {
      guard rawCoordinate.count == 3 else { return nil }
      let x = rawCoordinate[0]
      let y = rawCoordinate[1]
      let z = rawCoordinate[2]
      let coordinate = Coordinate(x, y, z)
      coordinates.append(coordinate)
    }
    self.coordinates = coordinates
    self.scaleValue = scaleValue
  }

  public init(coordinates: [Coordinate], scaleValue: Float) {
    self.coordinates = coordinates
    self.scaleValue = scaleValue
  }

}
