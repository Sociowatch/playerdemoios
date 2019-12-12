//
//  SlikeAdsQueue.m
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 25/05/18.
//

#import "SlikeAdsQueue.h"

@implementation SlikeAdsQueue

- (id)init {
    
    if (self = [super init]) {
        _startPoistion = 0L;
        _adContents = [[NSMutableArray alloc]init];
        _staticAdContents = [[NSMutableArray alloc]init];
        _skipCounter = 0L;
        _isPlayed = NO;
        _adType = SL_NONE;
    }
    return self;
}

/**
 Utility method for setting the Ad info
 
 @param start - Start Position of ad
 @param adsUnit - Ad Unit info
 */

- (void)addPosition:(NSInteger)start withAdUnit:(SlikeAdsUnit *)adsUnit {
     self.startPoistion = start;
    [self.adContents addObject:adsUnit];
    [self.staticAdContents addObject:adsUnit];
}

@end
