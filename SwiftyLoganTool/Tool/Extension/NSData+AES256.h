//
//  NSData+AES256.h
//  QiniuLog
//
//  Created by fuyoufang on 2021/4/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Encryption)
- (NSData *)AES128EncryptWithKey:(NSString *)key Iv:(NSString *)Iv;   //加密
- (NSData *)AES128DecryptWithKey:(NSString *)key Iv:(NSString *)Iv;   //解密

// URL安全的Base64编码
+ (NSString *)URLSafeBase64Encode:(NSData *)text;

@end


NS_ASSUME_NONNULL_END
