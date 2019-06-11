//
//  SlikeAdManager.m
//  Pods
//
//  Created by Sanjay Singh Rathor on 22/06/18.
//
#import <AVFoundation/AVFoundation.h>
#import "SlikePlayerConstants.h"
#import "SlikeAdManager.h"
#import "EventManager.h"
#import "SlikeGlobals.h"
#import "EventManagerProtocol.h"
#import "SlikeIMAAdController.h"
#import "EventManagerProtocol.h"
#import "EventManager.h"
#import "SlikeFANAdController.h"
#import "SlikeAdsQueue.h"
#import "SlikeAdsUnit.h"
#import "ISlikeAds.h"
#import "SlikeNetworkMonitor.h"
#import "SlikeAnalytics.h"
#import "NSDictionary+Validation.h"
#import "SlikeSharedDataCache.h"
#import "SlikeVideoPlayerRegistrar.h"
#import "SlikeAdEvent.h"
#import "EventModel.h"
#import "UIView+SlikeAlertViewAnimation.h"

@interface SlikeAdManager() <EventManagerProtocol, SlikeAdPlateformEvents> {
    NSString *_strCampaignID;
}
@property(nonatomic,strong) NSString *iu;
@property(nonatomic,strong) NSString * ha;
@property(nonatomic,weak) SlikeConfig *slikeConfigModel;
@property (nonatomic, strong) UIView *adPlaceholder;
@property (nonatomic, strong) UIView *adContainer;
@property (nonatomic, strong) id<ISlikeAds> adPlayer;
@property (nonatomic, readwrite) BOOL isAdInProgress;
@property (nonatomic, readwrite) BOOL isAdLoaded;
@property (nonatomic, assign) NSInteger adUnitPos;
@property (nonatomic, strong) NSTimer *delayTimer;
@property (nonatomic, assign) NSInteger currentAdPos;
@property (nonatomic, assign) NSInteger playerPosition;
@property (nonatomic, assign) NSInteger playerDuration;
@property (nonatomic, strong) StatusInfo *progressInfo;
@property (nonatomic, assign) NSInteger currentAdPostion;
@property (nonatomic, assign) NSInteger currentAdDuration;
@property (nonatomic, strong) SlikeVideoPlayerRegistrar *playerRegistrar;
@property (nonatomic, readwrite) BOOL isPreFetchAD;
@property (nonatomic, readwrite) BOOL isViewVissible;
@property (nonatomic, weak) SlikeAdsQueue *adUnitUsed;

@end

NSString * const kSlikeAdDescriptionKey            = @"errDescription";
NSString * const kSlikeAdErrMessageKey             = @"errMessage";
NSString * const kSlikeAdErrCodeKey                = @"errCode";
NSString * const kSlikeAdAdInfoKey                 = @"adInfo";
NSString * const kSlikeAdAdTypeKey                 = @"AdType";


@implementation SlikeAdManager

#pragma mark - EventManagerProtocol
- (void)update:(SlikeEventType)eventType playerState:(SlikePlayerState)state dataPayload:(NSDictionary *)payload slikePlayer:(id<ISlikePlayer>)player {
    
    if (eventType == ACTIVITY && state == SL_PLAYER_DISTROYED) {
        [self _resetAdsValue];
        if ([[SlikeSharedDataCache sharedCacheManager]isPrefetchAllow] && !_isAdLoaded) {
            
            SlikeDLog(@"ADS LOG: Player has Stoped now need to prefetch: %ld", self.adUnitPos);
            SlikeAdsQueue *slikeAdQueue = [[SlikeSharedDataCache sharedCacheManager]cachedPreloadedAdsContents];
            [self startPrefetchWithDelay:slikeAdQueue];
            
        }
    } else if(eventType == MEDIA) {
        [self _updatePlayerPosition:payload];
    }
}

/**
 Update the Player Position. We are getting the position and duration inside the playload
 @param payload - Payload
 
 NOTE: If Current Container is NULL then we have assumed that current request is for the Prefetch otherwise it is normal request
 */
- (void) _updatePlayerPosition:(NSDictionary*)payload {
    if (!payload ) {
        return;
    }
    NSNumber *currentPosition = [payload numberForKey:kSlikeCurrentPositionKey];
    if (currentPosition !=nil) {
        _playerPosition = [currentPosition integerValue];
    }
    NSNumber *duration = [payload numberForKey:kSlikeDurationKey];
    if (duration !=nil) {
        _playerDuration =   [duration integerValue];
    }
}

