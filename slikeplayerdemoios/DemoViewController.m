//
//  DemoViewController.m
//  slikeplayerdemoios
//
//  Created by Aravind Kumar on 05/09/18.
//  Copyright © 2018 BBDSL. All rights reserved.
//

#import "DemoViewController.h"
#import "SlikeAdStatusInfo.h"
#import <SlikePlayer.h>
#import <SlikeGlobals.h>

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
    [self startPlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startPlayer
{
    self.slikeConfig = [[SlikeConfig alloc] initWithChannel:@"slike" withID:@"1x13srhggk" withSection:@"default" withMSId:@"56087249" posterImage:@""];
    _slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    _slikeConfig.pid = @"101";
    _slikeConfig.shareText = @"Toi.in";
    _slikeConfig.isSkipAds =  NO;
    _slikeConfig.pageTemplate =  @"Test";
    _slikeConfig.isFullscreenControl =  YES;
    _slikeConfig.autorotationMode  =
    SlikeFullscreenAutorotationModeLandscape;
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
-(void)dealloc
{
    [self stopPlayer];
}
-(void)stopPlayer
{
    [_slikePlayer stopPlayer];
    self.slikePlayer =  nil;
}
@end
