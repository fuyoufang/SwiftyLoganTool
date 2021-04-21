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
            if let r = try LoganTool.decrypt(encryptKey: logEncryptKey,
                                             encryptKeyV: logEncryptKeyV,
                                             data: data) {
                decryptionResult = r
            }
        } catch {
            tipMessage = "失败/异常"
        }
    }
    
}

struct DecryptTogView_Previews: PreviewProvider {
    static var previews: some View {
        DecryptTogView()
    }
}
