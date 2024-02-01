//
//  SlikeVideoPlayerRegistrar.h
//
//  Created by Sanjay
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SlikeVideoPlayerAppState) {
    SlikeVideoPlayerAppState_ResignActive,
    SlikeVideoPlayerAppState_BecomeActive,
    SlikeVideoPlayerAppState_Forground,
    SlikeVideoPlayerAppState_Background
};

@interface SlikeVideoPlayerRegistrar : NSObject

@property (nonatomic, assign, readonly) SlikeVideoPlayerAppState state;

@property (nonatomic, copy, readwrite, nullable) void(^willResignActive)(SlikeVideoPlayerRegistrar *registrar);

@property (nonatomic, copy, readwrite, nullable) void(^didBecomeActive)(SlikeVideoPlayerRegistrar *registrar);

@property (nonatomic, copy, readwrite, nullable) void(^willEnterForeground)(SlikeVideoPlayerRegistrar *registrar);

@property (nonatomic, copy, readwrite, nullable) void(^didEnterBackground)(SlikeVideoPlayerRegistrar *registrar);

@property (nonatomic, copy, readwrite, nullable) void(^newDeviceAvailable)(SlikeVideoPlayerRegistrar *registrar);

@property (nonatomic, copy, readwrite, nullable) void(^oldDeviceUnavailable)(SlikeVideoPlayerRegistrar *registrar);

@property (nonatomic, copy, readwrite, nullable) void(^categoryChange)(SlikeVideoPlayerRegistrar *registrar);

@property (nonatomic, copy, readwrite, nullable) void(^audioSessionInterruption)(SlikeVideoPlayerRegistrar *registrar);

@end

NS_ASSUME_NONNULL_END
