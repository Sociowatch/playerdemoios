//
//  SlikeRumblePlayerViewController.m
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 18/09/18.
//

#import "SlikeRumblePlayerViewController.h"
#import "SlikePlayer.h"
#import "UIWebView+SlikeJavascriptInterface.h"
#import "SlikeInterfaceProvider.h"
#import "SlikeUtilities.h"
#import "NSBundle+Slike.h"
#import "EventModel.h"
#import "SlikePlayerEvent.h"
#import "EventManagerProtocol.h"
#import "EventManager.h"
#import "SlikePlayerConstants.h"
#import "SlikeMaterialDesignSpinner.h"
#import "UIView+SlikeAlertViewAnimation.h"


@interface SlikeRumblePlayerViewController () <SlikeInterfaceProvider,
EventManagerProtocol,
UIWebViewDelegate> {
    id _playerContainer;
}

@property (weak, nonatomic) IBOutlet UIWebView *playerWebView;
@property (nonatomic,assign)  BOOL isNativeControls;
@property (assign, nonatomic) BOOL playerLoaded;
@property (assign, nonatomic) BOOL playerDidStarted;
@property (assign, nonatomic) BOOL loadingFailed;

@property (strong,nonatomic) SlikeConfig * sdkConfiguration;
@property (assign, nonatomic) SlikePlayerState playerStatus;
@property (weak, nonatomic) IBOutlet SlikeMaterialDesignSpinner *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;

@end

@implementation SlikeRumblePlayerViewController

@synthesize slikeConfig;
@synthesize isAppAlreadyDestroyed;
@synthesize isAppActive;

static  NSString *const kRumbleUrl = @"https://videoplayer.indiatimes.com/v2/rumble.html?apikey=%@&videoid=%@";

- (void)viewDidLoad {
    [super viewDidLoad];
    _playerWebView.delegate=self;
    [_playerWebView initializeWebKit];
    [[EventManager sharedEventManager]registerEvent:self];
    [_playerWebView addJavascriptInterface:self forName:@"JsHandler"];
    [_playerWebView setBackgroundColor:[UIColor clearColor]];
    [_playerWebView setOpaque:NO];
    _playerWebView.allowsInlineMediaPlayback = YES;
    
    self.playerLoaded = NO;
    self.playerDidStarted = NO;
    self.loadingFailed = NO;
}

/**
 Load the player
 @param playerURL - Stream URL
 */
- (void)loadPlayer:(NSString *)playerURL {
    NSURLRequest *nsrequest= [NSURLRequest requestWithURL:[NSURL URLWithString:playerURL]];
    [_playerWebView loadRequest:nsrequest];

}

#pragma mark - ISlikePlayer Protocolimplementation
/*
 ISlikePlayer - Protocol method implementation
 */
- (void)playMovieStreamWithObject:(SlikeConfig *)si withParent:(id) parent withError:(NSError*)error {
    //For Error handlation
}

- (void)playMovieStreamWithObject:(SlikeConfig *)configuration withParent:(id) parent {
    
    self.sdkConfiguration = configuration;
    self.slikeConfig =  configuration;
    
    [self setVideoPlaceHolder:YES];
    
    //Genrate New SS if the video play in second time
    [[SlikeDeviceSettings sharedSettings] setPlayerViewArea:parent];
    self.sdkConfiguration.streamingInfo.strSS = @"";
    self.sdkConfiguration.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:self.sdkConfiguration.mediaId];
    
    //Add custom Controls
    self.isNativeControls = YES;
    _playerContainer = parent;
    NSString *getEmbededMp4Url = [self.sdkConfiguration.streamingInfo getURL:VIDEO_SOURCE_RUMBLE byQuality:@""].strURL;
    
    if (getEmbededMp4Url == nil) {
        [self prepareAndSendAnaltytics:SL_ERROR withEventType:MEDIA];
        return;
    }
    
    NSArray *splitArray = [getEmbededMp4Url componentsSeparatedByString:@"."];
    NSString* completePlayerUrl = [NSString stringWithFormat:kRumbleUrl, splitArray.firstObject, splitArray. lastObject];
    if (completePlayerUrl ==nil) {
        [self prepareAndSendAnaltytics:SL_ERROR withEventType:MEDIA];
        return;
    }
    
    //Send the video request to the server..
    [self prepareAndSendAnaltytics:SL_VIDEO_REQUEST withEventType:MEDIA];
    [self loadPlayer:completePlayerUrl];
}

