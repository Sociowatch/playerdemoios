//
//  SlikeAdsUnit.m
//  slikeplayerlite
//  Created by Sanjay Singh Rathor on 25/05/18.
//

#import "SlikeAdsUnit.h"

@implementation SlikeAdsUnit

- (id)init {
    
    if (self = [super init]) {
        self.strAdURL = @"";
        self.strAdCategory = @"";
    }
    return self;
}

- (instancetype)initWithCategory:(NSString *)category andAdURL:(NSString *)adURL {
    
    id val = [self init];
    if(adURL)self.strAdURL = adURL;
    if(category)self.strAdCategory = category;
    return val;
}

@end
