//
//  SlikeAnalyticInformation.m
//  Pods
//
//  Created by Aravind kumar on 5/8/17.
//
//

#import "SlikeAnalyticInformation.h"
#import "SlikeGlobals.h"
#import "SlikeConfig.h"

@interface SlikeAnalyticInformation() {
    
}

@end

@implementation SlikeAnalyticInformation

- (id)init {
    
    if (self = [super init]) {
        [self initializeData];
    }
    return self;
}

- (void) initializeData {
    self.isForce = YES;
    self.nTotalPlayedDuration = 0L;
    self.nTotalBufferDuration = 0L;
    self.rpc = 0L;
    self.rid = @"";
}
- (id)initWithAnalyticInformation:(SlikePlayerState)playerState isForced:(BOOL)force withPlayTime:(NSInteger)nPlayTime withBD:(NSInteger) bd  withConfig:(SlikeConfig*)slikeConfig withReplayCount:(NSInteger)replayCount withRId:(NSString*)rid {
    
    self.state = playerState;
    self.isForce = force;
    self.nTotalPlayedDuration = nPlayTime;
    self.nTotalBufferDuration = bd;
    self.config = slikeConfig;
    self.rpc = replayCount;
    self.rid = rid;
    return self;
}
@end
