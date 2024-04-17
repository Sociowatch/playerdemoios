//
//  DemoViewController.m
//  slikeplayerdemoios
//
//  Created by Aravind Kumar on 05/09/18.
//  Copyright © 2018 BBDSL. All rights reserved.
//

#import "DemoViewController.h"
//#import "SlikeMusicListViewController.h"


@interface DemoViewController ()
{
}
@property (weak, nonatomic) IBOutlet UIView *playerAreaView;
@property (strong, nonatomic) SWConfig *swConfig;
@property (strong, nonatomic) SWPlayer *swPlayer;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    if(_slikeConfigPrevious) {
        [self startPlayerPreviousMethod];
    }
    else if(self.playType == 0) {
        [self startPlayer];
    }else if(self.playType == 1) {
        [self startPlayerYoutube];
        
    }else if(self.playType == 2) {
        [self startPlayerYoutubeOutSide];
    }
    else if(self.playType == 4) {
        [self startFBPlayerSlikeId];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Slike Player
-(void)startPlayer {
    //1xwrad3ugg
    self.swConfig = [[SWConfig alloc] initWithChannel:@"swPlayer" withID:@"1xwrad3ugg" withSection:@"default" withMSId:@"56087249" posterImage:@""];
    _swConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    _swConfig.pid = @"101";
    _swConfig.shareText = @"";
    _swConfig.isSkipAds =  NO;
    _swConfig.section =  @"default";
    _swConfig.pageTemplate =  @"home/api/test";
    _swConfig.isFullscreenControl =  YES;
    _swConfig.autorotationMode  =
    SWFullscreenAutorotationModeLandscape;
    _swConfig.preview =  YES;
    _swConfig.isCloseControl = NO;
    _swConfig.isAllowSWPlaceHolder =  YES;
    _swConfig.appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.swPlayer = [SWPlayer sharedSWPlayer];
    [_swPlayer playVideo:_swConfig inParentView:self.playerAreaView withProgressHandler:^(SWEventType eventType, SWPlayerState playerState, StatusInfo *statusInfo) {
        
        NSLog(@"PARENT EVENT: (AD) ===> [adTypeEnum - %ld]", (long)statusInfo.adStatusInfo.adTypeEnum);
        
        if (eventType == AD) {
            
            //            NSLog(@"PARENT EVENT: (AD) ===> [position - %ld]", statusInfo.position);
            //            NSLog(@"PARENT EVENT: (AD) ===> [duration - %ld]", (long)statusInfo.duration);
            //            NSLog(@"PARENT EVENT: (AD) ===> [adTypeEnum - %ld]", (long)statusInfo.adStatusInfo.adTypeEnum);
            
        }
        else if (eventType == CONTROLS && playerState == SL_SHARE) {
            
            //Pause the player. Pause:FALSE (User has not paused the video. It is Paused by activity)
            //Input share logic
            //            if([[_swPlayer getAnyPlayer] isPlaying])
            //            [[_swPlayer getAnyPlayer] pause:NO];
            //            else  [[_swPlayer getAnyPlayer] play:NO];
            
        }
        else if (eventType == CONTROLS && playerState == SL_CLOSE) {
            [self stopPlayer];
        }
        
        else if (eventType == MEDIA) {
            NSLog(@"PARENT EVENT: (MEDIA) ===> [SWPlayerState - %ld]", (long)playerState);
        }
    }];
}

#pragma mark Slike Player Youtube
-(void)startPlayerYoutube {
    self.swConfig = [[SWConfig alloc] initWithChannel:@"sw" withID:@"4x1ea3pazg" withSection:@"default" withMSId:@"56087249" posterImage:@""];
    _swConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    _swConfig.pid = @"101";
    _swConfig.shareText = @"";
    _swConfig.isSkipAds =  NO;
    _swConfig.section =  @"default";
    _swConfig.pageTemplate =  @"home/api/test";
    _swConfig.isFullscreenControl =  YES;
    _swConfig.muteControlEnable =  YES;
    _swConfig.autorotationMode  =
    SWFullscreenAutorotationModeLandscape;
    _swConfig.preview =  YES;
    _swConfig.isGestureEnable = YES;
    _swConfig.appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.swPlayer = [SWPlayer sharedSWPlayer];
    [_swPlayer playVideo:_swConfig inParentView:self.playerAreaView withProgressHandler:^(SWEventType eventType, SWPlayerState playerState, StatusInfo *statusInfo) {
        
        if (eventType == AD) {
            
            NSLog(@"PARENT EVENT: (AD) ===> [position - %ld]", statusInfo.position);
            NSLog(@"PARENT EVENT: (AD) ===> [duration - %ld]", (long)statusInfo.duration);
            NSLog(@"PARENT EVENT: (AD) ===> [adTypeEnum - %ld]", (long)statusInfo.adStatusInfo.adTypeEnum);
            
        }
        else if (eventType == CONTROLS && playerState == SL_SHARE) {
            
            //Pause the player. Pause:FALSE (User has not paused the video. It is Paused by activity)
            //Input share logic
        }
        
        else if (eventType == MEDIA) {
            NSLog(@"PARENT EVENT: (MEDIA) ===> [SWPlayerState - %ld]", (long)playerState);
        }
    }];
}
#pragma mark Slike Player Direct Youtube
-(void)startPlayerYoutubeOutSide {
    //youtube ID
    
    self.swConfig =  [SWConfig createConfigForType:VIDEO_SOURCE_YT mediaTitle:@"Seagram’s 100 Pipers | The Legacy Project" mediaURL:@"cv8UocAT87c" posterURL:@"" isAutoPlay:YES];
    _swConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    _swConfig.pid = @"101";
    _swConfig.shareText = @"Toi.in";
    _swConfig.isSkipAds =  YES;
    _swConfig.section =  @"default";
    _swConfig.pageTemplate =  @"home/api/test";
    _swConfig.isFullscreenControl =  YES;
    _swConfig.autorotationMode  =
    SWFullscreenAutorotationModeLandscape;
    _swConfig.preview =  YES;
    _swConfig.appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.swPlayer = [SWPlayer sharedSWPlayer];
    [_swPlayer playVideo:_swConfig inParentView:self.playerAreaView withProgressHandler:^(SWEventType eventType, SWPlayerState playerState, StatusInfo *statusInfo) {
        
        if (eventType == AD) {
            
            NSLog(@"PARENT EVENT: (AD) ===> [position - %ld]", statusInfo.position);
            NSLog(@"PARENT EVENT: (AD) ===> [duration - %ld]", (long)statusInfo.duration);
            NSLog(@"PARENT EVENT: (AD) ===> [adTypeEnum - %ld]", (long)statusInfo.adStatusInfo.adTypeEnum);
            
        }
        else if (eventType == CONTROLS && playerState == SL_SHARE) {
            
            //Pause the player. Pause:FALSE (User has not paused the video. It is Paused by activity)
            //Input share logic
        }
        
        else if (eventType == MEDIA) {
            NSLog(@"PARENT EVENT: (MEDIA) ===> [SWPlayerState - %ld]", (long)playerState);
        }
    }];
}
-(void)stopPlayer {
    [_swPlayer stopPlayer];
    self.swPlayer =  nil;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        // Do your stuff here
        [self stopPlayer];
    }
}
-(void)dealloc
{
    [self stopPlayer];
}
-(void)startPlayerPreviousMethod {
    self.swPlayer = [SWPlayer sharedSWPlayer];
    [_swPlayer playVideo:_slikeConfigPrevious inParentView:self.playerAreaView withProgressHandler:^(SWEventType eventType, SWPlayerState playerState, StatusInfo *statusInfo) {
        
        if (eventType == AD) {
            
            NSLog(@"PARENT EVENT: (AD) ===> [position - %ld]", statusInfo.position);
            NSLog(@"PARENT EVENT: (AD) ===> [duration - %ld]", (long)statusInfo.duration);
            NSLog(@"PARENT EVENT: (AD) ===> [adTypeEnum - %ld]", (long)statusInfo.adStatusInfo.adTypeEnum);
            
        }
        else if (eventType == CONTROLS && playerState == SL_SHARE) {
            
            //Pause the player. Pause:FALSE (User has not paused the video. It is Paused by activity)
            //Input share logic
            //            if([[_swPlayer getAnyPlayer] isPlaying])
            //            [[_swPlayer getAnyPlayer] pause:NO];
            //            else  [[_swPlayer getAnyPlayer] play:NO];
            
        }
        
        else if (eventType == MEDIA) {
            NSLog(@"PARENT EVENT: (MEDIA) ===> [SWPlayerState - %ld]", (long)playerState);
        }
    }];
}

