@interface NSString (Advanced)

- (NSString *) md5;
+ (NSString*) uniqueString;
- (NSString*) urlEncodedString;
- (NSString*) urlDecodedString;
- (BOOL) validateEmailWithString;
+ (NSMutableAttributedString *)actionSheetAlertTitle;

+ (NSString *)stringFromMD5:(NSString *)str;
+ (NSString *)randomStringWithLength:(int)len;
+ (NSString *)getPaddedString:(NSString *)plainString;

- (BOOL)isValidString;

@end
