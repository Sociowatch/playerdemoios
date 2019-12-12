//
//  SlikeFBViewController.m
//  SlikePlayer
//
//  Created by TIL on 05/12/167.
//  Copyright (c) 2017 BBDSL. All rights reserved.

#import "SlikeFBViewController.h"
#import <SlikePlayer.h>
#import "SlikeAnalytics.h"
#import "SlikeDeviceSettings.h"
#import "SlikeReachability.h"
#import "NSBundle+Slike.h"
#import "YTPlayerView.h"
#import "EventModel.h"
#import "SlikePlayerEvent.h"
#import "EventManagerProtocol.h"
#import "EventManager.h"
#import "SlikePlayerConstants.h"

@interface SlikeFBViewController () <EventManagerProtocol> {
    NSString *strFBAppId;
    NSString *strMovieTitle;
    NSInteger nDuration, nBufferingTime;
    SlikePlayerState currentState;
}

@end

@implementation SlikeFBViewController
@synthesize isAppActive;
@synthesize isAppAlreadyDestroyed;
@synthesize slikeConfig;
@synthesize isNativeControls;

- (void)rotateMyView:(BOOL)isFullscreen {
    if(!isFullscreen) {
        [self.view setTransform:CGAffineTransformMakeRotation(0.0)];
    }
    else {
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI / 2.0)];
    }
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
    
    [self.btnClose setImage:[UIImage imageNamed:@"player_closebtn" inBundle:[NSBundle slikeImagesBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.btnCloseInternet setImage:[UIImage imageNamed:@"player_closebtn" inBundle:[NSBundle slikeImagesBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    self.isUserPaused = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    self.playerView.delegate = self;
    self.btnClose.hidden = YES;
    //The setup code (in viewDidLoad in your view controller)
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleNoInternetTap:)];
    [self.noNetworkWindow addGestureRecognizer:singleFingerTap];
    
    [[EventManager sharedEventManager]registerEvent:self];
    
    [_loadingView startAnimating];
    _loadingView.hidesWhenStopped=YES;
    
    [self.view bringSubviewToFront:_loadingView];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
    [self.playerView pause];
}

- (void)viewDidRotated:(NSNotification *)notification {
    SlikeDLog(@"The View is rotated...");
}

- (void)initWithStringWithID:(NSString *)strID withFbAppId:(NSString *) strFBId withTitle:(NSString *) strTitle
{
    SlikeDLog(@"FB (%@) -- (%@) -- (%@)", strID, strFBId, strTitle);
    nDuration = 0;
    strFBAppId = strFBId;
    strMovieTitle = strTitle;
    self.lblTitle.text = strTitle;
    self.playerView.delegate = self;
    [self.playerView loadWithVideoId:strID withAppId:strFBId];
}

- (CGRect)adjustDimenAfterRoatation:(CGRect) theFrame {
    
    CGSize theSize = [[[[UIApplication sharedApplication] delegate] window] bounds].size;
    CGSize mySize = theFrame.size;
    if(((theSize.width > theSize.height) && (mySize.width < mySize.height)) || ((theSize.width < theSize.height) && (mySize.width > mySize.height))) {
        NSInteger nW = mySize.width;
        NSInteger nH = mySize.height;
        theFrame.size.width = nH;
        theFrame.size.height = nW;
    }
    return theFrame;
}

-(IBAction)clbClose:(id) sender {
    if(isFullScreenEnabled) [self toggleFullscreen:NO];
    //[[SlikePlayer getInstance] stopPlayer];
}

- (void)toggleFullscreen:(BOOL) fullscreen {
}

#pragma --
#pragma mark SlikeFBPlayerViewDelegate

- (nonnull UIColor *)playerViewPreferredWebViewBackgroundColor:(nonnull SlikeFBVideoView *)playerView
{
    return [UIColor clearColor];
}
- (nullable UIView *)playerViewPreferredInitialLoadingView:(nonnull SlikeFBVideoView *)playerView
{
    return nil;
}

#pragma --
#pragma mark FBPlayerViewDelegate
- (void)playerViewDidBecomeReady:(SlikeFBVideoView *)playerView {
    SlikeDLog(@"The FB player is start ready to play.");
    playerStatus = SL_START;
}

- (void)playerView:(SlikeFBVideoView *)playerView didChangeToState:(FBPlayerState)state {
    
    switch (state) {
            
        case kFBPlayerStatePlaying:
            SlikeDLog(@"The YT player playback is started.");
            isPlaying = YES;
            
            if(playerStatus == SL_COMPLETED) {
                playerStatus = SL_REPLAY;
                [self sendPlayerStatus:playerStatus];
                [self sendData:playerStatus forced:NO];
            }
            break;
        case kFBPlayerStatePaused:
            if(playerStatus == SL_PAUSE || playerStatus == SL_SEEKED) {
                SlikeDLog(@"The YT player playback is Seeked.");
                playerStatus = SL_SEEKED;
                [self sendData:playerStatus forced:YES];
                return;
            }
            
            SlikeDLog(@"The YT player playback is paused.");
            isPlaying = NO;
            playerStatus = SL_PAUSE;
            [self sendPlayerStatus:playerStatus];
            [self sendData:playerStatus forced:YES];
            break;
            
        case kFBPlayerStateEnded:
            isPlaying = NO;
            SlikeDLog(@"The YT player playback is done. Means competed");
            playerStatus = SL_COMPLETED;
            [self sendPlayerStatus:playerStatus];
            [self sendData:playerStatus forced:YES];
            break;
            
        case kFBPlayerStateBuffering:
            isPlaying = NO;
            playerStatus = SL_BUFFERING;
            [self sendPlayerStatus:playerStatus];
            [self sendData:playerStatus forced:NO];
            break;
            
        case kFBPlayerStateQueued:
        case kFBPlayerStateUnknown:
            break;
        default:
            break;
    }
    
}

- (void)playerView:(SlikeFBVideoView *)playerView receivedError:(FBPlayerError)error {
    [self.loadingView stopAnimating];
    isPlaying = NO;
    NSString *strError;
    switch (error) {
        case kYTPlayerErrorInvalidParam:
            strError = @"Invalid parameter while playing video.";
            break;
        case kYTPlayerErrorHTML5Error:
            strError = @"HTML5 error while playing video.";
            break;
        case kYTPlayerErrorVideoNotFound:
            strError = @"Video not found. Please again later.";
            break;
        case kYTPlayerErrorNotEmbeddable:
            strError = @"The video is not possible to embed.";
            break;
        case kYTPlayerErrorUnknown:
            strError = @"Playback is failed due to some unknown error.";
            break;
        default:
            break;
    }
    SlikeDLog(@"The YT player playback getting error (%@).", strError);
    
    if(strError) {
        
        [SlikeUtilities showAlert:@"" withTitle:@"Playback failed" withController:self];
        //[[SlikePlayer getInstance] stopPlayer];
    }
}

- (void)playerView:(nonnull SlikeFBVideoView *)playerView didPlayTime:(float)playTime {
    
    [self performSelector:@selector(hideLoading) withObject:self afterDelay:2];
    
}

- (void)hideLoading {
     [self.loadingView stopAnimating];
}

#pragma ISlikePlayer implementation-
- (BOOL)isUserPausedVideo {
    SlikeDLog(@"%d",self.isUserPaused);
    return self.isUserPaused;
}

- (void)playMovieStreamWithObject:(SlikeConfig *)si withParent:(id) parent withError:(NSError*)error {
    //For Error handlation
}

-(void) playMovieStreamWithObject:(SlikeConfig *)si withParent:(id) parent {
    [[SlikeDeviceSettings sharedSettings] setPlayerViewArea:parent];
    si.streamingInfo.strSS = @"";
    if([self.slikeConfig.streamingInfo.strSS length] == 0)
        self.slikeConfig.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:self.slikeConfig.mediaId];
    
    rpc= 0;
    
    self.isNativeControls = YES;
    playerContainer = parent;
    self.slikeConfig = si;
    [self initWithStringWithID:[si.streamingInfo getURL:VIDEO_SOURCE_FB byQuality:@""].strURL withFbAppId:si.fbAppId withTitle:si.streamingInfo.strTitle];
    playerStatus = SL_READY;
    [self sendData:SL_READY forced:YES];
}

- (NSUInteger) getPosition {
    if(self.playerView) return [self.playerView getCurrentPosition]*1000;
    else return 0;
}

- (NSUInteger) getDuration {
    if(self.playerView) return [self.playerView getDuration]*1000;
    return 0;
}

- (NSUInteger) getBufferTime {
    return nBufferingTime;
}

- (SlikePlayerState) getStatus {
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
    self.isUserPaused = NO;
    [self.playerView play];
}

- (void) pause:(BOOL) isUser {
    if(!self.playerView) return;
    self.isUserPaused = YES;
    [self.playerView pause];
}

- (void) resume {
    if(!self.playerView) return;
    [self.playerView play];
}

- (void)sendCustomControlEvent:(SlikePlayerState) state {
    SlikeDLog(@"onSreentap");
    [self sendPlayerStatus:state];
}

- (void)replay {
    [self seekTo:0 userSeeked:NO];
}

-(BOOL) isPlaying {
    return  isPlaying;
}

-(void)playerMute:(BOOL)isMute {
    [self.playerView playerMute:isMute];
}

-(BOOL)getPlayerMuteStatus {
    return  [self.playerView getPlayerMuteStatus];
}

-(void) seekTo:(float) nPosition userSeeked:(BOOL)isUser {
    if(!self.playerView) return;
    [self.playerView seek:nPosition];
}

- (void)stop {
    if(!self.playerView) return;
    [self.playerView stop];
    [self.playerView removeWebView];
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    
}

- (BOOL)cleanup {
    if(self.isAppAlreadyDestroyed) return NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.isAppAlreadyDestroyed = YES;
    if(self.playerView) [self.playerView stop];
    return YES;
}

- (void)resetPlayer {
    [self stop];
}

- (BOOL)isFullScreen {
    return NO;
}

-(void)toggleFullScreen {
    [self toggleFullscreen:YES];
}

- (void)removePlayer {
    
    playerStatus = SL_PAUSE;
    [self sendData:SL_PAUSE forced:YES];
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
    }
}

