//
//  String+extension.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by Mathilde on 23/01/2019.
//  Copyright © 2019 MyBrainTechnologies. All rights reserved.
//

import Foundation

class CSVConverter {

  static public func data(fromFile filename: String,
                          lineSeparator: String,
                          columnSeparator: String)  -> [[String]] {
    guard let content = try? String(contentsOfFile: filename, encoding: .utf8)
      else {
        return [[String]]()
    }

    clearInput(content)

    return CSVConverter.data(fromString:content,
                             lineSeparator: lineSeparator,
                             columnSeparator: columnSeparator)
  }

  static public func data(fromString string: String,
                          lineSeparator: String,
                          columnSeparator: String) -> [[String]] {
    let clearContent = clearInput(string)

    let lines = clearContent.components(separatedBy: lineSeparator)
    var data = [[String]]()

    for line in lines {
      if !line.isEmpty {
        data.append(line.components(separatedBy: columnSeparator))
      }
    }

    return data
  }

  @discardableResult
  static private func clearInput(_ string: String) -> String {
    return string.replacingOccurrences(of: "\r", with: "")
  }

}