#pragma mark - public methods
- (instancetype)init {
    self = [super init];
    
    _adUnitPos = 0;
    _playerPosition = 0;
    _playerDuration = 0;
    _strCampaignID = @"";
    self.ha =  @"-1";
    self.iu =  @"";
    _isViewVissible= YES;
    [[EventManager sharedEventManager]registerEvent:self];
    _playerRegistrar = [[SlikeVideoPlayerRegistrar alloc]init];
    [self applicationPresenceState];
    
    return self;
}

+ (instancetype)sharedInstance {
    static SlikeAdManager *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[SlikeAdManager alloc] init];
    });
    return mediator;
}

/**
 Show the ad. This method needs to be used for prefetching or normal ads call
 
 @param slikeConfig -  Config model
 @param adsContainer - Ad container .
 @param position - PRE-(0)|POST-(-1)|MID
 */
- (void)showAd:(SlikeConfig *)slikeConfig adContainerView:(UIView *)adsContainer forAdPosition:(NSInteger)position {
    
    if(slikeConfig) {
        [[SlikeDeviceSettings sharedSettings] updateAdCustomParams:slikeConfig];
    }
    _currentAdPos = position;
    _adContainer = adsContainer;
    self.slikeConfigModel = slikeConfig;
    
    if (_isAdInProgress || (_adPlayer != nil && _isAdLoaded && _adContainer == nil)) {
        SlikeDLog(@"ADS LOG: Another ad is in progress, this request is discarded");
        return;
    }
    //Now ad is in progress
    _isAdInProgress = YES;
    if (_adContainer == nil) {
        // Normal Ad prefetch
        SlikeDLog(@"ADS LOG: Started prefetching of ad");
        
        if ([[SlikeSharedDataCache sharedCacheManager]isPrefetchAllow]) {
            [self prefetchAd:[[SlikeSharedDataCache sharedCacheManager]cachedPreloadedAdsContents]withPreFetchAD:TRUE withAdFallback:FALSE];
        }
        else {
            _isAdInProgress = NO;
            SlikeDLog(@"ADS LOG: Prefetching of ads not allowed");
        }
        
    } else {
        
        // Prefetch is there show Ad.
        [self _removeCallBacks];
        if (_adPlayer != nil && _isAdLoaded && _adContainer != nil) {
            
            SlikeDLog(@"ADS LOG: Loaded ad found. trying to play ad");
            if([SlikeSharedDataCache sharedCacheManager].pfid && [[SlikeSharedDataCache sharedCacheManager].pfid length] == 0)
            {
                [self _sendAdData:SL_READY withPayLoad:nil];
            }
            [self _addPlaceHolderViewToContainer];
            //[self _vissibleAdsWindows];
            [_adPlayer setSlikeConfigModel:_slikeConfigModel];
            
            [self _showAdLoading];
            [_adPlayer playAd];
            _isAdLoaded = FALSE;
            
        } else {
            // normal ad play
            SlikeDLog(@"ADS LOG: Loaded ad not found. trying to fetch normal ad");
            SlikeAdsQueue *slikeAdsQueue = [self getAdsAtPosition:slikeConfig.streamingInfo.adContentsArray withAdPosition:position];
            
            if (slikeAdsQueue != nil) {
                
                _adUnitPos = 0;
                 SlikeAdsUnit *currentAdUnit = slikeAdsQueue.adContents[_adUnitPos];
                _strCampaignID = currentAdUnit.strAdCategory;
                
                [self _sendAdData:SL_READY withPayLoad:nil];
                [self _showAdLoading];
                [self prefetchAd:slikeAdsQueue withPreFetchAD:FALSE withAdFallback:FALSE];
            }
            else {
                _isAdInProgress = FALSE;
                SlikeDLog(@"ADS LOG: Loaded ad not found and adqueue is null : position  %ld", (long)position);
                [self _hideAdLoading];
                [[EventManager sharedEventManager]dispatchEvent:AD playerState:SL_CONTENT_RESUME dataPayload:@{kSlikeAdAdTypeKey:@([self _currentAdType])} slikePlayer:nil];
            }
        }
    }
}

/**
 Prefetching the ads -
 @param slikeAdsQueue - Slike Ads Queue that contains contents of the array
 */
