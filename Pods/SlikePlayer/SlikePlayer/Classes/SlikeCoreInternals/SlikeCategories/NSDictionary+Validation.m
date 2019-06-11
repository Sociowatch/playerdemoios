//
//  NSDictionary+Validation.m


#import "NSDictionary+Validation.h"

@implementation NSDictionary (Validation)

- (id)objectOrNilForKey:(id)key {
    id object = [self objectForKey:key];
    if (object == [NSNull null]) {
        return nil;
    }
    return object;
}

- (NSString *)stringForKey:(id)key {
    
    NSString *string = [self objectOrNilForKey:key];
    if ([string isKindOfClass:[NSString class]] && string.length > 0) {
        return string;
    } else if ([string isKindOfClass:[NSNumber class]] ) {
        NSNumber *numberInstance = (NSNumber *)string;
        return [NSString stringWithFormat:@"%ld", (long)[numberInstance integerValue]];
    }
    return nil;
}


- (NSString *)stringOrEmptyStringForKey:(id)key {
    NSString *string = [self stringForKey:key];
    if (!string) return @"";
    return string;
}

- (NSString *)stringForKey:(id)key defaultValue:(NSString *)defaultValue {
    NSString *string = [self stringForKey:key];
    if (!string) return defaultValue;
    return string;
}


- (NSDictionary *)dictionaryForKey:(id)key {
    NSDictionary *dictionary = [self objectOrNilForKey:key];
    if ([dictionary isKindOfClass:[NSDictionary class]] && [[dictionary allKeys] count] > 0) {
        return dictionary;
    }
    return nil;
}

- (NSArray *)arrayForKey:(id)key {
    NSArray *array = [self objectOrNilForKey:key];
    if ([array isKindOfClass:[NSArray class]] && [array count] > 0) {
        return [self objectOrNilForKey:key];
    }
    return nil;
}

- (NSNumber *)numberForKey:(id)key {
    NSNumber *number = [self objectOrNilForKey:key];
    if ([number isKindOfClass:[NSNumber class]]) {
        return number;
    }
    return nil;
}

- (NSURL *)urlForKey:(id)key {
    return [NSURL URLWithString:[self stringForKey:key]];
}

- (BOOL)boolForKey:(id)key {
    return [[self objectOrNilForKey:key] boolValue];
}

- (BOOL)isValidDictonary {
    
    if(![self isKindOfClass:[NSNull class]] && self != (id)[NSNull null] && [self isKindOfClass:[NSDictionary class]]
       && self !=nil) {
        return YES;
    }
    return NO;
}

- (NSInteger)integerForKeyString:(id)key {
    NSString *result = [self stringForKey:key];
    if (result) {
        return [result integerValue];
    }
    return 0;
}

@end
