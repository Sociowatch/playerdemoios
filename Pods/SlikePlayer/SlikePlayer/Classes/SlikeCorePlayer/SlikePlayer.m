//
//  SlikePlayer.m
//  Slike
//
//  Created by TIL on 29/11/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//

#import "SlikePlayer.h"
#import "DMMainViewController.h"
#import "SlikeFBViewController.h"
#import "SlikeGifPlayerViewController.h"
#import "SlikeWebPlayerViewController.h"
#import "SlikeRumblePlayerViewController.h"
#import "SlikeMemePlayerViewController.h"
#import "ISlikeAnlytics.h"
#import "SlikeStringCommon.h"
#import "SlikeAnalytics.h"
#import "SlikeServiceError.h"
#import "SlikeDataProvider.h"
#import "SlikeSharedDataCache.h"
#import "SlikeNetworkMonitor.h"
#import "NSDictionary+Validation.h"
#import "NSBundle+Slike.h"
#import "SlikeUtilities.h"
#import "SlikeAvPlayerViewController.h"
#import "NewYTViewController.h"
#import "DMPlayerViewController.h"
#import "SlikeAdsQueue.h"
#import "StreamingInfo.h"
#import "ISlikePlayer.h"
#import "StatusInfo.h"
#import "UIView+SlikeAlertViewAnimation.h"
#import "SlikePlayerErrorView.h"
#import "SlikeDeviceSettings.h"
#import "EventManager.h"
#import "EventManagerProtocol.h"
#import "SlikePlayerConstants.h"
#import "SlikeAdManager.h"
#import "SlikeAnalytics.h"

static NSString *const kAllowTracking = @"allowTracking";
@interface SlikePlayer()  <EventManagerProtocol> {
    id _videoViewParent;
}

@property (strong, nonatomic) id<ISlikePlayer> slikePlayer;
@property (strong, nonatomic) NSMutableArray *playlistArray;
@property (assign, nonatomic) NSInteger currentPlaylistIndex;
@property (copy,   nonatomic) onChange callBackHandler;
@property (weak,   nonatomic) UIView *parentView;
@property (assign, nonatomic) BOOL requestInProcess;
@property (assign, nonatomic) NSInteger cardFecthTime;
@property (strong, nonatomic) SlikePlayerErrorView *slikeAlertView;
@property (assign, nonatomic) BOOL isMediaCompleted;
@property (assign, nonatomic) NSInteger nextCardIndex;
@property (assign, nonatomic) BOOL startObserving;
@property (assign, nonatomic) NSInteger slikePlayItemIndex;

/**
 Play Stream the config file for the stream and play the current stream
 @param configModel -  Config file for Stream
 @param parent - Parent Window
 @param block  - Player Status Block
 */
- (void)_playVideoWithInfo:(SlikeConfig *)configModel inParent:(id) parent withProgressHandler:(onChange) block;

@end

@implementation SlikePlayer

+ (instancetype)sharedSlikePlayer {
    return [[self alloc] init];
}

//Initialize the instance
- (id)init {
    if (self = [super init]) {
        
        //Initializing the analytics
        [[SlikeAnalytics sharedManager]registerAnalyticsToListenEvents];
        [[EventManager sharedEventManager]registerEvent:self];
        _playlistArray = [[NSMutableArray alloc]init];
        _cardFecthTime = 5;
        //It's value will be  0 =>Previous |1 => Next | -1 =>None
        _slikePlayItemIndex = -1;
        
        [self resetPlaylist];
    }
    
    return self;
}

- (instancetype)initWithPlaylist:(NSArray *)playlist {
    if (self = [self init]) {
        if (playlist && [playlist count]>0) {
            [_playlistArray addObjectsFromArray:playlist];
            [SlikeSharedDataCache sharedCacheManager].cacahedPlaylist = playlist;
        }
    }
    return self;
}

+ (instancetype)sharedSlikePlayerWithPlaylist:(NSArray *)playlist {
    SlikePlayer *player = [[SlikePlayer alloc] initWithPlaylist:playlist];
    return player;
}

/**
 Player Instance
 @return - Current Player Instance
 */
- (id<ISlikePlayer>)getAnyPlayer {
    if(_slikePlayer) {
        return _slikePlayer;
    }
    return nil;
}

/**
 Stop the CUrrent Player
 */
- (void)stopPlayer {
    [self releaseSlikePlayer];
}

/**
 Hide Controls
 */
-(void)hideControls {
    [[EventManager sharedEventManager] dispatchEvent:MEDIA playerState:SL_HIDECONTROLS dataPayload:@{} slikePlayer:nil];
}

/**
 Traverse the controller(s) heirarchy for source
 
 @param controllerView  - Controllers view
 @return - Result View
 */
- (id)traverseResponderChainForUIViewController:(UIView *) controllerView {
    id nextResponder = [controllerView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [self traverseResponderChainForUIViewController:(UIView *)nextResponder];
    } else {
        return nil;
    }
}

- (void)resetAlertView {
    if (self.slikeAlertView && [self.slikeAlertView superview]) {
        self.slikeAlertView.alpha =0;
        [self.slikeAlertView removeAlertViewWithAnimation:NO];
    }
}

/**
 Show the Error window.
 
 @param config - Config Model
 @param parent - Parent View
 @param resultBlock - Event Block
 @param error - Error Description
 */
