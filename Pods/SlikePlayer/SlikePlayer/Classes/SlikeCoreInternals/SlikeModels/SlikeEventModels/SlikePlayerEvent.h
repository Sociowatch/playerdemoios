//
//  SlikePlayerEvent.h
//  Pods
//
//  Created by Sanjay Singh Rathor on 13/07/18.
//

#import <Foundation/Foundation.h>
#import "SlikeGlobals.h"

@interface SlikePlayerEvent : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *eventType;
@property (nonatomic, assign) NSInteger playerType;
@property (nonatomic, assign) NSInteger replayCount;
@property (nonatomic, assign) long urts;
@property (nonatomic, assign) long uopts;
@property (nonatomic, assign) long playerDuration;
@property (nonatomic, assign) long playerPosition;
@property (nonatomic, assign) NSInteger currentPlayer;
@property (nonatomic, strong) NSString *streamFlavour;
@property (nonatomic, assign) BOOL isFullscreen;
@property(nonatomic, assign) SlikePlayerState playerState;
@end
