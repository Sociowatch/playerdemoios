//
//  NavViewController.m
//  slikeplayerexample
//
//  Created by TIL on 16/09/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//

#import "NavViewController.h"
#import <SlikePlayer/SlikePlayer.h>
#import <CustomAlertView.h>

@interface NavViewController ()
{
    UIViewController *myCntrlr;
}
@end

@implementation NavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"Suicide Squad" withID:@"1yty589glg" withSection:@"/videos/news" withMSId:@"4724967"];
    slikeConfig.isCloseControl = NO;
    slikeConfig.channel = @"toi";
    slikeConfig.isSkipAds = true;
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

- (IBAction)clbPlayWithNav:(id)sender
{
    
}
- (IBAction)clbPlayYTWithNav:(id)sender
{
    //
}
-(void) showAlert:(NSString *) strMsg
{
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"Playback failed" message:strMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    alertView = nil;
}


@end
