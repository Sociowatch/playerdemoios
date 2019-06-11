//
//  AdStatusInfo.m
//  slikeplayerlite
//  Created by Sanjay Singh Rathor on 25/05/18.
//

#import "SlikeAdStatusInfo.h"

@implementation SlikeAdStatusInfo

- (id)init {
    
    if (self = [super init]) {
        
        _adId = @"";
        _adType = @"";
        _campaignId = @"";
        _duration = 0;
        _position = 0;
        _muted = 0;
        _retryCount = 0;
        _adTypeEnum = SL_NONE;
    }
    return self;
}

+ (SlikeAdStatusInfo *)initWithID:(NSString *) adId withAdPos:(NSInteger) nAdPos withCampaign:(NSString *) cid withPosition:(NSInteger) pos withDuration:(NSInteger) dur withRetryCount:(NSInteger) count withState:(SlikePlayerState) state withAdType:(NSInteger)adType {
    
    SlikeAdStatusInfo *adStatusInfo = [[SlikeAdStatusInfo alloc] init];
    adStatusInfo.adId = adId == nil ? @"" : adId;
    [adStatusInfo setAdTypeByPosition:adType];
    adStatusInfo.campaignId = cid == nil ? @"" : cid;
    adStatusInfo.position = pos;
    adStatusInfo.duration = dur;
    adStatusInfo.state = state;
    
    return adStatusInfo;
}

- (void)setAdTypeByPosition:(NSInteger) nAdPos {
    
    if(nAdPos == 0) {
        self.adType = @"pre";
        self.adTypeEnum =  SL_PRE;
        
    } else if(nAdPos == -1) {
        self.adType = @"post";
        self.adTypeEnum =  SL_POST;
        
    } else {
        self.adType = @"mid";
        self.adTypeEnum =  SL_MID;
    }
}

- (NSString *) getString {
    
    return [NSString stringWithFormat:@"Ad id: %@, Campaign id: %@, Ad position: %ld, Ad duration: %ld, retry count: %ld, status: %ld", self.adId, self.campaignId, (long)self.position, (long)self.duration, (long)self.retryCount, (long)self.state];
}
@end
