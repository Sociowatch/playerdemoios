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
#import "EventModel.h"
#import "SlikePlayerEvent.h"
#import "EventManagerProtocol.h"
#import "EventManager.h"
#import "SlikePlayerConstants.h"
#import "SlikeMaterialDesignSpinner.h"


@interface DMMainViewController () <EventManagerProtocol> {
    
    NSString *strMovieID;
    NSString *strMovieTitle;
    NSInteger nDuration, nBufferingTime;
    BOOL isPlaying;
    
}
@property (weak, nonatomic) IBOutlet SlikeMaterialDesignSpinner *loadingView;
@end

@implementation DMMainViewController

@synthesize isAppActive;
@synthesize isAppAlreadyDestroyed;
@synthesize slikeConfig;
@synthesize isNativeControls;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    self.playerView.delegate = self;
    isPlaying= NO;
    //Define Play Duration Time--
    nTotalBufferDuration = 0;
    nTotalPlayedDuration = 0;
    nTotalBufferTimestamp = 0;
    nTotalPlayedTimestamp = 0;
    //The setup code (in viewDidLoad in your view controller)
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleNoInternetTap:)];
    [self.noNetworkWindow addGestureRecognizer:singleFingerTap];
    
    
    [_loadingView startAnimating];
    [[EventManager sharedEventManager]registerEvent:self];
    
}

- (void)initWithStringWithID:(NSString *)strID withClipID:(NSString *) strClipID withTitle:(NSString *) strTitle
{
    SlikeDLog(@"DMP (%@) -- (%@) -- (%@)", strID, strClipID, strTitle);
    nDuration = 0;
    strMovieID = strClipID;
    strMovieTitle = strTitle;
    // Set its delegate and other parameters (if any)
    self.playerView.delegate = self;
    self.playerView.autoOpenExternalURLs = false;
    self.playerView.webBaseURLString = @"http://www.dailymotion.com";
    NSDictionary *playerCallbacks = @{
                                      @"autoplay": self.slikeConfig.isAutoPlay ? @1 : @0 ,
                                      @"controls":self.isNativeControls ? @"1" : @"0",@"endscreen-enable":@"0",@"sharing-enable":@"0",@"ui-logo":@"0",@"ui-start-screen-info":@"0"};
    
    [self.playerView loadVideo:strID withParams:playerCallbacks];
    self.playerView.frame = self.view.frame;
    [self.playerView updatePlayerFrames];
}

