import Flutter
import UIKit
import CommonCrypto

let bufferSize = 8192

public class SwiftFileEncrypterPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "file_encrypter", binaryMessenger: registrar.messenger())
        let instance = SwiftFileEncrypterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: String] else{
            result(FlutterError(code: "", message: "Invalid Argument", details: nil))
            return
        }
        print(args)
        
        switch call.method {
        case "encrypt": encrypt(from: args["inFileName"], to: args["outFileName"], result)
        case "decrypt": decrypt(using: args["key"], from: args["inFileName"], to: args["outFileName"], result)
        default: result(FlutterMethodNotImplemented)
        }
    }
    
    
    private func encrypt(from inFileName:String?, to outFileName: String?, _ result: @escaping FlutterResult){
        
        guard let fileIn = InputStream(fileAtPath: inFileName!) else{
            result(fError("Failed to initialize input stream."))
            return
        }
        guard let fileOut = OutputStream(toFileAtPath: outFileName!, append: false) else {
            result(fError("Failed to initialize output stream."))
            return
        }
        fileIn.open()
        fileOut.open()
        let iv  = try! Random.generateBytes(byteCount: 16)
        guard  let secretKey = createAlphaNumericRandomString(length: kCCKeySizeAES256) else{
            result(fError("Invalid Key"))
            return
        }
        let key = arrayFrom(secretKey)
        
        
        let bytesWritten = fileOut.write(iv, maxLength: iv.count)
        
        let encryptor = try! StreamCryptor(encrypt: true, key: key, iv: iv)
        guard bytesWritten == iv.count else{
            result(fError("Failed to write IV to encrypted output file."))
            return
        }
        
        crypt(action: encryptor, from: fileIn, to: fileOut, taking: bufferSize)
        
        fileOut.close()
        fileIn.close()
        
        print(secretKey.toBase64())
        
        result(secretKey.toBase64())
    }
    
    private func decrypt(using baseKey:String?, from inFileName:String?, to outFileName: String?, _ result: @escaping FlutterResult){
        guard let fileIn = InputStream(fileAtPath: inFileName!) else{
            result(fError("Failed to initialize input stream."))
            return
        }
        guard let fileOut = OutputStream(toFileAtPath: outFileName!, append: false) else {
            result(fError("Failed to initialize output stream."))
            return
        }
        fileIn.open()
        fileOut.open()
        
        guard let secretkey = baseKey?.fromBase64() else{
            result(fError("Invalid key detected."))
            return
        }
        var iv  = Array<UInt8>(repeating: 0, count: 16)
        let key = arrayFrom(secretkey)
        
        let bytesRead = fileIn.read(&iv, maxLength: iv.count)
        
        let decryptor = try! StreamCryptor(encrypt: false, key: key, iv: iv)
        guard bytesRead == iv.count else{
            result(fError("Failed to read IV from encrypted output file."))
            return
        }
        
        crypt(action: decryptor, from: fileIn, to: fileOut, taking: bufferSize)
        
        fileOut.close()
        fileIn.close()
        
        result(nil)
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
    
    @discardableResult private func crypt(action sc : StreamCryptor,from  inputStream: InputStream,to outputStream: OutputStream,taking bufferSize: Int) -> (bytesRead: Int, bytesWritten: Int)
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
    
    func fError(_ description: String) -> FlutterError{
        return FlutterError(code: "", message: description, details: "")
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
