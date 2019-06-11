//
//  ISlikeAnlytic.h
//  Pods
//
//  Created by Aravind kumar on 9/27/17.
//
//

#import <Foundation/Foundation.h>
#import "SlikeConfig.h"

@protocol ISlikeAnlytics

typedef NS_ENUM(NSInteger, AnalyticMode) {
    AnalyticMode_GA = 0,
    AnalyticMode_COMSCORE = 1
};

- (id)init:(id) tracker;
- (void) setId:(NSString*)strId subId:(NSString*)strSubId Type:(AnalyticMode)type;
- (AnalyticMode) getType;
- (NSString*) getId;
- (void)sendEvent:(NSString*)category Action:(NSString*)action Label:(NSString*)label Value:(NSNumber*)value;
- (void)addComScoreMetaDataAd:(SlikeConfig*)config adLength:(NSInteger)ad_length  adType:(NSInteger)adtype  PlayerStatus:(SlikePlayerState) state;
- (void)addComScoreMetaDataVideo:(SlikeConfig*)config PlayerStatus:(SlikePlayerState) state;
@end
