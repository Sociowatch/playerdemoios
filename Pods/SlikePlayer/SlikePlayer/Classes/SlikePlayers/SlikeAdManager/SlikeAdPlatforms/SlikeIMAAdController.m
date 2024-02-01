//
//  SlikeIMAAdController.m
//  Pods
//
//  Created by Sanjay Singh Rathor on 22/06/18.
//

#import <GoogleInteractiveMediaAds/GoogleInteractiveMediaAds.h>
#import "SlikeIMAAdController.h"
#import "SlikeGlobals.h"
#import "SlikeConfig.h"
#import "SlikeDeviceSettings.h"
#import "SlikeUtilities.h"
#import "SlikeAdsUnit.h"
#import "SlikeAdManager.h"
#import "SlikeSharedDataCache.h"
#import "SlikePlayerConstants.h"

@interface SlikeIMAAdController() <IMAAdsLoaderDelegate, IMAAdsManagerDelegate, IMAWebOpenerDelegate>
{
    NSInteger _adMarkStart;
    NSInteger _adMarkAdPlayed;
}

@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) IMAAdsManager *adsManager;
@property(nonatomic, strong) IMAAdsLoader *adsLoader;
@property(nonatomic, strong) UIView *videoAdView;
@property(nonatomic, assign) SlikeAdEventType adEvent;
@property(nonatomic,strong) NSString *iu;
@property(nonatomic,strong) NSString * ha;
@property(nonatomic,readwrite) BOOL isAdPlaying;
@property(nonatomic,readwrite) BOOL isAdLoaded;
@property(nonatomic, weak) SlikeAdsUnit *adUnitModel;
@property(nonatomic, weak)id<SlikeAdPlateformEvents> eventsDelegate;
@property(nonatomic,readwrite) BOOL isViewVissible;
@property(nonatomic, assign) NSInteger adTime;
@property(nonatomic,assign) BOOL isHlsSupport;

@end

@implementation SlikeIMAAdController

@synthesize slikeConfigModel;

- (instancetype)initWithAdContainerView:(UIView *)parentView withAd:(SlikeAdsUnit *)adModel delegate:(id<SlikeAdPlateformEvents>)delegate {
    self = [super init];
    
    self.isHlsSupport = [SlikeDeviceSettings sharedSettings].tryHlsAds;
    self.containerView = parentView;
    self.adUnitModel = adModel;
    self.eventsDelegate = delegate;
    self.ha =  @"1";
    self.adTime = 0;
    return self;
}

/**
 Setup the AdLoader
 */
- (void)setUpAdsLoader {
    
    if (self.adsLoader) {
        self.adsLoader = nil;
    }

    IMASettings *settings = [[IMASettings alloc] init];
    settings.language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    settings.disableNowPlayingInfo=YES;
    self.adsLoader = [[IMAAdsLoader alloc] initWithSettings:settings];
    
    self.ha = @"1";
    [self getAdResion:self.adUnitModel];
    
    self.adEvent = kSlikeAdEventUpdateData;
    if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
        [self.eventsDelegate slikeAdEventDidReceiveAdEvent:self.adEvent withPayload:@{@"ha":self.ha}];
    }
    
    [self requestAdsWithTag:_adUnitModel.strAdURL];
}

// Initialize AdsLoader.
- (void)setUpIMA {
    if (self.adsManager) {
        [self.adsManager destroy];
        [self.adsLoader contentComplete];
    }
}

/**
 Create the Ads url to download the ads. Function will append some required parameters to
 to get the ad from the appropeate section
 @param adTagUrl - Ad tag URL
 */
