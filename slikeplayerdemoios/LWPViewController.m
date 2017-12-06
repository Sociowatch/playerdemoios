//
//  LWPViewController.m
//  slikeplayerexample
//
//  Created by TIL on 16/09/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//

#import "LWPViewController.h"
#import <SlikePlayer/SlikePlayer.h>
#import <CustomAlertView.h>

@interface LWPViewController ()

@end

@implementation LWPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"NBT Khabar express 26 09 2016 new" withID:@"1ytcef9gl6" withSection:@"/videos/news" withMSId:@"56087249" posterImage:nil];
    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    slikeConfig.channel = @"toi";
    slikeConfig.isCloseControl = NO;
    slikeConfig.autorotationMode = SlikeFullscreenAutorotationModeLandscape;
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:self.viewPlayer withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil)
        {
            NSLog(@"%@", [statusInfo getString]);
        }
        if(type == MEDIA && name == SK_ERROR)
        {
            NSLog(@"Error while playing media: %@", statusInfo.error);
            [self showAlert:statusInfo.error];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showAlert:(NSString *) strMsg
{
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"Playback failed" message:strMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    alertView = nil;
}

@end