- (void)playVideoWithInfoWithError:(SlikeConfig *)config inParent:(id)parent withProgressHandler:(onChange) resultBlock withError:(NSError*)error {
    
    self.requestInProcess = NO;
    // dispatch_async(dispatch_get_main_queue(), ^{
    self.slikeAlertView = [SlikePlayerErrorView slikePlayerErrorView];
    
    if (self.slikePlayer) {
        
        [self.slikePlayer playMovieStreamWithObject:config withParent:parent withError:error];
        UIViewController *slikePlayerController = nil;
        if (self.slikePlayer && [self.slikePlayer isKindOfClass:[UIViewController class]]) {
            slikePlayerController = (UIViewController *)self.slikePlayer;
        } else {
            slikePlayerController = (UIViewController *)[self.slikePlayer getViewController];
        }
        [slikePlayerController.view addSubview:self.slikeAlertView];
        self.slikeAlertView.frame = slikePlayerController.view.frame;
        self.slikeAlertView.autoresizingMask = UIViewAutoresizingFlexibleHeight |  UIViewAutoresizingFlexibleWidth;
        
    } else {
        UIView *parentView = (UIView *)parent;
        [parentView addSubviewWithContstraints:self.slikeAlertView];
    }
    
    if (error.code == SlikeServiceErrorNoNetworkAvailable) {
        [self.slikeAlertView setErrorMessage:[error localizedDescription] withCloseEnable:config.isNoNetworkCloseControlEnable withReloadEnable:YES];
    } else {
        [self.slikeAlertView setErrorMessage:[error localizedDescription] withCloseEnable:YES withReloadEnable:NO];
    }
    //});
    __block SlikePlayerErrorView* weakAlert = _slikeAlertView;
    weakAlert.closeButtonBlock = ^ {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.slikeAlertView removeAlertViewWithAnimation:YES];
            [self stopPlayer];
            if(resultBlock) {
                resultBlock(CONTROLS, SL_CLOSE, [StatusInfo initWithError:@""]);
            }
        });
    };
    
    weakAlert.reloadButtonBlock = ^ {
        if ([[SlikeNetworkMonitor sharedSlikeNetworkMonitor] isNetworkReachible]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.slikeAlertView removeAlertViewWithAnimation:YES];
                
                if (config.streamingInfo) {
                    [self _playVideoWithInfo:config inParent:parent withProgressHandler:resultBlock];
                    
                } else {
                    [self _downloadMediaConfigData:config inParentView:parent withProgressHandler:resultBlock];
                }
            });
        }
    };
}

/*
 - (void)handleAlertForPlaylistError {
 
 self.slikeAlertView.dynamicMessageLabel.text = @"Video will start after 5 seconds.";
 __weak typeof(self) _self = self;
 _controlTimer.executionBlock = ^(SlikeTimerControl * _Nonnull control) {
 __strong typeof(_self) self = _self;
 if ( !self ) return;
 
 NSString* messageString =  [NSString stringWithFormat:@"Video will start after %hd seconds.", control.counter];
 self.slikeAlertView.dynamicMessageLabel.text = messageString;
 
 if (control.counter ==0) {
 dispatch_async(dispatch_get_main_queue(), ^{
 [_self.controlTimer clear];
 [self.slikeAlertView removeAlertViewWithAnimation:YES];
 [self playNextVideoFromPlaylist];
 });
 }
 };
 [_controlTimer repeat];
 }*/


/**
 Download the Slike Config Data from the server
 
 @param config - Config instance provided by the Client
 @param completionBlock - Completion Block
 */
- (void)downloadSlikeData:(SlikeConfig *)config resultBlock:(void(^)(id slikeResponseModel, NSError* parseError))completionBlock {
    
    NSString *strBaseURL =  [[SlikeSharedDataCache sharedCacheManager]slikeBaseUrlString];
    NSString *downloadUrl = [NSString stringWithFormat:@"%@feed/playerconfig/%@/r001/%@.json", strBaseURL, @"beta", [[SlikeDeviceSettings sharedSettings] getKey]];
    
    SlikeDataProvider* dataProvider = [SlikeDataProvider  slikeDataProvider];
    [dataProvider downloadSlikeConfigData:downloadUrl withConfig:config resultBlock:^(NSDictionary *configDataDict, NSError *errExists) {
        if (errExists) {
            completionBlock(nil, errExists);
            return ;
        }
        //Download the Stream Data from the server
        [self downloadStreamData:config withConfigData:configDataDict resultBlock:completionBlock];
    }];
}

/**
 Download the Stream Data.
 
 @param configModel - Updated Config Model
 @param configDataDict - Config Row JSON data
 @param completionBlock - Completion Block
 */
- (void)downloadStreamData:(SlikeConfig *)configModel withConfigData:(NSDictionary *)configDataDict resultBlock:(void(^)(id slikeStreamModel, NSError* errExists))completionBlock {
    
    NSString *strAppBase = [configDataDict stringForKey:@"apibase"];
    NSString * streamUrlString = @"";
    
    if(strAppBase)  {
        // nType 1
        streamUrlString = [NSString stringWithFormat:@"%@?ext=json&_id=%@%@%@", strAppBase, configModel.mediaId, [configModel toString], [[SlikeDeviceSettings sharedSettings] getSlikeAnalyticsCache]];
        
    } else {
        // nType 2
        NSString *strBaseURL =  [[SlikeSharedDataCache sharedCacheManager]slikeBaseUrlString];
        streamUrlString = [NSString stringWithFormat:@"%@feed/stream/%@/%@/%@/%@.json", strBaseURL, [configModel.mediaId substringWithRange:NSMakeRange(2, 2)], [configModel.mediaId substringWithRange:NSMakeRange(4, 2)], configModel.mediaId, configModel.mediaId];
    }
    
    SlikeDataProvider* dataProvider = [SlikeDataProvider slikeDataProvider];
    [dataProvider downloadSlikeStreamData:streamUrlString playerConfig:configModel configInfoData:configDataDict resultBlock:^(id slikeStreamModel, NSError *errExists) {
        if (errExists) {
            completionBlock(nil, errExists);
            return ;
        }
        completionBlock(slikeStreamModel, nil);
    }];
}


/**
 Show the Network error Winow
 @param configModel - Config Model
 @param parent - Parent View
 @param stateBlock - Event Block
 */
- (void)showNetworkErrorWindow:(SlikeConfig *)configModel inParentView:(UIView *)parent withProgressHandler:(onChange)stateBlock {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *networkErr = SlikeServiceCreateError(SlikeServiceErrorNoNetworkAvailable, NO_NETWORK);
        [self playVideoWithInfoWithError:configModel inParent:parent withProgressHandler:stateBlock withError:networkErr];
        if(stateBlock) {
            stateBlock(MEDIA, SL_ERROR, [StatusInfo initWithError:[networkErr localizedDescription]]);
        }
    });
}

