//
//  String+Extension.swift
//  QiniuLog
//
//  Created by fuyoufang on 2021/4/8.
//

import Foundation
import CommonCrypto

extension String {
    public var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
