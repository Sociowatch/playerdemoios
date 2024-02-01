//
//  SlikePlayerConstants.m
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 16/05/18.
//
#import "SlikePlayerConstants.h"

/*
 Player State Event that the player has started
 */
NSString * const SlikePlayerPlaybackStateStartNotification =
@"SlikePlayerPlaybackStateStartNotification";

/*
 Player State Event that the player is ready for current stream
 */
NSString * const SlikePlayerPlaybackStateReadyNotification =
@"SlikePlayerPlaybackStateReadyNotification";

/*
 Player State Event that the player is buffering for current stream
 */
NSString * const SlikePlayerPlaybackStateBufferingNotification = @"SlikePlayerPlaybackStateBufferingNotification";


/*
 Player State Event that the player is buffering ended for current stream
 */
NSString * const SlikePlayerPlaybackStateBufferingEndedNotification = @"SlikePlayerPlaybackStateBufferingEndedNotification";



/*
 Player State Event that the player has paused for current stream
 */
NSString * const SlikePlayerPlaybackStatePauseNotification =
@"SlikePlayerPlaybackStatePauseNotification";

/*
 Player State Event that the player has stoped for current stream
 */
NSString * const SlikePlayerPlaybackStateStopNotification =
@"SlikePlayerPlaybackStateStopNotification";

/*
samc,mdskmck
 */
NSString * const SlikePlayerPlaybackStateSeekUpdateNotification = @"SlikePlayerPlaybackStateSeekUpdateNotification";

/*
 Player State Event that the player has started the seeking for current stream
 */
NSString * const SlikePlayerPlaybackStateSeekStartNotification = @"SlikePlayerPlaybackStateSeekStartNotification";

/*
 Player State Event that the player has completed the seeking for current stream
 */
NSString * const SlikePlayerPlaybackStateSeekEndNotification =
@"SlikePlayerPlaybackStateSeekEndNotification";

/*
 Player State Event that the player has failed in the seeking for current stream
 */
NSString * const SlikePlayerPlaybackStateSeekFailedNotification = @"SlikePlayerPlaybackStateSeekFailedNotification";

/**
 * Player State Event the player has updated the state for current media stream
 */
NSString * const SlikePlayerPlaybackStateUpdateNotification =
@"SlikePlayerPlaybackStateUpdateNotification";

/**
 *  Player State Event the player has updated the time for current media stream
 */
NSString * const SlikePlayerPlaybackStateTimeUpdateNotification =           @"SlikePlayerPlaybackStateTimeUpdateNotification";

/**
 *  Player State Event the player has finished for current media stream
 */
NSString * const SlikePlayerPlaybackStateFinishedNotification =
@"SlikePlayerPlaybackStateFinishedNotification";

/**
 *  Player State Event the player's duration has updated for current media stream
 */
NSString * const SlikePlayerPlaybackStateDurationUpdateNotification =
@"SlikePlayerPlaybackStateDurationUpdateNotification";

/**
 *  Player State Event the player is playing the current media stream
 */
NSString * const SlikePlayerPlaybackStatePlayNotification =
@"SlikePlayerPlaybackStatePlayNotification";


/**
 *  Player State Event the player is unable to play the current media stream
 */
NSString * const SlikePlayerPlaybackStatePlaybackErrorNotification =
@"SlikePlayerPlaybackStatePlaybackErrorNotification";

/**
 *  Player State Event the player's duration has updated for live media stream
 */
//NSString * const SlikePlayerPlaybackStateLiveStreamDurationUpdateNotification =
//@"SlikePlayerPlaybackStateLiveStreamDurationUpdateNotification";

/**
 *  Player State Event the player has changed its view mode (Normal mode to FullScren mode)
 */
NSString * const SlikePlayerPlaybackStateFullScreenNotification =
@"SlikePlayerPlaybackStateFullScreenNotification";


/**
 *  Player State Event the player has available the Duration
 */
NSString * const SlikePlayerLoadedTimeRangesNotification =
@"SlikePlayerLoadedTimeRangesNotification";


NSString * const kSlikeDesiableOrientationNotification  = @"kSlikeDesiableOrientationNotification";


#pragma mark - AVPlayer KeyPath
/*
 * AVPlayer Key String constant
 */

NSString * const kSlikeGifPlayerRestartedKey      = @"gif_restarted";


#pragma mark- Analytics keys

//Returns BOOL Keys
NSString * const kSlikeADispatchEventToParentKey             = @"dispatch_to_Parent";
NSString * const kSlikeEventIsForAnalyticsKey                = @"analytics_event";


NSString * const kSlikeAdStatusInfoKey         = @"status_info";

//If this value is true then need to pass the array of bitrates to parent app
NSString * const kSlikeCustomBitrateInfoKey                = @"custom_bitrate";
NSString * const kSlikeConfigModelKey                      = @"configModel";
NSString * const kSlikeConfigModelForNextItemKey           = @"next_item_configModel";

NSString * const kSlikeSeekProgressKey           = @"seek_progress";
NSString * const kSlikeBufferPositionKey         = @"current_bufferPos";
NSString * const kSlikeDurationKey               = @"duration";
NSString * const kSlikeCurrentPositionKey        = @"current_position";
NSString * const kSlikeBufferingEndedKey         = @"buffering_ended";
NSString * const kSlikePlayPauseByUserKey        = @"playPause_by_user";


//Media Previews. It is associated with
NSString * const kSlikePreviewStartedKey          = @"preview_started";
NSString * const kSlikePreviewProgressKey         = @"preview_progress";
NSString * const kSlikePreviewStopKey             = @"preview_stoped";

//Audio Model Properties
NSString * const kSlikeAudioConfigModelKey                = @"audioConfigModel";
NSString * const kSlikeAudioItemInfoKey                   = @"audioItemIdKey";

