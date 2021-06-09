import Foundation

public struct Electrodes: Codable {
  let acquisition: [ElectrodeLocation]
  let reference: [ElectrodeLocation]
  let ground: [ElectrodeLocation]
}
