//
//  SlikeAdEvent.m
//  Pods
//
//  Created by Sanjay Singh Rathor on 13/07/18.
//

#import "SlikeAdEvent.h"

@implementation SlikeAdEvent

- (instancetype)init {
    self = [super init];
    
    _adTitle  = @"";
    _isSkippable  = @"";
    _adStatusAnalytics = @"";
    _adStatus = 0;
    _slikeAdId = @"";
    _adCampaign = @"";
    _retryCount = 0;
    _mediaDuration = 0;
    _mediaPoistion = 0;
    _adDuration = 0;
    _adPosition = 0;
    _isVolumeOn = YES;
    _volumeLevel = 0.5f;
    _adMoreInfo = @"";
    _errDespription = @"";
    _slikeAdType = 1;
    _iu = @"";
    _adResgion = @"";
    _isAdPrefetched = NO;
    _pfid = @"";
    _adProviderType =  1;
    _errCode = @"";
    _advertiserName = @"";
    _contentType = @"";
    return self;
    
}

@end
