//
//  SlikeAdManager.h
//  Pods
//
//  Created by Sanjay Singh Rathor on 22/06/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SlikeAdsQueue;

OBJC_EXTERN NSString * const kSlikeAdDescriptionKey;
OBJC_EXTERN NSString * const kSlikeAdErrMessageKey;
OBJC_EXTERN NSString * const kSlikeAdErrCodeKey;
OBJC_EXTERN NSString * const kSlikeAdAdInfoKey;
OBJC_EXTERN NSString * const kSlikeAdAdTypeKey;


@interface SlikeAdManager : NSObject

/** Class method that gives access to the shared instance.
 */
+ (instancetype)sharedInstance;

/**
 Show the ad. This method needs to be used for prefetching or normal ads call
 
 @param slikeConfig -  Config model
 @param adsContainer - Ad container .
 @param position - PRE-(0)|POST-(-1)|MID
 */
- (void)showAd:(SlikeConfig *)slikeConfig adContainerView:(UIView *)adsContainer forAdPosition:(NSInteger)position;
@end