- (void)requestAdsWithTag:(NSString *)adTagUrl
{
    NSLog(@"adTagUrl = > %@",adTagUrl);
    self.adTime = 0;
   
 //   adTagUrl = @"https://pubads.g.doubleclick.net/gampad/ads?iu=/7176/NBT_App_Android/NBT_App_AOS_Video/NBT_APP_AOS_VDO_Prefetch_Video&description_url=[placeholder]&tfcd=0&npa=0&sz=300x230%7C300x400%7C300x415%7C320x240%7C320x480%7C400x300%7C400x315%7C420x320%7C480x320%7C640x360&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=";
    
    SlikeDLog(@"Requesting ad: %@", adTagUrl);
    NSString * q = adTagUrl;
    NSArray * pairs = [q componentsSeparatedByString:@"&"];
    NSString* output_iu = nil;
    for (NSString *string in pairs) {
        if([string hasPrefix:@"iu="]) {
            output_iu = [string substringFromIndex:0];
        }
    }
    self.iu=output_iu;
    if (self.iu)
    {
        self.adEvent = kSlikeAdEventUpdateData;
        if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
            [self.eventsDelegate slikeAdEventDidReceiveAdEvent:self.adEvent withPayload:@{@"iu": self.iu, @"ha":self.ha}];
        }
    }
    NSString* output = nil;
    for (NSString *string in pairs) {
        if([string hasPrefix:@"cust_params="]) {
            output = [string substringFromIndex:0];
        }
    }
    NSArray * componentData = [[SlikeDeviceSettings sharedSettings].pageSection componentsSeparatedByString:@"."];
    NSString *section=@"";
    int i = 0;
    for (NSString * info in componentData) {
        if(section.length==0) {
            section = info;
        } else {
            if(i==1) {
                section=  [NSString stringWithFormat:@"%@,%@_%@",section,section,info];
            }
        }
        i++;
    }
    if([section isEqualToString:@""]) {
        section = @"_";
    }
    
    time_t unixTime = (time_t)[[NSDate date]timeIntervalSince1970];
    NSString *timeStamp = [NSString stringWithFormat:@"%ld", unixTime];
    
    if(output && output!=nil) {
        NSString * cust_params = output;
        adTagUrl = [adTagUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"&%@",cust_params] withString:@""];
        cust_params =  [cust_params stringByReplacingOccurrencesOfString:@"cust_params=" withString:@""];
        
        NSString * a = @"&";
        if([SlikeDeviceSettings sharedSettings].pid && [[SlikeDeviceSettings sharedSettings].pid length]>0) {
            cust_params = [NSString stringWithFormat:@"%@%@pid=%@%@section=%@",cust_params,a,[SlikeDeviceSettings sharedSettings].pid,a,section];
            
        } else {
            cust_params = [NSString stringWithFormat:@"%@%@pid=%@%@section=%@",cust_params,a,@"_",a,section];
        }
        
        NSString * venderId =  [NSString stringWithFormat:@"%@",[SlikeDeviceSettings sharedSettings].vendorID];
        if([SlikeDeviceSettings sharedSettings].vendorID && [venderId length]>0) {
            cust_params = [NSString stringWithFormat:@"%@&vendor=%@",cust_params,[SlikeDeviceSettings sharedSettings].vendorID];
            
        } else {
            cust_params = [NSString stringWithFormat:@"%@&vendor=%@",cust_params,@"_"];
        }
        
        if([SlikeDeviceSettings sharedSettings].sg && [[SlikeDeviceSettings sharedSettings].sg length]>0) {
            cust_params =  [NSString stringWithFormat:@"%@&sg=%@",cust_params,[SlikeDeviceSettings sharedSettings].sg];
        }
        if([SlikeDeviceSettings sharedSettings].description_url && [[SlikeDeviceSettings sharedSettings].description_url length]>0) {
            cust_params =  [NSString stringWithFormat:@"%@&description_url=%@",cust_params,[SlikeDeviceSettings sharedSettings].description_url];
        }
        
        if([SlikeDeviceSettings sharedSettings].packageName && [[SlikeDeviceSettings sharedSettings].packageName length]>0) {
            cust_params =  [NSString stringWithFormat:@"%@&url=%@",cust_params,[SlikeDeviceSettings sharedSettings].packageName];
        }
        
        if(timeStamp)
        {
            cust_params =  [NSString stringWithFormat:@"%@&corelator=%@",cust_params,timeStamp];
        }
        
        cust_params =  [cust_params stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
        cust_params =  [cust_params stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        cust_params = [cust_params stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
        cust_params =  [NSString stringWithFormat:@"&cust_params=%@",cust_params];
        adTagUrl = [NSString stringWithFormat:@"%@%@",adTagUrl,cust_params];
        
    } else {
        
        NSString * cust_params = @"";
        NSString * a = @"&";
        [adTagUrl stringByReplacingOccurrencesOfString:cust_params withString:@""];
        
        if([SlikeDeviceSettings sharedSettings].pid && [[SlikeDeviceSettings sharedSettings].pid length]>0) {
            cust_params = [NSString stringWithFormat:@"%@%@pid=%@%@section=%@",cust_params,a,[SlikeDeviceSettings sharedSettings].pid,a,section];
        } else {
            cust_params = [NSString stringWithFormat:@"%@%@pid=%@%@section=%@",cust_params,a,@"_",a,section];
        }
        
        if([SlikeDeviceSettings sharedSettings].vendorID && [[SlikeDeviceSettings sharedSettings].vendorID length]>0) {
            cust_params = [NSString stringWithFormat:@"%@&vendor=%@",cust_params,[SlikeDeviceSettings sharedSettings].vendorID];
            
        } else {
            cust_params = [NSString stringWithFormat:@"%@&vendor=%@",cust_params,@"_"];
        }
        
        if([SlikeDeviceSettings sharedSettings].sg && [[SlikeDeviceSettings sharedSettings].sg length]>0) {
            cust_params =  [NSString stringWithFormat:@"%@&sg=%@",cust_params,[SlikeDeviceSettings sharedSettings].sg];
        }
        if([SlikeDeviceSettings sharedSettings].sg && [[SlikeDeviceSettings sharedSettings].sg length]>0) {
            cust_params =  [NSString stringWithFormat:@"%@&sg=%@",cust_params,[SlikeDeviceSettings sharedSettings].sg];
        }
        if([SlikeDeviceSettings sharedSettings].description_url && [[SlikeDeviceSettings sharedSettings].description_url length]>0) {
            cust_params =  [NSString stringWithFormat:@"%@&description_url=%@",cust_params,[SlikeDeviceSettings sharedSettings].description_url];
        }
        
        if([SlikeDeviceSettings sharedSettings].packageName && [[SlikeDeviceSettings sharedSettings].packageName length]>0) {
            cust_params =  [NSString stringWithFormat:@"%@&url=%@",cust_params,[SlikeDeviceSettings sharedSettings].packageName];
        }
        
        if(timeStamp)
        {
            cust_params =  [NSString stringWithFormat:@"%@&corelator=%@",cust_params,timeStamp];
        }
        
        cust_params =    [cust_params stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
        cust_params =  [cust_params stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        cust_params =  [cust_params stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
        cust_params =  [NSString stringWithFormat:@"&cust_params=%@",cust_params];
        adTagUrl = [NSString stringWithFormat:@"%@%@",adTagUrl,cust_params];
    }
    
    
    SlikeDLog(@"Requesting ad: %@", adTagUrl);
    IMAAdsRequest *request = [[IMAAdsRequest alloc] initWithAdTagUrl:adTagUrl adDisplayContainer:[self createAdDisplayContainer] contentPlayhead:nil userContext:nil];
    // [self showWaitingIndicator];
    [self.adsLoader requestAdsWithRequest:request];
    self.adsLoader.delegate = self;
    
    _isAdPlaying = NO;
    _isAdLoaded = NO;
    
    //We do not have config file. So here we are using the default Time out
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

#pragma mark IMA SDK methods
/**
 Create the ad display container
 @return - Display container
 */
- (IMAAdDisplayContainer *)createAdDisplayContainer {
    
    if ([_videoAdView  superview] && _videoAdView) {
        [_videoAdView removeFromSuperview];
        _videoAdView=nil;
    }
    _videoAdView = [[UIView alloc]initWithFrame:_containerView.bounds];
    _videoAdView.autoresizesSubviews = YES;
    _videoAdView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [_containerView addSubview:_videoAdView];
    
    // Create our AdDisplayContainer. Initialize it with our videoView as the container. This
    // will result in ads being displayed over our content video.
    return [[IMAAdDisplayContainer alloc] initWithAdContainer:_videoAdView companionSlots:nil];
}

/**
 Add has not loaded. So need to discard the AD and inform about this. so that player can continue with their tasks
 */

#pragma mark - IMAAdsLoaderDelegate
- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
    
    self.adsManager = adsLoadedData.adsManager;
    self.adsManager.delegate = self;
    _adEvent = kSlikeAdEventContentLoaded;
    
    //Send the loaded event. Now ad has loaded sucessfully
    if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
        [_eventsDelegate slikeAdEventDidReceiveAdEvent:_adEvent withPayload:@{}];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        IMAAdsRenderingSettings *adsRenderingSettings = [[IMAAdsRenderingSettings alloc] init];
        //adsRenderingSettings.webOpenerPresentingController =  [SlikeUtilities topMostController];
        adsRenderingSettings.webOpenerDelegate = self;
        
        if(self.isHlsSupport)
        adsRenderingSettings.mimeTypes=  [[NSArray alloc] initWithObjects:@"application/x-mpegURL", nil];
        
        [self.adsManager initializeWithAdsRenderingSettings:adsRenderingSettings];
    });
}
- (void)setUpAdsLoaderAfterHlsTryNormal {
    dispatch_async(dispatch_get_main_queue(), ^{
           self.adEvent = kSlikeAdEventNone;
           [self setUpIMA];
  if (self.adsLoader) {
      self.adsLoader = nil;
  }

  IMASettings *settings = [[IMASettings alloc] init];
  settings.language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
  settings.disableNowPlayingInfo=YES;
  self.adsLoader = [[IMAAdsLoader alloc] initWithSettings:settings];
  
  self.ha = @"1";
  [self getAdResion:self.adUnitModel];
//Don't sent analytics
        [self requestAdsWithTag:self->_adUnitModel.strAdURL];
    });
}

-(void)setDataForHLS
{
    [self setUpAdsLoaderAfterHlsTryNormal];
}
- (void)adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData {
    
    _isAdPlaying = NO;
    _isAdLoaded = YES;
    
    NSString *errMessage = @"";
    if (adErrorData.adError.message) {
        errMessage = adErrorData.adError.message;
    }
    NSString* errCode = [NSString stringWithFormat:@"%ld", (long)adErrorData.adError.code];
    NSString* errDescription =   [NSString stringWithFormat:@"%@||%@",errCode, errMessage];
    
    if([adErrorData.adError.message isKindOfClass:[NSString class]]) {
        if ([adErrorData.adError.message rangeOfString:@"Invalid ad type"].location != NSNotFound) {
            errDescription =   [NSString stringWithFormat:@"%@||%@",@"900",errMessage];
            errCode = @"900";
        }
    }
    SlikeDLog(@"%@", errDescription);
    
    //    NSDictionary * payload = @{
    //                               kSlikeAdErrMessageKey:errMessage,
    //                               kSlikeAdErrCodeKey:errCode,
    //                               kSlikeAdDescriptionKey :errDescription
    //                               };
    NSDictionary * payload = @{
        kSlikeAdErrMessageKey:errMessage,
        kSlikeAdErrCodeKey:errCode,
        kSlikeAdDescriptionKey :errCode
    };
    
    _adEvent = kSlikeAdEventLoadingError;
    if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
        [_eventsDelegate slikeAdEventDidReceiveAdEvent:_adEvent withPayload:payload];
    }
}

#pragma mark IMAWebOpenerDelegate
- (void)webOpenerWillOpenExternalBrowser:(NSObject *)webOpener {
    [self.adsManager pause];
}

/// Called before in-app browser opens.
- (void)webOpenerWillOpenInAppBrowser:(NSObject *)webOpener {
    [self.adsManager pause];
    //[[NSNotificationCenter defaultCenter]postNotificationName:kSlikeDesiableOrientationNotification object:nil userInfo:@{@"disable": @(YES)}];
}

/// Called when the in app browser is shown on the screen.
- (void)webOpenerDidOpenInAppBrowser:(NSObject *)webOpener {
    [self.adsManager pause];
}

/// Called when in-app browser is about to close.
- (void)webOpenerWillCloseInAppBrowser:(NSObject *)webOpener {
    [[NSNotificationCenter defaultCenter]postNotificationName:kSlikeDesiableOrientationNotification object:nil userInfo:@{@"disable": @(NO)}];
}

/// Called when in-app browser finishes closing.
- (void)webOpenerDidCloseInAppBrowser:(NSObject *)webOpener {
    if(_isAdPlaying) {
        [self.adsManager resume];
    }
    
}

#pragma mark AdsManager Delegates
- (void)adsManager:(IMAAdsManager *)adsManager adDidProgressToTime:(NSTimeInterval)mediaTime totalTime:(NSTimeInterval)totalTime {
    
    NSMutableDictionary *payload  = [[NSMutableDictionary alloc]init];
    if(mediaTime == 0 && _adMarkStart == 0) {
        _adMarkStart =  1;
        payload = [@{
            kSlikeAdAdInfoKey : @"START"
        } mutableCopy];
    }
    if(mediaTime > self.slikeConfigModel.adPlayed/1000 && _adMarkAdPlayed == 0) {
        
        payload = [[NSMutableDictionary alloc] initWithDictionary:[self _getAdPositionWithDuration:adsManager]];
        [payload setObject:@"SL_Q0" forKey:kSlikeAdAdInfoKey];
        _adMarkAdPlayed =  1;
    }
    
    _adEvent = kSlikeAdEventProgress;
    
    [payload addEntriesFromDictionary:[self _getAdPositionWithDuration:adsManager]];
    
    if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
        [_eventsDelegate slikeAdEventDidReceiveAdEvent:_adEvent withPayload:payload];
    }
}

