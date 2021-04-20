#import "GTMBase64.h"
#import "GTMDefines.h"
#import <CommonCrypto/CommonDigest.h>

static const char *kBase64EncodeChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const char *kWebSafeBase64EncodeChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
static const char kBase64PaddingChar = '=';
static const char kBase64InvalidChar = 99;

static const char kBase64DecodeChars[] = {

  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      62 , 99,      99,      99,      63 ,
  52 , 53 , 54 , 55 , 56 , 57 , 58 , 59 ,
  60 , 61 , 99,      99,      99,      99,      99,      99,
  99,       0 ,  1 ,  2 ,  3 ,  4 ,  5 ,  6 ,
  7 ,  8 ,  9 , 10 , 11 , 12 , 13 , 14 ,
  15 , 16 , 17 , 18 , 19 , 20 , 21 , 22 ,
  23 , 24 , 25 , 99,      99,      99,      99,      99,
  99,      26 , 27 , 28 , 29 , 30 , 31 , 32 ,
  33 , 34 , 35 , 36 , 37 , 38 , 39 , 40 ,
  41 , 42 , 43 , 44 , 45 , 46 , 47 , 48 ,
  49 , 50 , 51 , 99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99
};

static const char kWebSafeBase64DecodeChars[] = {
  
  
  
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      62 , 99,      99,
  52 , 53 , 54 , 55 , 56 , 57 , 58 , 59 ,
  60 , 61 , 99,      99,      99,      99,      99,      99,
  99,       0 ,  1 ,  2 ,  3 ,  4 ,  5 ,  6 ,
  7 ,  8 ,  9 , 10 , 11 , 12 , 13 , 14 ,
  15 , 16 , 17 , 18 , 19 , 20 , 21 , 22 ,
  23 , 24 , 25 , 99,      99,      99,      99,      63 ,
  99,      26 , 27 , 28 , 29 , 30 , 31 , 32 ,
  33 , 34 , 35 , 36 , 37 , 38 , 39 , 40 ,
  41 , 42 , 43 , 44 , 45 , 46 , 47 , 48 ,
  49 , 50 , 51 , 99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99,
  99,      99,      99,      99,      99,      99,      99,      99
};



GTM_INLINE BOOL IsSpace(unsigned char c) {
  
  
  static BOOL kSpaces[256] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1,  
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 1, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  
    0, 0, 0, 0, 0, 1,              
  };

  return kSpaces[c];
}

GTM_INLINE NSUInteger CalcEncodedLength(NSUInteger srcLen, BOOL padded) {
  NSUInteger intermediate_result = 8 * srcLen + 5;
  NSUInteger len = intermediate_result / 6;

  if (padded) {
    len = ((len + 3) / 4) * 4;
  }
  return len;
}

GTM_INLINE NSUInteger GuessDecodedLength(NSUInteger srcLen) {
  return (srcLen + 3) / 4 * 3;
}


@interface GTMBase64 (PrivateMethods)

+(NSData *)baseEncode:(const void *)bytes
               length:(NSUInteger)length
              charset:(const char *)charset
               padded:(BOOL)padded;

+(NSData *)baseDecode:(const void *)bytes
               length:(NSUInteger)length
              charset:(const char*)charset
       requirePadding:(BOOL)requirePadding;

+(NSUInteger)baseEncode:(const char *)srcBytes
                 srcLen:(NSUInteger)srcLen
              destBytes:(char *)destBytes
                destLen:(NSUInteger)destLen
                charset:(const char *)charset
                 padded:(BOOL)padded;

+(NSUInteger)baseDecode:(const char *)srcBytes
                 srcLen:(NSUInteger)srcLen
              destBytes:(char *)destBytes
                destLen:(NSUInteger)destLen
                charset:(const char *)charset
         requirePadding:(BOOL)requirePadding;


@end


@implementation GTMBase64

+(NSData *)encodeData:(NSData *)data {
  return [self baseEncode:[data bytes]
                   length:[data length]
                  charset:kBase64EncodeChars
                   padded:YES];
}

+(NSData *)decodeData:(NSData *)data {
  return [self baseDecode:[data bytes]
                   length:[data length]
                  charset:kBase64DecodeChars
           requirePadding:YES];
}

+(NSData *)encodeBytes:(const void *)bytes length:(NSUInteger)length {
  return [self baseEncode:bytes
                   length:length
                  charset:kBase64EncodeChars
                   padded:YES];
}

+(NSData *)decodeBytes:(const void *)bytes length:(NSUInteger)length {
  return [self baseDecode:bytes
                   length:length
                  charset:kBase64DecodeChars
           requirePadding:YES];
}

+(NSString *)stringByEncodingData:(NSData *)data {
  NSString *result = nil;
  NSData *converted = [self baseEncode:[data bytes]
                                length:[data length]
                               charset:kBase64EncodeChars
                                padded:YES];

  if (converted) {
    result = [[NSString alloc] initWithData:converted
                                    encoding:NSASCIIStringEncoding];
  }
  return result;
}

