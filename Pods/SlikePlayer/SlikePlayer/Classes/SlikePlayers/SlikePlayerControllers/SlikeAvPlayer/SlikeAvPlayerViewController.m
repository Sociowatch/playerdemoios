//
//  SlikeAvPlayerViewController.m
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 30/05/18.
//
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SlikeAvPlayerViewController.h"
#import "SlikeTapGestureRecognizer.h"
#import "SlikePlayerConstants.h"
#import "PlayerView.h"
#import "SlikePlayer.h"
#import "SlikeAvPlayerViewController+Helper.h"
#import "NSBundle+Slike.h"
#import "NSString+Advanced.h"
#import "SlikeServiceError.h"
#import "EventManager.h"
#import "EventManagerProtocol.h"
#import "SlikeMediaPlayerControl.h"
#import "NSDictionary+Validation.h"
#import "SlikeGestureUI.h"
#import "SlikeNetworkMonitor.h"
#import "SlikePlayerErrorView.h"
#import "UIView+SlikeAlertViewAnimation.h"
#import "SlikeGlobals.h"
#import "SlikeStringCommon.h"
#import "SlikeSharedDataCache.h"
#import "SlikeAdManager.h"
#import "EventModel.h"
#import "SlikeVideoPlayerRegistrar.h"
#import "SlikeBitratesModel.h"
#import "SlikeMaterialDesignSpinner.h"
#import "SlikeBitratesView.h"
#import "SlikeMediaPreview.h"
#import "UIImageView+SlikePlaceHolderImageView.h"
#import "SlikeVCRotationManager.h"
#import "SlikeOrientationObserver.h"

@interface SlikeAvPlayerViewController () <EventManagerProtocol, SJRotationManagerDelegate> {
    id _playerContainer;
}

@property (nonatomic, readwrite) BOOL hasPlayerObserverAdded;
@property (nonatomic, readwrite) BOOL isFullScreen;
@property (nonatomic, readwrite) BOOL isUserPaused;
@property (nonatomic, readwrite) BOOL isVideoSeen;
@property (nonatomic, readwrite) BOOL isUserSeeked;
@property (nonatomic, readwrite) BOOL isPlaybackDone;
@property (nonatomic, readwrite) BOOL isPlayerLoaded;
@property (nonatomic, readwrite) BOOL isBitrateSelect;
@property (nonatomic, readwrite) BOOL isNetworkWindowPresented;
@property (nonatomic, readwrite) BOOL isCurrentlyAdPlaying;
@property (nonatomic, readwrite) BOOL hasPostRollCompleted;
@property (nonatomic, readwrite) BOOL isMediaReStart;
@property (nonatomic, readwrite) BOOL isAutoPlayEnable;
@property (nonatomic, readwrite) BOOL isAppEnteredInBackground;
@property (nonatomic, assign) NSInteger mediaStartTime;
@property (nonatomic, assign) NSInteger cromeCastSeekTime;
@property (nonatomic, assign) NSInteger nTimeCode;
@property (nonatomic, assign) NSInteger nBufferTime;
@property (nonatomic, assign) float nLoadTimeRange;
@property (nonatomic, strong) NSString *strNewURL;
@property (nonatomic, assign) SlikePlayerState playerCurrentState;
@property (nonatomic, strong) StatusInfo *progressInfo;
@property (nonatomic, strong) SlikeGestureUI *slikeGestureUI;
@property (nonatomic, strong) SlikePlayerErrorView *slikeAlertView;
@property (nonatomic, strong) SlikeVideoPlayerRegistrar *playerRegistrar;
@property (nonatomic, strong) UIView *adPlayerView;
@property (nonatomic, weak) IBOutlet SlikeMaterialDesignSpinner *loadingIndicator;
@property (nonatomic, strong) SlikeBitratesView *bitratesView;
@property (nonatomic, weak)  UIView * parentReferenceView;
@property (nonatomic, strong) SlikeVCRotationManager *vcRotationManager;
@property (nonatomic, strong) SlikeOrientationObserver *orentationObserver;

@end

@implementation SlikeAvPlayerViewController
@synthesize isAppActive;
@synthesize isAppAlreadyDestroyed;
@synthesize slikeConfig;

#pragma mark - View Life cylcle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _addConfiguration];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)_addConfiguration {
    
    self.isUserPaused = NO;
    [self _addEventsObservers];
    [self _addOrientationObserver];
    
    //Register the class for listening the events
    [[EventManager sharedEventManager]registerEvent:self];
    _playerCurrentState = SL_STATE_NONE;
}