#pragma mark -  Version 2.0
- (void)playVideo:(SlikeConfig *)configModel inParentView:(UIView *)parent withProgressHandler:(onChange)stateBlock {
    
    if (![parent isKindOfClass:[UIView class]] || !parent) {
        
        [self playVideoWithInfoWithError:configModel inParent:parent withProgressHandler:stateBlock withError:SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, INVALID_INSTANCE_ERROR)];
        if(stateBlock) {
            stateBlock(MEDIA, SL_ERROR, [StatusInfo initWithError:INVALID_INSTANCE_ERROR]);
        }
        return;
    }
    parent.backgroundColor =  [UIColor blackColor];
    BOOL isModelValid = [self validateConfigModel:configModel parentController:parent withProgressHandler:stateBlock];
    
    if (isModelValid) {
        NSString *liveIdmatch = [[SlikeSharedDataCache sharedCacheManager] mappedLiveStreamId:configModel.mediaId];
        if(liveIdmatch && liveIdmatch!=nil && [liveIdmatch length]>0) {
            configModel.mediaId =  liveIdmatch;
        }
        
        BOOL isFbValid = [self configModelContainsValidFaceBookInfo:configModel parentController:parent withProgressHandler:stateBlock];
        if (!isFbValid) {
            return;
        }
        
        [[SlikeDeviceSettings sharedSettings] setM3U8HostValue:@""];
        _videoViewParent = parent;
        
        if (![[SlikeNetworkMonitor sharedSlikeNetworkMonitor] isNetworkReachible]) {
            [self showNetworkErrorWindow:configModel inParentView:parent withProgressHandler:stateBlock];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(configModel.streamingInfo) {
                
                BOOL isGeoAllowed = [[SlikeDeviceSettings sharedSettings] isGeoAllowed:configModel.gca GCB:configModel.gcb];
                if (self.playlistArray && [self.playlistArray count]>0 && !isGeoAllowed) {
                    [self skipVideoToNextIndex];
                } else {
                    [self _playVideoWithInfo:configModel inParent:parent withProgressHandler:stateBlock];
                }
                
            } else {
                [self _downloadMediaConfigData:configModel inParentView:parent withProgressHandler:stateBlock];
            }
        });
    }
}
/**
 Download media config data from the server
 @param configModel - Config model
 @param parent - Parent View
 @param stateBlock - State Block
 */
- (void)_downloadMediaConfigData:(SlikeConfig *)configModel inParentView:(UIView *)parent withProgressHandler:(onChange)stateBlock {
    
    [[SlikePlayerSettings playerSettingsInstance] setIdsForAnalyticsEvents:[SlikeDeviceSettings sharedSettings].gaId withCS_publisherId:[SlikeDeviceSettings sharedSettings].comscoreId];
    [[SlikeAnalytics sharedManager] processVideoRequest:configModel];
    
    [self downloadSlikeData:configModel resultBlock:^(id slikeDataResponse, NSError *parseError) {
        //NOTE :slikeDataResponse can be StreamInfo Model or Config JSON Data(NSDictonary)
        if (parseError) {
            [self playVideoWithInfoWithError:configModel inParent:parent withProgressHandler:stateBlock withError:parseError];
            if(stateBlock)  {
                stateBlock(MEDIA, SL_ERROR, [StatusInfo initWithError:[parseError localizedDescription]]);
            }
            
        } else {
            
            BOOL isGeoAllowed = [[SlikeDeviceSettings sharedSettings] isGeoAllowed:configModel.gca GCB:configModel.gcb];
            if (self.playlistArray && [self.playlistArray count]>0 && !isGeoAllowed) {
                [self skipVideoToNextIndex];
            } else {
                [self _playVideoWithInfo:configModel inParent:parent withProgressHandler:stateBlock];
                NSDate *dt = [NSDate date];
                [SlikeDeviceSettings sharedSettings].nConfigLoadTime = [dt timeIntervalSinceNow] * -1000.0;
            }
        }
    }];
}

/**
 Validate the MediaId Provided by the Parent Application
 
 @param configModel  - ConfigModel
 @param parent - Parent View
 @param block - Progress Block
 @return - YES|NO
 */
- (BOOL)validateConfigModel:(SlikeConfig *)configModel parentController:(id)parent withProgressHandler:(onChange) block {
    
    if(configModel.mediaId &&  [configModel.mediaId length]>2) {
        return YES;
    }
    
    if((configModel.mediaId == nil || [configModel.mediaId isEqualToString:@""]) && configModel.streamingInfo) {
        return YES;
    }

    if(block) {
        block(MEDIA, SL_ERROR, [StatusInfo initWithError:WRONG_CONFIGARATION]);
    }
    
    [self playVideoWithInfoWithError:configModel inParent:parent withProgressHandler:block withError:SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, WRONG_CONFIGARATION)];
    return NO;

}

/**
 If Model Contains facebook info.Then need to varrify the validity of facebook info
 
 @param configModel - Config Model
 @param parent - Parent View
 @param block - Progress Block
 @return - YES|NO
 */
- (BOOL)configModelContainsValidFaceBookInfo:(SlikeConfig *)configModel parentController:(id)parent withProgressHandler:(onChange) block {
    
    BOOL isFB = NO;
    if([configModel.streamingInfo hasVideo:VIDEO_SOURCE_FB]) {
        isFB = YES;
    }
    
    if(isFB) {
        if(configModel.fbAppId == nil || [configModel.fbAppId isEqualToString:@""]) {
            if(block) {
                block(MEDIA, SL_ERROR, [StatusInfo initWithError:FB_ERROR]);
            }
            
            [self playVideoWithInfoWithError:configModel inParent:parent withProgressHandler:block withError:SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, FB_ERROR)];
            return NO;
        }
    }
    return YES;
}


