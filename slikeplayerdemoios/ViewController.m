//
//  ViewController.m
//  slikeplayerexample
//
//  Created by TIL on 19/12/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//
 /*License
 -------
 
 Copyright 2017 Times Internet
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 **/
#import "ViewController.h"
#import <SlikePlayer.h>
#import <ISlikePlayer.h>
#import <DeviceSettings.h>
#import <CustomAlertView.h>
#import <SVProgressHUD.h>
#import <BoxUtility.h>
#import <DMPlayerViewController.h>
#import "SlikePlayerControl.h"

@interface ViewController ()<DMPlayerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //infoArray = [[NSArray alloc] initWithObjects: @"Play Video In Window",@"Play YouTube Video",@"Play With Navigation Controller",@"Play Live Stream",@"Play Audio",@"Play DailyMotion",@"LightWeight Player",nil];
    
    infoArray = [[NSArray alloc] initWithObjects: @"Play Video",@"Play Live Stream",@"Play With Navigation Controller",@"Play DailyMotion",@"Play YouTube Video",nil];

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
- (void)clbPlayVideo {
    
    if(![SVProgressHUD isVisible]) [SVProgressHUD show];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"aravind" withID:@"1_oprrpt0x" withSection:@"defaUlt" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];
    slikeConfig.title = @"NBT Khabar express 26 09 2016 new";
    
    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    //Enable next button
    slikeConfig.isNextControl = YES;
    slikeConfig.preferredVideoType = VIDEO_SOURCE_MP4;
    slikeConfig.isSkipAds = false;
    [slikeConfig setLatitudeLongitude:@"26.539345" Longitude:@"80.487820"];
    [slikeConfig setCountry_State_City:@"IN" State:@"UP" City:@"Unnao"];
    [slikeConfig setUserInformation:@"Male" Age:28];
    //customControl is optional, If you want to create your own custom control, Please provide the control
    NSBundle *myBundle = [NSBundle bundleForClass:[PlayerViewController class]];
    slikeConfig.customControl = [[SlikePlayerControl alloc] initWithNibName:@"PlayerControlView" bundle:myBundle];
    
    
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
        if(type == CONTROLS && name == SHARE)
        {
            NSLog(@"Share button is tapped.");
            [self share:slikeConfig];
        }
        else if(type == CONTROLS && name == NEXT)
        {
            NSLog(@"Next button is tapped.");
            [self clbPlayKaltura:nil];
        }
        else if(type == CONTROLS && name == PREVIOUS)
        {
            NSLog(@"Previous button is tapped.");
        }
        else if(type == CONTROLS && name == SHOWHUD)
        {
            if(![SVProgressHUD isVisible]) [SVProgressHUD show];
        }
        else if(type == CONTROLS && name == HIDEHUD)
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

- (void)clbPlayAudio
{
    
    if(![SVProgressHUD isVisible]) [SVProgressHUD show];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"toi" withID:@"1x1pjc59u9" withSection:@"/videos/news" withMSId:@"56087249" posterImage:nil];
    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    slikeConfig.isSkipAds = false;
    
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
        if(type == CONTROLS && name == SHARE)
        {
            NSLog(@"Share button is tapped.");
            [self share:slikeConfig];
        }
        else if(type == CONTROLS && name == NEXT)
        {
            NSLog(@"Next button is tapped.");
            [self clbPlayKaltura:nil];
        }
        else if(type == CONTROLS && name == PREVIOUS)
        {
            NSLog(@"Previous button is tapped.");
        }
        else if(type == CONTROLS && name == SHOWHUD)
        {
            if(![SVProgressHUD isVisible]) [SVProgressHUD show];
        }
        else if(type == CONTROLS && name == HIDEHUD)
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


- (IBAction)clbPlayKaltura:(id)sender {
    if(![SVProgressHUD isVisible]) [SVProgressHUD show];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"NBT Khabar express 26 09 2016 new" withID:@"1ytcef9gl6" withSection:@"/videos/news" withMSId:@"56087249" posterImage:nil];
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
        if(type == CONTROLS && name == SHARE)
        {
            NSLog(@"Share button is tapped.");
            [self share:slikeConfig];
        }
        else if(type == CONTROLS && name == CLOSE)
        {
            NSLog(@"Close button is tapped.");
        }
        else if(type == CONTROLS && name == NEXT)
        {
            NSLog(@"Next button is tapped.");
        }
        else if(type == CONTROLS && name == PREVIOUS)
        {
            NSLog(@"Previous button is tapped.");
            [self clbPlayVideo];
        }
        else if(type == CONTROLS && name == SHOWHUD)
        {
            if(![SVProgressHUD isVisible]) [SVProgressHUD show];
        }
        else if(type == CONTROLS && name == HIDEHUD)
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

