// ADOBE SYSTEMS INCORPORATED
// Copyright 2011 Adobe Systems Incorporated
// All Rights Reserved.

// NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
// terms of the Adobe license agreement accompanying it.  If you have received this file from a
// source other than Adobe, then your use, modification, or distribution of it requires the prior
// written permission of Adobe.

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerView : UIView {
}

@property (nonatomic, strong) AVPlayer * _Nullable player;
@property (nonatomic, assign) NSInteger nCurrentTime;
@property (nonatomic, assign) BOOL isLiveStream;
@property (nonatomic, assign) BOOL isSecure;

/**
 Set the bitrate for current stream
 
 @param nBitrate - Bitrate
 @return TRUE|FALSE
 */
- (BOOL)setPreferredBitrate:(NSInteger) nBitrate;

/**
 Seek the player to perticular time
 
 @param time - Seek Time
 @param isFastSeek - Is Fast seek required
 */
- (void)seekPlayerToTime:(CMTime)time fastSeek:(BOOL) isFastSeek  completionBlock:(void (^ __nullable)(BOOL finished))completionHandler;


/**
 Perform action once player is ready
 */
- (void)actionAfterReady;

/**
 Start the player for the stream
 
 @param isFirst - Is First stream
 */
- (void)startPlayingVideo:(BOOL) isFirst;

/**
 Utility method : Play the Video
 */
- (void)play;

/**
 Utility method : Pause the Video
 */
- (void)pause;

/**
 Utility method : Reset the player for next
 */
- (void)resetPlayerForNextPlay;

/**
 Utility method : Stop the Video also cleaning required
 */
- (void)stopVideo:(BOOL) cleanVideo;

/**
 Utility method : Restart the Video
 */
- (void)restart:(NSInteger)start completionBlock:(void (^ __nullable)(BOOL finished))completionHandler;

/**
 Utility method : Is player is playing any stream
 */
- (BOOL)isPlaying;

/**
 Utility method : Is playlist exist for the player
 */
- (BOOL)isPlayerExist;

/**
 Utility method : Current URI
 */

- (void)initialisePlayerWithPlaylist:(NSURL*_Nonnull)m3u8 withStartPos:(NSInteger)startTime;
/**
 Utility method : Add observer to listen the player's state change events
 */
- (void)addPlayerObservers;

/**
 Utility method : Update the bitrate
 */

- (void)updateBitrate;

/**
 Utility method : Remove the registered the observers
 */
- (void)removePlayerObservers;

/**
 Utility method : Cleanup the players resources
 */
- (void)cleanupAVPlayerResources;

/**
 Utility method : Change the players state (MUTE|UNMUTE)
 */
- (void)playerMute:(BOOL)isMute;

/**
 Utility method : players (MUTE|UNMUTE) state
 */
- (BOOL)getPlayerMuteStatus;

/**
 Utility method : Play the GIF Video Only
 */
-(void)playMp4Video:(NSString*_Nonnull)urlString;

/**
 Get the Current Playback URI
 @return - Current URI
 */
- (NSString *_Nonnull)currentPlaybackItemURI;

/**
 Get the Player Position
 @return - Position
 */
- (NSUInteger)getPlayerPosition;

/**
 Get the player
 
 @return - Duration
 */
- (NSUInteger)getPlayerDuration;
- (void)resetAvPlayer;

// Utility Methods
- (void)setAllowsAirPlay:(BOOL)allowsAirPlay;
- (BOOL)allowsAirPlay;

@end