- (void)_openSlikePlayer:(SlikeConfig *)configModel myBundle:(NSBundle *)myBundle parent:(id)parent eventBlock:(onChange)block {
    
    if ([self isPlayerAlreadyExists:[SlikeAvPlayerViewController class]]) {
        [self playStreamWithExistInstance:configModel inParent:parent];
    } else {
        [self stopPlayer];
        self.slikePlayer = [[SlikeAvPlayerViewController alloc] initWithNibName:@"PlayerView" bundle:myBundle];
        
        [self initiatePlayerController:configModel inParent:parent withProgressHandler:block];
    }
}

- (void)_openGIFPlayer:(SlikeConfig *)configModel myBundle:(NSBundle *)myBundle parent:(id)parent eventBlock:(onChange)block {
    
    if ([self isPlayerAlreadyExists:[SlikeGifPlayerViewController class]]) {
        [self playStreamWithExistInstance:configModel inParent:parent];
    } else {
        [self stopPlayer];
        self.slikePlayer = [[SlikeGifPlayerViewController alloc] initWithNibName:@"GifPlayerView" bundle:myBundle];
        [_slikePlayer setNativeControl:false];
        
        [self initiatePlayerController:configModel inParent:parent withProgressHandler:block];
    }
}

- (void)_openMemePlayer:(SlikeConfig *)configModel myBundle:(NSBundle *)myBundle parent:(id)parent eventBlock:(onChange)block {
    
    if ([self isPlayerAlreadyExists:[SlikeMemePlayerViewController class]]) {
        [self playStreamWithExistInstance:configModel inParent:parent];
    } else {
        [self stopPlayer];
        self.slikePlayer = [[SlikeMemePlayerViewController alloc] initWithNibName:@"SlikeMemePlayerView" bundle:myBundle];
        [_slikePlayer setNativeControl:false];
        
        [self initiatePlayerController:configModel inParent:parent withProgressHandler:block];
    }
}

- (void)_openRumblePlayer:(SlikeConfig *)configModel myBundle:(NSBundle *)myBundle parent:(id)parent eventBlock:(onChange)block {
    
    if ([self isPlayerAlreadyExists:[SlikeRumblePlayerViewController class]]) {
        [self playStreamWithExistInstance:configModel inParent:parent];
    } else {
        [self stopPlayer];
        self.slikePlayer = [[SlikeRumblePlayerViewController alloc] initWithNibName:@"SlikeRumblePlayer" bundle:myBundle];
        [_slikePlayer setNativeControl:false];
        
        [self initiatePlayerController:configModel inParent:parent withProgressHandler:block];
    }
}

- (void)_openWeblrPlayer:(SlikeConfig *)configModel myBundle:(NSBundle *)myBundle parent:(id)parent eventBlock:(onChange)block {
    
    if ([self isPlayerAlreadyExists:[SlikeWebPlayerViewController class]]) {
        [self playStreamWithExistInstance:configModel inParent:parent];
    } else {
        [self stopPlayer];
        self.slikePlayer = [[SlikeWebPlayerViewController alloc] initWithNibName:@"SlikeWebPlayer" bundle:myBundle];
        [_slikePlayer setNativeControl:false];
        
        [self initiatePlayerController:configModel inParent:parent withProgressHandler:block];
    }
}


- (void)_openDailyMotionPlayer:(SlikeConfig *)configModel myBundle:(NSBundle *)myBundle parent:(id)parent eventBlock:(onChange)block {
    
    if ([self isPlayerAlreadyExists:[DMMainViewController class]]) {
        [self playStreamWithExistInstance:configModel inParent:parent];
    } else {
        [self stopPlayer];
        self.slikePlayer = [[DMMainViewController alloc] initWithNibName:@"DMPlayerView" bundle:myBundle];
        [_slikePlayer setNativeControl:false];
        
        [self initiatePlayerController:configModel inParent:parent withProgressHandler:block];
    }
}

- (void)_openYoutubePlayer:(SlikeConfig *)configModel myBundle:(NSBundle *)myBundle parent:(id)parent eventBlock:(onChange)block {
    if ([self isPlayerAlreadyExists:[NewYTViewController class]]) {
        [self playStreamWithExistInstance:configModel inParent:parent];
    } else {
        [self stopPlayer];
        self.slikePlayer = [[NewYTViewController alloc] initWithNibName:@"NewYTView" bundle:myBundle];
        [self.slikePlayer setNativeControl:false];
        
        [self initiatePlayerController:configModel inParent:parent withProgressHandler:block];
    }
}

- (void)_openFacebookPlayer:(SlikeConfig *)configModel myBundle:(NSBundle *)myBundle parent:(id)parent eventBlock:(onChange)block {
    
    if ([self isPlayerAlreadyExists:[SlikeFBViewController class]]) {
        [self playStreamWithExistInstance:configModel inParent:parent];
    } else {
        [self stopPlayer];
        self.slikePlayer = [[SlikeFBViewController alloc] initWithNibName:@"SlikeFBView" bundle:myBundle];
        [self.slikePlayer setNativeControl:false];
        
        [self initiatePlayerController:configModel inParent:parent withProgressHandler:block];
    }
}
/**
 Play Stream the config file for the stream and play the current stream
 @param configModel -  Config file for Stream
 @param parent - Parent Window
 @param block  - Player Status Block
 */
