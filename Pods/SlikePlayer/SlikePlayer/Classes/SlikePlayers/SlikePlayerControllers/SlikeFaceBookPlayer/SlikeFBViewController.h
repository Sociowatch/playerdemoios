//
//  SlikeFBViewController.h
//  SlikePlayer
//
//  Created by TIL on 05/12/167.
//  Copyright (c) 2017 BBDSL. All rights reserved.
//

#import "ISlikePlayer.h"
#import "SlikeFBVideoView.h"
#import "SlikeMaterialDesignSpinner.h"
@interface SlikeFBViewController : UIViewController <SlikeFBPlayerViewDelegate, ISlikePlayer>
{
    NSInteger nHideTime;
    BOOL isNavigationControllerAvailable;
    BOOL isFullScreenEnabled;
    BOOL isFullScreen;
    id playerContainer;
    
    BOOL  isPlayerFullScreen;
    BOOL isPlaying;
    
    NSInteger nBufferTime;
    NSInteger nPlayTime;
    
    NSInteger nTimeCode;
    NSInteger nStartTime;
    NSInteger nEndTime;
    SlikePlayerState playerStatus;
    
    NSInteger nTotalBufferDuration;
    NSInteger nTotalPlayedDuration;
    NSInteger nTotalBufferTimestamp;
    NSInteger nTotalPlayedTimestamp;
    BOOL isCompleted;
    NSInteger rpc;
    BOOL isNativeControls;
    NSInteger lastPlayerPostion;
    
}

@property (weak, nonatomic) IBOutlet UIButton *btnCloseInternet;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property(nonatomic, strong) IBOutlet SlikeFBVideoView *playerView;
@property (nonatomic, strong) IBOutlet UIButton *btnClose;

-(IBAction)clbClose:(id) sender;
@property (strong, nonatomic) IBOutlet UIView *noNetworkWindow;
@property (nonatomic,assign)     BOOL isNativeControls;
@property(nonatomic,assign) BOOL isUserPaused;
@property (weak, nonatomic) IBOutlet SlikeMaterialDesignSpinner *loadingView;


@end
