//
//  StatusInfo.h
//  SlikePlayer
//
//  Created by TIL on 16/12/16.
//  Copyright (c) 2016 BBDSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SlikeAdStatusInfo.h"

@interface StatusInfo : NSObject
@property(nonatomic, assign) NSInteger buffer;
@property(nonatomic, strong) NSString *error;
@property(nonatomic, assign) NSInteger position;
@property(nonatomic, assign) NSInteger duration;
@property(nonatomic, assign) NSInteger muted;
@property(nonatomic, strong) SlikeAdStatusInfo *adStatusInfo;

+ (StatusInfo *)initWithError:(NSString *) strError;
+ (StatusInfo *)initWithBuffer:(NSInteger) buffer withPosition:(NSInteger) position withDuration:(NSInteger) duration muteStatus:(NSInteger) muted;
-(NSString *) getString;
@end
