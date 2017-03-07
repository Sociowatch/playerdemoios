//
//  ViewController.m
//  slikeplayerexample
//
//  Created by TIL on 19/12/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//
#import "ViewController.h"
#import <SlikePlayer.h>
#import <ISlikePlayer.h>
#import <DeviceSettings.h>
#import <CustomAlertView.h>
#import <SVProgressHUD.h>
#import <BoxUtility.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setRingRadius:15];
    [SVProgressHUD setRingNoTextRadius:15];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

/***
 The example demonstrate 
 1) HUD implementation. HUD is not now used by SlikePlayer
 2) Manual buttons event handling
 3) Usage of StatusInfo events.
 */
- (IBAction)clbPlayVideo:(id)sender {
    if(![SVProgressHUD isVisible]) [SVProgressHUD show];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"toi" withID:@"1_oprrpt0x" withSection:@"/videos/news" withMSId:@"56087249"];
    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    //Enable next button
    slikeConfig.isNextControl = YES;
    slikeConfig.preferredVideoType = VIDEO_SOURCE_MP4;
    
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil)
        {
            NSLog(@"%@", [statusInfo getString]);
            
            //Getting ads events...
            if(type == AD && statusInfo.adStatusInfo)
            {
                AdStatusInfo *info = statusInfo.adStatusInfo;
                /****See Globals.h for ads events ****/
                NSLog(@"Ads information, ## %@", [info getString]);
            }
            
            if(type == MEDIA && name == READY)
            {
                if([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
            }
        }
        if(type == CONTROL && name == SHARE)
        {
            NSLog(@"Share button is tapped.");
            [self share:slikeConfig];
        }
        else if(type == CONTROL && name == NEXT)
        {
            NSLog(@"Next button is tapped.");
            [self clbPlayKaltura:nil];
        }
        else if(type == CONTROL && name == PREVIOUS)
        {
            NSLog(@"Previous button is tapped.");
        }
        else if(type == CONTROL && name == SHOWHUD)
        {
            if(![SVProgressHUD isVisible]) [SVProgressHUD show];
        }
        else if(type == CONTROL && name == HIDEHUD)
        {
            if([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
        }
        else
        {
            if([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
        }
        if(type == MEDIA && name == ERROR)
        {
            NSLog(@"Error while playing media: %@", statusInfo.error);
            [self showAlert:statusInfo.error];
        }
    }];
    
}

- (IBAction)clbPlayAudio:(id)sender {
    if(![SVProgressHUD isVisible]) [SVProgressHUD show];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"toi" withID:@"0_2d1ote04" withSection:@"/videos/news" withMSId:@"56087249"];
    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    slikeConfig.isSkipAds = true;
    
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil)
        {
            NSLog(@"%@", [statusInfo getString]);
            
            //Getting ads events...
            if(type == AD && statusInfo.adStatusInfo)
            {
                AdStatusInfo *info = statusInfo.adStatusInfo;
                /****See Globals.h for ads events ****/
                NSLog(@"Ads information, ## %@", [info getString]);
            }
            
            if(type == MEDIA && name == READY)
            {
                if([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
            }
        }
        if(type == CONTROL && name == SHARE)
        {
            NSLog(@"Share button is tapped.");
            [self share:slikeConfig];
        }
        else if(type == CONTROL && name == NEXT)
        {
            NSLog(@"Next button is tapped.");
            [self clbPlayKaltura:nil];
        }
        else if(type == CONTROL && name == PREVIOUS)
        {
            NSLog(@"Previous button is tapped.");
        }
        else if(type == CONTROL && name == SHOWHUD)
        {
            if(![SVProgressHUD isVisible]) [SVProgressHUD show];
        }
        else if(type == CONTROL && name == HIDEHUD)
        {
            if([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
        }
        else
        {
            if([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
        }
        if(type == MEDIA && name == ERROR)
        {
            NSLog(@"Error while playing media: %@", statusInfo.error);
            [self showAlert:statusInfo.error];
        }
    }];
    
}

- (IBAction)clbPlayYT:(id)sender {
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"Youtube Video" withID:nil withSection:@"/videos/news" withMSId:@"56087249"];
    
    slikeConfig.streamingInfo = [StreamingInfo createStreamURL:@"hzTg4zPBtDU" withType:VIDEO_SOURCE_YT withTitle:@"YouTube Video" withSubTitle:@"" withDuration:0L withAds:nil];
    
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil) NSLog(@"%@", [statusInfo getString]);
    }];
}

- (IBAction)clbPlayKaltura:(id)sender {
    if(![SVProgressHUD isVisible]) [SVProgressHUD show];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"NBT Khabar express 26 09 2016 new" withID:@"1ytcef9gl6" withSection:@"/videos/news" withMSId:@"56087249"];
    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    slikeConfig.channel = @"toi";
    //Enable previous button
    slikeConfig.isPreviousControl = YES;
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil)
        {
            NSLog(@"%@", [statusInfo getString]);
            
            //Getting ads events...
            if(type == AD && statusInfo.adStatusInfo)
            {
                AdStatusInfo *info = statusInfo.adStatusInfo;
                /****See Globals.h for ads events ****/
                NSLog(@"Ads information, ## %@", [info getString]);
            }
            
            if(type == MEDIA && name == READY)
            {
                if([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
            }
        }
        if(type == CONTROL && name == SHARE)
        {
            NSLog(@"Share button is tapped.");
            [self share:slikeConfig];
        }
        else if(type == CONTROL && name == CLOSE)
        {
            NSLog(@"Close button is tapped.");
        }
        else if(type == CONTROL && name == NEXT)
        {
            NSLog(@"Next button is tapped.");
        }
        else if(type == CONTROL && name == PREVIOUS)
        {
            NSLog(@"Previous button is tapped.");
            [self clbPlayVideo:nil];
        }
        else if(type == CONTROL && name == SHOWHUD)
        {
            if(![SVProgressHUD isVisible]) [SVProgressHUD show];
        }
        else if(type == CONTROL && name == HIDEHUD)
        {
            if([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
        }
        else
        {
            if([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
        }
        if(type == MEDIA && name == ERROR)
        {
            NSLog(@"Error while playing media: %@", statusInfo.error);
            [self showAlert:statusInfo.error];
        }
    }];
}

- (IBAction)clbLiveStream:(id)sender {
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"toi" withID:@"times-now" withSection:@"/videos/news" withMSId:@"56087249"];
    slikeConfig.isSkipAds = YES;
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil) NSLog(@"%@", [statusInfo getString]);
        if(type == MEDIA && name == ERROR)
        {
            NSLog(@"Error while playing media: %@", statusInfo.error);
            [self showAlert:statusInfo.error];
        }
    }];
}

-(void) showAlert:(NSString *) strMsg
{
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"Playback failed" message:strMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    alertView = nil;
}

-(void) share:(SlikeConfig *) info
{
    NSMutableArray *sharingItems = [NSMutableArray array];
    [sharingItems addObject:info.title];
    
    if(![[DeviceSettings sharedSettings] isIPhoneDevice])
    {
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
        activityController.popoverPresentationController.sourceView = [[[SlikePlayer getInstance] getAnyPlayer] getViewController].view;
        activityController.popoverPresentationController.sourceRect = ((PlayerViewController *)[[SlikePlayer getInstance] getAnyPlayer]).btnActivity.frame;
        if(!self.presentedViewController)[self presentViewController:activityController animated:YES completion:nil];
        else [self.presentedViewController presentViewController:activityController animated:YES completion:nil];
    }
    else
    {
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
        if(!self.presentedViewController)[self presentViewController:activityController animated:YES completion:nil];
        else [self.presentedViewController presentViewController:activityController animated:YES completion:nil];
    }
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue
{
    [[SlikePlayer getInstance] stopPlayer];
}
@end