- (NSDictionary*)_getAdPositionWithDuration:(IMAAdsManager*)adsManager {
    NSInteger adTime = 0, adDur = 0;
    if(adsManager != nil && adsManager.adPlaybackInfo != nil) {
        adTime = adsManager.adPlaybackInfo.currentMediaTime ;
        adDur = adsManager.adPlaybackInfo.totalMediaTime ;
        if(adDur > 0) self.adTime = adDur;
        if(_adEvent == kSlikeAdEventCompleted)
        {
            adTime = self.adTime ;
        }
    }
    adTime = adTime*1000;
    adDur = adDur*1000;
    NSDictionary*  payload = @{
        @"adPosition" :@(adTime),
        @"aDduration" :@(adDur)
    };
    return payload;
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event {
    
    switch (event.type) {
        case  kIMAAdEvent_STARTED:
            _adEvent = kSlikeAdEventStarted;
            _isAdPlaying = YES;
            //[_activityIndicatorObject stopAnimating];
            break;
        case  kIMAAdEvent_FIRST_QUARTILE:
            _adEvent = kSlikeAdEventQ1;
            break;
        case  kIMAAdEvent_MIDPOINT:
            _adEvent = kSlikeAdEventMid;
            break;
        case  kIMAAdEvent_THIRD_QUARTILE:
            _adEvent = kSlikeAdEventQ3;
            break;
        case kIMAAdEvent_LOADED:
            _isAdLoaded = YES;
            _adEvent = kSlikeAdEventLoaded;
            break;
        case kIMAAdEvent_PAUSE:
            _adEvent = kSlikeAdEventPause;
            break;
        case kIMAAdEvent_RESUME:
            _adEvent = kSlikeAdEventResume;
            break;
        case kIMAAdEvent_COMPLETE:
            _adEvent = kSlikeAdEventCompleted;
            break;
        case kIMAAdEvent_SKIPPED:
            _adEvent = kSlikeAdEventSkipped;
            break;
        case kIMAAdEvent_CLICKED:
        case kIMAAdEvent_TAPPED:
            _adEvent = kSlikeAdEventCliked;
            break;
        default:
            _adEvent = kSlikeAdEventNone;
            break;
    }
    
    NSMutableDictionary * payLoad = [self _getAdTypeWithCreativeID:event.ad];
    [payLoad addEntriesFromDictionary:[self _getAdPositionWithDuration:adsManager]];
    if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
        [_eventsDelegate slikeAdEventDidReceiveAdEvent:_adEvent withPayload:payLoad];
    }
    
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error {
    SlikeDLog(@"AdsManager error: %@", error.message);
    if(error.code == 403 && self.isHlsSupport) {
        self.isHlsSupport = NO;
        [self setUpAdsLoaderAfterHlsTryNormal];
    }else {
    _adEvent = kSlikeAdEventPlayingError;
    _isAdPlaying = NO;
    
    NSString *errMessage = @"";
    if (error.message) {
        errMessage = error.message;
    }
    
    NSString *errCode = [NSString stringWithFormat:@"%ld", (long)error.code];
    NSString* errDescription =   [NSString stringWithFormat:@"%ld||%@",(long)error.code,error.message];
    
    NSDictionary *payload = @{
        kSlikeAdErrMessageKey:errMessage,
        kSlikeAdErrCodeKey:errCode,
        kSlikeAdDescriptionKey :errDescription
    };
    
    if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
        [_eventsDelegate slikeAdEventDidReceiveAdEvent:_adEvent withPayload:payload];
    }
    }
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    
    _adEvent = kSlikeAdEventPauseContent;
    if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
        [_eventsDelegate slikeAdEventDidReceiveAdEvent:_adEvent withPayload:@{}];
    }
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    _adEvent = kSlikeAdEventResumeContent;
    _isAdPlaying = NO;
    
    if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
        [_eventsDelegate slikeAdEventDidReceiveAdEvent:_adEvent withPayload:@{}];
    }
}