/**
 Remove the player and release all the resources
 */
- (void)removePlayer {
    
    //Send the Event to server for loading error the video
    [self prepareAndSendAnaltytics:SL_ENDED withEventType:MEDIA];
    
    [self cleanup];
    if(_playerContainer) {
        if([_playerContainer isKindOfClass:[UIView class]]) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
    }
}

- (void)stop {
    
    if ([self.playerWebView isLoading]) {
        [self.playerWebView stopLoading];
    }
    self.playerWebView.delegate=nil;
}

- (BOOL)cleanup {
    if(self.isAppAlreadyDestroyed) {
        return NO;
    }
    [self stop];
    self.isAppAlreadyDestroyed = YES;
    return YES;
}

#pragma mar- UIWebViewDelegate
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!self.playerLoaded) {
        self.playerLoaded=YES;
        
        self.sdkConfiguration.streamingInfo.strSS = @"";
        if([self.sdkConfiguration.streamingInfo.strSS length] == 0)
            self.sdkConfiguration.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:self.sdkConfiguration.mediaId];
    
        //Send the Event to server for loading the video
        [self prepareAndSendAnaltytics:SL_LOADED withEventType:MEDIA];

    }
    _loadingView.hidden = YES;
    [_loadingView stopAnimating];
    [self setVideoPlaceHolder:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    _loadingView.hidden = YES;
    [_loadingView stopAnimating];
    [self setVideoPlaceHolder:NO];
    
    //Its is sending the Cancel error message
    if(error.code != NSURLErrorCancelled && error) {
        [self prepareAndSendAnaltytics:SL_ERROR withEventType:MEDIA];
    }
    
    if (!self.loadingFailed && !self.playerLoaded) {
        self.loadingFailed=YES;
        
        //Send the Event to server for loading error the video
        [self prepareAndSendAnaltytics:SL_ERROR withEventType:MEDIA];

    }
}

/**
 Prepare the request for the Analytics.
 @param playerState - Type of Event
 @param eventType - Event type for the Request
 */
- (void)prepareAndSendAnaltytics:(SlikePlayerState)playerState withEventType:(SlikeEventType)eventType {
    _playerStatus = playerState;
    
    if (eventType == MEDIA) {
        
        EventModel *eventModel = [EventModel createEventModel:SlikeAnalyticsTypeRumble withBehaviorEvent:SlikeUserBehaviorEventNone withPayload:@{}];
        eventModel.slikeConfigModel = self.sdkConfiguration;
        eventModel.playerEventModel.playerState = playerState;
        [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:_playerStatus dataPayload:@{kSlikeEventModelKey:eventModel} slikePlayer:self];

    } else {
        
        EventModel *eventModel = [EventModel createEventModel:SlikeAnalyticsTypeRumbleAd withBehaviorEvent:SlikeUserBehaviorEventNone withPayload:@{}];
        eventModel.slikeConfigModel = self.sdkConfiguration;
        [[EventManager sharedEventManager]dispatchEvent:AD playerState:playerState dataPayload:@{kSlikeEventModelKey:eventModel} slikePlayer:nil];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:[self getPosition] withDuration:[self getDuration] muteStatus:0];
        [[EventManager sharedEventManager]dispatchEvent:eventType playerState:playerState dataPayload:@{kSlikeADispatchEventToParentKey:@YES, kSlikeAdStatusInfoKey:progressInfo} slikePlayer:self];
    });
}

