//
//  SlikeGestureUI.h
//  Pods
//
//  Created by Sanjay Singh Rathor on 08/06/18.
//

#import <Foundation/Foundation.h>
#import "ISlikePlayer.h"

@interface SlikeGestureUI : NSObject

- (instancetype)initWithGestureUI:(UIView *)parentView slikePlayer:(id<ISlikePlayer>)currentPlayer withSeekEnabled:(BOOL)seekEnabled;

/**
 Listen the Gesture events
 @param isListeningRequired - YES|NO
 */
- (void)listenForGestureEvents:(BOOL)isListeningRequired;
//- (void)updateFramesForFullScreen:(BOOL)isFullScreen;
@end