// Notify IMA SDK when content is done for post-rolls.
- (void)contentDidFinishPlaying:(NSNotification *)notification {
    SlikeDLog(@"The content is finished.");
    [self.adsLoader contentComplete];
    _isAdPlaying = NO;
    _isAdLoaded = YES;
}

/**
 Remove All the Acquired Resources
 */
- (void)removeAdsComponents:(void (^)(void))completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.eventsDelegate = nil;
        if(self.adsManager) {
            [self.adsManager destroy];
            [self.adsLoader contentComplete];
            self.adsManager = nil;
        }
        self.adsLoader.delegate = nil;
        if ([self.videoAdView  superview] && self.videoAdView) {
            [self.videoAdView removeFromSuperview];
            self.videoAdView=nil;
        }
        completionBlock();
    });
}

- (BOOL)isAdHasLoaded {
    return _isAdLoaded;
}

- (BOOL)isAdPlaying {
    return _isAdPlaying;
}

#pragma ISlikeAds

- (void)playAd {
    //dispatch_async(dispatch_get_main_queue(), ^{
    if (self.adsManager) {
        self.adsManager.delegate=self;
        [self.adsManager start];
        
    } else {
        self.adEvent = kSlikeAdEventError;
        if (self.eventsDelegate && [self.eventsDelegate respondsToSelector:@selector(slikeAdEventDidReceiveAdEvent:withPayload:)]) {
            [self.eventsDelegate slikeAdEventDidReceiveAdEvent:self.adEvent withPayload:@{}];
        }
    }
    //});
}

