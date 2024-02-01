//
//  NewYTViewController.h
//  SlikePlayer
//
//  Created by TIL on 08/08/16.
//  Copyright (c) 2014 BBDSL. All rights reserved.
//


#import "ISlikePlayer.h"
#import "SLWKYTPlayerView.h"

@interface NewYTViewController : UIViewController<SLWKYTPlayerViewDelegate, ISlikePlayer>
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
@property (weak, nonatomic) IBOutlet UILabel *noNetworkLbl;
@property(nonatomic, strong) IBOutlet SLWKYTPlayerView *playerView;
@property(nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) IBOutlet UIButton *btnClose;

-(IBAction)clbClose:(id) sender;
@property (strong, nonatomic) IBOutlet UIView *noNetworkWindow;
@property (nonatomic,assign)     BOOL isNativeControls;
@property(nonatomic,assign) BOOL isUserPaused;
@property (weak, nonatomic) IBOutlet UIButton *btncloseInternet;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;


@end
