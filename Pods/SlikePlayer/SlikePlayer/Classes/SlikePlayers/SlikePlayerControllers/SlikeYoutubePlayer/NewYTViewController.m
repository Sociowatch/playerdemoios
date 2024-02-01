//
//  NewYTViewController.m
//  SlikePlayer
//
//  Created by TIL on 08/08/16.
//  Copyright (c) 2014 BBDSL. All rights reserved.
//

#import "NewYTViewController.h"
#import <SlikePlayer.h>
#import "SlikeAnalytics.h"
#import "NSBundle+Slike.h"
#import "EventManager.h"
#import "SlikePlayerConstants.h"
#import "EventManagerProtocol.h"
#import "SLEventModel.h"
#import "SlikeMaterialDesignSpinner.h"
#import "UIImageView+SlikePlaceHolderImageView.h"

@interface NewYTViewController ()<EventManagerProtocol> {
    
    NSString *strMovieID;
    NSString *strMovieTitle;
    NSInteger nDuration, nBufferingTime;
    UIView *myRef;
    SlikePlayerState currentState;
}

@property (weak, nonatomic) IBOutlet SlikeMaterialDesignSpinner *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderImageView;
@property (assign, nonatomic) float mediaDuration;
@property (assign, nonatomic) float mediaPosition;

@end

@implementation NewYTViewController

@synthesize isAppActive;
@synthesize isAppAlreadyDestroyed;
@synthesize slikeConfig;
@synthesize isNativeControls;
@synthesize isUserPaused;

- (void)startTimer {
    if(self.playerView) {
        __weak typeof(self) _self = self;
        [self.playerView getPlayerState:^(SLWKYTPlayerState playerState, NSError * _Nullable error) {
            if (playerState != kSLWKYTPlayerStatePlaying) {
                return;
            } else {
                [_self createTimer];
            }
        }];
    }
}

- (void)createTimer {
    [self stopTimer];
    if(self.timer == nil) {
        self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        [runner addTimer:self.timer forMode: NSDefaultRunLoopMode];
    }
}


- (void)stopTimer {
    if(self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void) rotateMyView:(BOOL) isFullscreen {
    if(!isFullscreen) {
        [self.view setTransform:CGAffineTransformMakeRotation(0.0)];
    }
    else {
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI / 2.0)];
    }
}

- (void)updatePosition {
    [self.playerView getDuration:^(NSTimeInterval duration, NSError * _Nullable error) {
        if (!error) {
            self->_mediaDuration = duration;
        }
    }];
    
    if(self.playerView){
        [self.playerView getCurrentTime:^(float currentTime, NSError * _Nullable error) {
            if (!error) {
                self->_mediaPosition = currentTime;
            }
        }];
    }
}

