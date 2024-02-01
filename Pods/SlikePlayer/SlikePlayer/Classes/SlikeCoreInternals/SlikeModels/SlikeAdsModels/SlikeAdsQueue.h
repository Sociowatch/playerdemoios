//
//  SlikeAdsQueue.h
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 25/05/18.
//

#import <Foundation/Foundation.h>

@class SlikeAdsUnit;


@interface SlikeAdsQueue : NSObject

/**
 Start position for the Ad
 */
@property(nonatomic, assign) NSInteger startPoistion;

/**
 Current ad type Pre|Mid|Post
 */
@property(nonatomic, assign) SlikeAdType adType;

/**
  Ad contents Array
 */
@property(nonatomic, strong) NSMutableArray<SlikeAdsUnit *> *adContents;
@property(nonatomic, strong) NSMutableArray<SlikeAdsUnit *> *staticAdContents;

/**
 Skip Counter
 */
@property(nonatomic, assign) NSInteger skipCounter;


/**
 Prefetch the Ad. If this property is TRUE then ads will be prefetched and will not be played auto otherwise ad will be played after downloaded
 */
@property(nonatomic, assign) BOOL prefetch;


/**
 Is Ad has already plyed
 */
@property(nonatomic, assign) BOOL isPlayed;

/**
 Utility method for setting the Ad info

 @param start - Start Position of ad
 @param adsUnit - Ad Unit info
 */
- (void)addPosition:(NSInteger) start withAdUnit:(SlikeAdsUnit *)adsUnit;

@end
