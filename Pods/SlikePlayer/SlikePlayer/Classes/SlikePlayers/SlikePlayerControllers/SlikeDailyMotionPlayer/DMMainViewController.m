//
//  DMMainViewController.m
//  Pods
//
//  Created by Aravind kumar on 4/24/17.
//
//

#import "DMMainViewController.h"
#import <SlikePlayer.h>
#import "SlikeNetworkManager.h"
#import "SlikeInAppBrowserViewController.h"
#import "SlikeAnalytics.h"
#import "NSBundle+Slike.h"
#import "SLEventModel.h"
#import "SlikePlayerEvent.h"
#import "EventManagerProtocol.h"
#import "EventManager.h"
#import "SlikePlayerConstants.h"
#import "SlikeMaterialDesignSpinner.h"
#import "SlikeAdManager.h"
#import "UIView+SlikeAlertViewAnimation.h"
#import "SLEventModel.h"
#import "SlikeAdEvent.h"
#import "NSBundle+Slike.h"
#import "SlikePlayerErrorView.h"
#import "SlikeNetworkMonitor.h"
#import "SlikeServiceError.h"

#define SlikePlayerButtonNormalDm(file,imageBundle) [UIImage imageNamed:file inBundle:imageBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal

@interface DMMainViewController () <EventManagerProtocol> {
    
    NSString *strMovieID;
    NSString *strMovieTitle;
    NSInteger nDuration, nBufferingTime;
    BOOL isPlaying;
    BOOL isAutoPlay;
    
}
@property (nonatomic, readwrite) BOOL isNetworkWindowPresented;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (nonatomic, assign) NSInteger currentAdType;
@property (nonatomic, weak) IBOutlet SlikeMaterialDesignSpinner *loadingIndicator;
@property (nonatomic, strong) UIView *adPlayerView;
@property (nonatomic, readwrite) BOOL isCurrentlyAdPlaying;
@property (nonatomic, readwrite) BOOL isPlaybackDone;
@property (nonatomic, readwrite) BOOL hasPostRollCompleted;
@property (nonatomic, strong) SlikePlayerErrorView *slikeAlertView;


@end

@implementation DMMainViewController

@synthesize isAppActive;
@synthesize isAppAlreadyDestroyed;
@synthesize slikeConfig;
@synthesize isNativeControls;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSBundle *imageBundle = [NSBundle slikeImagesBundle];
    isAutoPlay = NO;
    [self.playBtn setImage:SlikePlayerButtonNormalDm(@"player_play",imageBundle)];
    self.playBtn.hidden = YES;
    _isPlaybackDone = NO;
    _hasPostRollCompleted = NO;
        
    // Do any additional setup after loading the view.
    self.playerView.delegate = self;
    isPlaying= NO;
    //Define Play Duration Time--
    nTotalBufferDuration = 0;
    nTotalPlayedDuration = 0;
    nTotalBufferTimestamp = 0;
    nTotalPlayedTimestamp = 0;
    //The setup code (in viewDidLoad in your view controller)
    [[EventManager sharedEventManager]registerEvent:self];
    isFullScreen = NO;
    
}
- (IBAction)playAction:(id)sender {
    self.playBtn.hidden = YES;
    isAutoPlay = YES;
   if(![[SlikeNetworkMonitor sharedSlikeNetworkMonitor] isNetworkReachible]) {
       [self _showAlertViewForOffline:YES hasEmptyBuffer:NO];
       [self _sendNetworkErrorMessage];
   } else  {
       [self loadMediaIntialState];
    }
   
}
- (void)initWithStringWithID:(NSString *)strID withClipID:(NSString *) strClipID withTitle:(NSString *) strTitle {
    SlikeDLog(@"DMP (%@) -- (%@) -- (%@)", strID, strClipID, strTitle);
    nDuration = 0;
    strMovieID = strClipID;
    strMovieTitle = strTitle;
    // Set its delegate and other parameters (if any)
    self.playerView.delegate = self;
    self.playerView.autoOpenExternalURLs = false;
    self.playerView.webBaseURLString = @"http://www.dailymotion.com";
    
    NSDictionary *playerCallbacks;
    if(isAutoPlay) {
    playerCallbacks = @{
        @"autoplay": @"1" ,
        @"controls":self.isNativeControls ? @"1" : @"0",@"endscreen-enable":@"0",@"sharing-enable":@"0",@"ui-logo":@"0",@"ui-start-screen-info":@"0"};
    }else  {
    playerCallbacks = @{
        @"autoplay": self.slikeConfig.isAutoPlay ? @"1" : @"0" ,
        @"controls":self.isNativeControls ? @"1" : @"0",@"endscreen-enable":@"0",@"sharing-enable":@"0",@"ui-logo":@"0",@"ui-start-screen-info":@"0"};
    }
    self.playerView.isDMExternalLinkHandle = self.slikeConfig.isDMExternalLinkHandle;
    [self.playerView loadVideo:strID withParams:playerCallbacks];
    self.playerView.frame = self.view.frame;
    [self.playerView updatePlayerFrames];
    [self sendPlayerStatus:SL_LOADED];
    
}

