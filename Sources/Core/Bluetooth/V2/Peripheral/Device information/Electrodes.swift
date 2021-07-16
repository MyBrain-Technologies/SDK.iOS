import Foundation

public struct Electrodes: Equatable, Codable {
  public let acquisitions: [ElectrodeLocation]
  public let references: [ElectrodeLocation]
  public let grounds: [ElectrodeLocation]
}
