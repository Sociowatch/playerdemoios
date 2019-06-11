//
//  SlikePlayerConstants.h
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 16/05/18.
//

#import <Foundation/Foundation.h>

/*
 * Slike player playback state. Notification that the payer will send during the play for curent
 * Stream
 */

/**
 *  Notification sent when the player is ready for current media stream
 */

OBJC_EXTERN NSString * const SlikePlayerPlaybackStateReadyNotification;

/**
 *  Notification sent when the player will start the current media stream
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStateStartNotification;

/**
 *  Notification sent when the player has paused for the current media stream
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStatePauseNotification;

/**
 *  Notification sent when the player is buffering for current media stream
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStateBufferingNotification;

/**
 *  Notification sent when the player is buffering has ended for current media stream
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStateBufferingEndedNotification;


/**
 *  Notification sent when the player has stop for current media stream
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStateStopNotification;

/**
 *  sdbcvedshjejh
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStateSeekUpdateNotification;

/**
 *  Notification sent when the player has started seeking for current media stream
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStateSeekStartNotification;

/**
 *  Notification sent when the player seeking  has ended for current media stream
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStateSeekEndNotification;

/**
 *  Notification sent when the player is unable to seek for current media stream
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStateSeekFailedNotification;

/**
 *  Notification sent when the player state has updated for current media stream
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStateUpdateNotification;

/**
 *  Notification sent when the time has updated for current media stream
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStateTimeUpdateNotification;

/**
 *  Notification sent when the player has completed for current media stream
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStateFinishedNotification;

/**
 *  Notification sent when the player duration has updated for current media stream
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStateDurationUpdateNotification;

/**
 *  Notification sent when the player is playing for current media stream
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStatePlayNotification;


/**
 *  Notification sent when the player  has received some issues while playing for current media stream
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStatePlaybackErrorNotification;

/**
 *  Notification sent when the player duration has updated for live stream
 */
//OBJC_EXTERN NSString * const SlikePlayerPlaybackStateLiveStreamDurationUpdateNotification;

/**
 *  Notification sent when the player has changed the orientation from normal screen to full screen
 */
OBJC_EXTERN NSString * const SlikePlayerPlaybackStateFullScreenNotification;

/**
 *  Notification sent when the player has available the duration
 */
OBJC_EXTERN NSString * const SlikePlayerLoadedTimeRangesNotification;



OBJC_EXTERN NSString * const kSlikeDesiableOrientationNotification;

/*
 * AVPlayer KeyPath Notifications
 */
OBJC_EXTERN NSString * const kSlikeGifPlayerRestartedKey;
/*
 * Analytics keys
 */
OBJC_EXTERN NSString * const kSlikeADispatchEventToParentKey;


OBJC_EXTERN NSString * const kSlikeConfigModelForNextItemKey;