#pragma mark DMPlayerDelegate
- (void)dailymotionPlayer:(DMPlayerViewController *)player didReceiveEvent:(NSString *)eventName {
    // Grab the "apiready" event to trigger an autoplay
    if (eventName.length)
    {
        if ([eventName isEqualToString:@"timeupdate"])
        {
            isPlaying = YES;
            playerStatus = SL_PLAYING;
            [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventNone forced:(playerStatus != SL_PLAYING) ? YES : NO];
        } else if ([eventName isEqualToString:@"progress"])
        {
            
        } else if ([eventName isEqualToString:@"durationchange"])
        {
            
        } else if ([eventName isEqualToString:@"fullscreenchange"])
        {
            
        } else if ([eventName isEqualToString:@"volumechange"])
        {
            
        } else if ([eventName isEqualToString:@"play"])
        {
            if(playerStatus == SL_PAUSE) [self sendData:SL_PLAY withUserBehavior:SlikeUserBehaviorEventPlay forced:YES];
            else [self sendData:SL_PLAY withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
            isPlaying  = YES;
            playerStatus = SL_PLAY;
        }  else if ([eventName isEqualToString:@"seeking"])
        {
            playerStatus = SL_SEEKING;
            [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventSeek forced:YES];
        } else if ([eventName isEqualToString:@"seeked"] )
        {
            playerStatus = SL_SEEKED;
            [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventSeek forced:YES];
            
        } else if ([eventName isEqualToString:@"qualitychange"] )
        {
            //Reset PD
            playerStatus = SL_PLAYING;
            [self sendData:SL_PLAYING withUserBehavior:SlikeUserBehaviorEventBirate forced:YES];
            
        } else if ([eventName isEqualToString:@"start"]) {
            
            
            if(isVideoEnd)
            {
                playerStatus = SL_REPLAY;
                isVideoEnd = NO;
                [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventReplay forced:YES];
                [self sendData:SL_START withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
            } else
            {
                playerStatus = SL_READY;
                [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
                
            }
            
        } else if ([eventName isEqualToString:@"ended"] ||
                   [eventName isEqualToString:@"end"] ||
                   [eventName isEqualToString:@"video_end"]) {
            playerStatus = SL_COMPLETED;
            if(!isVideoEnd) [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
            isVideoEnd = YES;
            isPlaying = NO;
        } else if ([eventName isEqualToString:@"pause"])
        {
            playerStatus = SL_PAUSE;
            if(isPlaying)
            {
                [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventPause forced:YES];
            }
            isPlaying = NO;
        } else if ([eventName isEqualToString:@"waiting"]) {
            playerStatus = SL_BUFFERING;
            [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
        } else if ([eventName isEqualToString:@"apiready"]) {
            
        } else if ([eventName isEqualToString:@"ad_start"])
        {
            [_loadingView stopAnimating];
            _loadingView.hidden=YES;
            isPlaying = NO;
            playerStatus = SL_PAUSE;
            [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
            
        } else if ([eventName isEqualToString:@"ad_end"])
        {
            isPlaying = YES;
        }
        else if ([eventName isEqualToString:@"started"])
        {
            [_loadingView stopAnimating];
            _loadingView.hidden=YES;
            playerStatus = SL_START;
            [self sendData:playerStatus withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
        } else if ([eventName isEqualToString:@"error"])
        {
            
        }
    }
    /*
    if([[SlikeReachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable && playerStatus == SL_BUFFERING)
    {
        BOOL doesContain = [self.view.subviews containsObject:self.noNetworkWindow];
        if(!doesContain)
        {
            self.noNetworkWindow.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
            
            [self.view addSubview:self.noNetworkWindow];
        }
    }
    else
    {
        BOOL doesContain = [self.view.subviews containsObject:self.noNetworkWindow];
        if(doesContain)
        {
            [self.noNetworkWindow removeFromSuperview];
        }
    }
    */
}
-(void)dailymotionAddOpen:(NSURL*) URL
{
    SlikeInAppBrowserViewController *webViewObj = [[SlikeInAppBrowserViewController alloc] initWithNibName:@"SlikeInAppBrowserView" bundle:[NSBundle slikeNibsBundle]];
    
    webViewObj.webURL = URL;
    webViewObj.titleInfo = @"Daily Motion";
    [self presentViewController:webViewObj animated:YES completion:nil];
}

- (void)sendPlayerStatus:(SlikePlayerState) status {
    
    StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:[self getPosition] withDuration:[self getDuration] muteStatus:0];
    [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:status dataPayload:@{kSlikeADispatchEventToParentKey:@YES, kSlikeAdStatusInfoKey:progressInfo} slikePlayer:self];
    
}

- (void)sendData:(SlikePlayerState)playerState withUserBehavior:(SlikeUserBehaviorEvent)userBehavior forced:(BOOL) forced {
    
    EventModel *eventModel;
    
    eventModel = [EventModel createEventModel:SlikeAnalyticsTypeMedia withBehaviorEvent:userBehavior withPayload:nil];
    
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


- (void)sendAllDataForcibly
{
    [self sendData:SL_COMPLETED withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
}

//Work More
#pragma ISlikePlayer implementation
-(void) playMovieStreamWithObject:(SlikeConfig *)si withParent:(id) parent withError:(NSError*)error {
    //For Error handlation
}
- (void) playMovieStreamWithObject:(SlikeConfig *)si withParent:(id) parent {
    
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
    [self initWithStringWithID:[si.streamingInfo getURL:VIDEO_SOURCE_DM byQuality:@""].strURL withClipID:si.streamingInfo.strID withTitle:si.streamingInfo.strTitle];
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

-(SlikePlayerState) getStatus
{
    return playerStatus;
}
- (void)viewWillEnterForeground
{
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
- (void)viewWillEnterBackground
{
    self.isAppActive = NO;
}
-(void) play:(BOOL) isUser
{
    if(!self.playerView) return;
    [self.playerView play];
    isVideoEnd = NO;
}
-(void) pause:(BOOL) isUser
{
    if(!self.playerView) return;
    [self.playerView pause];
}
-(void) resume
{
    if(!self.playerView) return;
    [self.playerView play];
}
-(void) sendCustomControlEvent:(SlikePlayerState) state
{
    SlikeDLog(@"onSreentap");
    [self sendPlayerStatus:state];
    
}
-(void) replay
{
    [self sendData:SL_REPLAY withUserBehavior:SlikeUserBehaviorEventNone forced:YES];
    
    [self seekTo:0 userSeeked:NO];
}
-(BOOL) isPlaying
{
    return  isPlaying;
}
-(void)playerMute:(BOOL)isMute
{
    // [self.playerView playerMute:isMute];
}
-(BOOL)getPlayerMuteStatus
{
    return  NO;
    // return  [self.playerView getPlayerMuteStatus];
}
-(void) seekTo:(float) nPosition userSeeked:(BOOL)isUser
{
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
    return self.playerView.fullscreen;
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
    //
}

- (id<ISlikeCast>)getCast {
    return nil;
}

- (NSString *)currentBitRateURI {
    return  @"";
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

@end


