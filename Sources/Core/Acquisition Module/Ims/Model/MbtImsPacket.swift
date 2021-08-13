import Foundation

public class MbtImsPacket {

  typealias Coordinate = (x: Float, y: Float, z: Float)

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Coordinate ********************/

  let x: Float

  let y: Float

  let z: Float

  let coordinate: Coordinate

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

//  public init(with buffer: Buffer) {
//
//  }

  init(x: Float, y: Float, z: Float) {
    self.x = x
    self.y = y
    self.z = z
    self.coordinate = (x, y, z)
  }

}