+(NSString *)stringByEncodingBytes:(const void *)bytes length:(NSUInteger)length {
  NSString *result = nil;

  NSData *converted = [self baseEncode:bytes
                                length:length
                               charset:kBase64EncodeChars
                                padded:YES];

  if (converted) {
    result = [[NSString alloc] initWithData:converted
                                    encoding:NSASCIIStringEncoding];
  }
  return result;
}

+(NSData *)decodeString:(NSString *)string {
  NSData *result = nil;
  NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];
  if (data) {
    result = [self baseDecode:[data bytes]
                       length:[data length]
                      charset:kBase64DecodeChars
               requirePadding:YES];
  }
  return result;
}


+(NSData *)webSafeEncodeData:(NSData *)data
                      padded:(BOOL)padded {
  return [self baseEncode:[data bytes]
                   length:[data length]
                  charset:kWebSafeBase64EncodeChars
                   padded:padded];
}

+(NSData *)webSafeDecodeData:(NSData *)data {
  return [self baseDecode:[data bytes]
                   length:[data length]
                  charset:kWebSafeBase64DecodeChars
           requirePadding:NO];
}

+(NSData *)webSafeEncodeBytes:(const void *)bytes
                       length:(NSUInteger)length
                       padded:(BOOL)padded {
  return [self baseEncode:bytes
                   length:length
                  charset:kWebSafeBase64EncodeChars
                   padded:padded];
}

+(NSData *)webSafeDecodeBytes:(const void *)bytes length:(NSUInteger)length {
  return [self baseDecode:bytes
                   length:length
                  charset:kWebSafeBase64DecodeChars
           requirePadding:NO];
}

+(NSString *)stringByWebSafeEncodingData:(NSData *)data
                                  padded:(BOOL)padded {
  NSString *result = nil;

  NSData *converted = [self baseEncode:[data bytes]
                                length:[data length]
                               charset:kWebSafeBase64EncodeChars
                                padded:padded];

  if (converted) {
    result = [[NSString alloc] initWithData:converted
                                    encoding:NSASCIIStringEncoding];
  }
  return result;
}

+(NSString *)stringByWebSafeEncodingBytes:(const void *)bytes
                                   length:(NSUInteger)length
                                   padded:(BOOL)padded {
  NSString *result = nil;

  NSData *converted = [self baseEncode:bytes
                                length:length
                               charset:kWebSafeBase64EncodeChars
                                padded:padded];

  if (converted) {
    result = [[NSString alloc] initWithData:converted
                                    encoding:NSASCIIStringEncoding];

  }
  return result;
}

+(NSData *)webSafeDecodeString:(NSString *)string {
  NSData *result = nil;

  NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];

  if (data) {
    result = [self baseDecode:[data bytes]
                       length:[data length]
                      charset:kWebSafeBase64DecodeChars
               requirePadding:NO];
  }
  return result;
}

#pragma mark - base64
+ (NSString *) md5_base64: (NSString *) inPutText
{
    const char *cStr = [inPutText UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest );
    
    NSData * base64 = [[NSData alloc]initWithBytes:digest length:16];

    base64 = [GTMBase64 encodeData:base64];
    
    NSString * output = [[NSString alloc] initWithData:base64 encoding:NSUTF8StringEncoding];
    return output;
}

+ (NSString*)encodeBase64String:(NSString * )input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

+ (NSString*)decodeBase64String:(NSString * )input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 decodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

