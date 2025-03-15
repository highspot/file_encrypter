//
//  FileEncrypterPlugin.swift
//  file_encrypter
//
//  Created by Sarbagya Dhaubanjar on 15/03/2025.
//

import CommonCrypto
import Flutter
import UIKit

public class FileEncrypterPlugin: NSObject, FlutterPlugin, FileEncrypterApi {
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
    
    private func encrypt(from inFileName:String, to outFileName: String, completion: @escaping (Result<String, any Error>) -> Void){
        guard let fileIn = InputStream(fileAtPath: inFileName!) else{
            errorResult("Failed to initialize input stream.")
            return
        }
        guard let fileOut = OutputStream(toFileAtPath: outFileName!, append: false) else {
            errorResult("Failed to initialize output stream.")
            return
        }
        fileIn.open()
        fileOut.open()
        let iv  = try! Random.generateBytes(byteCount: 16)
        guard  let secretKey = createAlphaNumericRandomString(length: kCCKeySizeAES256) else{
            errorResult("Invalid Key")
            return
        }
        let key = arrayFrom(secretKey)
        
        
        let bytesWritten = fileOut.write(iv, maxLength: iv.count)
        
        let encryptor = try! ChunkCryptor(encrypt: true, key: key, iv: iv)
        guard bytesWritten == iv.count else{
            errorResult("Failed to write IV to encrypted output file.")
            return
        }
        
        crypt(action: encryptor, from: fileIn, to: fileOut, taking: bufferSize)
        
        fileOut.close()
        fileIn.close()
        
        successResult(secretKey.toBase64())
    }
    
    private func decrypt(using key:String, from inFileName:String, to outFileName: String, completion: @escaping (Result<Void, any Error>) -> Void){
        guard let fileIn = InputStream(fileAtPath: inFileName!) else{
            errorResult("Failed to initialize input stream.")
            return
        }
        guard let fileOut = OutputStream(toFileAtPath: outFileName!, append: false) else {
            errorResult("Failed to initialize output stream.")
            return
        }
        fileIn.open()
        fileOut.open()
        
        guard let secretkey = baseKey?.fromBase64() else{
            errorResult("Invalid key detected.")
            return
        }
        var iv  = Array<UInt8>(repeating: 0, count: 16)
        let key = arrayFrom(secretkey)
        
        let bytesRead = fileIn.read(&iv, maxLength: iv.count)
        
        let decryptor = try! ChunkCryptor(encrypt: false, key: key, iv: iv)
        guard bytesRead == iv.count else{
            errorResult("Failed to read IV from encrypted output file.")
            return
        }
        
        crypt(action: decryptor, from: fileIn, to: fileOut, taking: bufferSize)
        
        fileOut.close()
        fileIn.close()
        
        successResult(nil)
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
    
    private func successResult(_ data: String?){
        DispatchQueue.main.async {
            self.result(data)
        }
    }
    
    func errorResult(_ description: String){
        DispatchQueue.main.async {
            self.result(FlutterError(code: "", message: description, details: ""))
        }
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