- (void)resetVariables {
    
    self.isUserPaused =NO;
    _isVideoSeen = NO;
    _isUserSeeked = NO;
    _isPlaybackDone = NO;
    _isPlayerLoaded = NO;
    _isBitrateSelect = NO;
    _isNetworkWindowPresented = NO;
    _isCurrentlyAdPlaying = NO;
    _hasPostRollCompleted = NO;
    _isMediaReStart =NO;
    _isAutoPlayEnable = NO;
    _mediaStartTime = 0.0;
    _cromeCastSeekTime = 0;
    _nTimeCode =0;
    _nBufferTime = 0;
    _nLoadTimeRange =0.0;
    _strNewURL = @"";
    _playerCurrentState = SL_STATE_NONE;
    _progressInfo = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (BOOL)prefersHomeIndicatorAutoHidden{
    return true;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //Notifies UIKit that your view controller updated its preference
    if (@available(iOS 11.0, *)) {
        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
}

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
            [self updateGestureActons:playerState dataPayload:payload];
            
        } else  if (eventType == CONTROLS) {
            [self updateControlActons:playerState dataPayload:payload];
            
        } else if(eventType == MEDIA) {
            [self updateMediaActons:playerState dataPayload:payload];
            
        } else if(eventType == AD) {
            
            if (playerState == SL_CONTENT_RESUME) {
                
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
 Update the Media Action
 
 @param state -  Player State
 @param payload - Data Payload
 */
- (void)updateMediaActons:(SlikePlayerState)state dataPayload:(NSDictionary *)payload {
    
    if(state == SL_START) {
        self.isMediaReStart =  NO;
        [self setVideoPlaceHolder:NO];
        
    } else  if(state == SL_COMPLETED) {
        [self setVideoPlaceHolder:YES];
        [self.view bringSubviewToFront:self.slikeConfig.customControls];
        self.isMediaReStart =  YES;
        
    } else if(state == SL_REPLAY) {
        
    } else if (state == SL_PLAY) {
        if ([[SlikeNetworkMonitor sharedSlikeNetworkMonitor] isNetworkReachible]) {
            [self removeErrorAlert];
        }
    } else if (state == SL_PLAYING) {
        //self.posterImage.alpha = 0.0;
        // TO DO :: Playing come after network --
        //        if ([[SlikeNetworkMonitor sharedSlikeNetworkMonitor] isNetworkReachible]) {
        //            [self removeErrorAlert];
        //        }
    }
}

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
 Update the Gesture action
 
 @param state - Player State
 @param payload - Payload data
 */
- (void)updateGestureActons:(SlikePlayerState)state dataPayload:(NSDictionary *)payload {
    
    if(state == SL_SEEKING || state == SL_SEEKED) {
        if(state == SL_SEEKING) {
            // [self pause:NO];
        } else {
            float seekedPositionInt =  0;
            NSNumber *seek_progress = [payload numberForKey:kSlikeSeekProgressKey];
            if (seek_progress !=nil) {
                seekedPositionInt =  [seek_progress floatValue];
            }
            float nPosition = seekedPositionInt;
            __weak typeof(self) weekSelf = self;
            [self _seekTo:nPosition userSeeked:YES completionBlock:^(BOOL finished) {
                [weekSelf play:NO];
            }];
            
        }
    }
}

/**
 Update the controls actions
 
 @param state - Player Action
 @param payload - Payload data
 */
- (void)updateControlActons:(SlikePlayerState)state dataPayload:(NSDictionary *)payload {
    
    if(state == SL_PLAY) {
        
        BOOL isUserInisiated = [payload boolForKey:kSlikePlayPauseByUserKey];
        if([self isPlaying]) {
            [self pause:isUserInisiated];
            
        } else {
            
            if(self.slikeConfig.streamingInfo.isLive) {
                __weak typeof(self) weekSelf = self;
                [self _seekTo:MAXFLOAT userSeeked:NO completionBlock:^(BOOL finished) {
                    [weekSelf play:isUserInisiated];
                }];
                
            } else {
                [self play:isUserInisiated];
            }
        }
        
    } else if(state == SL_SEEKING || state == SL_SEEKED || state ==  SL_SEEKPOSTIONUPDATE) {
        
        if(state == SL_SEEKPOSTIONUPDATE) {
            
            float seekedPositionInt =  0;
            NSNumber *seek_progress = [payload numberForKey:kSlikeSeekProgressKey];
            if (seek_progress !=nil) {
                seekedPositionInt =  [seek_progress floatValue];
            }
            float nPosition = [self getDuration]*seekedPositionInt/1000;
            NSUInteger currentPosition =nPosition*1000;
            NSUInteger duration = [self getDuration];
            NSDictionary *playerData = @{kSlikeCurrentPositionKey:@(currentPosition), kSlikeDurationKey:@(duration)};
            
            [self _sendPlayerStatus:SL_SEEKPOSTIONUPDATE withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:playerData];
            
        }
        else if(state == SL_SEEKING) {
            // [self pause:NO];
        } else {
            
            float seekedPositionInt =  0;
            NSNumber *seek_progress = [payload numberForKey:kSlikeSeekProgressKey];
            if (seek_progress !=nil) {
                seekedPositionInt =  [seek_progress floatValue];
            }
            float nPosition = [self getDuration]*seekedPositionInt/1000;
            NSUInteger currentPosition =nPosition*1000;
            NSUInteger duration = [self getDuration];
            NSDictionary *playerData = @{kSlikeCurrentPositionKey:@(currentPosition), kSlikeDurationKey:@(duration)};
            
            [self _sendPlayerStatus:SL_SEEKPOSTIONUPDATE withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:playerData];
            
            __weak typeof(self) weekSelf = self;
            [self _seekTo:nPosition userSeeked:YES completionBlock:^(BOOL finished) {
                [weekSelf play:NO];
            }];
        }
        
    } else  if(state ==  SL_REPLAY) {
        
        if (![[SlikeNetworkMonitor sharedSlikeNetworkMonitor] isNetworkReachible]) {
            [self _showAlertViewForOffline:YES];
            [self _sendNetworkErrorMessage];
            return;
        }
        
        [self replay];
        
    } else if(state == SL_SHARE)
    {
        [self updateShareCallBack];
        
    }
    else if(state == SL_QUALITYCHANGECLICKED) {
        [self showBitrateChooser:NO];
        
    } else if(state == SL_FULLSCREENCLICKED) {
        [self toggleFullScreen];
        
    }  else if(state == SL_PAUSE) {
        [self pause:NO];
    }
}

/**
 Update share call back
 */
- (void)updateShareCallBack {
    
    /* if (self.slikeConfig.shareText && self.slikeConfig.shareText.length ==0){
     //Parent send call back-
     } else {
     //Do the share controlls-
     //create a message
     NSString *theMessage = self.slikeConfig.shareText;
     NSArray *items = @[theMessage];
     
     // build an activity view controller
     UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
     // and present it
     [self presentActivityController:controller];
     }*/
}

/**
 Present share activity
 @param controller - Controller
 */
-  (void)presentActivityController:(UIActivityViewController *)controller {
    
    /*
     [self pause:NO];
     // for iPad: make the presentation a Popover
     controller.modalPresentationStyle = UIModalPresentationPopover;
     [self presentViewController:controller animated:YES completion:nil];
     
     UIPopoverPresentationController *popController = [controller popoverPresentationController];
     popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
     popController.barButtonItem = self.navigationItem.leftBarButtonItem;
     
     // access the completion handler
     controller.completionWithItemsHandler = ^(NSString *activityType,
     BOOL completed,
     NSArray *returnedItems,
     NSError *error){
     // react to the completion
     [self play:NO];
     if (error) {
     SlikeDLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
     }
     };*/
}

- (void)_applicationPresenceState {
    
    if([self.slikeConfig.streamingInfo hasVideo:AUDIO_SOURCE_MP3] || !self.slikeConfig)
    {
        return;
    }
    _playerRegistrar = [[SlikeVideoPlayerRegistrar alloc]init];
    __weak typeof(self) weekSelf = self;
    [_playerRegistrar setWillResignActive:^(SlikeVideoPlayerRegistrar * _Nonnull registrar) {
        if ([weekSelf isAdPlaying]) {
            return;
        }
        //If Video is in playing mode then need to pause the video
        if([weekSelf isPlaying] && !weekSelf.isNetworkWindowPresented) {
            [weekSelf pause:NO];
        }
    }];
    
    [_playerRegistrar setDidBecomeActive:^(SlikeVideoPlayerRegistrar * _Nonnull registrar) {
        [weekSelf.playerView addPlayerObservers];
        if ([weekSelf isAdPlaying]) {
            return;
        }
        
        if (weekSelf.isAppEnteredInBackground && ![[SlikeNetworkMonitor sharedSlikeNetworkMonitor] isNetworkReachible]) {
            
            [weekSelf _showAlertViewForOffline:YES];
            weekSelf.isAppEnteredInBackground = NO;
            [weekSelf _sendNetworkErrorMessage];
            return;
        }
        
        //User has not paused the video and network window is not presented then only need to play the video
        if(self.isAutoPlayEnable && !weekSelf.isUserPaused && !weekSelf.isNetworkWindowPresented && !self.isPlaybackDone) {
            [weekSelf play:NO];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weekSelf _hideWaitingIndicator];
            });
        }
    }];
    
    [_playerRegistrar setWillEnterForeground:^(SlikeVideoPlayerRegistrar * _Nonnull registrar) {
        [weekSelf.playerView addPlayerObservers];
        if(weekSelf.isNetworkWindowPresented) {
            [weekSelf setVideoPlaceHolder:YES];
        }
    }];
    
    [_playerRegistrar setDidEnterBackground:^(SlikeVideoPlayerRegistrar * _Nonnull registrar) {
        weekSelf.isAppEnteredInBackground = YES;
        
    }];
    
}

/**
 Is orientation is enabled from the config class
 @return - BOOL
 */
- (BOOL)isAllowDeviceOrientation {
    if (self.slikeConfig) {
        if (self.slikeConfig.autorotationMode == SlikeFullscreenAutorotationModeLandscape) {
            return YES;
        }
        return NO;
    }
    return YES;
}

#pragma mark- Observers Imlementaion
- (void)hideBitrateChooser {
}

/**
 Add observer to listen the player events
 */
- (void)_addEventsObservers {
    if(_hasPlayerObserverAdded) return;
    [self registerPlayerObservers];
    _hasPlayerObserverAdded = YES;
}

/**
 Detach the observer to listen the player events
 */
- (void)_removeEventsObservers {
    if(!_hasPlayerObserverAdded) return;
    [self unRegisterPlayerObservers];
    _hasPlayerObserverAdded = NO;
}

#pragma mark - iSlikePlayer
- (NSUInteger)getPosition {
    return [self.playerView getPlayerPosition];
}

- (NSUInteger)getDuration {
    return [self.playerView getPlayerDuration];
}

- (NSUInteger) getBufferTime {
    return _nBufferTime;
}

- (float)getLoadTimeRange {
    return _nLoadTimeRange;
}

- (SlikePlayerState)getStatus {
    return _playerCurrentState;
}

- (void)viewWillEnterForeground {
    self.isAppActive = YES;
}

- (void)viewWillEnterBackground
{
    self.isAppActive = NO;
}

