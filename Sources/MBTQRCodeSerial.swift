//
//  MBTModelNumber.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by Mathilde on 23/01/2019.
//  Copyright © 2019 MyBrainTechnologies. All rights reserved.
//

import Foundation

public class MBTQRCodeSerial : NSObject {
    
    private var qrCodesTable: [String:String] = [:]
    
    private var qrCodeIsMainKey: Bool = true
    
    public convenience init(fromCSVFile filename: String, qrCodeisKey: Bool = true) {
        self.init()
        
        qrCodeIsMainKey = qrCodeisKey
        
        guard let filepath = Bundle(identifier: "com.MyBrainTech.MyBrainTechnologiesSDK")?.path(forResource: filename, ofType: "csv") else { return }
        
        let data = CSVConverter.data(fromFile: filepath, lineSeparator: "\n", columnSeparator: ",")
        for pair in data {
            let qrCode = pair[0]
            let serialNumber = pair[1]
            if qrCodeIsMainKey {
                qrCodesTable[qrCode] = serialNumber
            } else {
                qrCodesTable[serialNumber] = qrCode
            }
        }
    }
    
}