//(SlikeAdsQueue slikeAdsQueue, boolean , boolean isAdFallback) {
- (void)prefetchAd:(SlikeAdsQueue *)slikeAdsQueue withPreFetchAD:(BOOL)isPreFetchAD withAdFallback:(BOOL)isAdFallback {

    
    if (![[SlikeNetworkMonitor sharedSlikeNetworkMonitor] isNetworkReachible] || slikeAdsQueue == nil  || slikeAdsQueue.adContents == nil || slikeAdsQueue.adContents.count == 0 || _adUnitPos >= slikeAdsQueue.adContents.count) {
    
        SlikeDLog(@"ADS LOG: Something went wrong : Not able to fetch Ad ");
        
        if (self.adContainer !=nil) {
            [[EventManager sharedEventManager]dispatchEvent:AD playerState:SL_CONTENT_RESUME dataPayload:@{kSlikeAdAdTypeKey:@([self _currentAdType])} slikePlayer:nil];
        }
        
        [self _resetAdsValue];
        [self _hideAdLoading];
        
//
//        if ([[SlikeSharedDataCache sharedCacheManager]isPrefetchAllow] && !_isAdLoaded) {
//            SlikeAdsQueue *slikeAdQueue = [[SlikeSharedDataCache sharedCacheManager]cachedPreloadedAdsContents];
//            [self startPrefetchWithDelay:slikeAdQueue];
//        }
        
        return;
    }
    
    self.isPreFetchAD = isPreFetchAD;
    self.adUnitUsed = slikeAdsQueue;
    SlikeAdsUnit *currentAdUnit = slikeAdsQueue.adContents[_adUnitPos];
    
    if (self.adPlayer) {
        [_adPlayer removeAdsComponents];
        _adPlayer=nil;
    }
    
    _strCampaignID = currentAdUnit.strAdCategory;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (currentAdUnit.adProvider == IMA) {
            self.adPlayer = [[SlikeIMAAdController alloc]initWithAdContainerView:[self adPlaceHolderView] withAd:currentAdUnit delegate:self];
        } else {
            
            self.adPlayer = [[SlikeFANAdController alloc]initWithAdContainerView:[self adPlaceHolderView] withAd:currentAdUnit delegate:self];
        }
        
        ///[self _hideAdsWindows];
        [self.adPlayer setSlikeConfigModel:self.slikeConfigModel];
        [self.adPlayer fetchAd];
        SlikeDLog(@"ADS LOG: Fetching ads of position : %ld",  (long)self.adUnitPos);
        
    });
    
    
    if(_isPreFetchAD) {
        [self sendPreFetchAnalytic:0 withError:nil];
    }
}


/**
 Start the Prefetch After some delay
 @param slikeAdsQueue - Slike Ads Queue
 */
- (void)startPrefetchWithDelay:(SlikeAdsQueue *)slikeAdsQueue {
    
    SlikeDLog(@"ADS LOG: Prefetch requested after some time, will start fetching after 10 sec : %ld", (long)_adUnitPos);
    [self _removeCallBacks];
    
    _isAdLoaded = FALSE;
    self.delayTimer = [NSTimer timerWithTimeInterval:10.0 target:self selector:@selector(_startPrefetching:) userInfo:@{@"slikeQueue": slikeAdsQueue} repeats:NO];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:self.delayTimer forMode: NSDefaultRunLoopMode];
    runner = nil;
}

/**
 Start the Prefetching Request
 @param timer - Timer event
 //TODO: Need to optimize this. Should be remove the timer and use call back
 */
- (void)_startPrefetching:(NSTimer *)timer {
    
    SlikeAdsQueue *slikeAdsQueue = (SlikeAdsQueue *)timer.userInfo[@"slikeQueue"];
    if (!self.isAdInProgress) {
        SlikeDLog(@"ADS LOG: Prefetch requested after some time but, trying to fetch : %ld", self.adUnitPos);
        [[EventManager sharedEventManager]registerEvent:self];
        [self prefetchAd:slikeAdsQueue withPreFetchAD:YES withAdFallback:NO];
        
    } else {
        SlikeDLog(@"ADS LOG: Prefetch requested after some time but ad is playing : %ld", self.adUnitPos);
    }
}

/**
 Retuns PRE|POST ad Queue only
 @param adContentsArray - Ads contents
 @param adIdentity - (0)=> PRE | (-1) => POST
 @return - Slike Ad Queue
 */

- (SlikeAdsQueue *)getAdsAtPosition:(NSArray<SlikeAdsQueue *> *)adContentsArray withAdPosition:(NSInteger) adIdentity {
    
    if (!adContentsArray) {
        return nil;
    }
    
    for (SlikeAdsQueue *adInfo in self.slikeConfigModel.streamingInfo.adContentsArray) {
        
        if (adIdentity == -1) {
            if (adInfo.startPoistion == -1 && adInfo.adType == SL_POST) {
                SlikeDLog(@"ADS LOG: Prefetch Ad from Config and AdType == POST");
                return adInfo;
            }
        } else if (adIdentity == 0) {
            if (adInfo.startPoistion == 0 && adInfo.adType == SL_PRE) {
                SlikeDLog(@"ADS LOG: Prefetch Ad from Config and AdType == PRE");
                return adInfo;
            }
        }
        else {
            //TODO: Need to do for the Mid
        }
    }
    return nil;
}

