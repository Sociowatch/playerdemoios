//
//  SlikeAdEvent.h
//  Pods
//
//  Created by Sanjay Singh Rathor on 13/07/18.
//

#import <Foundation/Foundation.h>

@interface SlikeAdEvent : NSObject

@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) NSString *advertiserName;
@property (nonatomic, strong) NSString *adTitle;
@property (nonatomic, assign) NSString *isSkippable;
@property (nonatomic, strong) NSString *adStatusAnalytics;
@property (nonatomic, assign) NSInteger adStatus;
@property (nonatomic, strong) NSString *slikeAdId;
@property (nonatomic, strong) NSString *adCampaign;
@property (nonatomic, assign) NSInteger retryCount;
@property (nonatomic, assign) NSInteger mediaDuration;
@property (nonatomic, assign) NSInteger mediaPoistion;
@property (nonatomic, assign) NSInteger adDuration;
@property (nonatomic, assign) NSInteger adPosition;
@property (nonatomic, assign) BOOL isVolumeOn;
@property (nonatomic, assign) float volumeLevel;
@property (nonatomic, strong) NSString *adMoreInfo;
@property (nonatomic, strong) NSString *errDespription;
@property (nonatomic, strong) NSString *errCode;
@property (nonatomic, assign) NSInteger slikeAdType;
@property (nonatomic, strong) NSString *iu;
@property (nonatomic, strong) NSString *adResgion;
@property (nonatomic, assign) BOOL isAdPrefetched;
@property (nonatomic, strong) NSString *pfid;
@property (nonatomic, assign) NSInteger adProviderType;
@property (nonatomic, assign) BOOL extranlAdFail;


@end
