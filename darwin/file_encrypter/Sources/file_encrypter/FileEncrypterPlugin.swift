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
    let bufferSize = 65536
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FileEncrypterPlugin()
#if os(iOS)
        let messenger = registrar.messenger()
#else
        let messenger = registrar.messenger
#endif
        FileEncrypterApiSetup.setUp(binaryMessenger: messenger, api: instance)
    }
    
    internal func encrypt(inFileName: String, outFileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let fileIn = InputStream(fileAtPath: inFileName),
                  let fileOut = OutputStream(toFileAtPath: outFileName, append: false) else {
                completion(.failure(PigeonError(code: "INIT_FAILED", message: "Failed to initialize file streams.", details: "")))
                return
            }
            
            fileIn.open()
            fileOut.open()
            
            guard let iv = try? Random.generateBytes(byteCount: 16),
                  let secretKeyData = self.generateRandomKey(length: kCCKeySizeAES256) else {
                completion(.failure(PigeonError(code: "INVALID_KEY", message: "Failed to generate encryption key.", details: "")))
                return
            }
            
            let key = [UInt8](secretKeyData)
            fileOut.write(iv, maxLength: iv.count)
            
            do {
                let encryptor = try ChunkCryptor(encrypt: true, key: key, iv: iv)
                self.crypt(action: encryptor, from: fileIn, to: fileOut)
                fileOut.close()
                fileIn.close()
                completion(.success(secretKeyData.base64EncodedString()))
            } catch {
                completion(.failure(PigeonError(code: "ENCRYPTION_FAILED", message: error.localizedDescription, details: "")))
            }
        }
    }
    
    internal func decrypt(key: String, inFileName: String, outFileName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let fileIn = InputStream(fileAtPath: inFileName),
                  let fileOut = OutputStream(toFileAtPath: outFileName, append: false) else {
                completion(.failure(PigeonError(code: "INIT_FAILED", message: "Failed to initialize file streams.", details: "")))
                return
            }
            
            fileIn.open()
            fileOut.open()
            
            guard let secretKeyData = Data(base64Encoded: key) else {
                completion(.failure(PigeonError(code: "INVALID_KEY", message: "Invalid Base64 Key.", details: "")))
                return
            }
            
            var iv = [UInt8](repeating: 0, count: 16)
            let bytesRead = fileIn.read(&iv, maxLength: iv.count)
            guard bytesRead == iv.count else {
                completion(.failure(PigeonError(code: "IV_READ_FAILED", message: "Failed to read IV from encrypted file.", details: "")))
                return
            }
            
            let secretKey = [UInt8](secretKeyData)
            
            do {
                let decryptor = try ChunkCryptor(encrypt: false, key: secretKey, iv: iv)
                self.crypt(action: decryptor, from: fileIn, to: fileOut)
                fileOut.close()
                fileIn.close()
                completion(.success(()))
            } catch {
                completion(.failure(PigeonError(code: "DECRYPTION_FAILED", message: error.localizedDescription, details: "")))
            }
        }
    }
    
    private func generateRandomKey(length: Int) -> Data? {
        var key = Data(count: length)
        let result = key.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!) }
        return result == errSecSuccess ? key : nil
    }
    
    @discardableResult private func crypt(action sc: ChunkCryptor, from inputStream: InputStream, to outputStream: OutputStream) -> (bytesRead: Int, bytesWritten: Int) {
        var inputBuffer = [UInt8](repeating: 0, count: bufferSize)
        var outputBuffer = [UInt8](repeating: 0, count: bufferSize)
        
        var totalBytesRead = 0
        var totalBytesWritten = 0
        
        while inputStream.hasBytesAvailable {
            let bytesRead = inputStream.read(&inputBuffer, maxLength: bufferSize)
            guard bytesRead > 0 else { break }
            
            totalBytesRead += bytesRead
            var cryptedBytes: Int = 0
            
            let status = sc.update(bufferIn: inputBuffer, byteCountIn: bytesRead, bufferOut: &outputBuffer, byteCapacityOut: bufferSize, byteCountOut: &cryptedBytes)
            if status != kCCSuccess {
                return (totalBytesRead, totalBytesWritten)
            }
            
            if cryptedBytes > 0 {
                let bytesWritten = outputStream.write(outputBuffer, maxLength: cryptedBytes)
                totalBytesWritten += bytesWritten
            }
        }
        
        var finalBytes: Int = 0
        let status = sc.final(bufferOut: &outputBuffer, byteCapacityOut: bufferSize, byteCountOut: &finalBytes)
        if status == kCCSuccess, finalBytes > 0 {
            let bytesWritten = outputStream.write(outputBuffer, maxLength: finalBytes)
            totalBytesWritten += bytesWritten
        }
        
        return (totalBytesRead, totalBytesWritten)
    }
}

extension String {
    func fromBase64() -> Data? {
        return Data(base64Encoded: self)
    }
    
    func toBase64() -> String {
        return Data(utf8).base64EncodedString()
    }
}