- (void)_resetAdsValue {
    
    if (!_isAdLoaded) {
        if (_adPlayer != nil) {
            [_adPlayer removeAdsComponents];
            _adPlayer=nil;
        }
        
        [self _removeCallBacks];
        if ([NSThread mainThread]) {
            [self _destroyPlaceHolder];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _destroyPlaceHolder];
            });
        }
    }
    _adUnitPos = 0;
    if (self.adContainer) {
        self.adContainer=nil;
    }
    _isAdInProgress = NO;
    
}

- (void)_removeCallBacks {
    if (self.delayTimer && [self.delayTimer isValid]) {
        [self.delayTimer invalidate];
        self.delayTimer = nil;
    }
}

/**
 Distroy the placeholder View
 */
-(void)_destroyPlaceHolder {
    [_adPlaceholder removeViewWithAnimationTime:0.1 completion:^{
        self.adPlaceholder=nil;
    }];
}

#pragma mark - Utility Methods
/**
 Create and retun the placeholder View . It will contain the ads contents
 @return - UIView
 */
- (UIView *)adPlaceHolderView {
    
    if (_adPlaceholder && [_adPlaceholder superview]) {
        [_adPlaceholder removeFromSuperview];
        _adPlaceholder=nil;
    }
    
    _adPlaceholder = [[UIView alloc] init];
    _adPlaceholder.backgroundColor = [UIColor clearColor];
    _adPlaceholder.autoresizesSubviews = YES;
    _adPlaceholder.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    CGSize size = [UIScreen mainScreen].bounds.size;
    _adPlaceholder.frame = CGRectMake(0, 0, size.width, size.height*0.30);
    
    return _adPlaceholder;
}

/**
 Add the placeholder view to the Ad Container
 */
- (void)_addPlaceHolderViewToContainer {
    self.adPlaceholder.frame = _adContainer.frame;
    [_adContainer addSubview:self.adPlaceholder];
}

#pragma mark - SlikeAdPlateformEvents
- (void)slikeAdEventDidReceiveAdEvent:(SlikeAdEventType)adEvent withPayload:(NSDictionary *)payload {
    
    if (adEvent == kSlikeAdEventLoaded) {
        
        _isAdLoaded = YES;
        _isAdInProgress = NO;
        [self _removeCallBacks];
        [self _sendAdData:SL_LOADED withPayLoad:payload];
        
        if (self.adContainer != nil) {
            SlikeDLog(@"ADS LOG: Trying to play ad :: %ld",_adUnitPos);
            [self _addPlaceHolderViewToContainer];
            //[self _vissibleAdsWindows];
            [_adPlayer setSlikeConfigModel:_slikeConfigModel];
            [_adPlayer playAd];
            _isAdLoaded = NO;
            
        } else {
            SlikeDLog(@"ADS LOG: But container is null means prefetch is done, use for future :: %ld",_adUnitPos);
        }
    }
    else if (adEvent == kSlikeAdEventCliked) {
        [self _sendAdData:SL_CLICKED withPayLoad:payload];
    }
    else if (adEvent == kSlikeAdEventCompleted) {
        [self _sendAdData:SL_COMPLETED withPayLoad:payload];
    }
    else  if (adEvent == kSlikeAdEventSkipped) {
        [self _sendAdData:SL_SKIPPED withPayLoad:payload];
    }
    else if (adEvent == kSlikeAdEventProgress) {
        
        if([payload stringForKey:kSlikeAdAdInfoKey] &&  [[payload stringForKey:kSlikeAdAdInfoKey] isEqualToString:@"START"]) {
            [self _sendAdData:SL_START withPayLoad:payload];
        }
        else if([payload stringForKey:kSlikeAdAdInfoKey] &&  [[payload stringForKey:kSlikeAdAdInfoKey] isEqualToString:@"SL_Q0"]) {
            [self _sendAdData:SL_Q0 withPayLoad:payload];
        } else {
            //TODO:
        }
    }
    else if (adEvent == kSlikeAdEventQ1) {
        [self _sendAdData:SL_Q1 withPayLoad:payload];
    }
    else if (adEvent == kSlikeAdEventMid) {
        [self _sendAdData:SL_Q2 withPayLoad:payload];
    }
    else if (adEvent == kSlikeAdEventQ3) {
        [self _sendAdData:SL_Q3 withPayLoad:payload];
    }
    else if (adEvent == kSlikeAdEventResumeContent) {
        SlikeDLog(@"ADS LOG: resume the contents");
        
        [self _resetAdsValue];
        [self _hideAdLoading];
    
        [[EventManager sharedEventManager]dispatchEvent:AD playerState:SL_CONTENT_RESUME dataPayload:@{kSlikeAdAdTypeKey:@([self _currentAdType])} slikePlayer:nil];
        
        if ([[SlikeSharedDataCache sharedCacheManager]isPrefetchAllow] && !_isAdLoaded) {
            SlikeAdsQueue *slikeAdQueue = [[SlikeSharedDataCache sharedCacheManager]cachedPreloadedAdsContents];
            [self startPrefetchWithDelay:slikeAdQueue];
        }
        
    }
    else if (adEvent == kSlikeAdEventPauseContent) {
        [[EventManager sharedEventManager]dispatchEvent:AD playerState:SL_CONTENT_PAUSE dataPayload:@{kSlikeAdAdTypeKey:@([self _currentAdType])} slikePlayer:nil];
    }
    else if (adEvent == kSlikeAdEventLoadingError) {
        //Plateform is unable to load the contents
        SlikeDLog(@"ADS LOG: AdEventLoadingError");
        if(_isPreFetchAD)
        {
            NSString *err = [payload objectForKey:kSlikeAdDescriptionKey];
            [self sendPreFetchAnalytic:2 withError:err];
        }else
        {
            [self _sendAdData:SL_ERROR withPayLoad:payload];
        }
        [self _adPlateformHasSomeIssue];
    }
    else if (adEvent == kSlikeAdEventPlayingError) {
        SlikeDLog(@"ADS LOG: AdEventPlayingError");
        //Plateform is unable to play the contents
        //Incase of playing error SDK always calls resume contents
        //[self _adPlateformHasSomeIssue];
        [self _sendAdData:SL_ERROR withPayLoad:payload];
    }
    else if (adEvent == kSlikeAdEventError) {
        //Plateform is facing some unknown error
        SlikeDLog(@"ADS LOG: AdEventError");
        [self _adPlateformHasSomeIssue];
    }
    else if (adEvent == kSlikeAdEventUpdateData) {
        [self _updateParametrs:payload];
    }
    else if (adEvent == kSlikeAdEventTimeout) {
        SlikeDLog(@"ADS LOG: AdEventTimeout");
        [self _adPlateformHasSomeIssue];
    }
    else if (adEvent == kSlikeAdEventStarted) {
        [self _hideAdLoading];
        if (!_isViewVissible) {
            [_adPlayer pauseAd];
        }
    }
}
- (void)_hideAdLoading {
    [[EventManager sharedEventManager]dispatchEvent:AD playerState:SL_HIDE_LOADING dataPayload:@{} slikePlayer:nil];
}