- (void)_playVideoWithInfo:(SlikeConfig *)configModel inParent:(id)parent withProgressHandler:(onChange) block {
    
    BOOL isVideoIsDisabled = [self _checkIfVideoIsDisabledForCurrentRegion:configModel withParent:parent withBlock:block];
    
    if (isVideoIsDisabled) {
        return;
    }
    
    NSBundle *myBundle = [NSBundle slikeNibsBundle];
    if([configModel.streamingInfo hasVideo:VIDEO_SOURCE_FB]) {
        [self _openFacebookPlayer:configModel myBundle:myBundle parent:parent eventBlock:block];
    }
    else if([configModel.streamingInfo hasVideo:VIDEO_SOURCE_YT]) {
        [self _openYoutubePlayer:configModel myBundle:myBundle parent:parent eventBlock:block];
    }
    else if([configModel.streamingInfo hasVideo:VIDEO_SOURCE_DM]) {
        [self _openDailyMotionPlayer:configModel myBundle:myBundle parent:parent eventBlock:block];
    }
    else if([configModel.streamingInfo hasVideo:VIDEO_SOURCE_VEBLR]) {
        [self _openWeblrPlayer:configModel myBundle:myBundle parent:parent eventBlock:block];
    }
    else if([configModel.streamingInfo hasVideo:VIDEO_SOURCE_RUMBLE]) {
        [self _openRumblePlayer:configModel myBundle:myBundle parent:parent eventBlock:block];
    }
    else if((configModel.preferredVideoType == VIDEO_SOURCE_MEME) &&
       [configModel.streamingInfo hasVideo:VIDEO_SOURCE_MEME]) {
      [self _openMemePlayer:configModel myBundle:myBundle parent:parent eventBlock:block];
    }
    else if((configModel.preferredVideoType == VIDEO_SOURCE_GIF_MP4) && (
                                                                    [configModel.streamingInfo hasVideo:VIDEO_SOURCE_GIF_MP4] || [configModel.streamingInfo hasVideo:VIDEO_SOURCE_MP4])) {
        [self _openGIFPlayer:configModel myBundle:myBundle parent:parent eventBlock:block];
    }
    else {
        [self _openSlikePlayer:configModel myBundle:myBundle parent:parent eventBlock:block];
    }
}

/**
 We have already a valid instance. So there is no need to create a new istance.
 @param configModel - Config model
 @param parent - Parent
 */
- (void)playStreamWithExistInstance:(SlikeConfig *)configModel inParent:(id)parent {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self resetAlertView];
        self.requestInProcess = NO;
        [self.slikePlayer playMovieStreamWithObject:configModel withParent:parent];
    });
}
/**
 Is player Already exists for perticular type
 @param playerClass - Player class
 @return - YES|NO
 */
- (BOOL)isPlayerAlreadyExists:(Class)playerClass {
    if (self.slikePlayer && [self.slikePlayer isKindOfClass:[playerClass class]]) {
        return YES;
    }
    return NO;
}


/**
 Initialize the Player
 
 @param configModel - Config model
 @param parent  - Parent
 @param block - Completion Block
 */
- (void)initiatePlayerController:(SlikeConfig *)configModel inParent:(id)parent withProgressHandler:(onChange)block {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.requestInProcess = NO;
        NSDate *dt = [NSDate date];
        [self.slikePlayer setOnPlayerStatusDelegate:block];
        UIView *parevtView = (UIView *) parent;
        UIViewController *slikePlayerController = nil;
        if (self.slikePlayer && [self.slikePlayer isKindOfClass:[UIViewController class]]) {
            slikePlayerController = (UIViewController *)self.slikePlayer;
        } else {
            slikePlayerController = (UIViewController *)[self.slikePlayer getViewController];
        }
        id cntrlr = [self traverseResponderChainForUIViewController:parevtView];
        if(cntrlr){
            [(UIViewController *)cntrlr addChildViewController:slikePlayerController];
        }
        [self.slikePlayer setParentReference:parevtView];
        [parevtView addSubview:slikePlayerController.view];
        slikePlayerController.view.frame = CGRectMake(0, 0, parevtView.frame.size.width, parevtView.frame.size.height);
        
        [SlikeDeviceSettings sharedSettings].nPlayerLoadTime = [dt timeIntervalSinceNow] * -1000.0f;
        self.requestInProcess = NO;
        [self.slikePlayer playMovieStreamWithObject:configModel withParent:parent];
        if(cntrlr) {
            [slikePlayerController didMoveToParentViewController:(UIViewController *)cntrlr];
        }
        [SlikeDeviceSettings sharedSettings].playerParentViewController = cntrlr;
    });
}

/**
 Check if Video has Disabled for the current region
 
 @param configModel  - Slike Model
 @param parent - Parent View
 @param block - Completion Block
 @return - YES|NO
 */
- (BOOL)_checkIfVideoIsDisabledForCurrentRegion:(SlikeConfig *)configModel withParent:(id)parent withBlock:(onChange) block {
    
    BOOL isGeoAllowed = [[SlikeDeviceSettings sharedSettings] isGeoAllowed:configModel.gca GCB:configModel.gcb];
    
    if(!isGeoAllowed) {
        [self playVideoWithInfoWithError:configModel inParent:parent withProgressHandler:block withError:SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, WRONG_GEO)];
        if(block) {
            block(MEDIA, SL_ERROR, [StatusInfo initWithError:WRONG_GEO]);
        }
        return YES;
        
    } else if(configModel.errorMsg && [configModel.errorMsg length] >0) {
        
        [self playVideoWithInfoWithError:configModel inParent:parent withProgressHandler:block withError:SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, configModel.errorMsg)];
        
        if(block) {
            block(MEDIA, SL_ERROR, [StatusInfo initWithError:configModel.errorMsg]);
        }
        return YES;
    }
    return NO;
}

/**
 Prefetch the ads
 */
- (void)_prefetchAds {
    
    NSString *strBaseURL =  [[SlikeSharedDataCache sharedCacheManager]slikeBaseUrlString];
    NSString *downloadUrl = [NSString stringWithFormat:@"%@feed/playerconfig/%@/r001/%@.json", strBaseURL, @"beta", [[SlikeDeviceSettings sharedSettings] getKey]];
    SlikeDataProvider* dataProvider = [SlikeDataProvider  slikeDataProvider];
    [dataProvider downloadAndCacheConfigData:downloadUrl resultBlock:^(id response, NSError *errExists) {
        if (!errExists) {
            [[SlikeAdManager sharedInstance] showAd:nil adContainerView:nil forAdPosition:0];
        } else {
            SlikeDLog(@"ADS LOG: Something went wrong : Not able to get prefetch Ads");
        }
    }];
}

- (void)dealloc {
    SlikeDLog(@"dealloc- Cleaning up SlikePlayer");
}

/**
 Release SlikePlayer
 */
