//
//  SlikeAnimatedImageView.h
//  Created by Sanjay.
//  Copyright (c) Times Internet. All rights reserved.


#import <UIKit/UIKit.h>

@class SlikeAnimatedImage;
@protocol SlikeAnimatedImageViewDebugDelegate;


//
//  An `SlikeAnimatedImageView` can take an `SlikeAnimatedImage` and plays it automatically when in view hierarchy and stops when removed.
//  The animation can also be controlled with the `UIImageView` methods `-start/stop/isAnimating`.
//  It is a fully compatible `UIImageView` subclass and can be used as a drop-in component to work with existing code paths expecting to display a `UIImage`.
//  Under the hood it uses a `CADisplayLink` for playback, which can be inspected with `currentFrame` & `currentFrameIndex`.
//
@interface SlikeAnimatedImageView : UIImageView

// Setting `[UIImageView.image]` to a non-`nil` value clears out existing `animatedImage`.
// And vice versa, setting `animatedImage` will initially populate the `[UIImageView.image]` to its `posterImage` and then start animating and hold `currentFrame`.
@property (nonatomic, strong) SlikeAnimatedImage *animatedImage;

@property (nonatomic, strong, readonly) UIImage *currentFrame;
@property (nonatomic, assign, readonly) NSUInteger currentFrameIndex;

- (void)playGifPlayer;
- (void)pauseGifPlayer;
- (BOOL)isGifPlaying;

#if DEBUG
// Only intended to report internal state for debugging
@property (nonatomic, weak) id<SlikeAnimatedImageViewDebugDelegate> debug_delegate;
#endif

@end


#if DEBUG
@protocol SlikeAnimatedImageViewDebugDelegate <NSObject>

@optional

- (void)debug_animatedImageView:(SlikeAnimatedImageView *)animatedImageView waitingForFrame:(NSUInteger)index duration:(NSTimeInterval)duration;

@end
#endif
