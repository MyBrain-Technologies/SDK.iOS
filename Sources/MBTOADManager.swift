//
//  MBTOADManager.swift
//  MyBrainTechnologiesSDK-iOS
//
//  Created by facileit on 25/06/2018.
//  Copyright © 2018 MyBrainTechnologies. All rights reserved.
//

import Foundation


class MBTOADManager {
    
    //MARK: - Variable
    
    ///Prefix Binary
    static let BINARY_HOOK = "mm-ota-"
    ///Extension Binary
    static let BINARY_FORMAT = ".bin"
    ///Version separation component
    static let FWVERSION_REGEX = "_"
    
    let OAD_BLOCK_SIZE = 18
    let HAL_FLASH_WORD_SIZE = 4
    let OAD_CRC_OFFSET = 0x278
    let OAD_FILE_LENGTH_OFFSET = 0x274
    let OAD_FW_VERSION_OFFSET = 0x27C
    let TARGET_FLASH_PAGE_SIZE = 0x100
    let OAD_BUFFER_SIZE:Int
    static let FILE_BUFFER_SIZE = 256000

    ///The data of the Bin
    var mFileBuffer = [UInt8]()
    ///the Array of data in Array of OAD_BLOCK_SIZE
    var mOadBuffer = [[UInt8]]()
    ///The metadata of OAD Progress
    let mProgInfo = ProgInfo()
    
    ///Length of the mFileBuffer
    var mFileLength:Int = 0
    ///Version of the binary
    var fwVersion:String
    
    
    //MARK: - Init Methods
    /// Init the OADManager which prepare for send the Binary to the Melomind
    ///
    /// - Parameter fileName: the file name of the binary
    init(_ fileName:String) {
        OAD_BUFFER_SIZE = 2 + OAD_BLOCK_SIZE
        if let filePath = Bundle(identifier: "com.MyBrainTech.MyBrainTechnologiesSDK")?.path(forResource: fileName, ofType: MBTOADManager.BINARY_FORMAT),
            let data = NSData(contentsOfFile: filePath){
            
            mFileBuffer = [UInt8](repeating: 0, count: data.length)
            
            data.getBytes(&mFileBuffer, length: data.length * MemoryLayout<UInt8>.size)
            
            mFileLength = mFileBuffer.count
            fwVersion = fileName.components(separatedBy: "-")[2] // mm-ota-x_y_z
            fwVersion = fwVersion.replacingOccurrences(of: MBTOADManager.FWVERSION_REGEX, with: ".")
            createBufferFromBinaryFile()
        } else {
            mFileLength = 0
            fwVersion = ""
        }

    }
    
    
    //MARK: - OADManager Methods
    
    /// Prepare the buffer and the progress info
    func createBufferFromBinaryFile() {
        mProgInfo.reset(mFileLength,OAD_BLOCK_SIZE: OAD_BLOCK_SIZE)
        var tempBuffer:[UInt8]
        
        while mProgInfo.iBlock < mProgInfo.nBlock {
            tempBuffer = [UInt8]()
            tempBuffer.append(ConversionUtils.loUInt16(v: mProgInfo.iBlock))
            tempBuffer.append(ConversionUtils.hiUInt16(v: mProgInfo.iBlock))
            if (mProgInfo.iBytes + OAD_BLOCK_SIZE) > mFileLength {
//                let remainder = MBTOADManager.mFileLength - mProgInfo.iBytes
                tempBuffer += [UInt8](mFileBuffer[mProgInfo.iBytes ..< mFileBuffer.count])
                
                while tempBuffer.count < OAD_BLOCK_SIZE + 2 {
                    tempBuffer.append(UInt8(0xFF))
                }
            } else {
                tempBuffer += [UInt8](mFileBuffer[mProgInfo.iBytes ..< mProgInfo.iBytes + OAD_BLOCK_SIZE])
            }
            
            mProgInfo.iBlock += 1
            mProgInfo.iBytes += OAD_BLOCK_SIZE
            mOadBuffer.append(tempBuffer)
        }
        
        mProgInfo.reset(mFileLength,OAD_BLOCK_SIZE: OAD_BLOCK_SIZE)
    }
    
    /// get the data to be send at the Melomind and increase the counter
    ///
    /// - Returns: A *Data* object which need to be send to the Melomind
    func getNextOADBufferData() -> Data {
        let block = mOadBuffer[Int(mProgInfo.iBlock)]
      let data = Data(block)
        mProgInfo.iBlock += 1
        return data
    }
    
    /// Get firmware version in octets
    ///
    /// - Returns: An Array of *UInt8* which is the firmware version in octets
    func getFWVersionAsByteArray() -> [UInt8] {
        var bytesArray = [UInt8]()
        for i in 0 ..< 2 {
            bytesArray.append(mFileBuffer[OAD_FW_VERSION_OFFSET + i])
        }
        return bytesArray
    }
    
    //MARK: - Progess OAD info

    class ProgInfo {
        var iBytes:Int = 0
        var iBlock:Int16 = 0
        var nBlock:Int16 = 0
        
        /// Reset the ProgInfo
        ///
        /// - Parameters:
        ///   - mFileLength: A *Int* instance which is the size of mFileBuffer
        ///   - OAD_BLOCK_SIZE: A *Int* instance which is the size of one block send to Melomind
        func reset(_ mFileLength:Int, OAD_BLOCK_SIZE:Int) {
            iBytes = 0
            iBlock = 0
            nBlock =  Int16((( mFileLength / (OAD_BLOCK_SIZE)) + ((mFileLength % OAD_BLOCK_SIZE) == 0 ? 0 : 1)))
        }
    }
 
}


class ConversionUtils {
    
    static func loUInt16(v:Int16) -> UInt8 {
        return UInt8(v & 0xFF)
    }
    
    static func hiUInt16(v:Int16) -> UInt8 {
        return UInt8(v >> 8 )
    }
}

/// State of the OAD
public enum OADStateType:Int {
    /// The process has not started
    case DISABLE = -1
    /// The process has started
    case START_OAD = 0
    /// The Melomind is ready to receive the binary
    case READY = 1
    /// The SDK is sending the binary
    case IN_PROGRESS = 2
    /// The Melomind has received all the binary
    case OAD_COMPLETE = 3
    /// The SDK needs that the bluetooth device reboot
    case REBOOT_BLUETOOTH = 4
    /// The SDK try to reconnect the Melomind
    case CONNECT = 5
    
    
    /// Decription Error
    var description:String {
        switch self {
        case .DISABLE :
            return "OAD disable"
        case .START_OAD :
            return "Start to process OAD"
        case .READY :
            return "Melomind is ready to transfert OAD"
        case .IN_PROGRESS :
            return "OAD is in progress"
        case .OAD_COMPLETE :
            return "OAD is complete"
        case .REBOOT_BLUETOOTH :
            return "need to reboot bluetooth Device"
        case .CONNECT :
            return "try to reconnect the Melomind"
        }
    }
}

func >(f:OADStateType,s:OADStateType) -> Bool {
    return f.rawValue > s.rawValue
}

func <(f:OADStateType,s:OADStateType) -> Bool {
    return f.rawValue < s.rawValue
}

func >=(f:OADStateType,s:OADStateType) -> Bool {
    return f.rawValue > s.rawValue || f.rawValue == s.rawValue
}

func <=(f:OADStateType,s:OADStateType) -> Bool {
    return f.rawValue < s.rawValue || f.rawValue == s.rawValue
}