- (void)releaseSlikePlayer {
    
    if (self.slikePlayer) {
        
        [_slikePlayer removePlayer];
        self.slikePlayer = nil;
        _videoViewParent =  nil;
        _playlistArray = nil;
        if (self.callBackHandler) {
            self.callBackHandler = nil;
        }
        if (self.parentView) {
            self.parentView = nil;
        }
        [[SlikeSharedDataCache sharedCacheManager]resetCachedStreams];
    }
}


#pragma mark - Playlist Implementation
- (void)playVideoAtIndex:(NSInteger)currrentIndex inParentView:(UIView *)parent withProgressHandler:(onChange)stateBlock {
    
    //Stop the instance if already Exist
    self.callBackHandler = stateBlock;
    self.parentView = parent;
    _currentPlaylistIndex = currrentIndex;
    _nextCardIndex = currrentIndex;

    [[SlikeSharedDataCache sharedCacheManager]updatePlylistIndex:currrentIndex];
    SlikeConfig *slikeConfigModel = _playlistArray[currrentIndex];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self resetAlertView];
        [self playVideo:slikeConfigModel inParentView:parent withProgressHandler:stateBlock];
    });
}

/**
 Check whether the player has more than on vodeo streams to play
 @return -  YES  if it has next stream to play
 */
- (BOOL)_hasNextVideo {
    if(_playlistArray && _currentPlaylistIndex >= 0 && _currentPlaylistIndex < [_playlistArray count]-1) {
        return YES;
    }
    return NO;
}

/**
 Returns Next Slike Config Index
 @return - Valid Index  || -1
 */

- (NSInteger)nextSlikeConfigIndex {
    _slikePlayItemIndex = -1;
    if ([self _hasNextVideo]) {
        _currentPlaylistIndex += 1;
        _slikePlayItemIndex = 1;
        return _currentPlaylistIndex ;
    }
    return -1;
}

/**
 Returns Previous Slike Config Index
 @return - Valid Index  || -1
 */
- (NSInteger)previousSlikeConfigIndex {
    _slikePlayItemIndex = -1;

    if ([self _hasPreviousVideo]) {
        --_currentPlaylistIndex;
        _slikePlayItemIndex = 0;
        return _currentPlaylistIndex ;
    }
    return -1;
}

/**
 Check whether the player has more than on vodeo streams to play
 @return -  YES  if it has next stream to play
 */
- (BOOL)_hasPreviousVideo {
    if (_currentPlaylistIndex > 0 && _currentPlaylistIndex < [_playlistArray count] ) {
        return YES;
    }
    return NO;
}

- (SlikeConfig *)slikeConfigAtIndex:(NSInteger)indexPath {
    if (_playlistArray && [_playlistArray count]>0 && indexPath <[_playlistArray count]) {
        return _playlistArray[indexPath];
    }
    return nil;
}

#pragma mark - EventManagerProtocol
- (void)update:(SlikeEventType)eventType playerState:(SlikePlayerState)playbackState dataPayload:(NSDictionary *)payload slikePlayer:(id<ISlikePlayer>)player {
    
    if (eventType == MEDIA && [_playlistArray count]>0) {
        
        if (playbackState == SL_START) {
            _startObserving = YES;
        }
        if (playbackState == SL_COMPLETED && _startObserving) {
            
            _startObserving = NO;
            __block typeof(self) blockSelf = self;
            _startObserving = YES;
            [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:SL_HIDE_NEXT_PLAYLIST_DATA dataPayload:@{} slikePlayer:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (blockSelf.isMediaCompleted) {
                    return ;
                }
                
                if (!blockSelf.isMediaCompleted) {
                    blockSelf.isMediaCompleted = YES;
                    [self performSelector:@selector(preventRaceConditon) withObject:self afterDelay:1.5];
                }
                [self playNextVideoFromPlaylist];
            });
            
        } else if (playbackState == SL_NEXT || playbackState == SL_PREVIOUS) {
            //TODO:
            _startObserving = NO;
            [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:SL_HIDE_NEXT_PLAYLIST_DATA dataPayload:@{} slikePlayer:nil];
        }
        else {
            
            if (!_startObserving) {
                return;
            }
            
            NSInteger _playerCurrentPosition =-1;
            NSInteger _playerDuration =-1;
            
            NSNumber *currentPosition = [payload numberForKey:kSlikeCurrentPositionKey];
            if (currentPosition !=nil) {
                _playerCurrentPosition = [currentPosition integerValue]/1000;
            }
            
            NSNumber *duration = [payload numberForKey:kSlikeDurationKey];
            if (duration !=nil) {
                _playerDuration =   [duration integerValue]/1000;;
            }
            if (currentPosition && duration && _playerCurrentPosition >0  && _playerDuration>0) {
                NSInteger remaingTime = _playerDuration - _playerCurrentPosition;
                if (remaingTime <= _cardFecthTime  && remaingTime >0) {
//                    NSLog(@"NextVideo => %ld", (long)self->_currentPlaylistIndex);
//                    NSLog(@"NextVideo => Duration- %ld", _playerDuration);
//                    NSLog(@"NextVideo => Current- %ld", _playerCurrentPosition);
//                    
                    [self fetchNextStreamInfo];
                }
            }
        }
    }
}

- (void)playNextVideoFromPlaylist {
    
    NSInteger nextIndex = [self nextSlikeConfigIndex];
    if (nextIndex != -1) {
        SlikeConfig *slikeConfig = [self slikeConfigAtIndex:self.currentPlaylistIndex];
        if (slikeConfig.isAutoPlayNext) {
            //Stop the Current Instance. and Play the Next
            [[self getAnyPlayer]resetPlayer];
            [self playVideoAtIndex:nextIndex inParentView:self.parentView withProgressHandler:self.callBackHandler];
        }
        
    } else {
        [self showEndScreen];
    }
}

- (void)preventRaceConditon {
    _isMediaCompleted = FALSE;
}

- (void)showEndScreen {
}