- (void)play:(BOOL)isUserInitiated {
    
    if (!_isAutoPlayEnable) {
        //Make the variable TRUE so that it should be called only on startup
        _isAutoPlayEnable = YES;
        if (self.slikeConfig.isSkipAds || self.slikeConfig.isPrerollEnabled == OFF || self.slikeConfig.ispr) {
            [self _startMediaStream];
        } else {
            //Play the Stream After the PreRoll Ads
            [self _requestAdForPosition:0];
        }
    }
    else {
        
        if(_isUserPaused && !isUserInitiated) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playerView play];
            self.isUserPaused = NO;
        });
    }
}

/**
 Pause the video
 @param isUserInitiated - Action is performed by the  user or auto
 */
- (void)pause:(BOOL)isUserInitiated {
    if(_isUserPaused) return;
    self.isUserPaused = isUserInitiated;
    [self.playerView pause];
}

/**
 Resume the Player
 */
- (void)resume {
    [self play:NO];
}

/**
 Is Media is in playing mode
 @return - BOOL
 */
- (BOOL)isPlaying {
    return  [self.playerView isPlaying];
}

/**
 Replay the Current Media
 */
- (void)replay {
    [self restartMoviePlay];
}

/**
 Seek the Media to spacif position
 
 @param nPosition - Position
 @param isUserInitiated - Action is performed by the  user or auto
 */
- (void)seekTo:(float)nPosition userSeeked:(BOOL)isUserInitiated {
    [self _seekTo:nPosition userSeeked:isUserInitiated completionBlock:nil];
}

/**
 Restart the current  Media
 */
- (void)restartMoviePlay {
    
    SlikeDLog(@"AV PLAYER LOG: replaying the play.");
    
    _isUserSeeked = NO;
    _mediaStartTime = 0;
    //Reset analytics values
    self.playerView.nCurrentTime = 0;
    
    __weak typeof(self) weekSelf = self;
    [weekSelf.playerView restart:_mediaStartTime completionBlock:^(BOOL finished) {
        
        [weekSelf _sendPlayerStatus:SL_REPLAY withUserBehavior:SlikeUserBehaviorEventReplay withError:nil withPayload:@{}];
        [weekSelf _sendPlayerStatus:SL_START withUserBehavior:SlikeUserBehaviorEventReplay withError:nil withPayload:@{}];
        [weekSelf _sendStatusToControls:SL_SHOWCONTROLS];
        //Set this
        weekSelf.isVideoSeen = NO;
        weekSelf.isPlaybackDone =  NO;
        weekSelf.isPlayerLoaded = YES;
        [weekSelf play:NO];
    }];
}

/**
 Seek the Media to spacif position
 
 @param nPosition - Position
 @param isUserInitiated - Action is performed by the  user or auto
 @param completionHandler - Completion handler
 */

- (void)_seekTo:(float)nPosition userSeeked:(BOOL)isUserInitiated completionBlock:(void (^ __nullable)(BOOL finished))completionHandler {
    
    __weak typeof(self) weekSelf = self;
    if(![self.playerView isPlayerExist]) {
        
        _isUserSeeked = NO;
        _mediaStartTime = 0;
        self.playerView.nCurrentTime = 0;
        [self.playerView restart:_mediaStartTime completionBlock:^(BOOL finished) {
            [self.playerView seekPlayerToTime:CMTimeMakeWithSeconds(weekSelf.mediaStartTime, NSEC_PER_SEC) fastSeek:YES completionBlock:nil];
            weekSelf.cromeCastSeekTime = nPosition;
            [self performSelector:@selector(seeekVideoWithDelay) withObject:self afterDelay:1];
            
            if (completionHandler) {
                completionHandler(finished);
            }
            
        }];
    } else {
        
        _isUserSeeked = isUserInitiated;
        [self.playerView seekPlayerToTime:CMTimeMakeWithSeconds(nPosition, NSEC_PER_SEC) fastSeek:FALSE completionBlock:^(BOOL finished) {
            
            if(self.isPlaybackDone) {
                weekSelf.isVideoSeen = NO;
                weekSelf.isPlaybackDone =  NO;
                weekSelf.isPlayerLoaded = YES;
                [weekSelf _sendPlayerStatus:SL_START withUserBehavior:SlikeUserBehaviorEventSeek withError:nil withPayload:@{}];
            }
            
            if (completionHandler) {
                completionHandler(finished);
            }
        }];
    }
}

/**
 Seek  the media with Delay
 */
- (void)seeekVideoWithDelay {
    [self _seekTo:_cromeCastSeekTime userSeeked:NO completionBlock:nil];
}
/**
 Is  media in FullScreen Mode
 @return - BOOL
 */
- (BOOL)isFullScreen {
    return _isFullScreen;
}

/**
 Toogle Media Orientation
 */
- (void)toggleFullScreen {
    [self toggleFullscreen:YES];
}

/**
 Is Player exists
 @return -  BOOL
 */
- (BOOL)isPlayerExist {
    return ([self.playerView isPlayerExist]);
}

/**
 Stop the Player
 */
- (void)stop {
    [self.playerView stopVideo:YES];
    self.slikeConfig.streamingInfo = nil;
}

/**
 Mute the Current Player
 @param isMute - BOOL
 */
- (void)playerMute:(BOOL)isMute {
    [self.playerView playerMute:isMute];
}

/**
 Get Mute status of the player
 @return - BOOL
 */
- (BOOL)getPlayerMuteStatus {
    return [self.playerView getPlayerMuteStatus];
}

/**
 Get the current Controller which is used by media to play
 @return - instance of class
 */
- (instancetype)getViewController {
    return self;
}

/**
 Set the parent Reference
 @param parentView - Parent View
 */
- (void)setParentReference:(UIView *) parentView {
    _parentReferenceView = parentView;
}

/**
 Set the custom controller that will be used to show the controlls
 @param control - Controlls instance
 */
- (void)setController:(id<ISlikePlayerControl>) control {
}

/**
 Get controlls instance
 @return - Instance
 */
- (id<ISlikePlayerControl>)getControl {
    return nil;
}

/**
 Bitrates can be shown
 @return _ BOOL
 */
- (BOOL)canShowBitrateChooser {
    return NO;
}

/**
 Show the bitrates chooser
 @param isCustom - isCustom
 @return - Array of bitrates
 */
- (NSArray*)showBitrateChooser:(BOOL)isCustom {
    
    if(isCustom) {
        return [self.slikeConfig.streamingInfo getVideosListByType:[self.slikeConfig.streamingInfo getCurrentVideoSource]];
    } else {
        [self showBitratesPopup];
        return nil;
    }
}

/**
 Get the current Bitrate String
 @return - Bitrate|nil
 */
- (NSString *)currentBitRateURI {
    if(self.playerView) {
        return [self.playerView currentPlaybackItemURI];
    }
    return nil;
}

-(void)setNativeControl:(BOOL) isNative {
    //self.isNativeControls = isNative;
}

-(BOOL)isAdPlaying {
    return _isCurrentlyAdPlaying;
}

- (void)setCast:(id<ISlikeCast>)cast {
    self.slikeCast = cast;
}

- (id<ISlikeCast>)getCast {
    return self.slikeCast;
}

/**
 Reset the player basic information
 */
-(void)releasePlayerInformation {
    [self resetPlayerdata];
}

/**
 Reset the player data only
 */
- (void)resetPlayerdata {
    if(self.playerView) {
        [self.playerView resetPlayerForNextPlay];
    }
    self.slikeConfig = nil;
    _isPlaybackDone = NO;
}

/**
 Stop the video .
 @param completed - Completion events
 */
