//
//  UIView+SlikeAlertViewAnimation.m
//  Pods
//
//  Created by Sanjay Singh Rathor on 06/06/18.
//

#import "UIView+SlikeAlertViewAnimation.h"

@implementation UIView (SlikeAlertViewAnimation)

/**
 Remove the alert view  from the parent View
 @param withAnimation - Is Animation Required
 */
- (void)removeAlertViewWithAnimation:(BOOL)withAnimation {
    
    if (withAnimation) {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             self.alpha = 0;
                         }completion:^(BOOL finished){
                             [self removeFromSuperview];
                             
                         }];
    } else {
        self.alpha = 0;
        [self removeFromSuperview];
    }
}


/**
 Show the alert View with the animation
 @param withAnimation - Is Animation required
 */
- (void)showAlertViewWithAnimation:(BOOL)withAnimation {
    if (withAnimation) {
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.alpha = 1;
                         }completion:^(BOOL finished){
                         }];
    } else {
        self.alpha = 1;
    }
}

/**
 Add Subview  and also all the constraints  to match the size with the parent
 @param containerView - Container View
 */
- (void)addSubviewWithContstraints:(UIView *)containerView {
    
    containerView.translatesAutoresizingMaskIntoConstraints=NO;
    [self addSubview:containerView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(containerView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[containerView]-0-|" options:0 metrics:nil views:views]];
    
    [self  addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[containerView]-0-|" options:0 metrics:nil views:views]];
}

- (void)slike_fadeIn {
    [self slike_fadeInAndCompletion:nil];
}

- (void)slike_fadeOut {
    [self slike_fadeOutAndCompletion:nil];
}

- (void)slike_fadeInAndCompletion:(void(^)(UIView *view))block {
    self.alpha = 0.001;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        if ( block ) block(self);
    }];
}

- (void)slike_fadeOutAndCompletion:(void(^)(UIView *view))block {
    self.alpha = 1;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.001;
    } completion:^(BOOL finished) {
        if ( block ) block(self);
    }];
}

- (void)slike_appearState:(BOOL)appearState {
    self.alpha = appearState ? 0.0:1.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = appearState ? 1.0 : 0.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)slike_fadeInTime:(CGFloat)time withCompletion:(void(^)(UIView *view))block {
    self.alpha = 0.001;
    [UIView animateWithDuration:time animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        if ( block ) block(self);
    }];
}

- (void)slike_fadeOutAndCompletion:(CGFloat)time withCompletion:(void(^)(UIView *view))block {
    self.alpha = 1;
    [UIView animateWithDuration:time animations:^{
        self.alpha = 0.001;
    } completion:^(BOOL finished) {
        if ( block ) block(self);
    }];
}
 
- (void)removeViewWithAnimationTime:(CGFloat)time  completion:(void(^)(void))block {
   
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionCrossDissolve;
        [UIView transitionWithView:self
                          duration:time
                           options:options
                        animations:^{
                            self.alpha = 0;
                        }
                        completion:^(BOOL finished){
                            [self removeFromSuperview];
                            block();
                        }];
    });
}

@end