- (BOOL)isPlayerExist {
    return self.playerView != nil;
}

- (NSString *)getCurrentFlavour {
    return @"";
}

- (UIViewController *)getViewController {
    return (UIViewController *)self;
}

- (void)setParentReference:(UIView *) parentView {
}

- (void)sendPlayerStatus:(SlikePlayerState) status {
    
    StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:[self getPosition] withDuration:[self getDuration] muteStatus:0];
    
    [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:status dataPayload:@{kSlikeADispatchEventToParentKey:@YES, kSlikeAdStatusInfoKey:progressInfo} slikePlayer:self];
}


- (void)sendData:(SlikePlayerState)playerState forced:(BOOL) forced {
    
    EventModel *eventModel;
    if(playerState ==  SL_PAUSE)
    {
        eventModel = [EventModel createEventModel:SlikeAnalyticsTypeMedia withBehaviorEvent:SlikeUserBehaviorEventPause withPayload:nil];
    }else
    {
        eventModel = [EventModel createEventModel:SlikeAnalyticsTypeMedia withBehaviorEvent:SlikeUserBehaviorEventNone withPayload:nil];
    }
    eventModel.isImmediateDispatch = forced;
    eventModel.slikeConfigModel = self.slikeConfig;
    eventModel.playerEventModel.currentPlayer = [self.slikeConfig.streamingInfo getCurrentPlayer];
    
    eventModel.playerEventModel.playerPosition = [self getPosition];
    eventModel.playerEventModel.playerDuration =  [self getDuration];
    eventModel.playerEventModel.streamFlavour = [self getCurrentFlavour];
    eventModel.playerEventModel.isFullscreen = [self isFullScreen];
    eventModel.playerEventModel.playerType =  [self.slikeConfig.streamingInfo getConstantValueForPlayerType];
    
    eventModel.isImmediateDispatch = forced;
    eventModel.slikeConfigModel = self.slikeConfig;
    [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:playerState dataPayload:@{kSlikeEventModelKey:eventModel} slikePlayer:self];
    
}