- (void)stopVideoWithCompletion:(BOOL)completed {
    
    if(!completed) {
        
        SlikeDLog(@"AV PLAYER LOG:stopVideoWithCompletion - With Error");
        NSDictionary *payload =  [NSDictionary dictionaryWithObjectsAndKeys:@"playback error",@"Error", nil];
        _playerCurrentState = SL_COMPLETED;
        [self _sendPlayerStatus:_playerCurrentState withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:payload];
    } else {
        
        SlikeDLog(@"AV PLAYER LOG:stopVideoWithCompletion - Without Error");
        
        _playerCurrentState = SL_COMPLETED;
        NSUInteger duration = [self getDuration];
        NSDictionary *playerData = @{kSlikeCurrentPositionKey:@(duration), kSlikeDurationKey:@(duration)};
        
        [self _sendPlayerStatus:_playerCurrentState withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:playerData];
        
        [self setVideoPlaceHolder:YES];
        [self _sendStatusToControls:SL_SHOWCONTROLS];
        [self.view bringSubviewToFront:self.slikeConfig.customControls];
    }
}

/**
 Show the error and stop the current Media
 @param err - Error
 */
- (void)errorAndStopMovie:(NSError *) err {
    [SlikeUtilities showAlert:@"" withTitle:@"Playback failed" withController:self];
    //[self stopVideoWithCompletion:NO];
}

#pragma mark - Notification Receiver
- (void)receiveNotifications:(NSNotification *)notification {
    SlikeDLog(@"AV PLAYER LOG: Current Notification  %@",notification.name);
    
    if([notification.name isEqualToString:SlikePlayerPlaybackStateStartNotification]) {
        [self _startMediaStream];
        
    } else if([notification.name isEqualToString:SlikePlayerPlaybackStateReadyNotification]){
        
        //Notification will be called on Startup/Bitrate Changed
        NSUInteger currentPosition = [self getPosition];
        NSUInteger duration = [self getDuration];
        NSDictionary *playerData = @{kSlikeCurrentPositionKey:@(currentPosition), kSlikeDurationKey:@(duration)};
        
        if(!_isPlayerLoaded) {
            _isPlayerLoaded = YES;
            
            [self _sendPlayerStatus:SL_LOADED withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:playerData];
            [self _readyMediaStream];
        }
        
        [self _layoutPlayerIfNeeded];
        
    } else if([notification.name isEqualToString:SlikePlayerPlaybackStateSeekUpdateNotification]) {
        
        [self _sendStatusToControls:SL_QUALITYCHANGED];
        [self _sendStatusToControls:SL_SHOWCONTROLS];
        [self _sendStatusToControls:SL_RESETCONTROLS];
        [self setVideoPlaceHolder:NO];
        [self play:NO];
        
        
    } else if([notification.name isEqualToString:SlikePlayerPlaybackStatePlayNotification]) {
        
        _playerCurrentState = SL_PLAY;
        
        NSUInteger currentPosition = [self getPosition];
        NSUInteger duration = [self getDuration];
        NSDictionary *playerData = @{kSlikeCurrentPositionKey:@(currentPosition), kSlikeDurationKey:@(duration)};
        
        [self _sendPlayerStatus:_playerCurrentState withUserBehavior:_isUserPaused?SlikeUserBehaviorEventPlay:SlikeUserBehaviorEventNone withError:nil withPayload:playerData];
        
    } else if([notification.name isEqualToString:SlikePlayerPlaybackStatePauseNotification]) {
        
        _playerCurrentState = SL_PAUSE;
        
        NSUInteger currentPosition = [self getPosition];
        NSUInteger duration = [self getDuration];
        NSDictionary *playerData = @{kSlikeCurrentPositionKey:@(currentPosition), kSlikeDurationKey:@(duration)};
        
        //Dispatching the events
        [self _sendPlayerStatus:_playerCurrentState withUserBehavior:_isUserPaused?SlikeUserBehaviorEventPause:SlikeUserBehaviorEventNone withError:nil withPayload:playerData];
        
    } else if([notification.name isEqualToString:SlikePlayerPlaybackStateBufferingNotification]) {
        
        if(_isUserPaused) return;
        if(!self.slikeConfig.isAutoPlay && !_isAutoPlayEnable){
            return;
        }
        _playerCurrentState = SL_BUFFERING;
        [self _sendPlayerStatus:_playerCurrentState withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:@{}];
        _nBufferTime += 1000;
        
    } else if([notification.name isEqualToString:SlikePlayerPlaybackStateBufferingEndedNotification]) {
        SlikeDLog(@"AV PLAYER LOG: Ended Buffering Notification");
        _playerCurrentState = SL_BUFFERING;
        [self _sendPlayerStatus:_playerCurrentState withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:@{kSlikeBufferingEndedKey: @(YES)}];
        
    } else if([notification.name isEqualToString:SlikePlayerPlaybackStateStopNotification]) {
        //        _playerCurrentState = SL_ENDED;
        //        //Send the Event for analytics
        //        [self _sendPlayerStatus:_playerCurrentState withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:@{}];
        
        
    } else if([notification.name isEqualToString:SlikePlayerPlaybackStateSeekStartNotification]) {
        _playerCurrentState = SL_SEEKING;
        if (_isUserSeeked) {
            [self _sendPlayerStatus:_playerCurrentState withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:@{}];
            return;
        }
        
    } else if([notification.name isEqualToString:SlikePlayerPlaybackStateSeekEndNotification]) {
        _playerCurrentState = SL_SEEKED;
        if(_isUserSeeked) {
            [self setVideoPlaceHolder:NO];
            [self _sendPlayerStatus:_playerCurrentState withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:@{}];
            return;
        }
    } else if([notification.name isEqualToString:SlikePlayerPlaybackStateSeekFailedNotification]) {
        
        
    } else if([notification.name isEqualToString:SlikePlayerPlaybackStateFullScreenNotification]) {
        _playerCurrentState = [self isFullScreen] ?SL_FSENTER :SL_FSEXIT;
        
        if ([self isFullScreen]) {
            [self _sendPlayerStatus:_playerCurrentState withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:@{}];
            
        } else {
            [self _sendPlayerStatus:_playerCurrentState withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:@{}];
        }
        
    } else if([notification.name isEqualToString:SlikePlayerLoadedTimeRangesNotification]) {
        
        _playerCurrentState = SL_TIMELOADRANGE;
        if([notification.userInfo objectForKey:@"loadTime"] && [[notification.userInfo objectForKey:@"loadTime"] intValue] >0) {
            self.nLoadTimeRange = [[notification.userInfo objectForKey:@"loadTime"] floatValue];
            NSUInteger duration = [self getDuration];
            NSDictionary *playerData = @{kSlikeBufferPositionKey:@(self.nLoadTimeRange), kSlikeDurationKey:@(duration)};
            NSInteger timeRange = self.nLoadTimeRange/1000;
            if (timeRange >= self.slikeConfig.previewsDndStartTime && !self.slikeConfig.streamingInfo.isLive) {
                [self downloadStreamTitledImage];
            }
            
            //Dispatching the events
            [self _sendPlayerStatus:_playerCurrentState withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:playerData];
        }
        
    } else if([notification.name isEqualToString:SlikePlayerPlaybackStateFinishedNotification]) {
        
        [self _removeBiratesUI];
        _isPlayerLoaded = NO;
        _isPlaybackDone = YES;
        
        /*
         _playerCurrentState = SL_COMPLETED;
         NSUInteger duration = [self getDuration];
         NSDictionary *playerData = @{kSlikeCurrentPositionKey:@(duration), kSlikeDurationKey:@(duration)};
         [self _sendPlayerStatus:_playerCurrentState withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:playerData];
         */
        [self _sendPlayerStatus:SL_VIDEO_COMPLETED withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:@{}];
        
        if (!_hasPostRollCompleted && !self.slikeConfig.isSkipAds && self.slikeConfig.isPostrollEnabled == ON && !self.slikeConfig.ispr) {
            [self _sendStatusToControls:SL_HIDECONTROLS];
            [self _requestAdForPosition:-1];
        } else {
            [self stopVideoWithCompletion:YES];
        }
        
    } else if([notification.name isEqualToString:SlikePlayerPlaybackStatePlaybackErrorNotification]) {
        
        NSError *playingError = [notification.userInfo objectForKey:@"data"];
        if(playingError) {
            
            if(playingError.code == SlikeServiceErrorM3U8FilerError) {
                return;
                
            } else if(playingError.code == SlikeServiceErrorNoNetworkAvailable) {
                
                NSMutableDictionary *payload = [[NSMutableDictionary alloc]init];
                if (playingError) {
                    [payload setObject:playingError forKey:@"data"];
                }
                [self _showAlertViewForOffline:YES];
                [self _sendPlayerStatus:SL_ERROR withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:payload];
                return;
                
            } else {
                
                NSDictionary *payload =  [NSDictionary dictionaryWithObjectsAndKeys:@"playback error",@"info", nil];
                [self _sendPlayerStatus:SL_ERROR withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:payload];
                SlikeDLog(@"AV PLAYER LOG: playback error");
                [self stopVideoWithCompletion:NO];
                return;
            }
        }
        else {
            NSDictionary *payload =  [NSDictionary dictionaryWithObjectsAndKeys:@"playback error",@"info", nil];
            [self _sendPlayerStatus:SL_ERROR withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:payload];
        }
        
    } else if([notification.name isEqualToString:SlikePlayerPlaybackStateDurationUpdateNotification] || [notification.name isEqualToString:SlikePlayerPlaybackStateTimeUpdateNotification]) {
        
        if ([notification.name isEqualToString:SlikePlayerPlaybackStateDurationUpdateNotification] ) {
            NSNumber *dur = (NSNumber *)notification.object;
            long long playerDuration = [dur longLongValue];
            if(playerDuration > 0 && self.slikeConfig.streamingInfo.nEndTime == 0) {
                self.slikeConfig.streamingInfo.nDuration = (NSInteger)playerDuration;
                self.slikeConfig.streamingInfo.nEndTime = (NSInteger)playerDuration;
            }
        }
        
        if(_isUserPaused) {
            return;
        }
        
        NSUInteger currentPosition = [self getPosition];
        NSUInteger duration = [self getDuration];
        NSDictionary *playerData = @{kSlikeCurrentPositionKey:@(currentPosition), kSlikeDurationKey:@(duration)};
        
        if(_isPlayerLoaded) {
            
            if([self isPlaying])
            {
                //                SlikeDLog(@"totalVideoPlayedDuration %ld",(long)[[SlikeSharedDataCache  sharedCacheManager] totalVideoPlayedDuration]);
                //                SlikeDLog(@"totalVideoPlayedDuration videoPlayed %ld",(long)self.slikeConfig.videoPlayed);
                
                if( [[SlikeSharedDataCache  sharedCacheManager] totalVideoPlayedDuration]  > self.slikeConfig.videoPlayed && _isVideoSeen == NO) {
                    [self _sendPlayerStatus:SL_VIDEOPLAYED withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:@{}];
                    _isVideoSeen =  YES;
                }
            }
            
            if(duration/1000 >[[notification.userInfo objectForKey:@"data"] intValue]) {
                
                //Dispatch the Event
                _playerCurrentState = self.isMediaReStart ?SL_START :SL_PLAYING;
                [self _sendPlayerStatus:_playerCurrentState withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:playerData];
                
                if (_playerCurrentState == SL_PLAYING) {
                    [self _sendPlayerStatus:SL_PLAYING withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:@{}];
                }
            }
            return;
        } else {
            SlikeDLog(@"AV PLAYER LOG: Unknown notification received...");
            return;
        }
    }
}

