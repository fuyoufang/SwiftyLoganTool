//
//  DecryptTogView.swift
//  QiniuLog
//
//  Created by fuyoufang on 2021/4/12.
//

import Foundation
import SwiftUI

struct DecryptTogView: View {
    
    @State var tipMessage = ""
    @State var path = ""
    @State var decryptionResult = ""
    @State var logEncryptKey = DefaultLogEncryptKey
    @State var logEncryptKeyV = DefaultLogEncryptKeyV
    
    var body: some View {
        VStack { 
            Text("解密模块")
                .font(.title)
            
            HStack {
                Text("加密： key")
                TextField("EncryptKey", text: $logEncryptKey)
                Text("加密： keyV")
                TextField("EncryptKeyV", text: $logEncryptKeyV)
            }
            
            Button("选择解密文件") {
                decrypt()
            }
            Text("解密文件：\(path)")
            Text("提示：\(tipMessage)")
            TextField("", text: $decryptionResult)
                .frame(minHeight: 100)
            
            Spacer()
        }
    }
    
    /// 解密
    func decrypt() {
        let panel = NSOpenPanel()
        
        panel.canChooseFiles = true //是否能选择文件file
        panel.canChooseDirectories = false //是否能打开文件夹
        panel.allowsMultipleSelection = false //是否允许多选file
        
        guard panel.runModal() == NSApplication.ModalResponse.OK else { //获取panel的响应
            return
        }
        
        guard let url = panel.urls.first else {
            return
        }
        path = url.absoluteString
        
        // LoganManager.setupLogan(key: logEncryptKey, iv: logEncryptKeyV)

        
        guard let data = try? Data(contentsOf: url) else {
            tipMessage = "数据为空"
            return
        }
        tipMessage = ""
        decryptionResult = ""
        do {
            if let r = try DecryptTog.decrypt(encryptKey: logEncryptKey,
                                              encryptKeyV: logEncryptKeyV,
                                              data: data) {
                decryptionResult = r
            }
        } catch {
            tipMessage = "失败/异常"
        }
        
//        decryptionResult = result
    }
    
}

enum DecryptTogError: Error {
    case failure // 失败
    case someError // 异常
}

struct DecryptTog {
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
                throw DecryptTogError.failure
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


struct DecryptTogView_Previews: PreviewProvider {
    static var previews: some View {
        DecryptTogView()
    }
}