- (void)_showAdLoading {
    [[EventManager sharedEventManager]dispatchEvent:AD playerState:SL_LOADING dataPayload:@{} slikePlayer:nil];
}

/**
 Ad plateform has received some issues. Check for next index to stop manager and notify the player
 */
- (void)_adPlateformHasSomeIssue {
    
    _isAdInProgress = NO;
    //[self _hideAdsWindows];
    if (_adContainer == nil) {
        _adUnitPos++;
        SlikeDLog(@"ADS LOG: Error found : Trying to fetch next ad for future :: %ld", _adUnitPos);
        [self prefetchAd:[[SlikeSharedDataCache sharedCacheManager]cachedPreloadedAdsContents] withPreFetchAD:YES withAdFallback:YES];
        
    } else {
        SlikeDLog(@"ADS LOG: Error found : Trying to play video :: %ld", _adUnitPos);
        
        [self _resetAdsValue];
        [self _hideAdLoading];

        [[EventManager sharedEventManager]dispatchEvent:AD playerState:SL_CONTENT_RESUME dataPayload:@{kSlikeAdAdTypeKey:@([self _currentAdType])} slikePlayer:nil];
        
        if ([[SlikeSharedDataCache sharedCacheManager]isPrefetchAllow] && !_isAdLoaded) {
            SlikeAdsQueue *slikeAdQueue = [[SlikeSharedDataCache sharedCacheManager]cachedPreloadedAdsContents];
            [self startPrefetchWithDelay:slikeAdQueue];
        }
        
    }
}


-(void)someTime {
    
}

//We are not showing the ads so need to hide all the windows that is being used to show the ads
- (void)hideAdsWindows {
    // [self.adContainer sendSubviewToBack:_adPlaceHolder];
}

// We are going to show the ads so need to make all the ads windows vissible
- (void)vissibleAdsWindows {
    // [self.adContainer bringSubviewToFront:_adPlaceHolder];
}

#pragma mark - Ad Analytics

/**
 Send Ad Analytics to server
 @param status - Current Status of Ad
 @param payload - Payload Data
 */