-(void) sendAllDataForcibly {
    [self sendData:SL_COMPLETED forced:YES];
}

-(void) setOnPlayerStatusDelegate:(onChange)block {
}

- (id<ISlikePlayerControl>)getControl{
    return nil;
}

- (void)setController:(id<ISlikePlayerControl>) control {
    
}

-(void)setNativeControl:(BOOL) isNative {
    self.isNativeControls = isNative;
}

-(NSArray*) showBitrateChooser:(BOOL)isCustom{
    //
    return nil;
}
-(void)updateCustomBitrate:(Stream*)obj
{
    //
}
- (void)updateCustomBitrateNew:(NSInteger)type
{
    
}
-(void)hideBitrateChooser
{
    
}
//Add These methods
-(void)playPrevious {
    
}

-(void)playNext{
}

- (void)clbPlayPrevious {
}

-(BOOL) canShowBitrateChooser {
    return NO;
}

-(void)setVideoPlaceHolder :(BOOL)isSet{
}

//No Internet Actions--
//The event handling method
- (void)handleNoInternetTap:(UITapGestureRecognizer *)recognizer {
    
    if([[SlikeReachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        self.noNetworkWindow.bounds = self.view.bounds;
        BOOL doesContain = [self.view.subviews containsObject:self.noNetworkWindow];
        if(!doesContain)[self.view addSubview:self.noNetworkWindow];
        
        [_loadingView stopAnimating];

    } else {
        [self.noNetworkWindow removeFromSuperview];
    }
}

- (void)setCast:(id<ISlikeCast>)cast {
}

- (id<ISlikeCast>) getCast {
    return nil;
}

- (NSString *)currentBitRateURI {
    return  @"";
}
-(NSInteger)currentBitRateType
{
    return 0;
}
- (float) getLoadTimeRange {
    return 0;
}

- (BOOL)isAdPlaying {
    return NO;
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
