//
//  SJRotationManagerProtocol.h

#ifndef SJRotationManagerProtocol_h
#define SJRotationManagerProtocol_h

#import <UIKit/UIKit.h>
@protocol SJRotationManagerProtocol;
/**
 - SJOrientation_Portrait:
 - SJOrientation_LandscapeLeft:
 - SJOrientation_LandscapeRight:
 */
typedef NS_ENUM(NSUInteger, SJOrientation) {
    SJOrientation_Portrait,
    SJOrientation_LandscapeLeft,  // UIDeviceOrientationLandscapeLeft
    SJOrientation_LandscapeRight, // UIDeviceOrientationLandscapeRight
};

/**
 - SJAutoRotateSupportedOrientation_Portrait:
 - SJAutoRotateSupportedOrientation_LandscapeLeft:
 - SJAutoRotateSupportedOrientation_LandscapeRight:
 - SJAutoRotateSupportedOrientation_All:
 */
typedef NS_ENUM(NSUInteger, SJAutoRotateSupportedOrientation) {
    SJAutoRotateSupportedOrientation_Portrait = 1 << 0,
    SJAutoRotateSupportedOrientation_LandscapeLeft = 1 << 1,  // UIDeviceOrientationLandscapeLeft
    SJAutoRotateSupportedOrientation_LandscapeRight = 1 << 2, // UIDeviceOrientationLandscapeRight
    SJAutoRotateSupportedOrientation_All = SJAutoRotateSupportedOrientation_Portrait | SJAutoRotateSupportedOrientation_LandscapeLeft | SJAutoRotateSupportedOrientation_LandscapeRight,
};


NS_ASSUME_NONNULL_BEGIN
@protocol SJRotationManagerDelegate<NSObject>
- (void)rotationManager:(id<SJRotationManagerProtocol>)manager willRotateView:(BOOL)isFullscreen;
- (void)rotationManager:(id<SJRotationManagerProtocol>)manager didRotateView:(BOOL)isFullscreen;
@end


@protocol SJRotationManagerProtocol<NSObject>
@property (nonatomic, weak, nullable) id<SJRotationManagerDelegate> delegate;
@property (nonatomic) BOOL disableAutorotation;
@property (nonatomic) SJAutoRotateSupportedOrientation autorotationSupportedOrientation;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, readonly) SJOrientation currentOrientation;

@property (nonatomic, readonly) BOOL isFullscreen;
@property (nonatomic, readonly) BOOL transitioning;

- (void)rotate;
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated;

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void(^)(id<SJRotationManagerProtocol> mgr))completionHandler;

@property (nonatomic, weak, nullable) UIView *superview;
@property (nonatomic, weak, nullable) UIView *target;
/// The block invoked when orientation will changed, if return YES, auto rotate will be triggered
@property (nonatomic, copy, nullable) BOOL(^rotationCondition)(id<SJRotationManagerProtocol> mgr);
@end
NS_ASSUME_NONNULL_END

#endif
