//
//  SlikeMemePlayerViewController.m
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 09/04/18.
//

#import "SlikeMemePlayerViewController.h"
#import "SlikeAnalytics.h"
#import "SlikePlayer.h"
#import "ISlikePlayerControl.h"
#import "SlikeStringCommon.h"
#import "SlikeUtilities.h"
#import "NSBundle+Slike.h"
#import "EventModel.h"
#import "SlikePlayerEvent.h"
#import "EventManagerProtocol.h"
#import "EventManager.h"
#import "SlikePlayerConstants.h"
#import "SlikeMaterialDesignSpinner.h"

@interface SlikeMemePlayerViewController () <EventManagerProtocol> {
    id playerContainer;
}

@property (weak, nonatomic) IBOutlet UIImageView *playerMemeView;
@property (weak, nonatomic) IBOutlet SlikeMaterialDesignSpinner *loadingView;
@property (nonatomic,assign) BOOL isNativeControls;
@property (strong,nonatomic) SlikeConfig * sdkConfiguration;
@property (nonatomic,assign) SlikePlayerState playerStatus;

@end

@implementation SlikeMemePlayerViewController

@synthesize slikeConfig;
@synthesize isAppAlreadyDestroyed;
@synthesize isAppActive;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.loadingView  startAnimating];
    [[EventManager sharedEventManager]registerEvent:self];
}

/**
 Load the player
 @param memeURL - Stream URL
 */
- (void)loadPlayer:(NSString *)memeURL {
    [[SlikeNetworkManager defaultManager] getImageForURL:[NSURL URLWithString:memeURL] completion:^(UIImage *image, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [self.loadingView stopAnimating];
            self.loadingView.hidden=YES;

            StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:0 withDuration:0 muteStatus:0];

            if (!error && image) {
                [self sendPlayerStatus:(SL_LOADED) withProgress:progressInfo];
                self.playerMemeView.image = image;
                [self prepareAndSendAnaltytics:@"1"];

            } else {
                
                [self prepareAndSendAnaltytics:@"-10"];
                    if([[SlikeReachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)  {
                        [self sendPlayerStatus:(SL_ERROR) withProgress:[StatusInfo initWithError:NO_NETWORK]];
                    } else {
                         [self sendPlayerStatus:(SL_ERROR) withProgress:progressInfo];
                    }
            }
        });
    }];
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

    [[SlikeDeviceSettings sharedSettings] setPlayerViewArea:parent];
    self.sdkConfiguration.streamingInfo.strSS = @"";
    if([self.sdkConfiguration.streamingInfo.strSS length] == 0)
        self.sdkConfiguration.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:self.sdkConfiguration.mediaId];

    //Add custom Controls
    self.isNativeControls = YES;
    playerContainer = parent;
    NSString *memeUrl = [self.sdkConfiguration.streamingInfo getURL:VIDEO_SOURCE_MEME byQuality:@""].strURL;

    if (memeUrl ==nil) {
        StatusInfo *progressInfo = [StatusInfo initWithBuffer:0 withPosition:0 withDuration:0 muteStatus:0];
        [self sendPlayerStatus:SL_ERROR withProgress:progressInfo];
        return;
    }
    self.loadingView.hidden=NO;
    [self loadPlayer:memeUrl];
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

- (void)removePlayer {
    [self cleanup];
    if(playerContainer) {
        if([playerContainer isKindOfClass:[UIView class]]) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];

        } else if([playerContainer isKindOfClass:[UIViewController class]]) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
    }
}

- (BOOL)isPlayerExist {
    return YES;
}

- (NSString *)getCurrentFlavour {
    return @"";
}

- (void)stop {
}

- (void)resetPlayer {
    [self stop];
}

- (BOOL)cleanup {
    if(self.isAppAlreadyDestroyed) {
        return NO;
    }
    self.isAppAlreadyDestroyed = YES;
    [self stop];

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

- (void)setVideoPlaceHolder :(BOOL)isSet {
}

- (BOOL)isAdPlaying {
    return  NO;
}

- (IBAction)clbCloseAction:(id)sender {
    //[[SlikePlayer getInstance] stopPlayer];
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



#pragma mark - Send Analytics Data

/**
 Prepare the request for the Analytics.
 @param eventTypeString - Type of Event
 */
- (void)prepareAndSendAnaltytics:(NSString *) eventTypeString  {
    
    EventModel *eventModel = [EventModel createEventModel:SlikeAnalyticsTypeMeme withBehaviorEvent:SlikeUserBehaviorEventNone withPayload:@{}];
    eventModel.slikeConfigModel = self.sdkConfiguration;
    eventModel.playerEventModel.eventType = eventTypeString;
    eventModel.playerEventModel.type = @"meme";
    eventModel.playerEventModel.currentPlayer = [self.sdkConfiguration.streamingInfo getCurrentPlayer];
    eventModel.playerEventModel.playerType = [self.sdkConfiguration.streamingInfo getConstantValueForPlayerType];
    
    [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:_playerStatus dataPayload:@{kSlikeEventModelKey:eventModel} slikePlayer:self];
    
}


#pragma mark -  Send Player Status
- (void)sendPlayerStatus:(SlikePlayerState) status withProgress:(StatusInfo *) progressInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _dispatchEventsToParent:status withProgress:progressInfo];
    });
}

- (void)_dispatchEventsToParent:(SlikePlayerState)status withProgress:(StatusInfo *)progressInfo {
    [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:status dataPayload:@{kSlikeADispatchEventToParentKey:@YES, kSlikeAdStatusInfoKey:progressInfo} slikePlayer:self];
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

/**
 Get the screen shot at perticular position
 @param position - Time in second
 @param completion - Completion Block
 */
- (void)getScreenShotAtPosition:(NSInteger)position withCompletionBlock:(void (^)(UIImage *image))completion {
    completion(nil);
}

@end