- (void)fetchNextStreamInfo {
    if (_requestInProcess) {
        return;
    }
    
    _requestInProcess = YES;
    //Check if there is a next stream needs to download.
    if ([self _hasNextVideo]) {
        _nextCardIndex = _currentPlaylistIndex;
        _nextCardIndex +=1;
        
        SlikeConfig *nextConfigModel = [self slikeConfigAtIndex:_nextCardIndex];
        //Config data available. So need to download the Stream info
        
        BOOL isCached = [[SlikeSharedDataCache sharedCacheManager] isStreamAlreadyCached: nextConfigModel.mediaId];
        
        if (nextConfigModel) {
            if (nextConfigModel.streamingInfo) {
                [self dispatchNextVideoData:nextConfigModel];
            }
            else if (!nextConfigModel.streamingInfo && !isCached) {
                [self preDownloadStreamData:nextConfigModel forIndex:_nextCardIndex];
                
            }  else if (!nextConfigModel.streamingInfo && isCached) {
                [self prepareFromCache:nextConfigModel forIndex:_nextCardIndex];
            }
        }
    }
}

/**
 PreDownlaod the stream info
 @param nextConfigModel - Media id for which the stream info needs to download
 */
- (void)preDownloadStreamData:(SlikeConfig *)nextConfigModel forIndex:(NSInteger)nextIndex {
    
    __weak __typeof__(self) weakSelf = self;
    NSString * streamUrlString = @"";
    NSString *strBaseURL = [[SlikeSharedDataCache sharedCacheManager]slikeBaseUrlString];
    streamUrlString = [NSString stringWithFormat:@"%@feed/stream/%@/%@/%@/%@.json", strBaseURL, [nextConfigModel.mediaId substringWithRange:NSMakeRange(2, 2)], [nextConfigModel.mediaId substringWithRange:NSMakeRange(4, 2)], nextConfigModel.mediaId, nextConfigModel.mediaId];
    
    SlikeDataProvider* dataProvider = [SlikeDataProvider slikeDataProvider];
    [dataProvider downloadAndCacheStreamData:streamUrlString forMediaId:nextConfigModel.mediaId resultBlock:^(id responseObject, NSError *errExists) {
        if (!errExists) {
            [weakSelf prepareFromCache: nextConfigModel forIndex:nextIndex];
        }
    }];
}

- (void)prepareFromCache:(SlikeConfig *)nextConfigModel forIndex:(NSInteger)nextIndex {
    
    __weak __typeof__(self) weakSelf = self;
    SlikeDataProvider* dataProvider = [SlikeDataProvider slikeDataProvider];
    [dataProvider prepareSlikeConfigFromCache:nextConfigModel resultBlock:^(id responseObject, NSError *errExists) {
        if (!errExists) {
            SlikeConfig *config = [self slikeConfigAtIndex:nextIndex];
            if ([config.mediaId isEqualToString:nextConfigModel.mediaId] && [weakSelf.playlistArray count]>0) {
                
                [weakSelf.playlistArray replaceObjectAtIndex:nextIndex withObject:nextConfigModel];
                [self dispatchNextVideoData:nextConfigModel];
            }
        }
    }];
}


/**
 Skip the Current Video . It has some issue. No need to play this video.
 @param configModel - Config Model having some issues
 */
- (void)skipCurrentVideo:(SlikeConfig *)configModel {
    if ([self _hasNextVideo]) {
        if ([self nextSlikeConfigIndex] != -1) {
            _requestInProcess = NO;
            self.slikePlayItemIndex = -1;
            [self fetchNextStreamInfo];
        }
    }
}


/**
 Skip the video to Next | Previous video
 */
- (void)skipVideoToNextIndex {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.requestInProcess = NO;
        [[self getAnyPlayer] resetPlayer];
        NSInteger pickVideoIndex_ = -1;
        
        if (self.slikePlayItemIndex == 1) {
            pickVideoIndex_ = [self nextSlikeConfigIndex];
        } else if (self.slikePlayItemIndex == 0) {
            pickVideoIndex_ = [self previousSlikeConfigIndex];
        }
        
        SlikeConfig * slikeConfig = [self slikeConfigAtIndex:pickVideoIndex_];
        if (slikeConfig && pickVideoIndex_ != -1) {
            if (slikeConfig.isAutoPlayNext) {
                [self playVideoAtIndex:pickVideoIndex_ inParentView:self.parentView withProgressHandler:self.callBackHandler];
            }
        }
    });
}


/**
 Dispatch the info for the next Item
 @param nextSlikeConfig - Next Item Info
 */
- (void)dispatchNextVideoData:(SlikeConfig *)nextSlikeConfig {
    
    if (_nextCardIndex - _currentPlaylistIndex == 1) {
        
        BOOL isGeoAllowed = [[SlikeDeviceSettings sharedSettings] isGeoAllowed:nextSlikeConfig.gca GCB:nextSlikeConfig.gcb];
        
        if (!isGeoAllowed) {
            [self skipCurrentVideo:nextSlikeConfig];
            return;
        }
        
        [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:SL_SET_NEXT_PLAYLIST_DATA dataPayload:@{kSlikeConfigModelForNextItemKey: nextSlikeConfig} slikePlayer:nil];
    } else {
        self.requestInProcess = NO;
        SlikeDLog(@"NextVideo => next item is in-correct");
    }
}
/**
 Restet the playlist the contents
 */
- (void)resetPlaylist {
    [_playlistArray removeAllObjects];
    [SlikeSharedDataCache sharedCacheManager].cacahedPlaylist = nil;
}

- (void)getUpdatedSlikeConfigInfo:(SlikeConfig *)configModel  withProgressHandler:(onConfigUpdateChange) completionBlock
{
    [self downloadSlikeData:configModel resultBlock:^(id slikeResponseModel, NSError *parseError) {
        
       completionBlock(configModel, parseError);
    }];
}
@end

#pragma mark - SDK
@implementation SlikePlayerSettings {
    
}

/**
 Shared Instance of player class
 @return  - Shared Player instance
 */

+ (instancetype)playerSettingsInstance {
    
    static SlikePlayerSettings *sharedPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlayer = [[SlikePlayerSettings alloc] init];
    });
    return sharedPlayer;
}

