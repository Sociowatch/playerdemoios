//
//  NavViewController.m
//  slikeplayerexample
//
//  Created by TIL on 16/09/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//

#import "NavViewController.h"
#import <SlikePlayer/SlikePlayer.h>

@interface NavViewController ()
{
    UIViewController *myCntrlr;
}
@end

@implementation NavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withID:@"1_oprrpt0x" withSection:@"/Entertainment/videos" withMSId:@"4724967"];
    slikeConfig.isCloseControl = NO;
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:self.viewPlayer withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil)
        {
            NSLog(@"%@", [statusInfo getString]);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clbPlayWithNav:(id)sender
{
    
}
- (IBAction)clbPlayYTWithNav:(id)sender
{
    //
}

@end
