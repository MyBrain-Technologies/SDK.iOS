//
//  Log.swift
//  MyBrainTechnologiesSDK
//
//  Created by Laurent on 29/06/2021.
//  Copyright © 2021 MyBrainTechnologies. All rights reserved.
//

import Foundation

let log = Logger.shared

class Logger {

  //----------------------------------------------------------------------------
  // MARK: - properties
  //----------------------------------------------------------------------------

  static var shared = Logger()

  var isLogging = true

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  private init() { }

  //----------------------------------------------------------------------------
  // MARK: - Logging
  //----------------------------------------------------------------------------

  /// log something generally unimportant (lowest priority)
  func verbose(_ message: Any,
               _ file: String = #file,
               _ function: String = #function,
               line: Int = #line,
               context: Any? = nil) {
    guard isLogging else { return }
    print(message)
  }

  /// log something which help during debugging (low priority)
  func debug(_ message: Any,
             _ file: String = #file,
             _ function: String = #function,
             line: Int = #line,
             context: Any? = nil) {
    guard isLogging else { return }
    print(message)
  }

  /// log something which you are really interested but which is not an issue
  /// or error (normal priority)
  func info(_ message: Any,
            _ file: String = #file,
            _ function: String = #function,
            line: Int = #line,
            context: Any? = nil) {
    guard isLogging else { return }
    print(message)
  }

  /// log something which may cause big trouble soon (high priority)
  func warning(_ message: Any,
               _ file: String = #file,
               _ function: String = #function,
               line: Int = #line,
               context: Any? = nil) {
    guard isLogging else { return }
    print(message)
  }

  /// log something which will keep you awake at night (highest priority)
  func error(_ message: Any,
             _ file: String = #file,
             _ function: String = #function,
             line: Int = #line,
             context: Any? = nil) {
    guard isLogging else { return }
    print(message)
  }

}
