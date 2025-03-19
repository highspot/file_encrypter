//
//  Random.swift
//  file_encrypter
//
//  Created by Sarbagya Dhaubanjar on 15/03/2025.
//

import Foundation
import CommonCrypto

class Random {
    class func generateBytes(byteCount: Int) throws -> Data {
        guard byteCount > 0 else {
            throw RandomizationError.invalidParameter("RNG: Invalid Parameter")
        }
        
        var bytes = Data(count: byteCount)
        let status = bytes.withUnsafeMutableBytes { buffer in
            CCRandomGenerateBytes(buffer.baseAddress!, byteCount)
        }
        
        guard status == kCCSuccess else {
            throw RandomizationError.randomGenerationFailed(status: Int(status))
        }
        return bytes
    }
}

enum RandomizationError: Error {
    case invalidParameter(String)
    case randomGenerationFailed(status: Int)
}
