//
//  SlikeGifView.h
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 08/03/18.
//

#import <UIKit/UIKit.h>
#import "SlikeGifBaseView.h"

@class SlikeGifBaseView;

@protocol SlikeGifPlayerDelegate<NSObject>
@optional
- (void)gifPlayerLoaded:(SlikeGifBaseView *)gifView;
- (void)gifPlayerStartPlaying:(SlikeGifBaseView *)gifView;
- (void)gifPlayerFailed:(NSError *)err;
- (void)gifPlayerReStarted;
- (void)gifPlayerUpdateTime:(SlikeGifBaseView *)gifView;

@end

@interface SlikeGifView : SlikeGifBaseView
@property(weak, nonatomic) id<SlikeGifPlayerDelegate>delegate;
@property (assign, nonatomic) NSInteger mp4Duration;

/*
 Load the Gif Player. Url should  be proper GIF
 */
- (void)loadGifPlayer:(NSString *)gifUrlString;
/*
 Load the Gif Player. Url should  be proper MP4
 */
- (void)loadMP4Player:(NSString *)playerUrlString;

/*
 Clean up the resurces acquired by the Payer
 */
- (void)cleanupGifResources;

/*
  Utility methods
 */

//Check whether the player is currently playing
- (BOOL)isPlaying;

//Play the GIF/MP4 file
- (void)playGif;

//Pause the GIF/MP4 file
- (void)pauseGif;

//Resume the player after the network interptions
- (void)resumeGifAfterNetworkIssue;

//Is player in full screen
- (BOOL)isPlayerInFullScreen;

//Change the Player size (YES - Making full screen , NO - Making the player in normal screen)
- (void)setFullscreen:(BOOL)fullscreen;

- (NSUInteger)gifMp4PlayerCurrentPosition;

@end
