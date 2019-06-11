//
//  SlikeFANAdController.h
//  Pods
//
//  Created by Sanjay Singh Rathor on 22/06/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ISlikeAds.h"

@class SlikeConfig;
@class SlikeAdsUnit;

@interface SlikeFANAdController : NSObject<ISlikeAds>

- (instancetype)initWithAdContainerView:(UIView *)parentView withAd:(SlikeAdsUnit *)adModel delegate:(id<SlikeAdPlateformEvents>)delegate;

/**
 Remove All the Acquired Resources
 */
- (void)removeAdsComponents;
@end
