//
//  ISlikePlayerControl.h
//  Pods
//
//  Created by Aravind kumar on 4/20/17.
//
//
#import <Foundation/Foundation.h>

@protocol ISlikePlayer;
@class SlikeConfig;

@protocol ISlikePlayerControl<NSObject>

@required

/**
 Player Configuration
 */
@property (nonatomic, strong) SlikeConfig *slikeConfig;

/**
 Called when Player will enters in foreground. Can be perform opertaions
 like (Making some UI controls vissible, play if Paused, Restarting timer etc)
 */
- (void)viewWillEnterForeground;

 /**
 Called when Player will enters in foreground. Can be perform opertaions
 like (Making some UI controls hidden, Paused Video, Pausing timer etc)
 */
- (void)viewWillEnterBackground;

/**
 Set the host player to access the Player properties (Play,Pause, Duration etc)
 @param hostPlayer set ISlikePlayer
 */
- (void)setHostPlayer:(id<ISlikePlayer>) hostPlayer;

/**
 To get the Host Player
 @return ISlikePlayer object
 */
- (id<ISlikePlayer>)getHostPlayer;

/**
 Set Slike Config data to control
 @param slikeConfig pass slikeConfig
 */
- (void)setPlayerData:(SlikeConfig *)slikeConfig;

/**
 Called when player events happen. It is called multiple times
 // UI related task can be done by accessing the player properties
 */
- (void)updatePlaybackProgress;

/**
   Called when buffered video has downloaded.
 */
- (void)updateBufferPlaybackProgress;

/**
 Update UI controls. Called multile times with associated status
 @param status - states (SL_READY, SL_LOADED, SL_START, SL_PLAYING, SL_PAUSE, RESUME, SL_BUFFERING, SL_SEEKING etc)
 */
- (void)updateButtons:(SlikePlayerState) status;

/**
 If user manually pauses the video.
 @return If user has paused the video manually then return YES, otherwise NO
 */
- (BOOL)isUserPausedVideo;
/**
 Player is about to enter in fullScreen Mode, Do UI work before enter in full Screen
 Dissmiss popups that are present on player view (ActionSheet|AlertController)
 Return YES if there are popups otherwise return NO
 */
- (BOOL)playerWillEnterFullScreen;

/**
 To show progessing View if user changes bitrate

 @param show -  If Yes to show the loader. It will show the buffering otherwise hide
 */
- (void)showProcessingHUD:(BOOL) show;

/**
 To show progressing view
 @param show -  Yes to show the loader otherwise hide
 */
- (void)showHUD:(BOOL) show;

/**
 for custom Control view visibility
 @return if custom Control view is visible then return YES, otherwise NO
 */
- (BOOL)isVisible;

/**
 To get the cast player update

 @return return YES if video is playing on Cast eg. Chromecast
 */
- (BOOL)isCastPlaying;


@optional

/**
 Use to show custom control view
 */
- (void)show;

/**
 Use to hide custom control view
 */
- (void)hide;


/**
 Update fullscreen layout
 @param isFullScreen set as YES or NO as per current view
 */
- (void)updateFullScreen:(BOOL) isFullScreen;

/**
 Stop the player and remove it from superview
 */
- (void)endPlayerView;
/**
 //
 @param arrMarkers //
 */
- (void)setAdsMarkers:(NSMutableArray *) arrMarkers;

/**
 @param index //
 */
- (void)setAdMarkerDone:(NSInteger) index;

/**
 toggle to FullScreen

 @param flag -  set as YES or NO according to full screen view
 */
- (void)showFullscreenButton:(BOOL) flag;

/**
 Called when video is playing on any cast eg. Chromecast

 @param isPlaying returns YES if video is playing on cast, otherwise NO.
 */
- (void)updatreCastPlay:(BOOL)isPlaying;

/**
 To update cast icon

 @param isShow get YES if cast is visible, else pass NO
 */
- (void)updateCastIcon:(BOOL)isShow;

/**
 To Update cast device Name

 @param deviceName get the cast device name
 */
- (void)updateMyCastView:(NSString*)deviceName;

/**
 To show and hide dock button

 @param isShow Pass YES and NO according to showing the dock option
 */
- (void)updateDocBtn:(BOOL)isShow;

@end