- (void)fetchAd {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.adEvent = kSlikeAdEventNone;
        [self setUpIMA];
        [self setUpAdsLoader];
    });
}

- (SlikeAdsPlatform)currentAdPlateform {
    return SlikeAdsPlatformIMA;
}

- (void)getAdResion:(SlikeAdsUnit *) adsUnit {
    
    if([adsUnit.strAdURL isEqualToString:@""] || [adsUnit.strAdURL isKindOfClass:[NSNull class]] || adsUnit.strAdURL == nil)
    {
        if(self.slikeConfigModel.isSkipAds == YES)
        {
            self.ha =  @"-12";
        } else
        {
            self.ha  = @"-1";
        }
    } else
    {
        if(self.slikeConfigModel.isSkipAds == YES)
        {
            self.ha  = @"-2";
        }
    }
}

- (NSMutableDictionary*) _getAdTypeWithCreativeID:(IMAAd *)ad {
    
    
    NSMutableDictionary *dict =  [NSMutableDictionary dictionary];
    
    if(ad != nil) {
        if(ad.isLinear) {
            // for Linear add
            [dict setObject:@"1" forKey:@"isLinear"];
        } else {
            // for Non Linear add
            [dict setObject:@"2" forKey:@"isLinear"];
        }
        
        if(ad.creativeID && [ad.creativeID length]>0) {
            [dict setObject:ad.creativeID forKey:@"creativeID"];
        }
        if(ad.adTitle && [ad.adTitle length]>0) {
            [dict setObject:ad.adTitle forKey:@"adTitle"];
        }
        [dict setObject:ad.isSkippable ? @"skippable" : @"non-skippable" forKey:@"isSkippable"];
   
        if(ad.adId && [ad.adId length]>0) {
            [dict setObject:ad.adId forKey:@"adId"];
        }
        if(ad.advertiserName && [ad.advertiserName length]>0) {
            [dict setObject:ad.advertiserName forKey:@"advertiserName"];
        }
        if(ad.contentType && [ad.contentType length]>0) {
            NSString * contentType = ad.contentType;
            contentType =  [contentType stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
            [dict setObject:contentType forKey:@"contentType"];
        }
    }
    return dict;
}

/**
 Resume the Ad
 */
- (void)resumeAd {
    if (_isAdPlaying) {
        [self.adsManager resume];
    }
}

/**
 Pause the Ad
 */
- (void)pauseAd {
    if (_isAdPlaying) {
        [self.adsManager pause];
    }
}

@end
