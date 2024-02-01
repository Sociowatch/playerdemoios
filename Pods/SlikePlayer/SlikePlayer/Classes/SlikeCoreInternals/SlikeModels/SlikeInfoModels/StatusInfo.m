//
//  StatusInfo.m
//  SlikePlayer
//
//  Created by TIL on 16/12/16.
//  Copyright (c) 2016 BBDSL. All rights reserved.
//

#import "StatusInfo.h"

@implementation StatusInfo

- (id)init {
    
    if (self = [super init]) {
        
        self.error = @"";
        self.position = 0;
        self.duration = 0;
        self.buffer = 0;
        self.muted = 0;
        self.adStatusInfo = nil;
    }
    return self;
}

+ (StatusInfo *)initWithError:(NSString *) strError {
    
    StatusInfo *statusInfo = [[StatusInfo alloc] init];
    statusInfo.error = strError ? strError : @"";
    
    return statusInfo;
}

+ (StatusInfo *)initWithBuffer:(NSInteger) buffer withPosition:(NSInteger) position withDuration:(NSInteger) duration muteStatus:(NSInteger) muted {
    
    StatusInfo *statusInfo = [[StatusInfo alloc] init];
    statusInfo.position = position;
    statusInfo.duration = duration;
    statusInfo.buffer = buffer;
    statusInfo.muted = muted;
    
    return statusInfo;
}

- (NSString *)getString {
    return [NSString stringWithFormat:@"position: %ld, duration: %ld, buffer: %ld, muted: %ld, %@", (long)self.position, (long)self.duration, (long)self.buffer, (long)self.muted, self.adStatusInfo ? [self.adStatusInfo getString] : @""];
}

-(void)dealloc {
     SlikeDLog(@"dealloc- Cleaning up StatusInfo");
}
@end