- (void)timerCallback:(NSTimer *) timer {
    if(!self.playerView) return;
    
    [self updatePosition];
    /**
     kYTPlayerStateUnstarted,
     kYTPlayerStateEnded,
     kYTPlayerStatePlaying,
     kYTPlayerStatePaused,
     kYTPlayerStateBuffering,
     kYTPlayerStateQueued,
     kYTPlayerStateUnknown
     */
    __weak typeof(self) _self = self;
    [self.playerView getPlayerState:^(SLWKYTPlayerState playerState, NSError * _Nullable error) {
        
        if(playerState == kSLWKYTPlayerStatePlaying) {
            self->playerStatus = SL_PLAYING;
            [_self sendPlayerStatus:self->playerStatus];
            [_self sendData:self->playerStatus forced:NO withBehaviorEvent:SlikeUserBehaviorEventNone];
            self->nDuration++;
            
        } else if(playerState == kSLWKYTPlayerStateBuffering) {
            self->nBufferingTime++;
            self->playerStatus = SL_BUFFERING;
        }
        
        //    if(nDuration > 30)
        if([[SlikeReachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable && self->playerStatus == SL_BUFFERING)
        {
            BOOL doesContain = [_self.view.subviews containsObject:_self.noNetworkWindow];
            if(!doesContain)
            {
                [_self.view addSubview:self.noNetworkWindow];
                _self.noNetworkWindow.frame = CGRectMake(_self.view.frame.origin.x, _self.view.frame.origin.y, _self.view.frame.size.width, _self.view.frame.size.height);
            }
        }
        else
        {
            BOOL doesContain = [_self.view.subviews containsObject:_self.noNetworkWindow];
            if(doesContain)
            {
                [_self.noNetworkWindow removeFromSuperview];
            }
        }
        [_self sendData:self->playerStatus forced:NO withBehaviorEvent:SlikeUserBehaviorEventNone];
        
    }];
}

- (void)playerWillExitFullscreen:(NSNotification *)notification {
    [self clbClose:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mediaDuration = 0;
    _mediaPosition = 0;
    
    self.noNetworkLbl.text = [SlikePlayerSettings playerSettingsInstance].slikestrings.networkErr;
    
    _errorLabel.text = @"";
    _errorLabel.alpha = 0;
    [self.btnClose setImage:[UIImage imageNamed:@"player_closebtn" inBundle:[NSBundle slikeImagesBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.btncloseInternet setImage:[UIImage imageNamed:@"player_closebtn" inBundle:[NSBundle slikeImagesBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    self.isUserPaused = NO;
    
    self.playerView.delegate = self;
    self.btnClose.hidden = YES;
    //The setup code (in viewDidLoad in your view controller)
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleNoInternetTap:)];
    [self.noNetworkWindow addGestureRecognizer:singleFingerTap];
    
    //Register this class to listen and send the events
    [[EventManager sharedEventManager]registerEvent:self];
    
    [_loadingView startAnimating];
    _loadingView.hidesWhenStopped=YES;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startTimer];
    CGRect theFrame = self.view.bounds;
    theFrame.origin = CGPointZero;
    CGRect theDeviceFrame = [[UIScreen mainScreen] bounds];
    theDeviceFrame.origin = CGPointZero;
    isFullScreenEnabled = CGRectEqualToRect(theFrame, theDeviceFrame);
    
    if(!isFullScreenEnabled)self.btnClose.hidden = YES;
    else self.btnClose.hidden = NO;
    
    //Define Play Duration Time--
    nTotalBufferDuration = 0;
    nTotalPlayedDuration = 0;
    nTotalBufferTimestamp = 0;
    nTotalPlayedTimestamp = 0;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopTimer];
    [self.playerView pauseVideo];
}

- (void)viewDidRotated:(NSNotification *)notification {
    SlikeDLog(@"The View is rotated...");
    //self.playerView.full
    //if(!isFullScreen) self.view.frame = myRef == nil ? [self adjustDimenAfterRoatation:theInitialFrame] : myRef.frame;
}

- (void)initWithStringWithID:(NSString *)strID withClipID:(NSString *) strClipID withTitle:(NSString *) strTitle {
    
    SlikeDLog(@"YouT (%@) -- (%@) -- (%@)", strID, strClipID, strTitle);
    nDuration = 0;
    strMovieID = strClipID;
    strMovieTitle = strTitle;
    NSInteger playInline = 1;
    if (self.slikeConfig.orientationTypeiPad && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        playInline = 0;
    }
    [self.playerView loadWithVideoId:strID playerVars:@{
        @"playsinline" : @(playInline),
        @"modestbranding" : @1,
        @"rel" : @0,
        @"controls":self.isNativeControls ? @1
        : @0 ,
        @"showinfo" : @0,
        @"autoplay" :self.slikeConfig.isAutoPlay ? @1 : @0,
        @"origin" : @"http://www.youtube.com"
    }];
}

- (CGRect) adjustDimenAfterRoatation:(CGRect) theFrame {
    
    CGSize theSize = [[[[UIApplication sharedApplication] delegate] window] bounds].size;
    CGSize mySize = theFrame.size;
    if(((theSize.width > theSize.height) && (mySize.width < mySize.height)) || ((theSize.width < theSize.height) && (mySize.width > mySize.height)))
    {
        NSInteger nW = mySize.width;
        NSInteger nH = mySize.height;
        theFrame.size.width = nH;
        theFrame.size.height = nW;
    }
    return theFrame;
}

- (IBAction)clbClose:(id) sender {
    
    playerStatus = SL_ENDED;
    [self sendPlayerStatus:playerStatus];
    
    if(isFullScreenEnabled) [self toggleFullscreen:NO];
    [self sendData:SL_ENDED forced:YES withBehaviorEvent:SlikeUserBehaviorEventNone];
    
    // [[SlikePlayer getInstance] stopPlayer];
}

-(void) toggleFullscreen:(BOOL) fullscreen {
    //    [self.playerView fullScreen];
}

#pragma --
#pragma mark YTPlayerViewDelegate
- (nonnull UIColor *)playerViewPreferredWebViewBackgroundColor:(nonnull SLWKYTPlayerView *)playerView {
    return [UIColor clearColor];
}

- (void)playerViewDidBecomeReady:(SLWKYTPlayerView *)playerView
{
    SlikeDLog(@"The YT player is ready to play.");
    playerStatus = SL_START;
    //playerView.webView.allowsInlineMediaPlayback = false;
    [self sendData:SL_START forced:YES withBehaviorEvent:SlikeUserBehaviorEventNone];
    [self.playerView playVideo];
    [_loadingView stopAnimating];
    [self setVideoPlaceHolder:NO];
}

- (void)playerView:(SLWKYTPlayerView *)playerView didChangeToState:(SLWKYTPlayerState)state
{
    switch (state){
        case kSLWKYTPlayerStatePlaying:
            SlikeDLog(@"The YT player playback is started.");
            
            isPlaying = YES;
            [self startTimer];
            
            if(playerStatus == SL_COMPLETED) {
                playerStatus = SL_REPLAY;
                [self sendPlayerStatus:playerStatus];
                [self sendData:playerStatus forced:NO withBehaviorEvent:SlikeUserBehaviorEventNone];
                
            }
            else
            {
                
                // [playerView getCurrentTime:^(float currentTime, NSError * _Nullable error) {
                
                float currentTime = _mediaPosition;
                float playerDiff = currentTime - self->lastPlayerPostion;
                if(playerDiff<0)
                {
                    playerDiff = -playerDiff;
                }
                
                
                if(self->lastPlayerPostion !=  currentTime && self->lastPlayerPostion!=0 && self->playerStatus ==SL_PAUSE && playerDiff>2.0) {
                    SlikeDLog(@"Seeked");
                    self->playerStatus = SL_SEEKED;
                    [self sendPlayerStatus:self->playerStatus];
                    [self sendData:self->playerStatus forced:YES withBehaviorEvent:SlikeUserBehaviorEventNone];
                    return;
                    
                } else {
                    SlikeDLog(@"%ld",(long)self->lastPlayerPostion);
                    SlikeDLog(@"Not Seeked");
                    
                }
                
                self->playerStatus = SL_PLAY;
                [self sendPlayerStatus:self->playerStatus];
                if(self.isUserPaused)
                    [self sendData:self->playerStatus forced:NO withBehaviorEvent:SlikeUserBehaviorEventPlay];
                else  [self sendData:self->playerStatus forced:NO withBehaviorEvent:SlikeUserBehaviorEventNone];
                
                // }];
                
                
            }
            break;
        case kSLWKYTPlayerStatePaused:
            
            if(playerStatus == SL_PAUSE || playerStatus == SL_SEEKED)
            {
                SlikeDLog(@"The YT player playback is Seeked.");
                playerStatus = SL_SEEKED;
                //                [self sendPlayerStatus:playerStatus];
                [self sendData:playerStatus forced:YES withBehaviorEvent:SlikeUserBehaviorEventNone];
                return;
            }
            
            SlikeDLog(@"The YT player playback is paused.");
            isPlaying = NO;
            playerStatus = SL_PAUSE;
            [self sendPlayerStatus:playerStatus];
            [self sendData:playerStatus forced:YES withBehaviorEvent:SlikeUserBehaviorEventPause];
            
            [self stopTimer];
            self.isUserPaused =  YES;
            break;
        case kSLWKYTPlayerStateEnded:
            isPlaying = NO;
            SlikeDLog(@"The YT player playback is done. Means competed");
            playerStatus = SL_COMPLETED;
            [self sendPlayerStatus:playerStatus];
            [self sendData:playerStatus forced:YES withBehaviorEvent:SlikeUserBehaviorEventNone];
            [self stopTimer];
            
            //            [self clbClose:nil];
            break;
        case kSLWKYTPlayerStateBuffering:
            
            if(playerStatus == SL_PAUSE )
            {
                SlikeDLog(@"The YT player playback is Seeked.");
                
                playerStatus = SL_SEEKED;
                [self sendPlayerStatus:playerStatus];
                [self sendData:playerStatus forced:YES withBehaviorEvent:SlikeUserBehaviorEventNone];
                return;
            }else
            {
                isPlaying = NO;
                playerStatus = SL_BUFFERING;
                [self sendPlayerStatus:playerStatus];
                [self sendData:playerStatus forced:NO withBehaviorEvent:SlikeUserBehaviorEventNone];
            }
            
            break;
        case kSLWKYTPlayerStateQueued:
        case kSLWKYTPlayerStateUnknown:
            break;
        default:
            break;
    }
    
}
- (void)playerView:(SLWKYTPlayerView *)playerView didChangeToQuality:(SLWKYTPlaybackQuality)quality
{
    SlikeDLog(@"The YT player playback quality is changed to (%ld).", (long)quality);
}
- (void)playerView:(SLWKYTPlayerView *)playerView receivedError:(SLWKYTPlayerError)error
{
    [self sendPlayerStatus:SL_ERROR];
    isPlaying = NO;
    NSString *strError;
    switch (error) {
        case kSLWKYTPlayerErrorInvalidParam:
            strError = @"Invalid parameter while playing video.";
            break;
        case kSLWKYTPlayerErrorHTML5Error:
            strError = @"HTML5 error while playing video.";
            break;
        case kSLWKYTPlayerErrorVideoNotFound:
            strError = @"Video not found. Please again later.";
            break;
        case kSLWKYTPlayerErrorNotEmbeddable:
            strError = @"The video is not possible to embed.";
            break;
        case kSLWKYTPlayerErrorUnknown:
            strError = @"Playback is failed due to some unknown error.";
            break;
        default:
            break;
    }
    SlikeDLog(@"The YT player playback getting error (%@).", strError);
    if(strError) {
        //_errorLabel.alpha = 1;
        // _errorLabel.text = @"Video not available";
        //[SlikeUtilities showAlert:@"" withTitle:@"Playback failed" withController:self];
        //[[SlikePlayer getInstance] stopPlayer];
    }
}

#pragma ISlikePlayer implementation-
-(BOOL) isUserPausedVideo
{
    SlikeDLog(@"%d",self.isUserPaused);
    
    return self.isUserPaused;
}
-(void) playMovieStreamWithObject:(SlikeConfig *)si withParent:(id) parent withError:(NSError*)error
{
    //For Error handlation
}
-(void) playMovieStreamWithObject:(SlikeConfig *)si withParent:(id) parent
{
    [[SlikeDeviceSettings sharedSettings] setPlayerViewArea:parent];
    
    //Genrate New SS if the video play in second time
    // [SlikeAnalytics  sharedManager].isFirstTimePlay = YES;
    
    si.streamingInfo.strSS = @"";
    
    if([self.slikeConfig.streamingInfo.strSS length] == 0)
        self.slikeConfig.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:self.slikeConfig.mediaId];
    
    rpc = 0;
    self.isNativeControls = YES;
    playerContainer = parent;
    self.slikeConfig = si;
    [self setVideoPlaceHolder:YES];
    [self initWithStringWithID:[si.streamingInfo getURL:VIDEO_SOURCE_YT byQuality:@""].strURL withClipID:si.streamingInfo.strID withTitle:si.streamingInfo.strTitle];
    playerStatus = SL_READY;
    
    
    [self sendData:SL_READY forced:YES withBehaviorEvent:SlikeUserBehaviorEventNone];
}
- (void)setVideoPlaceHolder:(BOOL)isSet {
    [self.placeholderImageView setPlaceHolderImage:isSet configModel:self.slikeConfig withPlayerView:_playerView];
}



- (NSUInteger)getPosition {
    return _mediaPosition *1000;
}

- (NSUInteger)getDuration {
    return _mediaDuration *1000;
}

-(NSUInteger) getBufferTime {
    return nBufferingTime;
}

-(SlikePlayerState) getStatus {
    return playerStatus;
}

- (void)viewWillEnterForeground {
    self.isAppActive = YES;
}

- (void)viewWillEnterBackground {
    self.isAppActive = NO;
}

-(void) play:(BOOL) isUser {
    if(!self.playerView) return;
    [self.playerView playVideo];
    self.isUserPaused = NO;
    
}

-(void) pause:(BOOL) isUser {
    if(!self.playerView) return;
    self.isUserPaused = YES;
    [self.playerView pauseVideo];
    
}

-(void) resume {
    if(!self.playerView) return;
    [self.playerView playVideo];
}

-(void) sendCustomControlEvent:(SlikePlayerState) state {
    SlikeDLog(@"onSreentap");
    [self sendPlayerStatus:state];
}

-(void) replay {
    [self seekTo:0 userSeeked:NO];
}

-(BOOL) isPlaying {
    return  isPlaying;
}

- (void)playerMute:(BOOL)isMute {
    //[self.playerView playerMute:isMute];
}

-(BOOL)getPlayerMuteStatus {
    return NO;
    //return  [self.playerView getPlayerMuteStatus];
}

- (void) seekTo:(float) nPosition userSeeked:(BOOL)isUser {
    if(!self.playerView) return;
    [self.playerView seekToSeconds:nPosition allowSeekAhead:YES];
}

- (void) stop {
    if(!self.playerView) return;
    [self.playerView stopVideo];
    [self.playerView removeWebView];
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    
}

- (void)resetPlayer {
    [self stop];
}

- (BOOL) cleanup {
    if(self.isAppAlreadyDestroyed) return NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopTimer];
    self.isAppAlreadyDestroyed = YES;
    if(self.playerView) [self.playerView stopVideo];
    return YES;
}

-(BOOL) isFullScreen {
    return NO;
}

- (void)toggleFullScreen {
    [self toggleFullscreen:YES];
}

- (void)removePlayer {
    playerStatus = SL_PAUSE;
    [self sendData:SL_PAUSE forced:YES withBehaviorEvent:SlikeUserBehaviorEventNone];
    [self cleanup];
    
    if(playerContainer) {
        
        if([playerContainer isKindOfClass:[UIView class]]) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
        else if([playerContainer isKindOfClass:[UIViewController class]]) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
        else if([playerContainer isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *) playerContainer;
            [navigationController popViewControllerAnimated:YES];
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL) isPlayerExist {
    return self.playerView != nil;
}

- (NSString *) getCurrentFlavour {
    return @"";
}

- (UIViewController *) getViewController {
    return (UIViewController *)self;
}

- (void)setParentReference:(UIView *)parentView {
    myRef = parentView;
}

- (void)sendAllDataForcibly {
    [self sendData:SL_COMPLETED forced:YES withBehaviorEvent:SlikeUserBehaviorEventNone];
}

- (id<ISlikePlayerControl>) getControl{
    return nil;
}

- (void)setController:(id<ISlikePlayerControl>)control {
}

- (void)setNativeControl:(BOOL)isNative {
    self.isNativeControls = isNative;
}

- (NSArray*) showBitrateChooser:(BOOL)isCustom {
    return nil;
}

- (void)updateCustomBitrate:(Stream*)obj {
    //DO NOTHING.
}
- (void)updateCustomBitrateNew:(NSInteger)type
{
    
}
-(void)hideBitrateChooser {
}
//Add These methods
- (void)playPrevious {
}

-(void) playNext{
}

-(void) clbPlayPrevious {
}

-(BOOL) canShowBitrateChooser {
    return NO;
}


- (void)handleNoInternetTap:(UITapGestureRecognizer *)recognizer {
    
    if([[SlikeReachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        
        self.noNetworkWindow.bounds = self.view.bounds;
        BOOL doesContain = [self.view.subviews containsObject:self.noNetworkWindow];
        if(!doesContain)[self.view addSubview:self.noNetworkWindow];
        
        
    } else {
        [self.noNetworkWindow removeFromSuperview];
    }
}

-(void) setCast:(id<ISlikeCast>)cast {
    //
}
-(id<ISlikeCast>) getCast {
    return nil;
}

- (NSString *)currentBitRateURI {
    return  @"";
}
-(NSInteger)currentBitRateType
{
    return 0;
}
-(float) getLoadTimeRange {
    return 0;
}

-(BOOL)isAdPlaying {
    return NO;
}

/**
 Set the completion block that will be used for sending the PLayer events
 @param eventChangeblock - Event completion block
 */
- (void)setOnPlayerStatusDelegate:(onChange)eventChangeblock {
    [[EventManager sharedEventManager] setEventHanlderBlock:eventChangeblock];
}

/**
 Send the player status to listeners
 @param status - Current player state
 */
- (void)sendPlayerStatus:(SlikePlayerState)status
{
    StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:[self getPosition] withDuration:[self getDuration] muteStatus:0];
    
    //send the event to parent application
    [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:status dataPayload:@{kSlikeADispatchEventToParentKey:@YES, kSlikeAdStatusInfoKey:progressInfo} slikePlayer:self];
}

- (void)sendData:(SlikePlayerState)playerState forced:(BOOL)forced withBehaviorEvent: (SlikeUserBehaviorEvent)behaviorEvent
{
    if(playerState == SL_PLAY)
    {
        //
        ///
    }
    SLEventModel *eventModel = [SLEventModel createEventModel:SlikeAnalyticsTypeMedia withBehaviorEvent:behaviorEvent withPayload:nil];
    eventModel.isImmediateDispatch = forced;
    eventModel.slikeConfigModel = self.slikeConfig;
    [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:playerState dataPayload:@{kSlikeEventModelKey:eventModel} slikePlayer:self];
}

/**
 Method will be called by the Event menager
 
 @param eventType - Current event Type
 @param state - Current State
 @param payload - Payload if any
 @param player - Current Player
 */
- (void)update:(SlikeEventType)eventType playerState:(SlikePlayerState)state dataPayload:(NSDictionary *) payload slikePlayer:(id<ISlikePlayer>)player {
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


@end
