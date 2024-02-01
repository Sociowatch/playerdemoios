//
//  SlikeIMAAdController.h
//  Pods
//
//  Created by Sanjay Singh Rathor on 22/06/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SlikeAdPlateformEvents.h"
#import "ISlikeAds.h"

@class SlikeConfig;
@class SlikeAdsUnit;

@interface SlikeIMAAdController : NSObject<ISlikeAds>

- (instancetype)initWithAdContainerView:(UIView *)parentView withAd:(SlikeAdsUnit *)adInfo delegate:(id<SlikeAdPlateformEvents>)delegate;

/**
 Remove All the Acquired Resources
 */
- (void)removeAdsComponents:(void (^)(void))completionBlock;

@end
