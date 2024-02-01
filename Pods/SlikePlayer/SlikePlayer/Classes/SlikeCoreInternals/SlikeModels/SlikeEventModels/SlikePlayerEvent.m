//
//  SlikePlayerEvent.m
//  Pods
//
//  Created by Sanjay Singh Rathor on 13/07/18.
//

#import "SlikePlayerEvent.h"

@implementation SlikePlayerEvent

- (instancetype)init {
    self = [super init];
    
    _type = @"tpu";
    _eventType = @"";
    _replayCount =0;
    _urts = 0;
    _uopts = 0;
    _playerType = 0;
    _playerDuration = 0;
    _playerPosition = 0;
    _currentPlayer = 0;
    _streamFlavour = @"";
    _isFullscreen = NO;
    
    return self;
}

@end