+ (NSString*)encodeBase64Data:(NSData *)data {
    data = [GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

+ (NSString*)decodeBase64Data:(NSData *)data {
    data = [GTMBase64 decodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

@end

@implementation GTMBase64 (PrivateMethods)


+(NSData *)baseEncode:(const void *)bytes
               length:(NSUInteger)length
              charset:(const char *)charset
               padded:(BOOL)padded {
  
  NSUInteger maxLength = CalcEncodedLength(length, padded);
  
  NSMutableData *result = [NSMutableData data];
  [result setLength:maxLength];
  
  NSUInteger finalLength = [self baseEncode:bytes
                                        srcLen:length
                                     destBytes:[result mutableBytes]
                                       destLen:[result length]
                                       charset:charset
                                        padded:padded];
  if (finalLength) {
    _GTMDevAssert(finalLength == maxLength, @"how did we calc the length wrong?");
  } else {
    result = nil;
  }
  return result;
}

+(NSData *)baseDecode:(const void *)bytes
               length:(NSUInteger)length
              charset:(const char *)charset
       requirePadding:(BOOL)requirePadding {
  
  NSUInteger maxLength = GuessDecodedLength(length);
  
  NSMutableData *result = [NSMutableData data];

  [result setLength:maxLength];
  
  NSUInteger finalLength = [self baseDecode:bytes
                                     srcLen:length
                                  destBytes:[result mutableBytes]
                                    destLen:[result length]
                                    charset:charset
                             requirePadding:requirePadding];
  if (finalLength) {
    if (finalLength != maxLength) {
      
      [result setLength:finalLength];
    }
  } else {
    result = nil;
  }
  return result;
}


+(NSUInteger)baseEncode:(const char *)srcBytes
                 srcLen:(NSUInteger)srcLen
              destBytes:(char *)destBytes
                destLen:(NSUInteger)destLen
                charset:(const char *)charset
                 padded:(BOOL)padded {
  if (!srcLen || !destLen || !srcBytes || !destBytes) {
    return 0;
  }

  char *curDest = destBytes;

  const unsigned char *curSrc = (const unsigned char *)(srcBytes);
  
  while (srcLen > 2) {
    
    _GTMDevAssert(destLen >= 4, @"our calc for encoded length was wrong");

    curDest[0] = charset[curSrc[0] >> 2];


    curDest[1] = charset[((curSrc[0] & 0x03) << 4) + (curSrc[1] >> 4)];
    curDest[2] = charset[((curSrc[1] & 0x0f) << 2) + (curSrc[2] >> 6)];
    curDest[3] = charset[curSrc[2] & 0x3f];

    curDest += 4;
    curSrc += 3;
    srcLen -= 3;
    destLen -= 4;
  }

  
  switch (srcLen) {
    case 0:
      
      break;
    case 1:
      
      
      _GTMDevAssert(destLen >= 2, @"our calc for encoded length was wrong");
      curDest[0] = charset[curSrc[0] >> 2];
      curDest[1] = charset[(curSrc[0] & 0x03) << 4];
      curDest += 2;
      destLen -= 2;
      if (padded) {
        _GTMDevAssert(destLen >= 2, @"our calc for encoded length was wrong");
        curDest[0] = kBase64PaddingChar;
        curDest[1] = kBase64PaddingChar;
        curDest += 2;
      }
      break;
    case 2:
      
      
      _GTMDevAssert(destLen >= 3, @"our calc for encoded length was wrong");
      curDest[0] = charset[curSrc[0] >> 2];
      curDest[1] = charset[((curSrc[0] & 0x03) << 4) + (curSrc[1] >> 4)];
      curDest[2] = charset[(curSrc[1] & 0x0f) << 2];
      curDest += 3;
      destLen -= 3;
      if (padded) {
        _GTMDevAssert(destLen >= 1, @"our calc for encoded length was wrong");

        curDest[0] = kBase64PaddingChar;

        curDest += 1;

      }
      break;
  }
  
  return (curDest - destBytes);
}

+(NSUInteger)baseDecode:(const char *)srcBytes
                 srcLen:(NSUInteger)srcLen
              destBytes:(char *)destBytes
                destLen:(NSUInteger)destLen
                charset:(const char *)charset
         requirePadding:(BOOL)requirePadding {
  if (!srcLen || !destLen || !srcBytes || !destBytes) {
    return 0;
  }

  int decode;
  NSUInteger destIndex = 0;
  int state = 0;

  char ch = 0;

  while (srcLen-- && (ch = *srcBytes++) != 0)  {
    if (IsSpace(ch))  
      continue;
    
    if (ch == kBase64PaddingChar)
      break;
    decode = charset[(unsigned int)ch];

    if (decode == kBase64InvalidChar)
      return 0;
    
    switch (state) {
      case 0:
        _GTMDevAssert(destIndex < destLen, @"our calc for decoded length was wrong");
        destBytes[destIndex] = decode << 2;
        state = 1;
        break;
      case 1:
        _GTMDevAssert((destIndex+1) < destLen, @"our calc for decoded length was wrong");
        destBytes[destIndex] |= decode >> 4;
        destBytes[destIndex+1] = (decode & 0x0f) << 4;
        destIndex++;
        state = 2;
        break;
      case 2:
        
        _GTMDevAssert((destIndex+1) < destLen, @"our calc for decoded length was wrong");
        destBytes[destIndex] |= decode >> 2;
        destBytes[destIndex+1] = (decode & 0x03) << 6;
        destIndex++;
        state = 3;
        break;
      case 3:
        _GTMDevAssert(destIndex < destLen, @"our calc for decoded length was wrong");
        destBytes[destIndex] |= decode;
        destIndex++;
        state = 0;
        break;
    }
  }
  
  
  
  if (ch == kBase64PaddingChar) {               
    if ((state == 0) || (state == 1)) {
      return 0;  
    }
    if (srcLen == 0) {
      if (state == 2) { 
        return 0;
      }
      
    } else {
      if (state == 2) {  
        while ((ch = *srcBytes++) && (srcLen-- > 0)) {
          if (!IsSpace(ch))
            break;
        }
        if (ch != kBase64PaddingChar) {
          return 0;
        }
      }
      
      while ((ch = *srcBytes++) && (srcLen-- > 0)) {
        if (!IsSpace(ch)) {
          return 0;
        }
      }
    }
  } else {
    if (requirePadding) {
      if (state != 0) {
        return 0;
      }
    } else {
      if (state == 1) {
        return 0;
      }
    }
  }
  
  if ((destIndex < destLen) &&
      (destBytes[destIndex] != 0)) {
    return 0;
  }
  
  return destIndex;
}

@end
