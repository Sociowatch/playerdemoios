//
//  DemoViewController.m
//  slikeplayerdemoios
//
//  Created by Aravind Kumar on 05/09/18.
//  Copyright © 2018 BBDSL. All rights reserved.
//

#import "DemoViewController.h"


@interface DemoViewController ()
{
}
@property (weak, nonatomic) IBOutlet UIView *playerAreaView;
@property (strong, nonatomic) SlikeConfig *slikeConfig;
@property (strong, nonatomic) SlikePlayer *slikePlayer;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(_slikeConfigPrevious)
    {
        [self startPlayerPreviousMethod];
    }
    else if(self.playType == 0)
    {
        [self startPlayer];
    }else if(self.playType == 1)
    {
        [self startPlayerYoutube];
        
    }else if(self.playType == 2)
    {
        [self startPlayerYoutubeOutSide];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Slike Player
-(void)startPlayer
{
    //1xwrad3ugg
    self.slikeConfig = [[SlikeConfig alloc] initWithChannel:@"slike" withID:@"1xwrad3ugg" withSection:@"default" withMSId:@"56087249" posterImage:@""];
    _slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    _slikeConfig.pid = @"101";
    _slikeConfig.shareText = @"";
    _slikeConfig.isSkipAds =  NO;
    _slikeConfig.section =  @"default";
    _slikeConfig.pageTemplate =  @"home/api/test";
    _slikeConfig.isFullscreenControl =  YES;
    _slikeConfig.autorotationMode  =
    SlikeFullscreenAutorotationModeLandscape;
    _slikeConfig.preview =  YES;
    _slikeConfig.isCloseControl = NO;
    _slikeConfig.isAllowSlikePlaceHolder =  YES;
    _slikeConfig.appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.slikePlayer = [SlikePlayer sharedSlikePlayer];
    [_slikePlayer playVideo:_slikeConfig inParentView:self.playerAreaView withProgressHandler:^(SlikeEventType eventType, SlikePlayerState playerState, StatusInfo *statusInfo) {
        
        if (eventType == AD) {
            
            NSLog(@"PARENT EVENT: (AD) ===> [position - %ld]", statusInfo.position);
            NSLog(@"PARENT EVENT: (AD) ===> [duration - %ld]", (long)statusInfo.duration);
            NSLog(@"PARENT EVENT: (AD) ===> [adTypeEnum - %ld]", (long)statusInfo.adStatusInfo.adTypeEnum);
            
        }
        else if (eventType == CONTROLS && playerState == SL_SHARE) {
            
            //Pause the player. Pause:FALSE (User has not paused the video. It is Paused by activity)
            //Input share logic
//            if([[_slikePlayer getAnyPlayer] isPlaying])
//            [[_slikePlayer getAnyPlayer] pause:NO];
//            else  [[_slikePlayer getAnyPlayer] play:NO];
                
        }
        
        else if (eventType == MEDIA) {
            NSLog(@"PARENT EVENT: (MEDIA) ===> [SlikePlayerState - %ld]", (long)playerState);
        }
    }];
}

#pragma mark Slike Player Youtube
-(void)startPlayerYoutube
{
    self.slikeConfig = [[SlikeConfig alloc] initWithChannel:@"slike" withID:@"1xn1487gk9" withSection:@"default" withMSId:@"56087249" posterImage:@""];
    _slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    _slikeConfig.pid = @"101";
    _slikeConfig.shareText = @"";
    _slikeConfig.isSkipAds =  NO;
    _slikeConfig.section =  @"default";
    _slikeConfig.pageTemplate =  @"home/api/test";
    _slikeConfig.isFullscreenControl =  YES;
    _slikeConfig.autorotationMode  =
    SlikeFullscreenAutorotationModeLandscape;
    _slikeConfig.preview =  YES;
    _slikeConfig.isGestureEnable = YES;
    _slikeConfig.appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.slikePlayer = [SlikePlayer sharedSlikePlayer];
    [_slikePlayer playVideo:_slikeConfig inParentView:self.playerAreaView withProgressHandler:^(SlikeEventType eventType, SlikePlayerState playerState, StatusInfo *statusInfo) {
        
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
            NSLog(@"PARENT EVENT: (MEDIA) ===> [SlikePlayerState - %ld]", (long)playerState);
        }
    }];
}
#pragma mark Slike Player Direct Youtube
-(void)startPlayerYoutubeOutSide
{
    //youtube ID
    
//    self.slikeConfig = [[SlikeConfig alloc] initWithChannel:@"Seagram’s 100 Pipers | The Legacy Project" withID:@"cv8UocAT87c" withSection:@"default" withMSId:@"56087249" posterImage:@""];
  self.slikeConfig =  [SlikeConfig createConfigForType:VIDEO_SOURCE_YT mediaTitle:@"Seagram’s 100 Pipers | The Legacy Project" mediaURL:@"cv8UocAT87c" posterURL:@"" isAutoPlay:YES];
//    _slikeConfig.streamingInfo = [StreamingInfo createStreamURL:@"cv8UocAT87c" withType:VIDEO_SOURCE_YT withTitle:@"Seagram’s 100 Pipers | The Legacy Project" withSubTitle:@"" withDuration:0L withAds:nil];
   // _slikeConfig.streamingInfo.isExternalPlayer = YES;
    _slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    _slikeConfig.pid = @"101";
    _slikeConfig.shareText = @"Toi.in";
    _slikeConfig.isSkipAds =  YES;
    _slikeConfig.section =  @"default";
    _slikeConfig.pageTemplate =  @"home/api/test";
    _slikeConfig.isFullscreenControl =  YES;
    _slikeConfig.autorotationMode  =
    SlikeFullscreenAutorotationModeLandscape;
    _slikeConfig.preview =  YES;
    _slikeConfig.appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.slikePlayer = [SlikePlayer sharedSlikePlayer];
    [_slikePlayer playVideo:_slikeConfig inParentView:self.playerAreaView withProgressHandler:^(SlikeEventType eventType, SlikePlayerState playerState, StatusInfo *statusInfo) {
        
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
            NSLog(@"PARENT EVENT: (MEDIA) ===> [SlikePlayerState - %ld]", (long)playerState);
        }
    }];
}
-(void)stopPlayer
{
    [_slikePlayer stopPlayer];
    self.slikePlayer =  nil;
}
-(void)dealloc
{
    [self stopPlayer];
}
-(void)startPlayerPreviousMethod
{
    self.slikePlayer = [SlikePlayer sharedSlikePlayer];
        [_slikePlayer playVideo:_slikeConfigPrevious inParentView:self.playerAreaView withProgressHandler:^(SlikeEventType eventType, SlikePlayerState playerState, StatusInfo *statusInfo) {
            
            if (eventType == AD) {
                
                NSLog(@"PARENT EVENT: (AD) ===> [position - %ld]", statusInfo.position);
                NSLog(@"PARENT EVENT: (AD) ===> [duration - %ld]", (long)statusInfo.duration);
                NSLog(@"PARENT EVENT: (AD) ===> [adTypeEnum - %ld]", (long)statusInfo.adStatusInfo.adTypeEnum);
                
            }
            else if (eventType == CONTROLS && playerState == SL_SHARE) {
                
                //Pause the player. Pause:FALSE (User has not paused the video. It is Paused by activity)
                //Input share logic
    //            if([[_slikePlayer getAnyPlayer] isPlaying])
    //            [[_slikePlayer getAnyPlayer] pause:NO];
    //            else  [[_slikePlayer getAnyPlayer] play:NO];
                    
            }
            
            else if (eventType == MEDIA) {
                NSLog(@"PARENT EVENT: (MEDIA) ===> [SlikePlayerState - %ld]", (long)playerState);
            }
        }];
}
@end

