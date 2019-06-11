//
//  SlikeWebPlayerViewController.m
//  SlikePlayer
//  Created by Sanjay Singh Rathor on 12/03/18.
//

#import "SlikeWebPlayerViewController.h"
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

@interface SlikeWebPlayerViewController () <SlikeInterfaceProvider,
EventManagerProtocol,
UIWebViewDelegate> {
    id _playerContainer;
}

@property (weak, nonatomic) IBOutlet UIWebView *playerWebView;
@property (nonatomic,assign)  BOOL isNativeControls;
@property (assign, nonatomic) BOOL playerLoaded;
@property (assign, nonatomic) BOOL playerDidStarted;
@property (assign, nonatomic) BOOL loadingFailed;
@property (assign, nonatomic) BOOL isReplayed;

@property (assign, nonatomic) NSInteger replayCount;
@property (strong,nonatomic)NSString *playerImageUrl;

@property (strong,nonatomic) SlikeConfig * sdkConfiguration;
@property (assign, nonatomic) NSInteger urts;
@property (assign, nonatomic) NSInteger uopts;
@property (assign, nonatomic) SlikePlayerState playerStatus;
@property (weak, nonatomic) IBOutlet SlikeMaterialDesignSpinner *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;


@end

@implementation SlikeWebPlayerViewController

@synthesize slikeConfig;
@synthesize isAppAlreadyDestroyed;
@synthesize isAppActive;

const NSString *const prefixUrl = @"https://videoplayer.indiatimes.com/v2/veblr.html?url=";

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
    _replayCount=0;
    
}

/**
 Load the player
 @param playerURL - Stream URL
 */
- (void)loadPlayer:(NSString *)playerURL {
    
   //NSString *encodedString=[siteUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURLRequest *nsrequest= [NSURLRequest requestWithURL:[NSURL URLWithString:playerURL]];
    [_playerWebView loadRequest:nsrequest];
    
    NSTimeInterval milisecondedDate = ([[NSDate date] timeIntervalSince1970] * 1000);
    _urts = (NSInteger) milisecondedDate;
    _uopts = -1;
    
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
    NSString *getEmbededMp4Url = [self.sdkConfiguration.streamingInfo getURL:VIDEO_SOURCE_VEBLR byQuality:@""].strURL;
    
    if (getEmbededMp4Url == nil) {
        [self sendPlayerStatus:SL_ERROR];
        return;
    }
    
    self.playerImageUrl = self.sdkConfiguration.streamingInfo.strImageURL;
    
    //Create the complete URL for the player
    NSString *vendor = [[SlikeDeviceSettings sharedSettings] getKey];
    if (![self.sdkConfiguration.business isEqualToString:@""] && self.sdkConfiguration.business !=nil) {
        vendor = self.sdkConfiguration.business;
    }
    
    NSString *veblorUrlString = @"";
    if ([[self.sdkConfiguration.streamingInfo.vendorName lowercaseString] isEqualToString:@"rumble"]) {
        veblorUrlString = getEmbededMp4Url;
    } else {
        veblorUrlString = [NSString stringWithFormat:@"%@&vendor=%@&enablejsapi=1",getEmbededMp4Url,vendor];
    }
    
    NSString*  encodedString = [self encodedString:veblorUrlString];
    NSString*  imageEncodedString = [self encodedString:_playerImageUrl];
    NSString* completePlayerUrl = [NSString stringWithFormat:@"%@%@&imgurl=%@",prefixUrl, encodedString, imageEncodedString];
    if (completePlayerUrl ==nil) {
        [self sendPlayerStatus:SL_ERROR];
        return;
    }
    [self loadPlayer:completePlayerUrl];
}

/**
 Remove the player and release all the resources
 */
- (void)removePlayer {
    
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
    self.isAppAlreadyDestroyed = YES;
    [self stop];
    return YES;
}

#pragma mark -  Send Player Status
- (void)sendPlayerStatus:(SlikePlayerState)status {
    _playerStatus = status;
    dispatch_async(dispatch_get_main_queue(), ^{
        StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:[self getPosition] withDuration:[self getDuration] muteStatus:0];
        [self _dispatchEventsToParent:status withProgress:progressInfo];
    });
}

/**
 Dispatch the Event to the parent Application.
 @param status - Current Player Status
 @param progressInfo - Progress info
 */
- (void)_dispatchEventsToParent:(SlikePlayerState)status withProgress:(StatusInfo *)progressInfo {
    [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:status dataPayload:@{kSlikeADispatchEventToParentKey:@YES, kSlikeAdStatusInfoKey:progressInfo} slikePlayer:self];
}