- (id)init {
    if (self = [super init]) {
        _arrAnalyticsTrackers = [NSMutableArray array];
    }
    return self;
}

/**
 Initialise the player with Key and Device UID
 
 @param apiKey  - API key
 @param uuid - UUID
 @param isDebug - Is debug purpose
 */

- (void)initPlayerWithApikey:(NSString *)apiKey andWithDeviceUID:(NSString *)uuid debugMode:(BOOL)isDebug {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"saved_bitrate"]) [[SlikeDeviceSettings sharedSettings] setMediaBitrate:[defaults objectForKey:@"saved_bitrate"]];
    [[SlikeNetworkManager defaultManager] initWithApikey:apiKey andWithDeviceUID:uuid debugMode:isDebug];
    
    NSString *strBaseURL =  [[SlikeSharedDataCache sharedCacheManager]slikeBaseUrlString];
    NSString *downloadUrl = [NSString stringWithFormat:@"%@feed/playerconfig/%@/r001/%@.json", strBaseURL, @"beta", [[SlikeDeviceSettings sharedSettings] getKey]];
    SlikeDataProvider* dataProvider = [SlikeDataProvider  slikeDataProvider];
    [dataProvider downloadAndCacheConfigData:downloadUrl resultBlock:^(id response, NSError *errExists) {
        if (!errExists) {
            [[SlikeAdManager sharedInstance] showAd:nil adContainerView:nil forAdPosition:0];
        } else {
            SlikeDLog(@"ADS LOG: Something went wrong : Not able to get prefetch Ads");
        }
    }];
}

/**
 GDPAEnabledenable information
 
 @param isGDPREnabled value true if enable else false
 */
-(void)setGDPAEnabled:(BOOL)isGDPREnabled
{
    [SlikeSharedDataCache sharedCacheManager].isGDPREnable =  isGDPREnabled;
}

/**
 For internal invocation only.
 
 @param analyticsMode -  Mode type
 @param strId  - String Id
 */
- (void)initiateInternalAnalytics:(AnalyticMode) analyticsMode withID:(NSString *) strId {
    
    if(strId == nil) return;
    
    if(analyticsMode == AnalyticMode_GA) {
        
        Class myClass = NSClassFromString(@"GAController");
        if(myClass == nil) return;
        if(![myClass conformsToProtocol:@protocol(ISlikeAnlytics)]) return;
        id<ISlikeAnlytics> slikeAnalytics = [[myClass alloc] init];
        [slikeAnalytics setId:strId subId:nil Type:AnalyticMode_GA];
        [self addAnalyticsInternal:slikeAnalytics];
        
    } else if(analyticsMode == AnalyticMode_COMSCORE){
        
        Class myClass = NSClassFromString(@"ComScoreController");
        if(myClass == nil) return;
        if(![myClass conformsToProtocol:@protocol(ISlikeAnlytics)]) return;
        id<ISlikeAnlytics> slikeAnalytics = [[myClass alloc] init];
        [slikeAnalytics setId:strId subId:nil Type:AnalyticMode_COMSCORE];
        _slikeAnalyticsComScore = slikeAnalytics;
    }
}

/**
 Analytics Trackers
 @return - AnalyticsTrackers
 */
- (NSArray*) getAnalyticsTrackers {
    return _arrAnalyticsTrackers;
}

/**
 ComScore Analytics Trackers
 @return - ComScoreAnalyticsTrackers
 */
- (id<ISlikeAnlytics>) getComScoreAnalyticsTrackers {
    return _slikeAnalyticsComScore;
}

/**
 Add the Analytics info - Only for internal purpose
 @param slikeAnalytics -
 */
- (void)addAnalyticsInternal:(id <ISlikeAnlytics>) slikeAnalytics {
    
    if(slikeAnalytics != nil) {
        
        id <ISlikeAnlytics> slikeAnalyticsInfo;
        BOOL isAlreadyAdded =  NO;
        for(slikeAnalyticsInfo in _arrAnalyticsTrackers) {
            if([[slikeAnalyticsInfo getId] isKindOfClass:[NSString class]] && [[slikeAnalytics getId] isEqualToString:[slikeAnalyticsInfo getId]]) {
                isAlreadyAdded = YES;
            }
        }
        
        if(!isAlreadyAdded) {
            [_arrAnalyticsTrackers addObject:slikeAnalytics];
        } else {
            SlikeDLog(@"[Slike Error: #Warning, This Tracker is already added]");
        }
    }
}

/**
 Set the ids for tracking the evnets

 */
- (void)setIdsForAnalyticsEvents:(NSString *)gaId withCS_publisherId:(NSString*)cs_publisherId
{
    if(gaId && gaId!=nil && [gaId length]>0) {
        [self initiateInternalAnalytics:AnalyticMode_GA withID:gaId];
    }
    
    if(cs_publisherId && cs_publisherId!=nil && [cs_publisherId length]>0) {
        [self initiateInternalAnalytics:AnalyticMode_COMSCORE withID:cs_publisherId];
    }
}

/**
 Add the Analytics Info
 @param slikeAnalytics -
 */
- (void)addAnalytics:(id <ISlikeAnlytics>) slikeAnalytics {
    
    if(_arrAnalyticsTrackers.count>4) {
        return;
    }
    
    if(slikeAnalytics != nil) {
        
        id <ISlikeAnlytics> slikeAnalyticsInfo;
        BOOL isAlreadyAdded =  NO;
        
        for(slikeAnalyticsInfo in _arrAnalyticsTrackers) {
            
            if([[slikeAnalyticsInfo getId] isKindOfClass:[NSString class]] && [[slikeAnalytics getId] isEqualToString:[slikeAnalyticsInfo getId]]) {
                isAlreadyAdded = YES;
                
            } else if ([_arrAnalyticsTrackers containsObject:slikeAnalyticsInfo]) {
                isAlreadyAdded = YES;
            }
        }
        
        if(!isAlreadyAdded) {
            [_arrAnalyticsTrackers addObject:slikeAnalytics];
        } else {
            SlikeDLog(@"[Slike Error: #Warning, This Tracker is already added]");
        }
    }
}

@end

