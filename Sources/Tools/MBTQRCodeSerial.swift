//
//  MBTModelNumber.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by Mathilde on 23/01/2019.
//  Copyright © 2019 MyBrainTechnologies. All rights reserved.
//

import Foundation

public class MBTQRCodeSerial : NSObject {
    
    private static var serialFile = "qrcodeSerial"
    
    private var qrCodesTable: [String:String] = [:]
    
    public convenience init(qrCodeisKey: Bool = true) {
        self.init()
        
        guard let filepath = Bundle(identifier: "com.MyBrainTech.MyBrainTechnologiesSDK")?.path(forResource: MBTQRCodeSerial.serialFile, ofType: "csv") else { return }
        
        let data = CSVConverter.data(fromFile: filepath, lineSeparator: "\n", columnSeparator: ",")
        for pair in data {
            let qrCode = pair[0]
            let serialNumber = pair[1]
            if qrCodeisKey {
                qrCodesTable[qrCode] = serialNumber
            } else {
                qrCodesTable[serialNumber] = qrCode
            }
        }
    }
    
    public func value(for key: String) -> String? {
        return qrCodesTable[key]
    }
    
}
