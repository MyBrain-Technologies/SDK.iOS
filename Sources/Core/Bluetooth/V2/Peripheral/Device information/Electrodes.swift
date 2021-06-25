import Foundation

public struct Electrodes: Codable {
  let acquisitions: [ElectrodeLocation]
  let references: [ElectrodeLocation]
  let grounds: [ElectrodeLocation]
}
