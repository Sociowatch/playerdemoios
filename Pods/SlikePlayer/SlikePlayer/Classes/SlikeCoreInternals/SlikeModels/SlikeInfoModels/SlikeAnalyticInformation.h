//
//  SlikeAnalyticInformation.h
//  Pods
//
//  Created by Aravind kumar on 5/8/17.
//
//

#import <Foundation/Foundation.h>
@class SlikeConfig;
@class SlikeGlobals;


@interface SlikeAnalyticInformation : NSObject

- (id)initWithAnalyticInformation:(SlikePlayerState)playerState isForced:(BOOL)force withPlayTime:(NSInteger)nPlayTime withBD:(NSInteger) bd  withConfig:(SlikeConfig*)slikeConfig withReplayCount:(NSInteger)replayCount withRId:(NSString*)rid;

@property(nonatomic, assign) SlikePlayerState state;
@property(nonatomic, assign) BOOL isForce;
@property(nonatomic, assign) NSInteger nTotalPlayedDuration;
@property(nonatomic, assign) NSInteger nTotalBufferDuration;
@property(nonatomic, strong) SlikeConfig *config;
@property(nonatomic, assign) NSInteger rpc;
@property(nonatomic, strong) NSString * rid;


@end

