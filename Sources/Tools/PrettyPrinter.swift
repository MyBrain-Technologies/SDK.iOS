//
//  PrettyPrinter.swift
//  easyvoyage
//
//  Created by facileit on 14/11/16.
//  Copyright © 2016 webedia. All rights reserved.
//

import Foundation

enum log {
    case ln(_: String)
    case ble(_:String)
    case url(_: String)
    case error(_: NSError)
    case date(_: NSDate)
    case obj(_: AnyObject)
    case any(_: Any)
}

func prettyPrint(_ target: log?) {
    guard let target = target else { return }
    
    func log<T>(emoji: String, _ object: T) {
        print("[SDK] " + emoji + " " + String(describing: object))
    }
    
    switch target {
    case .ln(let line):
        log(emoji: "✏️", line)
        
    case .url(let url):
        log(emoji: "🌏", url)
        
    case .error(let error):
        log(emoji: "❗️", error)
        
    case .any(let any):
        log(emoji: "⚪️", any)
        
    case .obj(let obj):
        log(emoji: "◽️", obj)
        
    case .date(let date):
        log(emoji: "🕒", date)
    case .ble(let string):
        log(emoji: "📲", string)
    }
}