- (void)_sendAdData:(NSInteger)status withPayLoad:(NSDictionary*)payload  {
    
//    if(status ==  SL_LOADED ) {
//        return;
//    }
    
    NSString *adMoreInfo =  @"";
    NSString *adTitle = @"";
    NSString *isSkippable = @"";
    NSString *ad_advertiserName = @"";
    NSString *ad_contentType = @"";

    if([payload stringForKey:@"contentType"])
    {
        ad_contentType = [payload stringForKey:@"contentType"];
    }
    if([payload stringForKey:@"adTitle"])
    {
        adTitle = [payload stringForKey:@"adTitle"];
    }
  //  NSLog(@"payload = > %@",payload);
    if([payload stringForKey:@"advertiserName"])
    {
        ad_advertiserName = [payload stringForKey:@"advertiserName"];
    }
    if([payload stringForKey:@"isSkippable"])
    {
        isSkippable = [payload stringForKey:@"isSkippable"];
    }
    if([payload stringForKey:@"isLinear"]) {
        adMoreInfo = [NSString stringWithFormat:@"&adty=%@",[payload stringForKey:@"isLinear"]];
        
        if([payload stringForKey:@"creativeID"]) {
            adMoreInfo = [NSString stringWithFormat:@"%@&adci=%@",adMoreInfo,[payload stringForKey:@"creativeID"]];
        }
    }
    else if(status == SL_ERROR && [[payload numberForKey:kSlikeAdErrCodeKey] integerValue] == 900) {
        adMoreInfo = [NSString stringWithFormat:@"&adty=%@",@"2"];
    }
    
    NSNumber *currentPosition = [payload numberForKey:@"adPosition"];
    if (currentPosition !=nil) {
        _currentAdPostion = [currentPosition integerValue];
    }
    
    NSNumber *duration = [payload numberForKey:@"aDduration"];
    if (duration !=nil) {
        _currentAdDuration =   [duration integerValue];
    }
    
    SlikeDLog(@"_currentAdPostion - %ld", (long)_currentAdPostion);
    
    NSInteger nStatus = 3;
    NSString * thirdPartyStatus = @"";
    if(status == SL_READY) {
        nStatus = 0;
        thirdPartyStatus = @"ADREQUEST";
    }
    else if(status == SL_LOADED) {
        nStatus = -1;
        thirdPartyStatus = @"ADLOADED";
        
    }
    else if(status == SL_START) {
        nStatus = 1;
        thirdPartyStatus = @"ADVIEW";

    } else if(status == SL_ERROR) {
        nStatus = 2;
        thirdPartyStatus = @"ADERROR";
    } else if(status == SL_Q0)
    {
        [SlikeSharedDataCache sharedCacheManager].pfid =  @"";
        nStatus = 3;
//        thirdPartyStatus = @"ADVIEW";
    }
    else if(status == SL_Q1)
    {
        nStatus = 4;
        thirdPartyStatus = @"QUARTILE1";

    }
    else if(status == SL_Q2)
    {
        nStatus = 5;
        thirdPartyStatus = @"QUARTILE2";

    }
    else if(status == SL_Q3)
    {
        nStatus = 6;
        thirdPartyStatus = @"QUARTILE3";

    }
    else if(status == SL_COMPLETED)
    {
        [SlikeSharedDataCache sharedCacheManager].pfid =  @"";
        nStatus = 7;
        thirdPartyStatus = @"ADCOMPLETE";

    } else if(status == SL_SKIPPED)
    {
        nStatus = 8;
        thirdPartyStatus = @"ADSKIP";

    } else if(status == SL_CLICKED)
    {
        nStatus = 9;
        thirdPartyStatus = @"ADCLICK";
    }
    //NSInteger position;
    NSInteger adt = 1;
    if(_currentAdPos == 0) {
        //position = 0;
        adt=1;
    } else if(_currentAdPos == -1) {
        //position = self.slikeConfigModel.streamingInfo.nEndTime;
        adt=3;
    } else {
        //
        //position = _playerPosition;
        adt=2;
    }
    
    float vol = [[AVAudioSession sharedInstance] outputVolume];
    BOOL playerVolume = NO ;
    if(vol>0.0) {
        playerVolume = NO;
        
    } else {
        playerVolume = YES;
    }
    
    NSString * adId = [payload stringForKey:@"adId"];
    if (!adId) {
        adId = @"";
    }
    
    NSMutableDictionary *payLoadDictonary = [[NSMutableDictionary alloc]init];
    if (self.slikeConfigModel) {
        [payLoadDictonary setObject:self.slikeConfigModel forKey:kSlikeConfigModelKey];
    }
    
    EventModel *eventModel = [EventModel createEventModel:SlikeAnalyticsTypeAVPlayerAd withBehaviorEvent:SlikeUserBehaviorEventNone withPayload:@{}];

    eventModel.slikeConfigModel = self.slikeConfigModel;
    eventModel.adEventModel.advertiserName = ad_advertiserName;
    eventModel.adEventModel.adTitle = adTitle;
    eventModel.adEventModel.contentType = ad_contentType;
    eventModel.adEventModel.isSkippable = isSkippable;
    eventModel.adEventModel.adStatus = nStatus;
    eventModel.adEventModel.adStatusAnalytics = thirdPartyStatus;
    eventModel.adEventModel.slikeAdId = adId;
    eventModel.adEventModel.adCampaign = _strCampaignID;
    eventModel.adEventModel.retryCount = _adUnitPos;
    eventModel.adEventModel.mediaDuration = self.slikeConfigModel.streamingInfo.nDuration;
    eventModel.adEventModel.mediaPoistion = _playerPosition;
    eventModel.adEventModel.adDuration = _currentAdDuration;
    eventModel.adEventModel.adPosition = _currentAdPostion;
    eventModel.adEventModel.volumeLevel = vol;
    eventModel.adEventModel.isVolumeOn = playerVolume;
    eventModel.adEventModel.adMoreInfo = adMoreInfo;
    eventModel.adEventModel.errDespription = [payload objectForKey:kSlikeAdDescriptionKey];
    eventModel.adEventModel.errCode = [payload stringForKey:kSlikeAdErrCodeKey];
    eventModel.adEventModel.slikeAdType = adt;
    eventModel.adEventModel.iu = self.iu;
    eventModel.adEventModel.adResgion = self.ha;
    eventModel.adEventModel.isAdPrefetched = _isPreFetchAD;
    
    if([_adPlayer currentAdPlateform] == SlikeAdsPlatformFacebook)
    {
        eventModel.adEventModel.adProviderType =  3;
    }
    if([SlikeSharedDataCache sharedCacheManager].pfid && [[SlikeSharedDataCache sharedCacheManager].pfid  length]>0) {
        eventModel.adEventModel.pfid = [SlikeSharedDataCache sharedCacheManager].pfid;
    }
    
    [[EventManager sharedEventManager]dispatchEvent:AD playerState:status dataPayload:@{kSlikeEventModelKey:eventModel} slikePlayer:nil];
    
    SlikeAdStatusInfo *info = [SlikeAdStatusInfo initWithID:adId withAdPos:_currentAdPostion withCampaign:_strCampaignID withPosition:_playerPosition withDuration:_currentAdDuration withRetryCount:_adUnitPos withState:status withAdType:_currentAdPos];
    [self _updateAdStatusInfo:info];
}