#pragma mark - Notification Uitility Methods
- (void)_startMediaStream {
    
    SlikeDLog(@"AV PLAYER LOG: _startMediaStream");
    _playerCurrentState = SL_START;
    [self _sendPlayerStatus:_playerCurrentState withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:@{}];
    [self.playerView startPlayingVideo:YES];
}

- (void)_readyMediaStream {
    
    SlikeDLog(@"AV PLAYER LOG: Player has loaded sucessfully");
    //User wants to auto play the media
    if(self.slikeConfig.isAutoPlay) {
        //Not interested in the ads
        if (self.slikeConfig.isSkipAds || self.slikeConfig.isPrerollEnabled == OFF || self.slikeConfig.ispr) {
            [self.playerView actionAfterReady];
        } else {
            //TODO: Can be used here to fetch the PreRoll in future
        }
    } else {
        //User wants to auto pause the Media
        _isAutoPlayEnable = NO;
        //[self setVideoPlaceHolder:NO];
        [self _sendStatusToControls:SL_SHOWCONTROLS];
        [self.playerView pause];
    }
}

#pragma mark - iSlikePlayer Player Play Stream
- (void)playMovieStreamWithObject:(SlikeConfig *)configModel withParent:(id) parent withError:(NSError *)error {
    [[SlikeDeviceSettings sharedSettings] setPlayerViewArea:parent];
    self.slikeConfig = configModel;
    [self _updateOrientationSettings];
}

//#warning - Need to implement no prefetch and no ads in stream
/**
 Set the Config Model
 @param configModel - Config Model
 @param parent - Parent view on which the Controller needs to set
 */
- (void)playMovieStreamWithObject:(SlikeConfig *)configModel withParent:(id)parent {
    
    SlikeDLog(@"AV PLAYER LOG: playMovieStreamWithObject");
    self.isAppAlreadyDestroyed = NO;
    [self resetVariables];

    _isAutoPlayEnable = YES;
    _loadingIndicator.hidden=YES;
    _loadingIndicator.alpha=0.0;
    //Reset the player Data if exists
    [[SlikeSharedDataCache sharedCacheManager] resetSlikeBitratesModel];
    if(configModel.resetPlayerInformation) {
        [self releasePlayerInformation];
        configModel.resetPlayerInformation =  NO;
    }
    
    if([configModel.streamingInfo.strSS length] == 0)
        configModel.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:configModel.mediaId];
    
    self.slikeConfig = configModel;
    [self _applicationPresenceState];
    [self _updateOrientationSettings];
    
    if(!configModel.isControlDisable)
    {
        if (configModel.customControls)
        {
            [self.view addSubview:configModel.customControls];
            configModel.customControls.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        } else {
            //Parent has not provided the controls UI. We need to create it
            [self _createSlikeCustomControlUI];
        }
    }
    
    [[SlikeDeviceSettings sharedSettings] setPlayerViewArea:parent];
    _playerContainer = parent;
    
    //NOTE: Here we are setting the player url but not using result, so that we can get the proper 'stt' value. Need to put it some proper place
    [StreamingInfo slikeMediaUrl:self.slikeConfig];
    
    //send the player status ready to server
    _playerCurrentState = SL_READY;
    [self _sendPlayerStatus:_playerCurrentState withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:@{kSlikeConfigModelKey: self.slikeConfig}];
    
    _nTimeCode = configModel.timecode;
    if(self.slikeConfig.isAllowSlikePlaceHolder) {
        [self setVideoPlaceHolder:YES];
    }
    
    if (self.slikeConfig.isAutoPlay) {
        if (self.slikeConfig.isSkipAds || self.slikeConfig.isPrerollEnabled == OFF || self.slikeConfig.ispr) {
            [self.view bringSubviewToFront:self.slikeConfig.customControls];
            [self _loadMediaStream];
            
        } else
        {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_MSEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self _initializeLoadingIndicator];
                [self _requestAdForPosition:0];
                [self _loadMediaStream];
            });
        }
    } else {
        [self _loadMediaStream];
        [self.view bringSubviewToFront:self.slikeConfig.customControls];
    }
    
}
/**
 Playing the Stream after the PreRoll
 */
- (void)_playStreamAfterPreRoll {
    SlikeDLog(@"AV PLAYER LOG: _playStreamAfterPreRoll");
    if(_isPlayerLoaded) {
        [self.playerView actionAfterReady];
    } else {
        //PATCH: Need to fix later . Ads creates some issue and player has not loaded
        [self performSelector:@selector(_playStreamAfterPreRoll) withObject:self afterDelay:1.0];
    }
}

/**
 Load the Media Stream
 */
