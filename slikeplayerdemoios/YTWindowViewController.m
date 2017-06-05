//
//  YTWindowViewController.m
//  slikeplayerexample
//
//  Created by TIL on 16/09/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//

#import "YTWindowViewController.h"
#import <SlikePlayer/SlikePlayer.h>

@interface YTWindowViewController ()

@end

@implementation YTWindowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withID:@"1x1wxws9ou" withSection:@"/Entertainment/videos" withMSId:@"4724967" posterImage:nil];
    
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil) NSLog(@"%@", [statusInfo getString]);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
