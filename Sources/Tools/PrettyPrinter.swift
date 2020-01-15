import Foundation

enum LogType {
  case ln
  case ble
  case url
  case error
  case date
  case obj
  case any

  var emoji: String {
    switch self {
    case .any: return "⚪️"
    case .ble: return "📲"
    case .date: return "🕒"
    case .error: return "❗️"
    case .ln: return "✏️"
    case .obj: return "◽️"
    case .url: return "🌏"
    }
  }
}

class PrettyPrinter {

  static var prefix = "[SDK] "

  //----------------------------------------------------------------------------
  // MARK: - Log
  //----------------------------------------------------------------------------

  static func log<T>(_ type: LogType, _ object: T) {
    log([type], object)
  }

  static func log<T>(_ types: [LogType], _ object: T) {
    let description = String(describing: object)
    let emojies = types.map() { $0.emoji }.joined()
    print("\(prefix) \(emojies) \(description)")
  }

  //----------------------------------------------------------------------------
  // MARK: - Error
  //----------------------------------------------------------------------------

  static func error(_ object: Error) {
    PrettyPrinter.log(.error, object)
  }

  static func error<T>(_ type: LogType, _ object: T) {
    PrettyPrinter.log([.error, type], object)
  }

  static func error(_ type: LogType, _ message: String, _ error: Error) {
    PrettyPrinter.log([.error, type], "\(message): \(error)")
  }

  //----------------------------------------------------------------------------
  // MARK: - Custom
  //----------------------------------------------------------------------------

  static func network<T>(_ object: T) {
    PrettyPrinter.log(.url, object)
  }

  static func bluetooth<T>(_ object: T) {
    PrettyPrinter.log(.ble, object)
  }

  static func writing<T>(_ object: T) {
    PrettyPrinter.log(.ln, object)
  }

}
