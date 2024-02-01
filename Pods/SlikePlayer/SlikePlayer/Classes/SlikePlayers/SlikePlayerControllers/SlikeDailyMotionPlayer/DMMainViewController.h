//
//  DMMainViewController.h
//  Pods
//
//  Created by Aravind kumar on 4/24/17.
//
//

#import <UIKit/UIKit.h>
#import "DMPlayerViewController.h"
#import "ISlikePlayer.h"

@interface DMMainViewController : UIViewController <DMPlayerDelegate, ISlikePlayer> {
    
    NSInteger nHideTime;
    BOOL isNavigationControllerAvailable;
    BOOL isFullScreenEnabled;
    BOOL isFullScreen;
    BOOL isPlayerFullScreen;
    BOOL isVideoEnd;
    BOOL isNativeControls;
    
    id playerContainer;
    SlikePlayerState playerStatus;
    NSInteger nBufferTime;
    NSInteger nPlayTime;
    NSInteger nTotalBufferDuration;
    NSInteger nTotalPlayedDuration;
    NSInteger nTotalBufferTimestamp;
    NSInteger nTotalPlayedTimestamp;
    NSInteger rpc;
}

@property (weak, nonatomic) IBOutlet DMPlayerViewController *playerView;
@property (nonatomic,assign) BOOL isNativeControls;

@end
