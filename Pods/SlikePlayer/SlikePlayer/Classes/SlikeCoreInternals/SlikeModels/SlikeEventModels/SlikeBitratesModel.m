//
//  SlikeBitratesModel.m
//  Pods
//
//  Created by Sanjay Singh Rathor on 19/07/18.
//

#import "SlikeBitratesModel.h"
#import "SlikeSharedDataCache.h"

@interface SlikeBitratesModel() {
    
}
@end

@implementation SlikeBitratesModel

- (instancetype)init {
    self = [super init];
    _bitrateType = SlikeMediaBitrateNone;
    _isValid = NO;
    _bitrateName = @"";
    return self;
}
@end
