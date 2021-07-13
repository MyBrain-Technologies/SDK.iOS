import Foundation

public struct Electrodes: Equatable, Codable {
  let acquisitions: [ElectrodeLocation]
  let references: [ElectrodeLocation]
  let grounds: [ElectrodeLocation]
}
