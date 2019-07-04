//
//  SlikeFANAdController.m
//  Pods
//
//  Created by Sanjay Singh Rathor on 22/06/18.
//

#import "SlikeAdManager.h"
#import "SlikeFANAdController.h"
#import "SlikeAdsUnit.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <AdSupport/ASIdentifierManager.h>
#import "SlikeVideoPlayerRegistrar.h"
#import "SlikeSharedDataCache.h"

@interface SlikeFANAdController()<FBInstreamAdViewDelegate>

@property(nonatomic, weak)UIView *adContainerView;
@property(nonatomic, weak)id<SlikeAdPlateformEvents> eventsDelegate;
@property (nonatomic, strong) FBInstreamAdView *adView;
@property(nonatomic, assign) SlikeAdEventType adEvent;
@property(nonatomic, weak) SlikeAdsUnit *adUnitModel;
@property(nonatomic,readwrite) BOOL isAdPlaying;
@property(nonatomic,readwrite) BOOL isAdLoaded;
@end

@implementation SlikeFANAdController

@synthesize slikeConfigModel;

- (instancetype)initWithAdContainerView:(UIView *)parentView withAd:(SlikeAdsUnit *)adModel delegate:(id<SlikeAdPlateformEvents>)delegate {
    
    self = [super init];
    self.adUnitModel = adModel;
    self.adContainerView = parentView;
    self.eventsDelegate = delegate;
    self.adContainerView.autoresizesSubviews = YES;
    self.adContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    return self;
}
/**
 Setup the FAN
 */

- (void)_setUpFAN {
    
    if ([SlikeDeviceSettings sharedSettings].isDebugMode) {
        NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        [FBAdSettings addTestDevice:idfaString];
#ifndef NDEBUG
        [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
#endif
    }
    
    
    if (self.adView && [self.adView superview]) {
        [_adView removeFromSuperview];
        self.adView=nil;
    }
    self.adView = [[FBInstreamAdView alloc] initWithPlacementID:_adUnitModel.strAdURL];
    self.adView.autoresizesSubviews = YES;
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.adContainerView addSubview:_adView];
    _adView.frame = _adContainerView.bounds;
    
    self.adView.delegate = self;
    [self.adView loadAd];
    
    _isAdPlaying = NO;
    _isAdLoaded = NO;
    
    NSInteger adCleanupTime = [SlikeSharedDataCache sharedCacheManager].adCleanupTime;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, adCleanupTime * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        if(!self.isAdLoaded) {
            self.adEvent = kSlikeAdEventTimeout;
            if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
                [self.eventsDelegate slikeAdEventDidReceiveAdEvent:self.adEvent withPayload:@{}];
            }
        }
    });
}
-(void)adViewWillLogImpression:(FBInstreamAdView *)adView
{
    
}
#pragma amrk - FBInstreamAdViewDelegate

- (void)adViewDidLoad:(FBInstreamAdView *)adView {
    
    _isAdLoaded=YES;
    _adEvent = kSlikeAdEventLoaded;
    if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
        [_eventsDelegate slikeAdEventDidReceiveAdEvent:_adEvent withPayload:@{}];
    }
}

/**
 AdView Completed
 @param adView - Ad View
 */
- (void)adViewDidEnd:(FBInstreamAdView *)adView {
    
    _adEvent = kSlikeAdEventCompleted;
    if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
        [_eventsDelegate slikeAdEventDidReceiveAdEvent:_adEvent withPayload:@{}];
    }
    
    _adEvent = kSlikeAdEventResumeContent;
    if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
        [_eventsDelegate slikeAdEventDidReceiveAdEvent:_adEvent withPayload:@{}];
    }
}

/**
 AdView Did Clicked
 @param adView - AdView
 @param error - Error Code
 */
- (void)adView:(FBInstreamAdView *)adView didFailWithError:(NSError *)error {
    
    _adEvent = kSlikeAdEventLoadingError;
    
    NSString *errMessage = @"";
    if (error.localizedDescription) {
        errMessage = error.localizedDescription;
    }
    NSLog(@"%@",errMessage);
    NSString *errCode = [NSString stringWithFormat:@"%ld", (long)error.code];
//    NSDictionary *payload = @{
//                              kSlikeAdDescriptionKey:errMessage,
//                              kSlikeAdErrCodeKey:errCode,
//                              };
    NSDictionary *payload = @{
                              kSlikeAdDescriptionKey:errCode,
                              kSlikeAdErrCodeKey:errCode,
                              };
    if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
        [_eventsDelegate slikeAdEventDidReceiveAdEvent:_adEvent withPayload:payload];
    }
}


/**
 AdView did Clicked. Now need to tell the parent about this event
 @param adView - Ad View
 */
- (void)adViewDidClick:(FBInstreamAdView *)adView {
    _adEvent = kSlikeAdEventCliked;
    if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
        [_eventsDelegate slikeAdEventDidReceiveAdEvent:_adEvent withPayload:@{}];
    }
}

/**
 Remove all the components
 */
- (void)removeAdsComponents {

    self.eventsDelegate=nil;
    if (self.adView) {
        self.adView.delegate=nil;
        if ([self.adView superview]) {
           [_adView removeFromSuperview];
        }
        self.adView=nil;
    }
}

/**
 Show the ad.
 */
- (void)_showVideoAd {
    
    //Loaded Ad is valid
    if (self.adView && self.adView.isAdValid) {
        
        _adEvent = kSlikeAdEventStarted;
        if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
            [_eventsDelegate slikeAdEventDidReceiveAdEvent:_adEvent withPayload:@{}];
        }
        
        
        _adEvent = kSlikeAdEventPauseContent;
        if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
            [_eventsDelegate slikeAdEventDidReceiveAdEvent:_adEvent withPayload:@{}];
        }
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        [self.adView showAdFromRootViewController:vc];
        
    } else {
        
        _adEvent = kSlikeAdEventPlayingError;
        
        NSString *errMessage = @"unable to load";
        NSString *errCode = [NSString stringWithFormat:@"%ld", (long)400];
//        NSDictionary *payload = @{
//                                   kSlikeAdDescriptionKey:errMessage,
//                                   kSlikeAdErrCodeKey:errCode,
//                                  };
        NSDictionary *payload = @{
                                  kSlikeAdDescriptionKey:errCode,
                                  kSlikeAdErrCodeKey:errCode,
                                  };
        if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
            [_eventsDelegate slikeAdEventDidReceiveAdEvent:_adEvent withPayload:payload];
        }
    }
}

/**
 Fetch the ad
 */
- (void)fetchAd {
    _adEvent = kSlikeAdEventNone;
    [self _setUpFAN];
}

/**
 Play the Ad
 */
- (void)playAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _showVideoAd];
    });
}

/**
 Current Playteform
 @return - IMA|FAN
 */
- (SlikeAdsPlatform)currentAdPlateform {
    return SlikeAdsPlatformFacebook;
}

/**
 Resume the Ad
 */
- (void)resumeAd {
    if (_isAdPlaying) {
     
    }
}
/**
 Pause the Ad
 */
- (void)pauseAd {
    if (_isAdPlaying) {
     
    }
}

@end