/**
 Update the parameters for the analytics
 @param info - Payload dictonary
 */
- (void)_updateParametrs:(NSDictionary*)info {
    if([info stringForKey:@"iu"]) {
        self.iu =  [info stringForKey:@"iu"];
    }
    if([info stringForKey:@"ha"]) {
        self.ha =  [info stringForKey:@"ha"];
    }
}

/**
 Update the Ads status info
 @param adsInfo - Ad status of current Ad
 */
- (void)_updateAdStatusInfo:(SlikeAdStatusInfo *) adsInfo {
    
    if(adsInfo) {
        
        [self _getStatusInfo: adsInfo.state];
        self.progressInfo.adStatusInfo = adsInfo;
        
        //Need to post the event to parent app
        [[EventManager sharedEventManager]dispatchEvent:AD playerState:adsInfo.state dataPayload:@{kSlikeADispatchEventToParentKey:@YES, kSlikeAdStatusInfoKey:_progressInfo} slikePlayer:nil];
    }
    else {
        self.progressInfo.adStatusInfo = nil;
    }
}

- (StatusInfo *)_getStatusInfo:(SlikePlayerState)status {
    
    if(self.progressInfo == nil) {
        self.progressInfo = [StatusInfo initWithBuffer:0 withPosition:_playerPosition withDuration:_playerDuration muteStatus:0];
    } else {
        self.progressInfo.position = _playerPosition;
        self.progressInfo.duration = _playerDuration;
    }
    return _progressInfo;
}

/**
 Return the Current Ad Type
 @return - Ad Type
 */
- (SlikeAdType)_currentAdType {
    
    SlikeAdType adType = SL_MID;
    if (_currentAdPos==0) {
        adType = SL_PRE;
    } else if (_currentAdPos==-1) {
        adType = SL_POST;
    }
    return adType;
}

/**
 Application States handling
 */
