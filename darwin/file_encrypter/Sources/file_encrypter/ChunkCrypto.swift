//
//  ChunkCrypto.swift
//  file_encrypter
//
//  Created by Sarbagya Dhaubanjar on 15/03/2025.
//

import Foundation
import CommonCrypto

class ChunkCryptor {
    
    var status = CCCryptorStatus(kCCSuccess)
    private var context: CCCryptorRef?
    
    convenience init(encrypt isEncryption: Bool, key: Data, iv: Data) throws {
        guard key.count == kCCKeySizeAES256 else {
            throw ChunkCryptorError.runtimeError("Invalid Key Size")
        }
        self.init(encrypt: isEncryption, keyBuffer: (key as NSData).bytes, keyByteCount: key.count, ivBuffer: (iv as NSData).bytes, ivByteCount: iv.count)
    }
    
    init(encrypt isEncryption: Bool, keyBuffer: UnsafeRawPointer, keyByteCount: Int, ivBuffer: UnsafeRawPointer, ivByteCount: Int) {
        status = CCCryptorCreate(
            CCOperation(isEncryption ? kCCEncrypt : kCCDecrypt),
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(kCCOptionPKCS7Padding),
            keyBuffer,
            keyByteCount,
            ivBuffer,
            &context
        )
    }
    
    func update(bufferIn: UnsafeRawPointer, byteCountIn: Int, bufferOut: UnsafeMutableRawPointer, byteCapacityOut: Int, byteCountOut: inout Int) -> CCCryptorStatus {
        guard let cryptor = context else { return CCCryptorStatus(kCCParamError) }
        return CCCryptorUpdate(cryptor, bufferIn, byteCountIn, bufferOut, byteCapacityOut, &byteCountOut)
    }
    
    func final(bufferOut: UnsafeMutableRawPointer, byteCapacityOut: Int, byteCountOut: inout Int) -> CCCryptorStatus {
        guard let cryptor = context else { return CCCryptorStatus(kCCParamError) }
        return CCCryptorFinal(cryptor, bufferOut, byteCapacityOut, &byteCountOut)
    }
    
    deinit {
        if let cryptor = context {
            let status = CCCryptorRelease(cryptor)
            if status != kCCSuccess {
                print("WARNING: CCCryptorRelease failed with status \(status).")
            }
        }
    }
}

enum ChunkCryptorError: Error {
    case runtimeError(String)
}
