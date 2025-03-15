//
//  ChunkCrypto.swift
//  file_encrypter
//
//  Created by Sarbagya Dhaubanjar on 15/03/2025.
//

import Foundation
import CommonCrypto

class ChunkCryptor{
    
    var status = CCCryptorStatus(kCCSuccess)
    
    convenience init(encrypt isEncryption:Bool, key: [UInt8], iv: [UInt8]) throws {
        guard key.count == kCCKeySizeAES256 else{
            throw ChunkCryptorError.runtimeError("Invalid Key Size")
        }
        self.init(encrypt: isEncryption, keyBuffer: key, keyByteCount: key.count, ivBuffer: iv, ivByteCount: iv.count)
    }
    
    init(encrypt isEncryption:Bool, keyBuffer:UnsafeRawPointer, keyByteCount:Int, ivBuffer: UnsafeRawPointer, ivByteCount: Int) {
        let status = CCCryptorCreate(CCOperation(isEncryption ? kCCEncrypt: kCCDecrypt), CCAlgorithm(kCCAlgorithmAES), CCOptions(kCCOptionPKCS7Padding), keyBuffer, keyByteCount, ivBuffer, context)
        self.status = status
    }
    
    func update(bufferIn: UnsafeRawPointer, byteCountIn: Int, bufferOut: UnsafeMutableRawPointer, byteCapacityOut: Int, byteCountOut: inout Int) -> CCCryptorStatus{
        if(self.status == kCCSuccess){
            return CCCryptorUpdate(context.pointee, bufferIn, byteCountIn, bufferOut, byteCapacityOut, &byteCountOut)
        }
        return self.status
    }
    
    func final(bufferOut: UnsafeMutableRawPointer, byteCapacityOut: Int, byteCountOut: inout Int)-> CCCryptorStatus{
        if(self.status == kCCSuccess){
            return CCCryptorFinal(context.pointee, bufferOut, byteCapacityOut, &byteCountOut)
        }
        return self.status
    }
    
    deinit {
        let status = CCCryptorRelease(context.pointee)
        if(status != kCCSuccess){
            print("WARNING: CCCryptorRelease failed with status \(status).")
        }
        context.deallocate()
    }
    
    fileprivate var context = UnsafeMutablePointer<CCCryptorRef?>.allocate(capacity: 1)
}

enum ChunkCryptorError: Error {
    case runtimeError(String)
}
