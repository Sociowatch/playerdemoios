//
//  SlikeAvPlayerViewController+Helper.m
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 30/05/18.
//

#import "SlikeAvPlayerViewController+Helper.h"
#import "SlikePlayerConstants.h"
#import "SlikeAvPlayerViewController.h"

@implementation SlikeAvPlayerViewController (Helper)

/**
 Add Player Observer
 */
- (void)registerPlayerObservers {
    
   // [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateReadyNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStatePlayNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateStartNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateBufferingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateBufferingEndedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStatePauseNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateStopNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateSeekStartNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateSeekEndNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateSeekFailedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateUpdateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateTimeUpdateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateFinishedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStatePlaybackErrorNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateDurationUpdateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerLoadedTimeRangesNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateFullScreenNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateSeekUpdateNotification object:nil];
    
    
}

- (void)unRegisterPlayerObservers {

    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateReadyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStatePlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateBufferingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStatePauseNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateBufferingEndedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateStopNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateSeekStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateSeekEndNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateSeekFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateTimeUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStatePlaybackErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateDurationUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateFullScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerLoadedTimeRangesNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateSeekUpdateNotification object:nil];
    
}

@end
