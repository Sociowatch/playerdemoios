//
//  SlikeTimerControl.h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SlikeTimerControl : NSObject

/// default is 3;
@property (nonatomic, assign, readwrite) short interval;
@property (nonatomic, assign, readwrite) short counter;


@property (nonatomic, copy, readwrite, nullable) void(^executionBlock)(SlikeTimerControl *control);

- (void)start;

- (void)repeat;

- (void)clear;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