- (void)clbLiveStream
{
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"toi" withID:@"times-now" withSection:@"/videos/news" withMSId:@"56087249" posterImage:@""];
    slikeConfig.isSkipAds = YES;
    slikeConfig.streamingInfo.isLive = YES;
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
    /*NSMutableArray *sharingItems = [NSMutableArray array];
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
    }*/
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue
{
    [[SlikePlayer getInstance] stopPlayer];
}

- (void)clbPlayDailyMotion
{
    [self testDMP];
}

#pragma mark DMPlayerDelegate
- (void)dailymotionPlayer:(DMPlayerViewController *)player didReceiveEvent:(NSString *)eventName {
    // Grab the "apiready" event to trigger an autoplay
    if ([eventName isEqualToString:@"apiready"]) {
        // From here, it's possible to interact with the player API.
        NSLog(@"Received apiready event");
    }
}
-(void)testDMP
{
//    if(![SVProgressHUD isVisible]) [SVProgressHUD show];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"toi" withID:@"1x1wxpa9ou" withSection:@"default" withMSId:@"56087249" posterImage:nil];
    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    //Enable next button
    slikeConfig.isNextControl = NO;
    slikeConfig.preferredVideoType = VIDEO_SOURCE_DM;
    slikeConfig.isSkipAds = YES;
 
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
          
        }
    }];
    
}
-(void)testYT
{
    
//    if(![SVProgressHUD isVisible]) [SVProgressHUD show];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"toi" withID:@"1x1wxws9ou" withSection:@"default" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];
    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    //Enable next button
    slikeConfig.isNextControl = NO;
    slikeConfig.preferredVideoType = VIDEO_SOURCE_YT;
    slikeConfig.isSkipAds = YES;
 
    
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
            
        }
    }];
    
}

#pragma --
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return  10;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    header.backgroundColor =[UIColor whiteColor];

    return header;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return infoArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [self.tbView dequeueReusableCellWithIdentifier:@"infoCell"];
    
    
//    if(indexPath.row == 0)
//    {
//        UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
//        infoLbl.text = [infoArray objectAtIndex:indexPath.row];
//        infoLbl.textColor = [UIColor colorWithRed:142.0/255.0 green:109.0/255.0 blue:4.0/255.0 alpha:1];
//        
//    }else
        if(indexPath.row == 0)
    {
        cell = [self.tbView dequeueReusableCellWithIdentifier:@"infoCellWindow"];
        UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
        infoLbl.text = [infoArray objectAtIndex:indexPath.row];
        infoLbl.textColor = [UIColor colorWithRed:0/255.0 green:119/255.0 blue:0/255.0 alpha:1];

    }
    else if(indexPath.row == 1)
    {
        UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
        infoLbl.text = [infoArray objectAtIndex:indexPath.row];
        infoLbl.textColor = [UIColor colorWithRed:210/255.0 green:10/255.0 blue:6/255.0 alpha:1];

    }

    else if(indexPath.row == 2)
    {
        cell = [self.tbView dequeueReusableCellWithIdentifier:@"infoCellNavigation"];
        UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
        infoLbl.text = [infoArray objectAtIndex:indexPath.row];
        infoLbl.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1];
        
    }
    else if(indexPath.row == 3)
    {
        UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
        infoLbl.text = [infoArray objectAtIndex:indexPath.row];
        infoLbl.textColor = [UIColor colorWithRed:41/255.0 green:132/255.0 blue:140/255.0 alpha:1];

    }
    else if(indexPath.row == 4)
    {
        UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
        infoLbl.text = [infoArray objectAtIndex:indexPath.row];
        infoLbl.textColor = [UIColor colorWithRed:142.0/255.0 green:109.0/255.0 blue:4.0/255.0 alpha:1];

    }
    else if(indexPath.row == 5)
    {
        UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
        infoLbl.text = [infoArray objectAtIndex:indexPath.row];
        infoLbl.textColor = [UIColor colorWithRed:142.0/255.0 green:109.0/255.0 blue:4.0/255.0 alpha:1];
        

    }
    else if(indexPath.row == 6)
    {
        cell = [self.tbView dequeueReusableCellWithIdentifier:@"infoCellLightWait"];
        UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
        infoLbl.text = [infoArray objectAtIndex:indexPath.row];
        infoLbl.textColor = [UIColor colorWithRed:210/255.0 green:10/255.0 blue:6/255.0 alpha:1];
        
    }
   
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if(indexPath.row == 0)
//    {
//        [self clbPlayVideo];
//        
//    }else
        if(indexPath.row == 0)
    {
     //Window Call from xib
    }
    else if(indexPath.row == 1)
    {
        [self clbLiveStream];

    }
    else if(indexPath.row == 2)
    {
        //Navigation

    }
    else if(indexPath.row == 3)
    {
        [self clbPlayDailyMotion];



    }
    else if(indexPath.row == 4)
    {
        [self testYT];



    }
    else if(indexPath.row == 5)
    {
        [self clbPlayAudio];

    }
    else if (indexPath.row == 6)
    {
//Play Light Wait
    }
}

@end