#pragma mark -  JS call backs implementation
- (NSDictionary<NSString *, NSValue *> *) javascriptInterfaces{
    return @{
             @"playerEvent" : [NSValue valueWithPointer:@selector(playerEvent: :)],
             };
}

- (void)playerEvent:(NSString *)eventName  :(id)customData {
    
    if([eventName isEqualToString:@"loadVideo"]) {
    }
    else if([eventName isEqualToString:@"play"]){
        [self prepareAndSendAnaltytics:SL_PLAY withEventType:MEDIA];
    }
    else if([eventName isEqualToString:@"pause"]){
        [self prepareAndSendAnaltytics:SL_PAUSE withEventType:MEDIA];
    }
    else if([eventName isEqualToString:@"fullscreen" ]){
        [self prepareAndSendAnaltytics:SL_PAUSE withEventType:MEDIA];
    }
    else if([eventName isEqualToString:@"videoEnd"]){
        [self prepareAndSendAnaltytics:SL_VIDEO_COMPLETED withEventType:MEDIA];
    }
    else if([eventName isEqualToString:@"preAd"]){
       [self prepareAndSendAnaltytics:SL_AD_REQUESTED withEventType:AD];
    }
    else if([eventName isEqualToString:@"adError"]){
      [self prepareAndSendAnaltytics:SL_ERROR withEventType:AD];
    }
    else if([eventName isEqualToString:@"adImpression"]){
      [self prepareAndSendAnaltytics:SL_ERROR withEventType:AD];
    }
    else if([eventName isEqualToString :@"adClick"]){
       [self prepareAndSendAnaltytics:SL_CLICKED withEventType:AD];
    }
}

- (NSString *)encodedString:(NSString *)veblorUrlString {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    NSString*  encodedString = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                    (CFStringRef)veblorUrlString,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8 ));
#pragma clang diagnostic pop
    return encodedString;
    
}



#pragma mark- Delegate methods of iSlikePlayer
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
    return;
}

- (void)pause:(BOOL) isUser {
    return;
}

- (void)resume {
    return;
}

- (void)replay {
    return;
}

- (BOOL)isPlaying {
    return NO;
}

- (BOOL)isFullScreen {
    return NO;
}

- (void)toggleFullScreen {
    return;
}

-(void) seekTo:(float) nPosition userSeeked:(BOOL) isUser {
    return;
}
- (BOOL)isPlayerExist {
    return YES;
}

- (NSString *)getCurrentFlavour {
    return @"";
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
    //self.slikeControl = control;
}
- (id<ISlikePlayerControl>) getControl {
    return nil;
    // return self.slikeControl;
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

- (void)resetPlayer {
    [self stop];
}

- (IBAction)clbCloseAction:(id)sender {
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

#pragma mark -
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
                        self.playerWebView.hidden = NO;
                    }];
                    
                } else if([SlikeUtilities getPosterImage:self.slikeConfig].length>0) {
                    
                    [[SlikeNetworkManager defaultManager] getImageForURL:[NSURL URLWithString:[SlikeUtilities getPosterImage:self.slikeConfig]] completion:^(UIImage *image, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
                        
                        if(!error) {
                            self.posterImage.image =image;
                        }
                        else {
                            
                            [self.posterImage slike_fadeOutAndCompletion:^(UIView *view) {
                                self.posterImage.hidden= YES;
                                self.playerWebView.hidden = NO;
                            }];
                        }
                    }];
                } else {
                    [self.posterImage slike_fadeOutAndCompletion:^(UIView *view) {
                        self.posterImage.hidden= YES;
                        self.playerWebView.hidden = NO;
                    }];
                }
            } else {
                
                if(!self.posterImage.hidden) {
                    [self.posterImage slike_fadeOutAndCompletion:^(UIView *view) {
                        self.posterImage.hidden= YES;
                        self.playerWebView.hidden = NO;
                    }];
                }
            }
        } else {
            self.posterImage.hidden= YES;
        }
    });
}

@end
