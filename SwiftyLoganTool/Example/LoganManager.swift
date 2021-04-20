//
//  Manager.swift
//  QiniuLog
//
//  Created by fuyoufang on 2021/4/14.
//

import Foundation
import Logan

class LoganManager {

    static func setupLogan(key: String, iv: String) {
        let keyData = key.utf8Encoded
        let ivData = iv.utf8Encoded

        let maxFileSize: UInt64 = 10 * 1024 * 1024
        loganInit(keyData, ivData, maxFileSize)
    }    
}
