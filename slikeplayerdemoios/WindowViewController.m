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
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"NBT Khabar express 26 09 2016 new" withID:@"1x1ch55glk" withSection:@"/videos/news" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];
    //    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"NBT Khabar express 26 09 2016 new" withID:@"1_oprrpt0x" withSection:@"/videos/news" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];

    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    slikeConfig.channel = @"toi";
    slikeConfig.isCloseControl = NO;
    slikeConfig.autorotationMode = SlikeFullscreenAutorotationModeLandscape;
    slikeConfig.isSkipAds =  false;
    slikeConfig.preferredVideoType = VIDEO_SOURCE_MP4;
    //
    [slikeConfig setLatitudeLongitude:@"26.539345" Longitude:@"80.487820"];
    [slikeConfig setCountry_State_City:@"IN" State:@"UP" City:@"Unnao"];
    [slikeConfig setUserInformation:@"Male" Age:28];
    slikeConfig.isSkipAds =  YES;
    //
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
