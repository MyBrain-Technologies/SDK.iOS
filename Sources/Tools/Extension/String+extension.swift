import Foundation

extension String {

  //----------------------------------------------------------------------------
  // MARK: - Filename
  //----------------------------------------------------------------------------

  var withoutExtension: String {
    return self.components(separatedBy: ".").first ?? self
  }

  //----------------------------------------------------------------------------
  // MARK: - Regex
  //----------------------------------------------------------------------------

  func matches(regex: String,
               options: NSRegularExpression.Options = []) -> [String] {
    guard let regex = try? NSRegularExpression(pattern: regex,
                                               options: options) else {
                                                return []
    }

    let string = self as NSString
    let range = NSRange(location: 0, length: self.count)
    let matches = regex.matches(in: self, range: range)
    return matches.map() { string.substring(with: $0.range) }
  }

  func contains(regex: String,
                options: NSRegularExpression.Options = []) -> Bool {
    return matches(regex: regex, options: options).count > 0
  }

  func firstMatch(regex: String,
                  options: NSRegularExpression.Options = []) -> String? {
    return matches(regex: regex, options: options).first
  }
}