- (void)_loadMediaStream {
    SlikeDLog(@"AV PLAYER LOG: _loadMediaStream");
    //Set the placehoder image & automatically on media start event
    [self _initialiseMediaStream];
    if (self.slikeConfig.isGestureEnable) {
        [self _addSlikeGestureUI];
    }
}

/**
 Request the Ad for the postion
 @param adPosition - 0=>PRE | -1=>POST
 */
- (void)_requestAdForPosition:(NSInteger)adPosition {
    [self _sendStatusToControls:SL_AD_REQUESTED];
    [[SlikeAdManager sharedInstance] showAd:self.slikeConfig adContainerView:[self _adPlayerContainerView] forAdPosition:adPosition];
}

- (void)_setAdIsPlaying:(BOOL)isPlaying {
    self.isCurrentlyAdPlaying = isPlaying;
}
/**
 Initialise Media Stream
 */
- (void)_initialiseMediaStream {
    
    if(self.isAppAlreadyDestroyed) return;
    
    _mediaStartTime = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"slike_bitrate_label"] && [defaults objectForKey:@"slike_bitrate_label"] != nil) {
        
        [[SlikeDeviceSettings sharedSettings] setMediaBitrate:[[SlikeDeviceSettings sharedSettings] getBitrateBylabel:self.slikeConfig]];
        
    } else {
        [[SlikeDeviceSettings sharedSettings] setMediaBitrate:@"none"];
    }
    
    SlikeDLog(@"AV PLAYER LOG: start time: %ld", (long)self.slikeConfig.streamingInfo.nStartTime);
    _mediaStartTime = self.slikeConfig.streamingInfo.nStartTime;
    if(_mediaStartTime != 0) {
        _mediaStartTime = _mediaStartTime / 1000;
    }
    else {
        _mediaStartTime = 0;
    }
    self.playerView.nCurrentTime = _mediaStartTime;
    
    _nTimeCode = _mediaStartTime;
    self.strNewURL = [StreamingInfo slikeMediaUrl:self.slikeConfig];
    _progressInfo = nil;
    _isPlayerLoaded = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callPlayVideo:self.strNewURL];
    });
}
/**
 Call for the Video . It will start the playing
 @param m3u8URL - Current m3u8
 */
- (void)callPlayVideo:(NSString *)m3u8URL {
    //For routue player
    if([self.slikeConfig.streamingInfo hasVideo:VIDEO_SOURCE_HLS])
    {
        m3u8URL = [m3u8URL stringByReplacingOccurrencesOfString:@"http" withString:@"123"];
    }
    SlikeDLog(@"AV PLAYER LOG: Inside callPlayVideo...");
    if ([NSURL URLWithString:m3u8URL] == nil) {
        SlikeDLog(@"AV PLAYER LOG: Invalid URL %@ not loaded",m3u8URL);
        [self errorAndStopMovie:nil];
        return;
    }
    if([self.slikeConfig.streamingInfo getCurrentVideoSource] == VIDEO_SOURCE_DRM) {
        m3u8URL = [NSString stringWithFormat:@"%@%@%@", m3u8URL, ([m3u8URL rangeOfString:@"?"].length > 0) ? @"&" : @"?", @"drm=1"];
    } else {
        // [self createAirPlayData];
        
    }
    NSURL *m3u8 = [NSURL URLWithString:m3u8URL];
    SlikeDLog(@"AV PLAYER LOG: Loading URL %@", m3u8URL);
    [[SlikeDeviceSettings sharedSettings] setM3U8HostValue:[m3u8 host]];
    self.playerView.isLiveStream = self.slikeConfig.streamingInfo.isLive;
    [self.playerView initialisePlayerWithPlaylist:m3u8 withStartPos:_nTimeCode];
}

/**
 Get the Current Falour URI
 @return -  URI
 */
- (NSString *)getCurrentFlavour {
    
    if(!self.slikeConfig.streamingInfo) return @"";
    if(!self.playerView) return @"";
    
    NSString *uri = [self.playerView currentPlaybackItemURI];
    return [self.slikeConfig.streamingInfo getCurrentStreamFlavour:uri forVideoType:[self.slikeConfig.streamingInfo getCurrentVideoSource]];
}

#pragma mark - Show BitRates Popups
/**
 Show the Bitrates popup
 */
- (void)showBitratesPopup {
    if([[SlikeSharedDataCache sharedCacheManager] isBitratesAvailableForStream]) {
        [self showUpdateBitratesUI];
    }
}

#pragma mark- handle Device Orinetations
/**
 Toggle full screen
 
 @param isOrientationChanged  -
 */
- (void)toggleFullscreen:(BOOL)isOrientationChanged {
    
#ifdef __SLIKE_ORIENTATION_WITH_VIEW_CONTROLLER__
    [_vcRotationManager rotate];
#else
    [self updateFullScreen];
#endif
    
}
/**
 Update the full Screen Mode
 */
- (void)updateFullScreen {
#ifndef __SLIKE_ORIENTATION_WITH_VIEW_CONTROLLER__
    if(slikeConfig.isFullscreenControl && _orentationObserver) {
        [_orentationObserver rotateDevice];
    }
#endif
}

- (void)_layoutPlayerIfNeeded {
#ifndef __SLIKE_ORIENTATION_WITH_VIEW_CONTROLLER__
    if( _orentationObserver) {
        [_orentationObserver changePlayerSize];
    }
#endif
}


#pragma Orientation Observer
- (void)_addVCControlOrientationObserver {
    __weak typeof(self) weekSelf = self;
    _vcRotationManager = [[SlikeVCRotationManager alloc] initWithViewController:self];
    _vcRotationManager.superview = _parentReferenceView;
    _vcRotationManager.target = self.view;
    _vcRotationManager.rotationCondition = ^BOOL(id<SJRotationManagerProtocol>  _Nonnull mgr) {
        return [weekSelf isAllowDeviceOrientation];
    };
    _vcRotationManager.delegate = self;
}

- (void)_addOrientationObserver {
    
#ifdef __SLIKE_ORIENTATION_WITH_VIEW_CONTROLLER__
    [self _addVCControlOrientationObserver];
    
#else
    __weak typeof(self) weekSelf = self;
    _orentationObserver = [[SlikeOrientationObserver alloc] initWithTarget:self rotationCondition:^BOOL(SlikeOrientationObserver * _Nonnull observer) {
        return [weekSelf isAllowDeviceOrientation];
        return YES;
        
    }];
    _orentationObserver.backWindowColor = self.slikeConfig.fullScreenWindowColor;
    [self _updateOrientationSettings];
    
    _orentationObserver.orientationChanged = ^(SlikeOrientationObserver * _Nonnull observer, BOOL isFullScreen) {
        
        weekSelf.isFullScreen = isFullScreen;
        [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStateFullScreenNotification object:nil userInfo:nil];
        
        if (isFullScreen && weekSelf.slikeGestureUI) {
            [weekSelf.slikeGestureUI listenForGestureEvents:YES];
            [weekSelf _updateGestureForCurrentState];
            
        } else {
            [weekSelf.slikeGestureUI listenForGestureEvents:NO];
        }
    };
    
    _orentationObserver.orientationWillChange = ^(SlikeOrientationObserver * _Nonnull observer, BOOL isFullScreen) {
        if(weekSelf.adPlayerView && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if ([weekSelf isAdPlaying]) {
                weekSelf.adPlayerView.backgroundColor = [UIColor blackColor];
            }
            else {
                weekSelf.adPlayerView.backgroundColor = weekSelf.slikeConfig.isAutoPlay ? [UIColor clearColor] : [UIColor blackColor];
            }
        }
    };
#endif
    
}
- (void)_updateOrientationSettings {
    if (_orentationObserver) {
        if (self.slikeConfig.orientationTypeiPad && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _orentationObserver.orientationType = SlikeOrientationTypeiPad;
        } else {
            _orentationObserver.orientationType = SlikeOrientationTypeiPhone;
        }
    }
}

