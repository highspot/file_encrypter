//
//  FileEncrypterPlugin.swift
//  file_encrypter
//
//  Created by Sarbagya Dhaubanjar on 15/03/2025.
//

import CommonCrypto

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

public class FileEncrypterPlugin: NSObject, FlutterPlugin, FileEncrypterApi {
    let bufferSize = 8192
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FileEncrypterPlugin()
        // Workaround for https://github.com/flutter/flutter/issues/118103.
#if os(iOS)
        let messenger = registrar.messenger()
#else
        let messenger = registrar.messenger
#endif
        FileEncrypterApiSetup.setUp(binaryMessenger: messenger, api: instance)
    }
    
    internal func encrypt(inFileName:String, outFileName: String, completion: @escaping (Result<String, any Error>) -> Void){
        DispatchQueue.global(qos: .background).async {
            guard let fileIn = InputStream(fileAtPath: inFileName) else{
                DispatchQueue.main.async {
                    completion(Result.failure(PigeonError(code: "INIT_FAILED", message: "Failed to initialize input stream.", details: "")))
                }
                return
            }
            guard let fileOut = OutputStream(toFileAtPath: outFileName, append: false) else {
                DispatchQueue.main.async {
                    completion(Result.failure(PigeonError(code: "INIT_FAILED", message: "Failed to initialize output stream.", details: "")))
                }
                return
            }
            fileIn.open()
            fileOut.open()
            let iv  = try! Random.generateBytes(byteCount: 16)
            guard  let secretKey = self.createAlphaNumericRandomString(length: kCCKeySizeAES256) else{
                DispatchQueue.main.async {
                    completion(Result.failure(PigeonError(code: "INVALID_KEY", message: "Invalid Key", details:"")))
                }
                return
            }
            let key = arrayFrom(secretKey)
            
            
            let bytesWritten = fileOut.write(iv, maxLength: iv.count)
            
            let encryptor = try! ChunkCryptor(encrypt: true, key: key, iv: iv)
            guard bytesWritten == iv.count else{
                DispatchQueue.main.async {
                    completion(Result.failure(PigeonError(code: "IV_READ_FAILED", message: "Failed to read IV from encrypted output file.", details: "")))
                }
                return
            }
            
            self.crypt(action: encryptor, from: fileIn, to: fileOut, taking: self.bufferSize)
            
            fileOut.close()
            fileIn.close()
            
            DispatchQueue.main.async {
                completion(Result.success(secretKey.toBase64()))
            }
        }
    }
    
    internal func decrypt(key:String, inFileName:String, outFileName: String, completion: @escaping (Result<Void, any Error>) -> Void){
        DispatchQueue.global(qos: .background).async {
            guard let fileIn = InputStream(fileAtPath: inFileName) else{
                DispatchQueue.main.async {
                    completion(Result.failure(PigeonError(code: "INIT_FAILED", message: "Failed to initialize input stream.", details: "")))
                }
                return
            }
            guard let fileOut = OutputStream(toFileAtPath: outFileName, append: false) else {
                DispatchQueue.main.async {
                    completion(Result.failure(PigeonError(code: "INIT_FAILED", message: "Failed to initialize output stream.", details: "")))
                }
                return
            }
            fileIn.open()
            fileOut.open()
            
            guard let secretkey = key.fromBase64() else{
                DispatchQueue.main.async {
                    completion(Result.failure(PigeonError(code: "INVALID_KEY", message: "Invalid Key", details: "")))
                }
                return
            }
            var iv  = Array<UInt8>(repeating: 0, count: 16)
            let key = arrayFrom(secretkey)
            
            let bytesRead = fileIn.read(&iv, maxLength: iv.count)
            
            let decryptor = try! ChunkCryptor(encrypt: false, key: key, iv: iv)
            guard bytesRead == iv.count else{
                DispatchQueue.main.async {
                    completion(Result.failure(PigeonError(code: "IV_READ_FAILED", message: "Failed to read IV from encrypted output file.", details: "")))
                }
                return
            }
            
            self.crypt(action: decryptor, from: fileIn, to: fileOut, taking: self.bufferSize)
            
            fileOut.close()
            fileIn.close()
            
            DispatchQueue.main.async {
                completion(Result.success(()))
            }
        }
    }
    
    private func createAlphaNumericRandomString(length: Int) -> String? {
        let randomNumberModulo: UInt8 = 64
        let symbols = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        var alphaNumericRandomString = ""
        let maximumIndex = symbols.count - 1
        
        while alphaNumericRandomString.count != length {
            let bytesCount = 1
            var randomByte: UInt8 = 0
            
            guard errSecSuccess == SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomByte) else {
                return nil
            }
            let randomIndex = randomByte % randomNumberModulo
            guard randomIndex <= maximumIndex else { continue }
            let symbolIndex = symbols.index(symbols.startIndex, offsetBy: Int(randomIndex))
            alphaNumericRandomString.append(symbols[symbolIndex])
        }
        return alphaNumericRandomString
    }
    
    @discardableResult private func crypt(action sc : ChunkCryptor,from  inputStream: InputStream,to outputStream: OutputStream,taking bufferSize: Int) -> (bytesRead: Int, bytesWritten: Int)
    {
        var inputBuffer = Array<UInt8>(repeating:0, count:1024)
        var outputBuffer = Array<UInt8>(repeating:0, count:1024)
        
        
        var cryptedBytes : Int = 0
        var totalBytesWritten = 0
        var totalBytesRead = 0
        while inputStream.hasBytesAvailable
        {
            let bytesRead = inputStream.read(&inputBuffer, maxLength: inputBuffer.count)
            totalBytesRead += bytesRead
            let status = sc.update(bufferIn: inputBuffer, byteCountIn: bytesRead, bufferOut: &outputBuffer, byteCapacityOut: outputBuffer.count, byteCountOut: &cryptedBytes)
            assert(status == kCCSuccess)
            if(cryptedBytes > 0)
            {
                let bytesWritten = outputStream.write(outputBuffer, maxLength: Int(cryptedBytes))
                assert(bytesWritten == Int(cryptedBytes))
                totalBytesWritten += bytesWritten
            }
        }
        let status = sc.final(bufferOut: &outputBuffer, byteCapacityOut: outputBuffer.count, byteCountOut: &cryptedBytes)
        assert(status == kCCSuccess)
        if(cryptedBytes > 0)
        {
            let bytesWritten = outputStream.write(outputBuffer, maxLength: Int(cryptedBytes))
            assert(bytesWritten == Int(cryptedBytes))
            totalBytesWritten += bytesWritten
        }
        return (totalBytesRead, totalBytesWritten)
    }
}

func arrayFrom(_ string: String) -> [UInt8]{
    let array = [UInt8](string.utf8)
    return array
}

extension String{
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else{
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String{
        return Data(self.utf8).base64EncodedString()
    }
}
