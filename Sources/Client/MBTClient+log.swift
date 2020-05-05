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
// MARK: - MBTClient + log
//----------------------------------------------------------------------------

extension MBTClient {

  public func initLog(logToFile: Bool, isDebugMode: Bool = false) {
    log.removeAllDestinations()

    let destination = logToFile ? FileDestination() : ConsoleDestination()

    let debugFormat = "[SDK] $DHH:mm:ss ($N.$F:$l) $C$L $M $X"
    let defaultFormat = "[SDK] $DHH:mm:ss $C$L $M $X"
    destination.format = isDebugMode ? debugFormat : defaultFormat
    destination.minLevel = isDebugMode ? .verbose : .info
    log.addDestination(destination)
  }
}
