//
//  SlikeFBVideoView.h
//  fbPlayer
//
//  Created by Aravind kumar on 12/4/17.
//  Copyright © 2017 Aravind kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SlikeFBVideoView;

/** These enums represent the state of the current video in the player. */
typedef NS_ENUM(NSInteger, FBPlayerState) {
    kFBPlayerStateUnstarted,
    kFBPlayerStateEnded,
    kFBPlayerStatePlaying,
    kFBPlayerStatePaused,
    kFBPlayerStateBuffering,
    kFBPlayerStateQueued,
    kFBPlayerStateUnknown
};

/** These enums represent error codes thrown by the player. */
typedef NS_ENUM(NSInteger, FBPlayerError) {
    kFBPlayerErrorInvalidParam,
    kFBPlayerErrorHTML5Error,
    kFBPlayerErrorVideoNotFound, // Functionally equivalent error codes 100 and
    // 105 have been collapsed into |kYTPlayerErrorVideoNotFound|.
    kFBPlayerErrorNotEmbeddable, // Functionally equivalent error codes 101 and
    // 150 have been collapsed into |kYTPlayerErrorNotEmbeddable|.
    kFBPlayerErrorUnknown
};

@protocol SlikeFBPlayerViewDelegate<NSObject>
@optional
/*
 **
 * Invoked when the player view is ready to receive API calls.
 *
 * @param playerView The SlikeFBVideoView instance that has become ready.
 */
- (void)playerViewDidBecomeReady:(nonnull SlikeFBVideoView *)playerView;

/**
 * Callback invoked when player state has changed, e.g. stopped or started playback.
 *
 * @param playerView The SlikeFBVideoView instance where playback state has changed.
 * @param state FBPlayerState designating the new playback state.
 */
- (void)playerView:(nonnull SlikeFBVideoView *)playerView didChangeToState:(FBPlayerState)state;


/**
 * Callback invoked when an error has occured.
 *
 * @param playerView The SlikeFBVideoView instance where the error has occurred.
 * @param error FBPlayerError containing the error state.
 */
- (void)playerView:(nonnull SlikeFBVideoView *)playerView receivedError:(FBPlayerError )error;

/**
 * Callback invoked frequently when playBack is plaing.
 *
 * @param playerView The SlikeFBVideoView instance where the error has occurred.
 * @param playTime float containing curretn playback time.
 */
- (void)playerView:(nonnull SlikeFBVideoView *)playerView didPlayTime:(float)playTime;


- (nonnull UIColor *)playerViewPreferredWebViewBackgroundColor:(nonnull SlikeFBVideoView *)playerView;
- (nullable UIView *)playerViewPreferredInitialLoadingView:(nonnull SlikeFBVideoView *)playerView;
@end


@interface SlikeFBVideoView : UIView<UIWebViewDelegate>
@property(nonatomic, strong, nullable, readonly) UIWebView *webView;
@property(nonatomic, weak, nullable) id<SlikeFBPlayerViewDelegate> delegate;

- (BOOL)loadWithVideoId:(nonnull NSString *)videoId withAppId:(nonnull NSString *) appId;
- (void)stop;
- (void)play;
- (void)pause;
- (void)mute;
- (void)unmute;
- (float)getDuration;
- (float)getCurrentPosition;
- (void)seek:(float)seekToSeconds;
- (void)removeWebView;
- (void)playerMute:(BOOL)isMute;
- (BOOL)getPlayerMuteStatus;
@end