-(void)startFBPlayerSlikeId {
    //1xwrad3ugg
    self.swConfig = [[SWConfig alloc] initWithChannel:@"swplayer" withID:@"1xwmdv1kll" withSection:@"default" withMSId:@"56087249" posterImage:@""];
    _swConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    _swConfig.pid = @"101";
    _swConfig.shareText = @"";
    _swConfig.isSkipAds =  NO;
    _swConfig.section =  @"default";
    _swConfig.pageTemplate =  @"home/api/test";
    _swConfig.isFullscreenControl =  YES;
    _swConfig.autorotationMode  =
    SWFullscreenAutorotationModeLandscape;
    _swConfig.preview =  YES;
    _swConfig.isCloseControl = NO;
    _swConfig.isAllowSWPlaceHolder =  YES;
    _swConfig.appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.swPlayer = [SWPlayer sharedSWPlayer];
    [_swPlayer playVideo:_swConfig inParentView:self.playerAreaView withProgressHandler:^(SWEventType eventType, SWPlayerState playerState, StatusInfo *statusInfo) {
        
        NSLog(@"PARENT EVENT: (AD) ===> [adTypeEnum - %ld]", (long)statusInfo.adStatusInfo.adTypeEnum);
        
        if (eventType == AD) {
            
            //            NSLog(@"PARENT EVENT: (AD) ===> [position - %ld]", statusInfo.position);
            //            NSLog(@"PARENT EVENT: (AD) ===> [duration - %ld]", (long)statusInfo.duration);
            //            NSLog(@"PARENT EVENT: (AD) ===> [adTypeEnum - %ld]", (long)statusInfo.adStatusInfo.adTypeEnum);
            
        }
        else if (eventType == CONTROLS && playerState == SL_SHARE) {
            
            //Pause the player. Pause:FALSE (User has not paused the video. It is Paused by activity)
            //Input share logic
            //            if([[_swPlayer getAnyPlayer] isPlaying])
            //            [[_swPlayer getAnyPlayer] pause:NO];
            //            else  [[_swPlayer getAnyPlayer] play:NO];
            
        }
        else if (eventType == CONTROLS && playerState == SL_CLOSE) {
            [self stopPlayer];
        }
        
        else if (eventType == MEDIA) {
            NSLog(@"PARENT EVENT: (MEDIA) ===> [SWPlayerState - %ld]", (long)playerState);
        }
    }];
}

@end