#pragma mark DMPlayerDelegate
- (void)dailymotionPlayer:(DMPlayerViewController *)player didReceiveEvent:(NSString *)eventName {
    // Grab the "apiready" event to trigger an autoplay
    if (eventName.length){
        if ([eventName isEqualToString:@"timeupdate"]){
            isPlaying = YES;
            playerStatus = SL_PLAYING;
            [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventNone forced:(playerStatus != SL_PLAYING) ? YES : NO];
        } else if ([eventName isEqualToString:@"progress"]){
            
        } else if ([eventName isEqualToString:@"durationchange"]){
            
        } else if ([eventName isEqualToString:@"fullscreenchange"]){
            if(!isFullScreen) [self sendData:SL_FSENTER withUserBehavior:SlikeUserBehaviorEventPlay forced:YES];
            else [self sendData:SL_FSEXIT withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
            isFullScreen = !isFullScreen;

        } else if ([eventName isEqualToString:@"volumechange"]){
            
        } else if ([eventName isEqualToString:@"play"]){
            if(playerStatus == SL_PAUSE) [self sendData:SL_PLAY withUserBehavior:SlikeUserBehaviorEventPlay forced:YES];
            else [self sendData:SL_PLAY withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
            isPlaying  = YES;
            playerStatus = SL_PLAY;
        }  else if ([eventName isEqualToString:@"seeking"]){
            playerStatus = SL_SEEKING;
            [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventSeek forced:YES];
        } else if ([eventName isEqualToString:@"seeked"]){
            playerStatus = SL_SEEKED;
            [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventSeek forced:YES];
            
        } else if ([eventName isEqualToString:@"qualitychange"]){
            //Reset PD
            playerStatus = SL_PLAYING;
            [self sendData:SL_PLAYING withUserBehavior:SlikeUserBehaviorEventBirate forced:YES];
            
        } else if ([eventName isEqualToString:@"start"]) {
            if(isVideoEnd){
                playerStatus = SL_REPLAY;
                isVideoEnd = NO;
                [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventReplay forced:YES];
                [self sendData:SL_START withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
            } else{
                playerStatus = SL_READY;
                [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
            }
            
        } else if ([eventName isEqualToString:@"ended"] ||
                   [eventName isEqualToString:@"end"] ||
                   [eventName isEqualToString:@"video_end"]) {
            self.isPlaybackDone = YES;
            playerStatus = SL_VIDEO_COMPLETED;
            if(!isVideoEnd) {
                [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
                if (!_hasPostRollCompleted && !self.slikeConfig.isSkipAds && self.slikeConfig.isPostrollEnabled == ON && !self.slikeConfig.ispr) {
                    [self _sendStatusToControls:SL_HIDECONTROLS];
                    [self _requestAdForPosition:-1];
                } else {
                    [self stopVideoWithCompletion:YES];
                }
            }
            isVideoEnd = YES;
            isPlaying = NO;
        } else if ([eventName isEqualToString:@"pause"]){
            playerStatus = SL_PAUSE;
            if(isPlaying){
                [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventPause forced:YES];
            }
            isPlaying = NO;
        } else if ([eventName isEqualToString:@"waiting"]) {
            playerStatus = SL_BUFFERING;
            [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
        } else if ([eventName isEqualToString:@"apiready"]) {
            
        } else if ([eventName isEqualToString:@"ad_start"]){
            isPlaying = NO;
            playerStatus = SL_PAUSE;
            [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
        } else if ([eventName isEqualToString:@"ad_end"]){
            isPlaying = YES;
        }
        else if ([eventName isEqualToString:@"started"]){
            playerStatus = SL_START;
            [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
        } else if ([eventName isEqualToString:@"error"]){
            
        }
    }
    
}

-(void)dailymotionAddOpen:(NSURL*) URL{
    SlikeInAppBrowserViewController *webViewObj = [[SlikeInAppBrowserViewController alloc] initWithNibName:@"SlikeInAppBrowserView" bundle:[NSBundle slikeNibsBundle]];
    webViewObj.webURL = URL;
    webViewObj.titleInfo = @"Daily Motion";
    [self presentViewController:webViewObj animated:YES completion:nil];
}
- (void)dailymotionPlayer:(DMPlayerViewController *)player didFailToInitializeWithError:(NSError *)error{
    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:error, @"data", nil];
    [self _sendPlayerStatus:SL_ERROR withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:payload];
}
- (void)sendPlayerStatus:(SlikePlayerState) status {
    
    StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:[self getPosition] withDuration:[self getDuration] muteStatus:0];
    [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:status dataPayload:@{kSlikeADispatchEventToParentKey:@YES, kSlikeAdStatusInfoKey:progressInfo} slikePlayer:self];
    
}

- (void)sendData:(SlikePlayerState)playerState withUserBehavior:(SlikeUserBehaviorEvent)userBehavior forced:(BOOL) forced {
    
    SLEventModel *eventModel;
    
    eventModel = [SLEventModel createEventModel:SlikeAnalyticsTypeMedia withBehaviorEvent:userBehavior withPayload:nil];
    
    eventModel.isImmediateDispatch = forced;
    eventModel.slikeConfigModel = self.slikeConfig;
    eventModel.playerEventModel.currentPlayer = [self.slikeConfig.streamingInfo getCurrentPlayer];
    
    eventModel.playerEventModel.playerPosition = [self getPosition];
    eventModel.playerEventModel.playerDuration =  [self getDuration];
    eventModel.playerEventModel.streamFlavour = [self getCurrentFlavour];
    eventModel.playerEventModel.isFullscreen = isFullScreen;
    eventModel.playerEventModel.playerType =  [self.slikeConfig.streamingInfo getConstantValueForPlayerType];
    
    eventModel.isImmediateDispatch = forced;
    eventModel.slikeConfigModel = self.slikeConfig;
    [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:playerState dataPayload:@{kSlikeEventModelKey:eventModel} slikePlayer:self];
    [self sendPlayerStatus:playerState];

}


- (void)sendAllDataForcibly{
    [self sendData:SL_COMPLETED withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
}

//Work More
#pragma ISlikePlayer implementation
-(void) playMovieStreamWithObject:(SlikeConfig *)si withParent:(id) parent withError:(NSError*)error {
    //For Error handlation
}
- (void) playMovieStreamWithObject:(SlikeConfig *)si withParent:(id) parent {
    [self _hideWaitingIndicator];
    isAutoPlay = NO;
    //Genrate New SS if the video play in second time
    [[SlikeDeviceSettings sharedSettings] setPlayerViewArea:parent];
    si.streamingInfo.strSS = @"";
    if([self.slikeConfig.streamingInfo.strSS length] == 0)
        self.slikeConfig.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:self.slikeConfig.mediaId];
    rpc= 0;
    //Add custom Controls
    self.isNativeControls = YES;
    playerContainer = parent;
    self.slikeConfig = si;
    
    if(![[SlikeNetworkMonitor sharedSlikeNetworkMonitor] isNetworkReachible]) {
          [self _showAlertViewForOffline:YES hasEmptyBuffer:NO];
          [self _sendNetworkErrorMessage];
    } else {
    if (self.slikeConfig.isAutoPlay) {
        [self loadMediaIntialState];
    } else {
          if(self.slikeConfig.tpAds && [self.slikeConfig.tpAds containsObject:@"dm"]) {
        self.playBtn.hidden = NO;
        [self.view bringSubviewToFront:self.playBtn];
          }else  {
              [self.view bringSubviewToFront:self.slikeConfig.customControls];
            [self _loadMediaStream];
          }
    }
    }
}

-(void)loadMediaIntialState {
    if(self.slikeConfig.tpAds && [self.slikeConfig.tpAds containsObject:@"dm"]) {
    if (self.slikeConfig.isSkipAds || self.slikeConfig.isPrerollEnabled == OFF || self.slikeConfig.ispr) {
        [self.view bringSubviewToFront:self.slikeConfig.customControls];
        [self _loadMediaStream];
    } else{
        [self addCall];
    }
    }else  {
        [self.view bringSubviewToFront:self.slikeConfig.customControls];
        [self _loadMediaStream];
    }
}
-(void)addCall {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_MSEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self _initializeLoadingIndicator];
        [self _requestAdForPosition:0];
    });
}
-(NSUInteger) getPosition {
    SlikeDLog(@"%f",[self.playerView currentTime]);
    if(self.playerView) return [self.playerView currentTime]*1000;
    else return 0;
}

-(NSUInteger) getDuration {
    SlikeDLog(@"%f",[self.playerView duration]);
    if(self.playerView) return [self.playerView duration]*1000;
    return 0;
}

-(NSUInteger) getBufferTime {
    if(self.playerView) return [self.playerView bufferedTime]*1000;
    return nBufferingTime;
}

-(SlikePlayerState) getStatus {
    return playerStatus;
}
- (void)viewWillEnterForeground {
    self.isAppActive = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self play:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self pause:YES];
    
}
- (void)viewWillEnterBackground {
    self.isAppActive = NO;
}
-(void) play:(BOOL) isUser {
    if(!self.playerView) return;
    [self.playerView play];
    isVideoEnd = NO;
}
-(void) pause:(BOOL) isUser {
    if(!self.playerView) return;
    [self.playerView pause];
}
-(void) resume {
    if(!self.playerView) return;
    [self.playerView play];
}
-(void) sendCustomControlEvent:(SlikePlayerState) state {
    SlikeDLog(@"onSreentap");
    //[self sendPlayerStatus:state];
    
}
-(void) replay {
    [self sendData:SL_REPLAY withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
    [self seekTo:0 userSeeked:NO];
}
-(BOOL) isPlaying {
    return  isPlaying;
}
-(void)playerMute:(BOOL)isMute {
    // [self.playerView playerMute:isMute];
}
-(BOOL)getPlayerMuteStatus {
    return  NO;
    // return  [self.playerView getPlayerMuteStatus];
}
-(void) seekTo:(float) nPosition userSeeked:(BOOL)isUser {
    if(!self.playerView) return;
    [self.playerView setCurrentTime:nPosition];
    [self play:NO];
}

- (void)stop {
    if(!self.playerView) return;
    [self.playerView pause];
    [self.playerView removeFromSuperview];
    [self.playerView removeWebView];
    self.playerView  = nil;
    [self sendPlayerForceCloseEvent];

}

- (BOOL)cleanup {
    
    if(self.isAppAlreadyDestroyed) return NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.isAppAlreadyDestroyed = YES;
    if(self.playerView) [self stop];
    return YES;
}

- (void)resetPlayer {
    
    if(!self.playerView) return;
    [self.playerView pause];
    [self.playerView removeFromSuperview];
    [self.playerView removeWebView];
    self.playerView  = nil;
}

- (BOOL)isFullScreen {
    return isFullScreen;
}

- (void)toggleFullScreen {
    if(!self.playerView) return;
    [self.playerView setFullscreen:YES];
}

- (void)removePlayer {
    [self sendData:SL_ENDED withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
    [self cleanup];
    if(playerContainer) {
        if([playerContainer isKindOfClass:[UIView class]]) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
    }
}

- (BOOL)isPlayerExist {
    return self.playerView != nil;
}

- (NSString *)getCurrentFlavour {
    return @"";
}

-(instancetype) getViewController {
    return self;
}

-(void) setParentReference:(UIView *) parentView {
    
}

-(void) setOnPlayerStatusDelegate:(onChange) block {
         [[EventManager sharedEventManager] setEventHanlderBlock:block];
}

- (void)setController:(id<ISlikePlayerControl>)control {
}

- (void)setNativeControl:(BOOL) isNative {
    self.isNativeControls = isNative;
}

- (id<ISlikePlayerControl>) getControl {
    return nil;
}

-(NSArray*) showBitrateChooser:(BOOL)isCustom{
    return nil;
}

- (void)updateCustomBitrate:(Stream*)obj {
}
- (void)updateCustomBitrateNew:(NSInteger)type
{
    
}
- (void)hideBitrateChooser {
}
- (void)playPrevious {
}

-(void) playNext {
}

- (void)clbPlayPrevious {
    
}
- (BOOL)canShowBitrateChooser {
    return NO;
}

- (void)setVideoPlaceHolder :(BOOL)isSet{
}

- (void)setCast:(id<ISlikeCast>)cast {
    //
}

- (id<ISlikeCast>)getCast {
    return nil;
}

- (NSString *)currentBitRateURI {
    return  @"";
}
-(NSInteger)currentBitRateType
{
    return 0;
}
- (float)getLoadTimeRange {
    return 0;
}

- (BOOL)isAdPlaying {
    return NO;
}

#pragma mark - EventManagerProtocol
/**
 Method will be called by the Event menager
 @param eventType - Current event Type
 @param playerState - Current State
 @param payload - Payload if any
 @param player - Current Player
 */
- (void)update:(SlikeEventType)eventType playerState:(SlikePlayerState)playerState dataPayload:(NSDictionary *) payload slikePlayer:(id<ISlikePlayer>)player {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (eventType == GESTURE) {
            
        } else  if (eventType == CONTROLS) {
            
        } else if(eventType == MEDIA) {
            
        } else if(eventType == AD) {
            if(payload[kSlikeEventModelKey]) {
                SLEventModel *eventModel  = payload[kSlikeEventModelKey];
                if (eventModel && eventModel.adEventModel.extranlAdFail) {
                    return;
                }
            }
            if (playerState == SL_CONTENT_RESUME) {
                if(payload[kSlikeNormalAdFailKey]){
                    [self _requestAdForPosition:self->_currentAdType];
                    return;
                }
                [self _hideAdPlayerContainerView];
                [self _setAdIsPlaying:NO];
                if (!self.isPlaybackDone) {
                    [self _playStreamAfterPreRoll];
                } else {
                    self.hasPostRollCompleted = YES;
                    [self stopVideoWithCompletion:YES];
                }
            } else if (playerState == SL_CONTENT_PAUSE) {
                [self _sendStatusToControls:SL_HIDECONTROLS];
                [self _setAdIsPlaying:YES];
                if(self.adPlayerView) {
                    [self.view bringSubviewToFront:self.adPlayerView];
                }
                [self.view bringSubviewToFront:self.loadingIndicator];
                if (!self.isPlaybackDone && [self isPlaying]) {
                    [self pause:NO];
                }
            } else if (playerState == SL_HIDE_LOADING) {
                [self _hideWaitingIndicator];
            } else if (playerState == SL_LOADING) {
                if(self.adPlayerView) {
                    [self.view bringSubviewToFront:self.adPlayerView];
                }
                [self _showWaitingIndicator];
            }
        }
    });
}

/**
 Get the screen shot at perticular position
 @param position - Time in second
 @param completion - Completion Block
 */
- (void)getScreenShotAtPosition:(NSInteger)position withCompletionBlock:(void (^)(UIImage *image))completion {
    completion(nil);
}

- (BOOL)isAdPaused {
    return NO;
}
#pragma mark Add task ---
/**
 Load the Media Stream
 */
- (void)_loadMediaStream {
    SlikeDLog(@"AV PLAYER LOG: _loadMediaStream");
    //Set the placehoder image & automatically on media start event
    [self _initialiseMediaStream];
    
}
/**
 Initialise Media Stream
 */
- (void)_initialiseMediaStream {
    [self _hideWaitingIndicator];
    [self initWithStringWithID:[ self.slikeConfig.streamingInfo getURL:VIDEO_SOURCE_DM byQuality:@""].strURL withClipID: self.slikeConfig.streamingInfo.strID withTitle: self.slikeConfig.streamingInfo.strTitle];
}
/**
 Request the Ad for the postion
 @param adPosition - 0=>PRE | -1=>POST
 */
- (void)_requestAdForPosition:(NSInteger)adPosition {
    self.currentAdType =  adPosition;
    if(self.slikeConfig.streamingInfo && self.slikeConfig.streamingInfo.outSideAd)
    {
        [[SlikeAdManager sharedInstance] cleanupAdManager:^{
            
            [self _sendStatusToControls:SL_AD_REQUESTED];
            [[SlikeAdManager sharedInstance] showAd:self.slikeConfig adContainerView:[self _adPlayerContainerView] forAdPosition:adPosition];
        }];
    }else
    {
        [self _sendStatusToControls:SL_AD_REQUESTED];
        [[SlikeAdManager sharedInstance] showAd:self.slikeConfig adContainerView:[self _adPlayerContainerView] forAdPosition:adPosition];
    }
}
- (void)_sendStatusToControls:(SlikePlayerState)playerState  {
    [[EventManager sharedEventManager] dispatchEvent:MEDIA playerState:playerState dataPayload:@{} slikePlayer:self];
}
- (void)_setAdIsPlaying:(BOOL)isPlaying {
    self.isCurrentlyAdPlaying = isPlaying;
}
/**
 Initialize the Waiting Indicator
 */
- (void)_initializeLoadingIndicator {
    _loadingIndicator.backgroundColor = [UIColor clearColor];
    _loadingIndicator.alpha=0.0;
    _loadingIndicator.hidden=YES;
}

- (UIView *)_adPlayerContainerView {
    
    if (self.adPlayerView && [self.adPlayerView superview]) {
        [self.adPlayerView removeFromSuperview];
        self.adPlayerView=nil;
    }
    
    self.adPlayerView = [[UIView alloc]init];
    _adPlayerView.frame = self.view.frame;
    _adPlayerView.backgroundColor = self.slikeConfig.isAutoPlay ? [UIColor clearColor] : [UIColor blackColor];
    _adPlayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.adPlayerView.alpha= 0.0;
    [self.view addSubview: self.adPlayerView];
    [_adPlayerView slike_fadeIn];
    
    [self.view bringSubviewToFront:_adPlayerView];
    return _adPlayerView;
}

- (void)_hideAdPlayerContainerView {
    [_adPlayerView removeViewWithAnimationTime:0.25 completion:^{
        self.adPlayerView=nil;
    }];
}
- (void)_playStreamAfterPreRoll {
    SlikeDLog(@"AV PLAYER LOG: _playStreamAfterPreRoll");
    [self _loadMediaStream];
}
/**
 Stop the video .
 @param completed - Completion events
 */
- (void)stopVideoWithCompletion:(BOOL)completed {
    
    [self sendData:SL_COMPLETED withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
}
/**
 Show Waiting Indicatior
 */
- (void)_showWaitingIndicator {
    _loadingIndicator.hidden=NO;
    _loadingIndicator.alpha=1.0;
    [_loadingIndicator startAnimating];
    [self.view bringSubviewToFront:_loadingIndicator];
}

/**
 Hide Waiting Indicatior
 */

- (void)_hideWaitingIndicator {
    [self.view sendSubviewToBack:_loadingIndicator];
    [_loadingIndicator stopAnimating];
    _loadingIndicator.alpha=0.0;
    _loadingIndicator.hidden=YES;
}
/**
 Remove the Player . Also dealloc all the Associated resources
 */
-(void)sendPlayerForceCloseEvent
{
    [[EventManager sharedEventManager] dispatchEvent:ACTIVITY playerState:SL_PLAYER_DISTROYED dataPayload:@{} slikePlayer:self];
    [self sendData:SL_ENDED withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
    
}
#pragma mark Network Call
/**
 Remove the alert View
 */
- (void)removeErrorAlert {
    
    if(_slikeAlertView && [_slikeAlertView superview]) {
        [_slikeAlertView removeAlertViewWithAnimation:YES];
        _slikeAlertView =  nil;
        _isNetworkWindowPresented = NO;
    }
}
/**
 Show the Offline message.
 */
- (void)_showAlertViewForOffline:(BOOL)enableReload hasEmptyBuffer:(BOOL)bufferEmpty {
    self.playBtn.hidden = YES;
     if(!self.isNetworkWindowPresented) {
    [self setVideoPlaceHolder:YES];
    [self _sendStatusToControls:SL_HIDECONTROLS];
    if (_isNetworkWindowPresented && bufferEmpty) {
        [self pause:NO];
        [self _sendStatusToControls:SL_HIDECONTROLS];
        return;
    }
    [self pause:NO];
    self.slikeAlertView = [SlikePlayerErrorView slikePlayerErrorView];
    UIView *parentView = (UIView *)self.view;
    [parentView addSubviewWithContstraints:_slikeAlertView];
    
    
    __block SlikePlayerErrorView* weakAlert = _slikeAlertView;
    if(self.slikeConfig.isNoNetworkCloseControlEnable)
    {
        [_slikeAlertView setErrorMessage:[SlikePlayerSettings playerSettingsInstance].slikestrings.networkErr withCloseEnable:NO withReloadEnable:enableReload];
    }else
    {
        [_slikeAlertView setErrorMessage:[SlikePlayerSettings playerSettingsInstance].slikestrings.networkErr withCloseEnable:self.slikeConfig.isNoNetworkCloseControlEnable withReloadEnable:enableReload];
    }
    _isNetworkWindowPresented = YES;
    
    //Set the poster image
    [self setVideoPlaceHolder:YES];
    __weak typeof(self) weekSelf = self;
    
    _slikeAlertView.reloadButtonBlock = ^ {
        if ([[SlikeNetworkMonitor sharedSlikeNetworkMonitor] isNetworkReachible]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakAlert removeAlertViewWithAnimation:YES];
                weekSelf.slikeAlertView =  nil;
                weekSelf.isNetworkWindowPresented = NO;
                [weekSelf performSelector:@selector(reloadCall) withObject:nil afterDelay:0.0];
            });
        }
    };
    weakAlert.closeButtonBlock = ^ {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.slikeAlertView.closeButton.hidden =  YES;
            //[self.slikeAlertView removeAlertViewWithAnimation:YES];
            [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_CLOSE dataPayload:@{kSlikeADispatchEventToParentKey: @(YES)} slikePlayer:nil];
        });
    };
    
    [self.view bringSubviewToFront:_slikeAlertView];
     }
}
-(void)reloadCall {
    if (self.slikeConfig.isSkipAds || self.slikeConfig.isPrerollEnabled == OFF || self.slikeConfig.ispr) {
        [self.view bringSubviewToFront:self.slikeConfig.customControls];
        [self _loadMediaStream];
    } else{
        if(self.slikeConfig.tpAds && [self.slikeConfig.tpAds containsObject:@"dm"]) {
        [self addCall];
        }else {
            [self _loadMediaStream];
        }
    }
}
- (void)_sendNetworkErrorMessage {
    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:[NSError errorWithDomain:SlikeServiceErrorDomain code:SlikeServiceErrorNoNetworkAvailable userInfo:@{NSLocalizedDescriptionKey:@"Internet not available."}], @"data", nil];
    [self _sendPlayerStatus:SL_ERROR withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:payload];
}
/**
 Send the player status
 
 @param playerState - Player Status
 @param strError - Error
 */
- (void)_sendPlayerStatus:(SlikePlayerState)playerState withUserBehavior:(SlikeUserBehaviorEvent)isUserAction withError:(NSString *)strError withPayload:(NSDictionary *)payload  {
    
   
    SLEventModel *eventModel = [SLEventModel createEventModel:SlikeAnalyticsTypeMedia withBehaviorEvent:isUserAction withPayload:nil];
    eventModel.slikeConfigModel = self.slikeConfig;
    
    NSMutableDictionary *payloadInfo =  [[NSMutableDictionary alloc]initWithDictionary:payload];
    [payloadInfo setObject:eventModel forKey:kSlikeEventModelKey];
    [payloadInfo setObject:@(YES) forKey:kSlikeADispatchEventToParentKey];
    
    [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:playerState dataPayload:payloadInfo slikePlayer:self];
    
}
@end


