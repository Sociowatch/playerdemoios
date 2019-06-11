//
//  ISlikeAds.h
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 28/06/18.
//

#ifndef ISlikeAds_h
#define ISlikeAds_h
#endif /* ISlikeAds_h */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SlikeAdPlateformEvents.h"

@class SlikeAdsUnit;

typedef NS_ENUM(NSInteger, SlikeAdsPlatform) {
    SlikeAdsPlatformIMA = 0,
    SlikeAdsPlatformFacebook,
    SlikeAdsPlatformCount
};

@protocol ISlikeAds<NSObject>
@property(nonatomic, weak) SlikeConfig *slikeConfigModel;

- (void)playAd;
- (void)fetchAd;
- (void)removeAdsComponents;
- (SlikeAdsPlatform)currentAdPlateform;

- (void)resumeAd;
- (void)pauseAd;

@end