- (void)applicationPresenceState {
    
    __weak typeof(self) weekSelf = self;
    [_playerRegistrar setWillResignActive:^(SlikeVideoPlayerRegistrar * _Nonnull registrar) {
        if (weekSelf.adContainer && weekSelf.adPlayer){
            weekSelf.isViewVissible = NO;
            [weekSelf.adPlayer pauseAd];
        }
    }];
    
    [_playerRegistrar setDidBecomeActive:^(SlikeVideoPlayerRegistrar * _Nonnull registrar) {
        if (weekSelf.adContainer && weekSelf.adPlayer){
            weekSelf.isViewVissible = YES;
            [weekSelf.adPlayer resumeAd];
        }
    }];
    
    [_playerRegistrar setWillEnterForeground:^(SlikeVideoPlayerRegistrar * _Nonnull registrar) {
        if (weekSelf.adContainer && weekSelf.adPlayer){
            weekSelf.isViewVissible = YES;
            [weekSelf.adPlayer resumeAd];
        }
    }];
}


/**
 Send the Prefetch Ads hadling
 
 @param evt - Event Type
 @param error - Error if any
 */
- (void)sendPreFetchAnalytic:(NSInteger)evt withError:(NSString*)error {
   
    if([SlikeSharedDataCache sharedCacheManager].isGDPREnable) return;

    NSString *ss =  @"";
    NSString *videoId = @"";
    NSInteger noss = 1;
    self.ha =  @"1";
    if(self.slikeConfigModel)
    {
        videoId =  self.slikeConfigModel.mediaId;
        ss =  self.slikeConfigModel.streamingInfo.strSS;
        if([ss isValidString]) {
            noss = 0;
        }
    }
    NSString *analyticInfo =  @"";
    long atl = (long)[SlikeDeviceSettings sharedSettings].nAdLoadTime;
    long atc = (long)[SlikeDeviceSettings sharedSettings].nAdContentLoadTime;
    
    if(evt == 0) {
        
        if(![SlikeSharedDataCache sharedCacheManager].pfid || [SlikeSharedDataCache sharedCacheManager].pfid == nil || [[SlikeSharedDataCache sharedCacheManager].pfid isKindOfClass:[NSNull class]]) {
            [SlikeSharedDataCache sharedCacheManager].pfid = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:@"pfid"];
        }
        else if([SlikeSharedDataCache sharedCacheManager].pfid && [[SlikeSharedDataCache sharedCacheManager].pfid length] == 0) {
            [SlikeSharedDataCache sharedCacheManager].pfid = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:@"pfid"];
        }
        
        analyticInfo = [NSString stringWithFormat:@"evt=%ld&k=%@&ss=%@&vp=%ld&pf=%d&ha=%@&noss=%ld&pfid=%@&rt=%ld&mrtad=%ld&atr=0&atl=%ld&atc=%ld&adt=-1&ci=%@&",(long)evt,videoId,ss,(long)self.playerPosition,self.isPreFetchAD,self.ha,(long)noss, [SlikeSharedDataCache sharedCacheManager].pfid,(long)_adUnitPos, (long)[[SlikeSharedDataCache sharedCacheManager] prefetchedAdsCount],atl,atc,_strCampaignID];
        
    } else {
        analyticInfo = [NSString stringWithFormat:@"evt=%ld&k=%@&ss=%@&vp=%ld&pf=%d&ha=%@&noss=%ld&pfid=%@&err=%@&rt=%ld&mrtad=%ld&atr=0&atl=%ld&atc=%ld&adt=-1&ci=%@&",(long)evt,videoId,ss,(long)self.playerPosition,self.isPreFetchAD,self.ha,(long)noss, [SlikeSharedDataCache sharedCacheManager].pfid,error,(long)_adUnitPos,(long)[[SlikeSharedDataCache sharedCacheManager] prefetchedAdsCount],atl,atc,_strCampaignID];
    }
    
    [[SlikeNetworkManager defaultManager] sendPreFetchAnalyticLog:analyticInfo withCompletionBlock:^(id obj, NSError *error) {
        
        NSString *responseString = (NSString *)obj;
        NSDictionary *dict = [SlikeUtilities jsonStringToDictionary:responseString];
        
        if([dict isValidDictonary]) {
            NSDictionary *responseDict = [dict dictionaryForKey:@"body"];
            if (responseDict) {
                [SlikeSharedDataCache sharedCacheManager].pfid = [responseDict stringForKey:@"pfid"];
                [SlikeSharedDataCache sharedCacheManager].ts = [responseDict stringForKey:@"ts"];
                [SlikeSharedDataCache sharedCacheManager].interval = [responseDict stringForKey:@"interval"];
            }
        }
    }];
}

@end
