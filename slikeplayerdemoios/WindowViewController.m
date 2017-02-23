//
//  WindowViewController.m
//  slikeplayerexample
//
//  Created by TIL on 16/09/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//

#import "WindowViewController.h"
#import <SlikePlayer/SlikePlayer.h>
#import <CustomAlertView.h>

@interface WindowViewController ()

@end

@implementation WindowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"For Sting   TOI ENT Manish Wadhwa likes portraying negative roles" withID:@"1yti1t9gl6" withSection:@"/videos/news" withMSId:@"4724967"];
    slikeConfig.channel = @"toi";
    slikeConfig.isCloseControl = NO;
    slikeConfig.autorotationMode = SlikeFullscreenAutorotationModeLandscape;
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:self.viewPlayer withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil)
        {
            NSLog(@"%@", [statusInfo getString]);
        }
        if(type == MEDIA && name == ERROR)
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
