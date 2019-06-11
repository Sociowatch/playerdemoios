//
//  AdStatusInfo.h
//  slikeplayerlite
//  Created by Sanjay Singh Rathor on 25/05/18.
//

#import <Foundation/Foundation.h>
#import "SlikeGlobals.h"

@interface SlikeAdStatusInfo : NSObject

@property(nonatomic, strong) NSString *adId;
@property(nonatomic, strong) NSString *adType;
@property(nonatomic, strong) NSString *campaignId;
@property(nonatomic, assign) NSInteger duration;
@property(nonatomic, assign) NSInteger position;
@property(nonatomic, assign) NSInteger muted;
@property(nonatomic, assign) NSInteger retryCount;
@property(nonatomic, assign) SlikePlayerState state;
@property(nonatomic, assign) SlikeAdType adTypeEnum;

+ (SlikeAdStatusInfo *)initWithID:(NSString *) adId withAdPos:(NSInteger) nAdPos withCampaign:(NSString *) cid withPosition:(NSInteger) pos withDuration:(NSInteger) dur withRetryCount:(NSInteger) count withState:(SlikePlayerState) state withAdType:(NSInteger)adType;

- (void)setAdTypeByPosition:(NSInteger) nAdPos;
-(NSString *)getString;

@end
