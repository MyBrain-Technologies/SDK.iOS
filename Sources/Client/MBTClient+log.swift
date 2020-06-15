//
//  MBTClient+log.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by Mathilde Ressier on 05/05/2020.
//  Copyright © 2020 MyBrainTechnologies. All rights reserved.
//

import Foundation
import SwiftyBeaver

//----------------------------------------------------------------------------
// MARK: - Log
//----------------------------------------------------------------------------

let log = SwiftyBeaver.self

//----------------------------------------------------------------------------
// MARK: - Options
//----------------------------------------------------------------------------

public enum LogOptions {
  case acquisition
  case headsetServices
  case mailboxService
}

//----------------------------------------------------------------------------
// MARK: - MBTClient + log
//----------------------------------------------------------------------------

extension MBTClient {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private var hideAcquisitionFilter: FilterType {
    return Filters.Path.excludes("EEGAcquisition")
  }

  private var hideHeadsetServicesFilters: [FilterType] {
    return [
      Filters.Message.excludes("Did update value for characteristic"),
      Filters.Message.excludes("Brain activity service"),
      Filters.Message.excludes("Headset status service"),
      Filters.Message.excludes("Device battery service")
    ]
  }

  private var hideMailBoxFilter: FilterType {
    return Filters.Message.excludes("Mailbox")
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  public func initLog(logToFile: Bool,
                      isDebugMode: Bool = false,
                      options: [LogOptions] = []) {
    log.removeAllDestinations()

    var destination = getDestination(isFile: logToFile)
    destination = setupDestination(destination, isDebugMode: isDebugMode)
    destination = addFilters(on: destination, options: options)

    log.addDestination(destination)
  }

  private func getDestination(isFile: Bool) -> BaseDestination {
    return isFile ? FileDestination() : ConsoleDestination()
  }

  private func setupDestination(_ destination: BaseDestination,
                                isDebugMode: Bool = false) -> BaseDestination {
    let debugFormat = "[SDK] $DHH:mm:ss ($N.$F:$l) $C$L $M $X"
    let defaultFormat = "[SDK] $DHH:mm:ss $C$L $M $X"
    destination.format = isDebugMode ? debugFormat : defaultFormat
    destination.minLevel = isDebugMode ? .verbose : .info

    return destination
  }

  private func addFilters(on destination: BaseDestination,
                          options: [LogOptions]) -> BaseDestination {
    var filters = [FilterType]()
    if !options.contains(.acquisition) {
      filters.append(hideAcquisitionFilter)
    }

    if !options.contains(.headsetServices) {
      filters.append(contentsOf: hideHeadsetServicesFilters)
    }

    if !options.contains(.headsetServices) {
      filters.append(hideMailBoxFilter)
    }

    for filter in filters {
      destination.addFilter(filter)
    }

    return destination
  }

}
