//
//  DecryptTog.swift
//  SwiftyLoganTool
//
//  Created by fuyoufang on 2021/4/21.
//

import Foundation

enum LoganToolError: Error {
    case failure // 失败
    case someError // 异常
}

struct LoganTool {
    static func decrypt(encryptKey: String,
                        encryptKeyV: String,
                        data: Data) throws -> String? {
        var result = String()
        
        let content = [UInt8](data)

        var i = 0
        while i < content.count {
            defer {
                i += 1
            }
            let start = content[i]
            guard start == 1 else { // start == '\1'
                continue
            }
            i += 1
            // 此处需要转成 Int，因为使用 UInt8 在位移操作时会出现超出 UInt8 最大值，导致结果为 0
            let length = (Int(content[i]) & 0xFF) << 24 |
                (Int(content[i + 1]) & 0xFF) << 16 |
                (Int(content[i + 2]) & 0xFF) << 8 |
                (Int(content[i + 3]) & 0xFF)
            
            i += 3
           
            guard length > 0 else {
                continue
            }
            var type: Int
            let temp = i + Int(length) + 1
            if content.count - i - 1 == length { // 异常
                type = 0
                result += "解密有异常\n"
            } else if content.count - i - 1 > length && content[temp] == 0 {
                type = 1
            } else if content.count - i - 1 > length && content[temp] == 1 {
                type = 2 // 异常
                result += "解密有异常\n"
            } else {
                i -= 4
                continue
            }
            
            let dest = [UInt8](content[((i + 1)..<(i + 1 + Int(length)))])
            let destData = Data(bytes: dest, count: dest.count) as NSData
            let decryptData = destData.aes128Decrypt(withKey: encryptKey, iv: encryptKeyV)
            
            guard let ungzipData = LFCGzipUtility.ungzipData(decryptData) else {
                result += "有异常，无法解析\n"
                continue
            }
                        
            guard let r = String(data: ungzipData, encoding: .utf8) else {
                // "解密失败"
                throw LoganToolError.failure
            }
            debugPrint("解密结果：\(r)")
            result += r
            i += Int(length)
            if type == 1 {
                i += 1
            }
        }
        
        return result
    }
}