#pragma mar- UIWebViewDelegate
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (!_isReplayed) {
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!self.playerLoaded) {
        self.playerLoaded=YES;
        if (_uopts==-1) {
            _uopts = ([[NSDate date] timeIntervalSince1970] * 1000);
        }
        
        self.sdkConfiguration.streamingInfo.strSS = @"";
        if([self.sdkConfiguration.streamingInfo.strSS length] == 0)
            self.sdkConfiguration.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:self.sdkConfiguration.mediaId];
        
        
        
        NSString *analyticsString = [NSString stringWithFormat:@"&urts=%ld&uopts=%ld",_urts, (long) _uopts];
        [self prepareAndSendAnaltytics:@"1" withTimeStamp:analyticsString];
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
        StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:0 withDuration:0 muteStatus:0];
        [self _dispatchEventsToParent:SL_ERROR withProgress:progressInfo];
    }
    
    if (!self.loadingFailed && !self.playerLoaded) {
        self.loadingFailed=YES;
        [self prepareAndSendAnaltytics:@"-10" withTimeStamp:nil];
    }
}

/**
 Prepare the request for the Analytics.
 
 @param eventTypeString - Type of Event
 @param timeStampParam - Time stamp at time of request
 */
- (void)prepareAndSendAnaltytics:(NSString *)eventTypeString withTimeStamp:(NSString *)timeStampParam {
    
    EventModel *eventModel = [EventModel createEventModel:SlikeAnalyticsTypeEmbed withBehaviorEvent:SlikeUserBehaviorEventNone withPayload:@{}];
    eventModel.slikeConfigModel = self.sdkConfiguration;
    
    eventModel.playerEventModel.eventType = eventTypeString;
    eventModel.playerEventModel.replayCount = _replayCount;
    eventModel.playerEventModel.type = @"tpu";
    if (timeStampParam) {
        eventModel.playerEventModel.urts = _urts;
        eventModel.playerEventModel.uopts = _uopts;
    }
    
    [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:_playerStatus dataPayload:@{kSlikeEventModelKey:eventModel} slikePlayer:self];
}

#pragma mark -  JS call backs implementation
/**
 Called from the JS side. Telling the video has started
 @param input - Some string from the JS Side
 @return- UnUsed
 */
- (NSString *)videoStartFn:(NSString *) input {
    if (!self.playerDidStarted) {
        self.playerDidStarted=YES;
        
        NSString *analyticsString = [NSString stringWithFormat:@"&urts=%ld&uopts=%ld",_urts, (long) _uopts];
        [self prepareAndSendAnaltytics:@"2" withTimeStamp:analyticsString];
        StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:0 withDuration:0 muteStatus:0];
        [self _dispatchEventsToParent:SL_START withProgress:progressInfo];
        
    }
    
    return @"";
}

/**
 Called from the JS side. Telling the video persantage
 @param input - Some string from the JS Side
 @return- UnUsed
 */

- (NSString *)videoFirstQuartileFn:(NSString *) input {
    StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:0 withDuration:0 muteStatus:0];
    [self _dispatchEventsToParent:SL_Q1 withProgress:progressInfo];
    return @"";
}

/**
 Called from the JS side. Telling the video persantage
 @param input - Some string from the JS Side
 @return- UnUsed
 */

- (NSString *)videoMidQuartileFn:(NSString *) input {
    StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:0 withDuration:0 muteStatus:0];
    [self _dispatchEventsToParent:SL_Q2 withProgress:progressInfo];
    return @"";
}

- (NSString *)videoThirdQuartileFn:(NSString *) input {
    StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:0 withDuration:0 muteStatus:0];
    [self _dispatchEventsToParent:SL_Q3 withProgress:progressInfo];
    return @"";
}

/**
 Function call from the JS . It will send either the 'end' event or the 'relplay' event on video completion
 @param state  - reply|end
 @return - Currently Unused
 */

- (NSString *)videoEndedFn:(NSString *) state {
    
    if ([state isEqualToString:@"end"]) {
        _isReplayed=NO;
        [self prepareAndSendAnaltytics:@"4" withTimeStamp:nil];
        
        // change the ss
        StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:0 withDuration:0 muteStatus:0];
        [self _dispatchEventsToParent:SL_ENDED withProgress:progressInfo];
        
        _urts=0;
        _uopts=0;
        
        
    } else if([state isEqualToString:@"replay"] ) {
        
        // change the ss
        [self prepareAndSendAnaltytics:@"5" withTimeStamp:nil];
        
        StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:0 withDuration:0 muteStatus:0];
        [self _dispatchEventsToParent:SL_REPLAY withProgress:progressInfo];
        
        self.playerLoaded=NO;
        self.playerDidStarted=NO;
        self.loadingFailed=NO;
        _isReplayed=YES;
        _replayCount=1;
        [self.playerWebView reload];
    }
    return @"";
}


/**
 The JS interface
 @return - JS methods that needs to be called from the JS side
 */
- (NSDictionary<NSString *, NSValue *> *) javascriptInterfaces{
    return @{
             @"videoStartFn" : [NSValue valueWithPointer:@selector(videoStartFn:)],
             @"videoFirstQuartileFn" : [NSValue valueWithPointer:@selector(videoFirstQuartileFn:)],
             @"videoMidQuartileFn" : [NSValue valueWithPointer:@selector(videoMidQuartileFn:)],
             @"videoThirdQuartileFn" : [NSValue valueWithPointer:@selector(videoThirdQuartileFn:)],
             @"videoEndedFn" : [NSValue valueWithPointer:@selector(videoEndedFn:)],
             };
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


