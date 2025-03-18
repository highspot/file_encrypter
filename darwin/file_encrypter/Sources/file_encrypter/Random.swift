//
//  Random.swift
//  file_encrypter
//
//  Created by Sarbagya Dhaubanjar on 15/03/2025.
//

import Foundation
import CommonCrypto

class Random{
    class func generateBytes(byteCount: Int) throws -> [UInt8]{
        guard byteCount > 0 else {
            throw RandomizationError.runtimeError("RNG: Invalid Parameter")
        }
        var bytes: [UInt8] = Array(repeating: UInt8(0), count: byteCount)
        let status = CCRandomGenerateBytes(&bytes, byteCount)
        
        guard status == kCCSuccess else {
            throw RandomizationError.runtimeError(status.description)
        }
        return bytes
    }
}

enum RandomizationError: Error {
    case runtimeError(String)
}
