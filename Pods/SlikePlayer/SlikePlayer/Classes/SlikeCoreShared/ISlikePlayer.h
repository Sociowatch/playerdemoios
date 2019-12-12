

//
//  ISlikePlayer.h
//  SlikePlayer
//
//  Created by TIL on 04/05/17.
//  Copyright © 2017 BBDSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatusInfo.h"
#import "StreamingInfo.h"
#import "SlikeConfig.h"
#import "ISlikePlayerControl.h"
#import "ISlikeCast.h"
#import "ISlikeAnlytics.h"
#import "SLCueMDO.h"

//Blocks for listing the player Events
typedef void(^onChange)(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo);
typedef void(^onConfigUpdateChange)(id slikeResponseModel, NSError *parseError);

@protocol ISlikePlayer<NSObject>

@property (nonatomic, assign) BOOL isAppAlreadyDestroyed;
@property (nonatomic, assign) BOOL isAppActive;
@property (nonatomic, weak) SlikeConfig *slikeConfig;

/**
 Utility method for Playing the video streams
 @param si  -  Configuration that contains stream info
 @param parent - Parent Controller/View
 */
- (void)playMovieStreamWithObject:(SlikeConfig *)si withParent:(id) parent;

/**
 Utility method for Playing the video streams
 @param si  -  Configuration that contains video info
 @param parent - Parent Controller/View
 @param error  -  Returns error
 */
- (void)playMovieStreamWithObject:(SlikeConfig *)si withParent:(id)parent withError:(NSError*)error;

/**
 Get the current position of the media being played
 @return - It returns the current position of player
 */
- (NSUInteger)getPosition;

/**
 Get the duration of media
 @return - It returns the duration of media
 */
- (NSUInteger)getDuration;

/**
 Get the buffered duration of media
 @return - Buffered duration
 */
-(NSUInteger) getBufferTime;

/**
 Get the buffer progress
 @return -buffer progress
 */
- (float)getLoadTimeRange;

/**
 Get the current player Status eg. Ready/Pause etc
 @return - Player states
 */
- (SlikePlayerState)getStatus;

/**
 Called when the app will come in foreground
 */
- (void)viewWillEnterForeground;

/**
 Called when the app will come in background
 */
- (void)viewWillEnterBackground;

/**
 Play the video
 @param isUser -  If user plays the media manually then pass YES, otherwise pass NO
 */

- (void)play:(BOOL)isUser;

/*
 Pause the video
 *  @param - isUser, If user pauses the media manually then pass YES, otherwise pass NO
 */
-(void) pause:(BOOL) isUser;

/**
 Resume the Video
 */
- (void)resume;

/**
 Replay the video
 */
- (void)replay;

/**
 Current status of player
 returns YES if player is playing otherwise returns NO
 */
- (BOOL)isPlaying;

/**
 Seek video to a particular position
 * @nPosition -  seeked video postion
 * @isUser  - If user is manually seeking then pass YES otherwise NO
 */
- (void)seekTo:(float) nPosition userSeeked:(BOOL) isUser;

/**
 Get Player's full screen status
 @return -  YES if playing in full screen window, otherwise NO
 */
- (BOOL)isFullScreen;

/**
 Toggle the player's screen size
 */
- (void)toggleFullScreen;

/**
 Remove the player from current view
 */
- (void)removePlayer;

/**
 Returns If player has intitialized and exists
 */
- (BOOL)isPlayerExist;

/**
 Get the current flavour of bitrate
 return -  flavour of bitrate
 */
- (NSString *)getCurrentFlavour;

/**
 Stop current video
 */
- (void)stop;

/**
 Clean up player and associated data
 */
- (BOOL)cleanup ;

/**
 Reset the player. associated data will be removed
 */
- (void)resetPlayer;

/**
 Mute/Unmute player's sound
 @isMute If player has to be muted then pass YES otherwise NO
 */
- (void)playerMute:(BOOL)isMute;

/**
 Get the player's mute status
 @return -  Mute status
 */
- (BOOL)getPlayerMuteStatus;

/**
 Get the current view Controller's instance
 @return - Curent Insatnce
 */
- (UIViewController *)getViewController;

/**
 Set the reference of parent
 
 @param parentView - Parent View
 */
- (void)setParentReference:(UIView *) parentView;

/**
 Event Listener Block
 @param block - Event Listener
 */
- (void)setOnPlayerStatusDelegate:(onChange) block;

/**
 Set the custom Controls
 @param slikeControl -  Instance of UIViewController
 */
- (void)setController:(id<ISlikePlayerControl>) slikeControl;

/**
 Get the custom control instance
 */
- (id<ISlikePlayerControl>) getControl;

/*
 @BOOL returns YES if player has multiple streams
 */

/**
 If Player is supporting multiple bitrates for the current video
 @return - YES/NO
 */
- (BOOL)canShowBitrateChooser;

/**
 Array Of Bitrates Streams
 
 @param isCustom If YES then return all streams other wise returns empty array
 @return - streams
 */
- (NSArray*)showBitrateChooser:(BOOL)isCustom;

- (void)updateCustomBitrateNew:(NSInteger)type;
/**
 Change the Bitrate for current video
 @param obj - New Bitrate
 */
- (void)updateCustomBitrate:(Stream*)obj;

/**
 Current Video URL
 */
- (NSString*)currentBitRateURI;
-(NSInteger)currentBitRateType;
/**
 Hide the Bitrate Custom View
 */
- (void)hideBitrateChooser;

/**
 The Video placeholder
 @param isSet - YES then set the placeholder for the video
 */
- (void)setVideoPlaceHolder :(BOOL)isSet;

/**
 Set the Native controls
 @param isNative - Pass YES to set the native controls
 */
- (void)setNativeControl:(BOOL) isNative;

/**
 Send the custom control event for states
 @param state  - State
 */
- (void)sendCustomControlEvent:(SlikePlayerState) state;

/**
 Set the cast for player
 */
- (void)setCast:(id<ISlikeCast>)cast;

/**
 Get the cast for player
 */
- (id<ISlikeCast>) getCast;

/**
 Get the screen shot at perticular position
 @param position - Time in second
 @param completion - Completion Block
 */
- (void)getScreenShotAtPosition:(NSInteger)position withCompletionBlock:(void (^)(UIImage *image))completion;

@optional

/*
 Get the Time Ranges. It is used for DVR streams to get the duration.
 - DVR Stream duration is indifinite
 - return - Time Range
 */
- (CMTimeRange)getTimeRange;

/*
 Switch stream to DVR vs Live .
 @param stream - Switch Stream
 Note: It is used only for DVR/Live not for VOD stream
 */

- (void)switchToStream:(SLKMediaPlayerStreamType)stream;

/**
 Get the ad Playing information
 
 @return YES if ad Playing otherwise NO
 */
- (BOOL)isAdPlaying;
- (BOOL)isAdPaused;

/**
 Play audio strem
 
 @param audioTrackArray slike audio array
 @param itemIndex item index to play in this list;
 */
- (void)playAudioStreamWithObject:(NSArray<id> *)audioTrackArray startItemIndex:(NSInteger) itemIndex;
@end

@protocol ICueHandler<NSObject>

@optional
- (void)onCueData:(SLCueMDO*)model;

@end
