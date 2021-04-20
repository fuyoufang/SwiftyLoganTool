//
//  EncryptTogView.swift
//  QiniuLog
//
//  Created by fuyoufang on 2021/4/12.
//

import Foundation
import SwiftUI
import Logan

struct EncryptTogView: View {
    
    @State var originalText = ""
    @State var originalType = ""
    @State var encryptedResult = ""
    @State var tipMessage = ""
    @State var encryptedFilePath = ""
    @State var logEncryptKey = DefaultLogEncryptKey
    @State var logEncryptKeyV = DefaultLogEncryptKeyV
    
    
    var body: some View {
        VStack { // 加密
            Text("加密模块")
                .font(.title)
            
            HStack {
                Text("加密： key")
                TextField("EncryptKey", text: $logEncryptKey)
                Text("加密： keyV")
                TextField("EncryptKeyV", text: $logEncryptKeyV)
            }
            
            
            TextField("待加密类型(数字)", text: $originalType)
            TextField("待加密内容", text: $originalText)
            Button("开始加密") {
                encrypt()
            }
            Text("提示：\(tipMessage)")
            
            if #available(OSX 11.0, *) {
                TextEditor(text: $encryptedFilePath)
                    .frame(maxHeight: 100)
            } else {
                
            }
            Spacer()
        }
    }
    
    /// 加密
    func encrypt() {
        LoganManager.setupLogan(key: logEncryptKey, iv: logEncryptKeyV)
        encryptedFilePath = ""
        guard originalText.count > 0 else {
            tipMessage = "加密内容为空"
            return
        }
        
        guard let type = UInt(originalType) else {
            tipMessage = "加密类型必须为正整数"
            return
        }
        
        logan(type, originalText)
        
        loganFlush()
        
        tipMessage = "开始加密"
        loganUploadFilePath(loganTodaysDate()) { (path) in
            
            guard let path = path else {
                tipMessage = "未获取到解密路径"
                return
            }
            encryptedFilePath = path
            tipMessage = "加密成功"
            
            NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
        }
    }
}


struct EncryptTogView_Previews: PreviewProvider {
    static var previews: some View {
        EncryptTogView()
    }
}