- (void)_updateGestureForCurrentState {
    
    ///Enable/Desiable the Gestures on some defined events
    if(_playerCurrentState == SL_BUFFERING || _playerCurrentState == SL_PAUSE || _playerCurrentState == SL_COMPLETED || _playerCurrentState == SL_REPLAY || _playerCurrentState == SL_ENDED || [self isAdPlaying] || ![[SlikeNetworkMonitor sharedSlikeNetworkMonitor] isNetworkReachible] || ![self isPlaying] || _isPlaybackDone) {
        
        if (_slikeGestureUI) {
            [_slikeGestureUI listenForGestureEvents:NO];
        }
    } else {
        if (_slikeGestureUI) {
            [_slikeGestureUI listenForGestureEvents:YES];
        }
    }
}

/**
 Add for the Gesture Events
 */
- (void)_addSlikeGestureUI {
    if (self.slikeGestureUI) {
        _slikeGestureUI =nil;
    }
    if (self.slikeConfig) {
        _slikeGestureUI = [[SlikeGestureUI alloc]initWithGestureUI:self.view slikePlayer:self withSeekEnabled: self.slikeConfig.streamingInfo.isLive ? NO :YES];
        [_slikeGestureUI listenForGestureEvents:NO];
    }
}

/**
 Play the Stream with Some delay
 */
- (void)_playStreamWithDelay {
    [self play:NO];
    [self setVideoPlaceHolder:NO];
}
/**
 Set the completion block that will be used for sending the PLayer events
 @param eventChangeblock - Event completion block
 */
- (void)setOnPlayerStatusDelegate:(onChange)eventChangeblock {
    [[EventManager sharedEventManager] setEventHanlderBlock:eventChangeblock];
}

- (void)sendCustomControlEvent:(SlikePlayerState)state {
}

#pragma mark- Ads Info
/**
 Get the Status Info
 
 @param status - Status
 @return Progress Info
 */
- (StatusInfo *)_getStatusInfo:(SlikePlayerState) status {
    if(self.progressInfo == nil) {
        self.progressInfo = [StatusInfo initWithBuffer:0 withPosition:[self getPosition] withDuration:[self getDuration] muteStatus:0];
    } else {
        self.progressInfo.position = [self getPosition];
        self.progressInfo.duration = [self getDuration];
    }
    return _progressInfo;
}

/**
 Send the player status
 
 @param playerState - Player Status
 @param strError - Error
 */
- (void)_sendPlayerStatus:(SlikePlayerState)playerState withUserBehavior:(SlikeUserBehaviorEvent)isUserAction withError:(NSString *)strError withPayload:(NSDictionary *)payload  {
    
    //Update thee Gesture For Current State
    [self _updateGestureForCurrentState];
    
    [self _getStatusInfo:playerState];
    
    if(strError) {
        _progressInfo.error = strError;
    } else {
        _progressInfo.error = @"";
    }
    
    if(_progressInfo.adStatusInfo) {
        _progressInfo.adStatusInfo = nil;
    }
    
    EventModel *eventModel = [EventModel createEventModel:SlikeAnalyticsTypeMedia withBehaviorEvent:isUserAction withPayload:nil];
    eventModel.slikeConfigModel = self.slikeConfig;
    
    NSMutableDictionary *payloadInfo =  [[NSMutableDictionary alloc]initWithDictionary:payload];
    [payloadInfo setObject:eventModel forKey:kSlikeEventModelKey];
    [payloadInfo setObject:@(YES) forKey:kSlikeADispatchEventToParentKey];
    [payloadInfo setObject:_progressInfo forKey:kSlikeAdStatusInfoKey];
    
    [[EventManager sharedEventManager]dispatchEvent:MEDIA playerState:playerState dataPayload:payloadInfo slikePlayer:self];
    
}

- (void)_sendStatusToControls:(SlikePlayerState)playerState  {
    [[EventManager sharedEventManager] dispatchEvent:MEDIA playerState:playerState dataPayload:@{} slikePlayer:self];
}
- (void)_sendNetworkErrorMessage {
    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:[NSError errorWithDomain:SlikeServiceErrorDomain code:SlikeServiceErrorNoNetworkAvailable userInfo:@{NSLocalizedDescriptionKey:@"Internet not available."}], @"data", nil];
    [self _sendPlayerStatus:SL_ERROR withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:payload];
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

/**
 Create our
 */
- (void)_createSlikeCustomControlUI {
    
    SlikeMediaPlayerControl *slikeControlView = [[[NSBundle slikeNibsBundle] loadNibNamed:NSStringFromClass([SlikeMediaPlayerControl class]) owner:self options:nil] lastObject];
    slikeControlView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    slikeControlView.backgroundColor = [UIColor clearColor];
    slikeControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:slikeControlView];
    self.slikeConfig.customControls = slikeControlView;
}

/**
 Set the place holder
 @param isSet -
 */
- (void)setVideoPlaceHolder:(BOOL)isSet {
    [self.posterImage setPlaceHolderImage:isSet configModel:self.slikeConfig withPlayerView:_playerView];
}

/**
 Show the Bitrate Updates UI
 */
- (void)showUpdateBitratesUI {
    
    if (_bitratesView && [_bitratesView superview]) {
        [_bitratesView removeFromSuperview];
        _bitratesView=nil;
    }
    
    [self _sendStatusToControls:SL_HIDECONTROLS];
    
    _bitratesView = [SlikeBitratesView slikeBitratesView];
    _bitratesView.configModel = self.slikeConfig;
    [_bitratesView  presentAvailableBitratesForStream];
    
    UIView *parentView = (UIView *)self.view;
    [parentView addSubviewWithContstraints:_bitratesView];
    _bitratesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    __weak typeof(self) weekSelf = self;
    __block SlikeBitratesView* weakAlert = _bitratesView;
    _bitratesView.closeButtonBlock = ^ {
        [weakAlert removeAlertViewWithAnimation:YES];
    };
    
    _bitratesView.selectedBirateBlock = ^(id bitrateType) {
        SlikeMediaBitrate selectStreamBitrate = [bitrateType integerValue];
        [[SlikeSharedDataCache sharedCacheManager] setCurrentStreamBitrate:selectStreamBitrate];
        [weekSelf _updateBitrate];
        [weakAlert removeAlertViewWithAnimation:YES];
    };
    
    //Bring the Subview to Front
    [self.view bringSubviewToFront:_bitratesView];
}

/**
 Update the bitrate
 */
- (void)_updateBitrate {
    if(self.playerView.nCurrentTime != 0 && self.playerView.nCurrentTime != [self getDuration]) {
        _nTimeCode = self.playerView.nCurrentTime;
    }
    else {
        _nTimeCode = _mediaStartTime;
    }
    
    if(_nTimeCode <= 0) {
        _nTimeCode = 100;
        
    } else {
        _nTimeCode *= 1000;
    }
    
    [self.playerView stopVideo:NO];
    self.isBitrateSelect =  YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callPlayVideo:self.strNewURL];
        [self _sendPlayerStatus:SL_QUALITYCHANGE withUserBehavior:SlikeUserBehaviorEventBirate withError:nil withPayload:@{}];
        [self setVideoPlaceHolder:YES];
    });
    
}
/**
 Update Bitrate
 @param stream - Stream
 */
- (void)updateCustomBitrate:(Stream*)stream {
    
}

/**
 Remove the Bitrates UI
 */
- (void)_removeBiratesUI {
    if(_bitratesView && [_bitratesView superview]) {
        [_bitratesView removeAlertViewWithAnimation:YES];
        _bitratesView =  nil;
    }
}


- (void)getScreenShotAtPosition:(NSInteger)position withCompletionBlock:(void (^)(UIImage *image))completion {
    
    //We do not have the thumbnails info
    if (!self.slikeConfig.streamingInfo.thumbnailsInfoModel) {
        completion(nil);
        return;
    }
    
    NSInteger closestIndex = [SlikeUtilities getClosestIndexWithInCollection:self.slikeConfig.streamingInfo.thumbnailsInfoModel.timeCounts forSearchValue:@(position)];
    
    [self.slikeConfig.streamingInfo getThimbnailFromTiledImage:closestIndex withCompletionBlock:^(UIImage *image) {
        completion (image);
    }];
}

