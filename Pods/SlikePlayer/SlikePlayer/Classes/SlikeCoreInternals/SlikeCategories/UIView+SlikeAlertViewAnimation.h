//
//  UIView+SlikeAlertViewAnimation.h
//  Pods
//
//  Created by Sanjay Singh Rathor on 06/06/18.
//

#import <UIKit/UIKit.h>

@interface UIView (SlikeAlertViewAnimation)

- (void)removeAlertViewWithAnimation:(BOOL)withAnimation;
- (void)showAlertViewWithAnimation:(BOOL)withAnimation ;
- (void)addSubviewWithContstraints:(UIView *)containerView;

- (void)slike_appearState:(BOOL)appearState;
- (void)slike_fadeOut;
- (void)slike_fadeIn;
- (void)slike_fadeInAndCompletion:(void(^)(UIView *view))block;
- (void)slike_fadeOutAndCompletion:(void(^)(UIView *view))block;

- (void)slike_fadeInTime:(CGFloat)time withCompletion:(void(^)(UIView *view))block;
- (void)slike_fadeOutAndCompletion:(CGFloat)time withCompletion:(void(^)(UIView *view))block;

- (void)removeViewWithAnimationTime:(CGFloat)time  completion:(void(^)(void))block;
@end
