
//  NSDictionary+Validation.h

#import <Foundation/Foundation.h>

@interface NSDictionary (Validation)

- (id)objectOrNilForKey:(id)key;
- (NSString *)stringForKey:(id)key;
- (NSString *)stringOrEmptyStringForKey:(id)key;
- (NSString *)stringForKey:(id)key defaultValue:(NSString *)defaultValue;
- (NSDictionary *)dictionaryForKey:(id)key;
- (NSArray *)arrayForKey:(id)key;
- (NSNumber *)numberForKey:(id)key;
- (NSURL *)urlForKey:(id)key;
- (BOOL)boolForKey:(id)key;
- (BOOL)isValidDictonary;
- (NSInteger)integerForKeyString:(id)key;
@end
