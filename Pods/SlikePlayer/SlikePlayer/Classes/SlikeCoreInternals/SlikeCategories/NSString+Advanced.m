#import "NSString+Advanced.h"
#import <CommonCrypto/CommonDigest.h>

#define SLIKE_RGBA(r, g, b, a)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation NSString (Advanced)

- (NSString *) md5 {
    
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int) strlen(cStr), result);
    return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];      
}

+ (NSString*) uniqueString {
    
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);
	NSString	*uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return uuidString;
}

- (NSString*) urlEncodedString {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

    
    CFStringRef encodedCFString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                          (__bridge CFStringRef) self,
                                                                          nil,
                                                                          CFSTR("?!@#$^&%*+,:;='\"`<>()[]{}/\\| "),
                                                                          kCFStringEncodingUTF8);
    
    NSString *encodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) encodedCFString];
    if(!encodedString)
        encodedString = @"";
    
#pragma clang diagnostic pop
    return encodedString;
}

- (NSString*) urlDecodedString {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    CFStringRef decodedCFString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, 
                                                                                          (__bridge CFStringRef) self, 
                                                                                          CFSTR(""),
                                                                                          kCFStringEncodingUTF8);
    
    // We need to replace "+" with " " because the CF method above doesn't do it
    NSString *decodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) decodedCFString];
    
#pragma clang diagnostic pop
    return (!decodedString) ? @"" : [decodedString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
}

- (BOOL) validateEmailWithString {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

+ (NSMutableAttributedString *)actionSheetAlertTitle {
    
    NSMutableAttributedString *strTitle = [[NSMutableAttributedString alloc] initWithString:@"Select Quality"];
    [strTitle addAttribute:NSFontAttributeName
                     value:[UIFont systemFontOfSize:18.0]
                     range:NSMakeRange(0, 14)];
    [strTitle addAttribute:NSForegroundColorAttributeName
                     value:SLIKE_RGBA(24, 45, 45, 1.0)
                     range:NSMakeRange(0, 14)];
    return strTitle;
}

+ (NSString *)stringFromMD5:(NSString *)str {
    
    if(str == nil || [str length] == 0)
        return nil;
    
    const char *value = [str UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (int)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

+ (NSString *)randomStringWithLength:(int)len {
    
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:len];
    for (NSUInteger i = 0U; i < len; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return s;
}

+ (NSString *)getPaddedString:(NSString *)plainString {
    
    NSArray *arr = [plainString componentsSeparatedByString:@"."];
    NSInteger nIndex, nLen = arr.count;
    if(nLen <= 1) return plainString;
    NSString *strTmp;
    NSInteger num;
    plainString = @"";
    
    for(nIndex = 0; nIndex < nLen; nIndex++) {
        strTmp = [arr objectAtIndex:nIndex];
        num = [strTmp integerValue];
        if(num <= 9 && nIndex >0) plainString = [NSString stringWithFormat:@"%@0%ld", plainString, (long)num];
        else plainString = [NSString stringWithFormat:@"%@%@", plainString, strTmp];
    }
    return plainString;
}

- (BOOL)isValidString {
    if(self !=nil && ![self isKindOfClass:[NSNull class]] && ![self isEqualToString:@""] && [self isKindOfClass:[NSString class]]) {
        return YES;
    }
    return NO;
}

@end