/**
 Download the Titled image for the media previews
 */
- (void)downloadStreamTitledImage {
    
    if (self.slikeConfig.preview) {
        
        if ([self.slikeConfig.streamingInfo.thumbnailsInfoModel.tileImageUrls count]==0 && [self.slikeConfig.streamingInfo.thumbnailsInfoModel.thumbImages count]==0  && !self.slikeConfig.streamingInfo.downloadingInProcess) {
            self.slikeConfig.streamingInfo.downloadingInProcess = YES;
            [self.slikeConfig.streamingInfo downloadInitialMediaThumbnails];
        }
    }
}

/**
 Show the Offline message.
 */
- (void)_showAlertViewForOffline:(BOOL)enableReload {
    
    [self setVideoPlaceHolder:YES];
    [self _sendStatusToControls:SL_HIDECONTROLS];
    if (_isNetworkWindowPresented) {
        return;
    }
    
    [self pause:NO];
    self.slikeAlertView = [SlikePlayerErrorView slikePlayerErrorView];
    UIView *parentView = (UIView *)self.view;
    [parentView addSubviewWithContstraints:_slikeAlertView];
    
    __block SlikePlayerErrorView* weakAlert = _slikeAlertView;
    [_slikeAlertView setErrorMessage:NO_NETWORK withCloseEnable:self.slikeConfig.isNoNetworkCloseControlEnable withReloadEnable:enableReload];
    _isNetworkWindowPresented = YES;
    
    [self _removeBiratesUI];
    [self _sendStatusToControls:SL_HIDECONTROLS];
    
    //Set the poster image
    [self setVideoPlaceHolder:YES];
    __weak typeof(self) weekSelf = self;
    
    _slikeAlertView.reloadButtonBlock = ^ {
        if ([[SlikeNetworkMonitor sharedSlikeNetworkMonitor] isNetworkReachible]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakAlert removeAlertViewWithAnimation:YES];
                weekSelf.slikeAlertView =  nil;
                weekSelf.isNetworkWindowPresented = NO;
                [weekSelf performSelector:@selector(_playStreamWithDelay) withObject:nil afterDelay:0.0];
            });
        }
    };
    weakAlert.closeButtonBlock = ^ {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.slikeAlertView removeAlertViewWithAnimation:YES];
            [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_CLOSE dataPayload:@{kSlikeADispatchEventToParentKey: @(YES)} slikePlayer:nil];
        });
    };
    
    [self.view bringSubviewToFront:_slikeAlertView];
}

#pragma mark - Cleanup
/**
 Remove the Player . Also dealloc all the Associated resources
 */
- (void)removePlayer {
    
    [[EventManager sharedEventManager] dispatchEvent:ACTIVITY playerState:SL_PLAYER_DISTROYED dataPayload:@{} slikePlayer:self];
    [self _sendPlayerStatus:SL_ENDED withUserBehavior:SlikeUserBehaviorEventNone withError:nil withPayload:@{}];
    
    if([self.playerView isPlayerExist]) {
        [self pause:NO];
    }
    [self.playerView stopVideo:YES];
    
    __weak typeof(self) _self = self;
    [self _removeCustomControls:^{
        [_self cleanup];
        _self.progressInfo=nil;
    }];
    
#ifdef __SLIKE_ORIENTATION_WITH_VIEW_CONTROLLER__
    if (self.vcRotationManager) {
        self.vcRotationManager =nil;
    }
#else
    if (self.orentationObserver) {
        self.orentationObserver =nil;
    }
#endif
    
    if (_playerRegistrar) {
        self.playerRegistrar = nil;
    }
    if (self.slikeGestureUI) {
        self.slikeGestureUI =nil;
    }
    self.strNewURL=nil;
    if (self.slikeAlertView) {
        [_slikeAlertView removeFromSuperview];
        self.slikeAlertView=nil;
    }
    
    if(_playerContainer && self.view) {
        if([_playerContainer isKindOfClass:[UIView class]]) {
            if(self.parentViewController) {
                [self willMoveToParentViewController:nil];
            }
            if([self.view superview]){
                [self.view removeFromSuperview];
            }
            if(self.parentViewController) {
                [self removeFromParentViewController];
            }
        }
        _playerContainer=nil;
    }
}


- (void)_removeCustomControls:(void(^)(void))completed {
    if (self.slikeConfig && self.slikeConfig.customControls) {
        if ([NSThread isMainThread]) {
            completed();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self removeSafelyCustomControls];
                completed();
            });
        }
    }
}
- (void)removeSafelyCustomControls {
    if (self.slikeConfig && [self.slikeConfig.customControls superview] && self.slikeConfig.customControls) {
        [self.slikeConfig.customControls removeFromSuperview];
        self.slikeConfig.customControls=nil;
    }
}

- (BOOL)cleanup {
    
    if(self.isAppAlreadyDestroyed) return NO;
    SlikeDLog(@"AV PLAYER LOG: Cleaning up video player...");
    if(self.isFullScreen ) {
        [self toggleFullscreen:NO];
    }
    [self _removeEventsObservers];
    self.slikeConfig.streamingInfo = nil;
    self.slikeConfig = nil;
    [self.playerView cleanupAVPlayerResources];
    self.playerView = nil;
    self.isAppAlreadyDestroyed = YES;
    return YES;
}

- (void)dealloc {
    SlikeDLog(@"dealloc- Cleaning up SlikeAvPlayerViewController");
}

/**
 Reset the player . It Will Reset all the data except the parent View.
 */
- (void)resetPlayer {
    
    if(self.isAppAlreadyDestroyed) {
        return;
    }
    if([self.playerView isPlayerExist]) {
        [self pause:NO];
    }
    [self.playerView resetAvPlayer];
    
    self.slikeConfig.customControls.alpha=0;
    self.progressInfo = nil;
    self.strNewURL = nil;
    if (self.playerRegistrar) {
        self.playerRegistrar= nil;
    }
    if (self.slikeAlertView) {
        [_slikeAlertView removeFromSuperview];
        self.slikeAlertView=nil;
    }
    [self setVideoPlaceHolder:NO];
    self.posterImage.image= nil;
    [self resetBooleans];
    
    [self _removeCustomControls:^{
        self.slikeConfig.streamingInfo = nil;
        self.slikeConfig = nil;
    }];
    self.isAppAlreadyDestroyed = YES;
}

- (void)resetBooleans {
    
    _isUserPaused = NO;
    _isVideoSeen = NO;
    _isUserSeeked = NO;
    _isPlaybackDone = NO;
    _isPlayerLoaded = NO;
    _isBitrateSelect = NO;
    _isNetworkWindowPresented = NO;
    _isCurrentlyAdPlaying = NO;
    _hasPostRollCompleted = NO;
    _isMediaReStart = NO;
    _isAutoPlayEnable = NO;
}

#ifdef __SLIKE_ORIENTATION_WITH_VIEW_CONTROLLER__
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [_vcRotationManager vc_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (BOOL)shouldAutorotate {
    return [_vcRotationManager vc_shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [_vcRotationManager vc_supportedInterfaceOrientations];
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [_vcRotationManager vc_preferredInterfaceOrientationForPresentation];
}
#else
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
#endif

#pragma mark - SLRotationManagerDelegate
- (void)rotationManager:(id<SJRotationManagerProtocol>)manager willRotateView:(BOOL)isFullscreen {
}

- (void)rotationManager:(id<SJRotationManagerProtocol>)manager didRotateView:(BOOL)isFullscreen {
    
    self.isFullScreen = isFullscreen;
    [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStateFullScreenNotification object:nil userInfo:nil];
    if (_isFullScreen && self.slikeGestureUI) {
        [self.slikeGestureUI listenForGestureEvents:YES];
        [self _updateGestureForCurrentState];
        
    } else {
        [self.slikeGestureUI listenForGestureEvents:NO];
    }
}
@end
