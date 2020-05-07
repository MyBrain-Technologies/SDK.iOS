import Foundation

/*******************************************************************************
 * CSVConverter
 *
 * Read a CSV file and return its content as a nested array of string
 *
 ******************************************************************************/
class CSVConverter {

  /// Read file content and return csv data as a nested array of string
  static public func data(fromFile filename: String,
                          lineSeparator: String,
                          columnSeparator: String) -> [[String]] {
    guard let content = try? String(contentsOfFile: filename, encoding: .utf8)
      else {
        return [[String]]()
    }

    clearInput(content)

    return CSVConverter.data(fromString: content,
                             lineSeparator: lineSeparator,
                             columnSeparator: columnSeparator)
  }

  /// Convert a string representing the content of a CSV as a nested array of string, based on lineSeparator
  /// and column separator.
  static public func data(fromString string: String,
                          lineSeparator: String,
                          columnSeparator: String) -> [[String]] {
    let clearContent = clearInput(string)
    let lines = clearContent.components(separatedBy: lineSeparator)

    let data = lines.compactMap() {
      $0.isEmpty ? nil : $0.components(separatedBy: columnSeparator)
    }

    return data
  }

  @discardableResult
  static private func clearInput(_ string: String) -> String {
    return string.replacingOccurrences(of: "\r", with: "")
  }

}
