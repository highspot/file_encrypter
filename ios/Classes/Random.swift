//
//  Random.swift
//  file_encrypter
//
//  Created by Sarbagya Dhaubanjar on 6/26/20.
//

import Foundation
import CommonCrypto

class Random{
    class func generateBytes(byteCount: Int) throws -> [UInt8]{
        guard byteCount > 0 else {
            throw "RNG: Invalid Parameter"
        }
        var bytes: [UInt8] = Array(repeating: UInt8(0), count: byteCount)
        let status = CCRandomGenerateBytes(&bytes, byteCount)
        
        guard status == kCCSuccess else {
            throw status.description
        }
        return bytes
    }
}

extension String: LocalizedError {
    public var errorDescription: String? {return self}
}


