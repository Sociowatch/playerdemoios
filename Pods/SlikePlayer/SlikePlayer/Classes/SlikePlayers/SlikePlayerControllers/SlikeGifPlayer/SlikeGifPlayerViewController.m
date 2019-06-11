//
//  SlikeGifPlayerViewController.m
//  Pods-SlikePlayer_Example
//
//  Created by Sanjay Singh Rathor on 07/03/18.
//

#import "SlikeGifPlayerViewController.h"
#import "SlikeUtilities.h"
#import "NSBundle+Slike.h"
#import "EventModel.h"
#import "SlikePlayerEvent.h"
#import "EventManagerProtocol.h"
#import "EventManager.h"
#import "SlikePlayerConstants.h"
#import "UIView+SlikeAlertViewAnimation.h"


@interface SlikeGifPlayerViewController () <SlikeGifPlayerDelegate, EventManagerProtocol> {
    id playerContainer;
}

@property (assign, nonatomic) BOOL playerLoaded;
@property (assign, nonatomic) BOOL playerStarted;
@property (assign, nonatomic) BOOL isPlaying;
@property (assign, nonatomic) NSInteger playingCounter;
@property (assign, nonatomic) NSInteger mp4Duration;
@property (nonatomic,assign)  BOOL isNativeControls;
@property (nonatomic,assign) NSUInteger mediaTimeStamp;
@property (strong,nonatomic) SlikeConfig * sdkConfiguration;
@property(assign) NSInteger analyticsTime;

@property (strong, nonatomic) IBOutlet UIView *networkErrorView;
@property (weak, nonatomic) IBOutlet UIImageView *networkErrIcon;
@property (weak, nonatomic) IBOutlet UIButton *networkTabButton;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet SlikeGifView *slikeGifView;
@property (assign, nonatomic) SlikePlayerState playerStatus;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;

@end

