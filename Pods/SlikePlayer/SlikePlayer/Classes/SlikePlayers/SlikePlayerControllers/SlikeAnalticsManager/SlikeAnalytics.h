//
//  AnalyticController.h
//  Pods
//
//  Created by Aravind kumar on 5/25/17.
//
//

#import <Foundation/Foundation.h>
#import "SLEventModel.h"

@interface SlikeAnalytics : NSObject {
}

+ (instancetype)sharedManager;

/**
 Regiter the class to liten the events
 */
- (void)registerAnalyticsToListenEvents;
- (void)sendEvent:(NSString*)category Action:(NSString*)action Label:(NSString*)label;
- (void)addComScoreMetaDataAd:(SlikeConfig*)config adLength:(NSInteger)ad_length  adType:(NSInteger)adtype  adStatus:(NSInteger) state;
-(void)sendGAAnalytics:(SLEventModel *)eventModel;
-(void)processVideoRequest:(SlikeConfig*)slikeConfigModel;
-(NSString*)sendSlikePlayerAnalytics:(SlikeEventType)eventType playerState:(SlikePlayerState)state dataPayload:(SLEventModel *)eventModel withCurrentPlayerTime:(NSInteger)pCurrentTime;
@end
