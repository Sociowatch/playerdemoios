//
//  SlikeOrientationObserver.h
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 04/06/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SlikeOrientationType) {
    SlikeOrientationTypeiPhone = 0,
    SlikeOrientationTypeiPad
};

@interface SlikeOrientationObserver : NSObject

- (instancetype)initWithTarget:(UIViewController *)viewController rotationCondition:(BOOL(^)(SlikeOrientationObserver *observer))rotationCondition;

/// The block invoked when orientation will changed, if return YES, auto rotate will be triggered
@property (nonatomic, copy, nullable) BOOL(^rotationCondition)(SlikeOrientationObserver *observer);
@property (nonatomic,readwrite) BOOL fullScreen;
@property (nonatomic,assign) SlikeOrientationType orientationType;


/// The block invoked when orientation changed
@property (nonatomic, copy, readwrite, nullable) void(^orientationWillChange)(SlikeOrientationObserver *observer, BOOL isFullScreen);
@property (nonatomic, copy, nullable) void(^orientationChanged)(SlikeOrientationObserver *observer, BOOL isFullScreen);
@property (strong, nonatomic)UIColor *backWindowColor;
- (void)rotateDevice;
- (void)changePlayerSize;

@end


NS_ASSUME_NONNULL_END