@implementation SlikeGifPlayerViewController
@synthesize slikeConfig;
@synthesize isAppAlreadyDestroyed;
@synthesize isAppActive;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.btnClose setImage:[UIImage imageNamed:@"player_closebtn" inBundle:[NSBundle slikeImagesBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    self.networkErrIcon.image = [UIImage imageNamed:@"iconError" inBundle:[NSBundle slikeImagesBundle] compatibleWithTraitCollection:nil];
    self.networkErrorView.hidden= YES;
    [self.networkTabButton addTarget:self action:@selector(handleNoInternetTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [[EventManager sharedEventManager]registerEvent:self];
    
    self.btnClose.hidden = YES;
    self.playerLoaded=NO;
    self.playerStarted=NO;
    self.isPlaying=NO;
    self.playingCounter = 0;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // [self pause:YES];
}

#pragma mark - ISlikePlayer Protocolimplementation
/*
 ISlikePlayer - Protocol method implementation
 */
- (void)playMovieStreamWithObject:(SlikeConfig *)si withParent:(id) parent withError:(NSError*)error {
    //For Error handlation
}

- (void)playMovieStreamWithObject:(SlikeConfig *)config withParent:(id) parent {
    
    self.sdkConfiguration = config;
    self.slikeConfig = config;
    //Genrate New SS if the video play in second time
    [[SlikeDeviceSettings sharedSettings] setPlayerViewArea:parent];
    
    [self setVideoPlaceHolder:YES];
    
    // [SlikeAnalytics  sharedManager].isFirstTimePlay = YES;
    self.sdkConfiguration.streamingInfo.strSS = @"";
    
    if([self.sdkConfiguration.streamingInfo.strSS length] == 0)
        self.sdkConfiguration.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:self.sdkConfiguration.mediaId];
    //Add custom Controls
    self.isNativeControls = YES;
    
    
    self.slikeGifView.parentController=self;
    self.slikeGifView.delegate=self;
    playerContainer = parent;
    
    if([self.sdkConfiguration.streamingInfo.strSS length] == 0) {
        self.sdkConfiguration.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:self.sdkConfiguration.mediaId];
        self.sdkConfiguration.streamingInfo.strSS = self.sdkConfiguration.streamingInfo.strSS;
    }
    
    NSString *getGifMp4Url = [self.sdkConfiguration.streamingInfo getURL:VIDEO_SOURCE_MP4 byQuality:@""].strURL;
    if(getGifMp4Url != nil) {
        [self.slikeGifView loadMP4Player:getGifMp4Url];
    } else {
        getGifMp4Url = [self.sdkConfiguration.streamingInfo getURL:VIDEO_SOURCE_GIF_MP4 byQuality:@""].strURL;
        [self.slikeGifView loadGifPlayer:getGifMp4Url];
    }
    self.analyticsTime = (self.sdkConfiguration.gifInterval/1000)-1;
}

- (NSUInteger)getPosition {
    return 0;
}

- (NSUInteger)getDuration {
    return 0;
}

- (NSUInteger)getBufferTime {
    return 0;
}

-(float) getLoadTimeRange {
    return 0;
}

- (SlikePlayerState) getStatus {
    return _playerStatus;
}

- (void)viewWillEnterForeground {
    self.isAppActive = YES;
}

- (void)viewWillEnterBackground {
    self.isAppActive = NO;
}

- (void)play:(BOOL) isUser {
    if(!self.slikeGifView) return;
    
    if (![self.slikeGifView isPlaying]) {
        [self.slikeGifView playGif];
    }
}

- (void)pause:(BOOL) isUser {
    if(!self.slikeGifView) return;
    [self.slikeGifView pauseGif];
}

- (void)resume {
    if(!self.slikeGifView) return;
}

- (void)replay {
    if(!self.slikeGifView) return;
}

- (BOOL)isPlaying {
    return _isPlaying;
}

- (BOOL)isFullScreen {
    if(!self.slikeGifView) {
        return NO;
    }
    return [self.slikeGifView isPlayerInFullScreen];
}

- (void)toggleFullScreen {
    if(!self.slikeGifView) return;
    [self.slikeGifView setFullscreen:YES];
}

-(void) seekTo:(float) nPosition userSeeked:(BOOL) isUser {
    return;
}

- (void)removePlayer {
    
    [self sendAnalyticsData];
    [self cleanup];
    
    if(playerContainer) {
        if([playerContainer isKindOfClass:[UIView class]]) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
    }
}

- (BOOL)isPlayerExist {
    return (self.slikeGifView ==nil)? NO :YES;
}

- (NSString *)getCurrentFlavour {
    return @"";
}

- (void)stop {
    if(!self.slikeGifView) return;
    [self.slikeGifView cleanupGifResources];
}

- (BOOL)cleanup {
    
    if(self.isAppAlreadyDestroyed) {
        return NO;
    }
    self.isAppAlreadyDestroyed = YES;
    if(self.slikeGifView) {
        [self stop];
    }
    self.slikeConfig.streamingInfo = nil;
    self.slikeConfig = nil;
    self.sdkConfiguration = nil;
    return YES;
}

- (void)playerMute:(BOOL)isMute {
    //Do Nothing
}

- (BOOL)getPlayerMuteStatus {
    return  NO;
}

- (instancetype)getViewController {
    return self;
}
- (void)setParentReference:(UIView *) parentView {
}

- (void)setOnPlayerStatusDelegate:(onChange) block {
}
- (void)setController:(id<ISlikePlayerControl>) control {
}
- (id<ISlikePlayerControl>) getControl {
    return nil;
}

- (BOOL)canShowBitrateChooser {
    return NO;
}

- (NSArray*)showBitrateChooser:(BOOL)isCustom {
    return nil;
}

- (void)sendCustomControlEvent:(SlikePlayerState) state {
}

- (void)updateCustomBitrate:(Stream*)obj {
    //DO NOTHING.
}

- (void)setNativeControl:(BOOL) isNative {
    self.isNativeControls = isNative;
}

- (NSString*)currentBitRateURI {
    return @"";
}

- (void)hideBitrateChooser {
}


- (BOOL)isAdPlaying {
    return  NO;
}

- (IBAction)clbCloseAction:(id)sender {
   // [[SlikePlayer getInstance] stopPlayer];
}

- (void)playPrevious {
}

- (void)playNext {
}

- (id<ISlikeCast>)getCast {
    return  nil;
}

- (void)setCast:(id<ISlikeCast>)cast {
}

- (void)getScreenShotAtPosition:(NSInteger)position withCompletionBlock:(void (^)(UIImage *))completion {
    completion(nil);
}


#pragma mark - SlikeGifPlayerDelegate
- (void)gifPlayerLoaded:(SlikeGifView *)gifView {
    _playerStatus = SL_READY;
    if(!self.playerLoaded) {
        
        //Duration is not available if media type is not mp4
        if(gifView.mp4Duration != -1){
            self.mp4Duration = gifView.mp4Duration;
        }
        self.playerLoaded=YES;
        [self setVideoPlaceHolder:NO];
        [self prepareAndSendAnaltytics:@"1" andPlayDuration:@"0" andReset:NO];
    }
}

- (void)gifPlayerStartPlaying:(SlikeGifView *)gifView {
    _playerStatus = SL_PLAYING;
    if(!self.playerStarted) {
        self.playerStarted=YES;
        [self prepareAndSendAnaltytics:@"2" andPlayDuration:@"0" andReset:NO];
        
        _mediaTimeStamp = CACurrentMediaTime();
    }
    self.isPlaying =YES;
}

- (void)gifPlayerUpdateTime:(SlikeGifView *)gifView {
    if(CACurrentMediaTime()  - _mediaTimeStamp > self.analyticsTime && self.playingCounter) {
        [self sendAnalyticsData];
    }
}

- (void)sendAnalyticsData {
    
    NSInteger totalTimePlayed = self.playingCounter * _mp4Duration + [self.slikeGifView gifMp4PlayerCurrentPosition];
    [self prepareAndSendAnaltytics:@"3" andPlayDuration:[NSString stringWithFormat:@"%ld",(long)totalTimePlayed] andReset:YES];
    _mediaTimeStamp = CACurrentMediaTime();
    self.playingCounter = 0;
}

- (void)gifPlayerReStarted {
    ++self.playingCounter;
}

- (void)gifPlayerFailed:(NSError *)err {
    _playerStatus = SL_ERROR;
    [self sendPlayerStatus:_playerStatus];
    
    if([[SlikeReachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [self handleNoInternetTap:nil];
    }
}

#pragma mark - Send the analytic data to the server
- (void)prepareAndSendAnaltytics:(NSString *) evtString andPlayDuration:(NSString *)playDutration andReset:(BOOL)resetCounter {
    
    if([self.sdkConfiguration.streamingInfo.strSS length] == 0) {
        self.sdkConfiguration.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:self.sdkConfiguration.mediaId];
        self.sdkConfiguration.streamingInfo.strSS = self.sdkConfiguration.streamingInfo.strSS;
    }
    
    if(self.mp4Duration <0 ){
        self.mp4Duration=0;
    }
    
    EventModel *eventModel = [EventModel createEventModel:SlikeAnalyticsTypeGif withBehaviorEvent:SlikeUserBehaviorEventNone withPayload:@{}];
    eventModel.slikeConfigModel = self.sdkConfiguration;
    
    eventModel.playerEventModel.eventType = evtString;
    eventModel.playerEventModel.type = @"gif";
    eventModel.playerEventModel.currentPlayer = [self.sdkConfiguration.streamingInfo getCurrentPlayer];
    //
//    eventModel.playerEventModel.playerType = [self.sdkConfiguration.streamingInfo getConstantValueForPlayerType];
    eventModel.playerEventModel.playerType = 18;

    eventModel.playerEventModel.playerPosition = [playDutration integerValue];
    eventModel.playerEventModel.playerDuration = self.mp4Duration;
    
    [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:_playerStatus dataPayload:@{kSlikeEventModelKey:eventModel} slikePlayer:self];
    
}

#pragma mark - Handle Network Error

- (void)handleNoInternetTap:(id)recognizer {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([[SlikeReachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
            
            self.networkErrorView.frame = self.view.bounds;
            self.networkErrorView.autoresizesSubviews = YES;
            BOOL doesContain = [self.view.subviews containsObject:self.networkErrorView];
            if(!doesContain) {
                
                self->_networkErrorView.hidden = NO;
                [self.view addSubview:self.networkErrorView];
            }
            
        } else {
            [self.slikeGifView resumeGifAfterNetworkIssue];
            [self.networkErrorView removeFromSuperview];
            self->_networkErrorView.hidden = YES;
        }
    });
}


#pragma mark -  Send Player Status
- (void)sendPlayerStatus:(SlikePlayerState) status {
    
    StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:[self getPosition] withDuration:[self getDuration] muteStatus:0];
    [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:status dataPayload:@{kSlikeADispatchEventToParentKey:@YES, kSlikeAdStatusInfoKey:progressInfo} slikePlayer:self];
    
}

#pragma mark - EventManagerProtocol
/**
 Method will be called by the Event menager
 
 @param eventType - Current event Type
 @param state - Current State
 @param payload - Payload if any
 @param player - Current Player
 */
- (void)update:(SlikeEventType)eventType playerState:(SlikePlayerState)state dataPayload:(NSDictionary *) payload slikePlayer:(id<ISlikePlayer>)player {
}



- (void)setVideoPlaceHolder:(BOOL)isSet {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(!isSet && self.posterImage.hidden) {
            return;
        }
        if(self.slikeConfig.isAllowSlikePlaceHolder) {
            self.posterImage.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1];
            
            if(isSet) {
                if(self.posterImage.image!=nil) {
                    [self.posterImage slike_fadeInTime:0.1 withCompletion:^(UIView *view) {
                        self.posterImage.hidden= NO;
                    }];
                    
                } else if([SlikeUtilities getPosterImage:self.slikeConfig].length>0) {
                    
                    [[SlikeNetworkManager defaultManager] getImageForURL:[NSURL URLWithString:[SlikeUtilities getPosterImage:self.slikeConfig]] completion:^(UIImage *image, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
                        
                        if(!error) {
                            self.posterImage.image =image;
                        }
                        else {
                            
                            [self.posterImage slike_fadeOutAndCompletion:^(UIView *view) {
                                self.posterImage.hidden= YES;
                            }];
                        }
                    }];
                } else {
                    [self.posterImage slike_fadeOutAndCompletion:^(UIView *view) {
                        self.posterImage.hidden= YES;
                    }];
                }
            } else {
                
                if(!self.posterImage.hidden) {
                    [self.posterImage slike_fadeOutAndCompletion:^(UIView *view) {
                        self.posterImage.hidden= YES;
                    }];
                }
            }
        } else {
            self.posterImage.hidden= YES;
        }
    });
}

- (void)resetPlayer {
    [self stop];
}
@end
