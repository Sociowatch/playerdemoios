//
//  ViewController.m
//  slikeplayerexample
//
//  Created by TIL on 19/12/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//
/**
 
 # SlikePlayer  (v0.1.0)
 
 ## Example
 
 To run the example project, clone the repo by clicking [**SlikePlayer demo for iOS**][aef1a7c4]
 
 [aef1a7c4]: https://bitbucket.org/times_internet/slikeplayerdemoios.git "SlikePlayerDemoiOS"
 
 ## Requirements
 platform: iOS 8 or greater
 NSAppTransportSecurity: (For app transport security see the example's info plist file.)
 
 ## Installation
 
 SlikePlayer is available through private repo [CocoaPods](http://cocoapods.org). To install
 it, simply add the following line to your Podfile:
 
 ```
 
 pod 'SlikePlayer', :git => 'https://your_name@bitbucket.org/times_internet/slikeplayer-ios.git', :tag => '0.1.0'
 
 ```
 
 
 #HOW TO INTEGRATE:
 Best way to integrate, [**just clone the example repo**][65b043dc].
 
 [65b043dc]: https://bitbucket.org/times_internet/slikeplayerdemoios.git "SlikePlayerDemoiOS"
 
 **************************************
 SlikePlayer is a singleton class. To instantiate,
 
 ```
 SlikePlayer *myPlayer = [SlikePlayer getInstance];
 ```
 SlikePlayer will be initialized as follows.
 
 `-(void) initPlayerWithApikey:(NSString *) apikey andWithDeviceUID:(NSString *) uuid`
 
 #####apikey
 The Slike key provided by the Slike CMS.
 #####uuid
 Device unique id used by the app.
 
 ####method
 
 `- (void) playVideo:(SlikeConfig *) config inParent:(id) parent withAds:(NSMutableArray *) arrAds withProgressHandler:(onChange) block`
 
 #### Parameters:
 #####config:
 The media configuration file and instance of **SlikeConfig MDO**.
 SlikeConfig has following properties.
 Property|Type|Description
 --|---|--
 mediaId|String|Media id to be played.(required)
 ssoid|String|SSO login id.(optional)
 msId|String|entity id (required)
 title|String|title of the media.
 channel|String|channel name. No need to be filled.
 section|String|Section id. Ads will be served as per section id. (required)
 streamingInfo|StreamingInfo|StreamingInfo instance. Not required to fill if using mediaId. SlikePlayer will take care of it.
 adCleanupTime|Number|Remove pending or stucked ad within time. Default is 8000 milliseconds.
 timecode|Number|Time in milliseconds from where media should start.
 isSkipAds|boolean|If property true, SlikePlayer does not show any ad.
 isAutoPlay|boolean|If property true, the media will start automatically.
 isFullscreenControl|boolean|If property false, the fullscreen button will not be visible.
 isCloseControl|boolean|If property false, the close button will be visible only in fullscreen mode. Close control sends CONTROL event as CLOSE.
 isShareControl|boolean|If property false, share button will not be visible. Share control sends CONTROL event as SHARE.
 isNextControl|boolean|If property true, next button control will be visible. Next control sends CONTROL event as NEXT.
 isPreviousControl|boolean|If property true, previous button control will not be visible. Previous control sends CONTROL event as PREVIOUS.
 #####parent:
 Parent is the view in which the player will be added. It could be either an UIView or UIViewController or UINavigationController. If parent is nil, the player will added
 into the rootviewcontroller of the main window. For smaller view of the player, you should set a view as parent. Only view will set the player in window view.
 #####arrAds:
 The ads array. It is a mutable array of BoxAdsInfo instances.
 
 ```
 
 NSMutableArray *arr = [NSMutableArray array];
 BoxAdsInfo * info = (BoxAdsInfo *)[[BoxAdsInfo alloc] init];
 [info addPosition:0 withAdUnit:[[BoxAdsUnit alloc] initWithCategory:@"6" andAdURL:@"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator="]];
 [arr addObject:info];
 
 ```
 
 This ads array will override the actual ads of the video.
 
 **This should be nil in most cases and should not use explicitely.**
 
 #####onChange:
 `typedef void(^onChange)(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo);`
 
 The onChange handler is optional. If set, it will provide video update detail MDO i.e. StatusInfo instance.
 
 
 ###Other playback options:
 
 In case of other playback option, the playback can be done by explicitely creating media MDO.
 
 ``+(StreamingInfo *) createStreamURL:(NSString *) strURL withTitle:(NSString *) strTitle withSubTitle:(NSString *) strSubTitle withDuration:(NSInteger) duration withAds:(NSMutableArray *) arrAds;``
 
 This method will give an instance of **StreamingInfo**. Add this instance into config's **(SlikeConfig's)** streaminginfo property.
 And can be used in...
 
 ```- (void) playVideo:(SlikeConfig *) config inParent:(id) parent withAds:(NSMutableArray *) arrAds withProgressHandler:(onChange) block```
 
 
 ###For playing a playlist...
 
 Create a mutable array of StreamingInfo instances and pass it to the following method.
 
 ```- (void) playVideo:(NSMutableArray *)arrVideos withIndex:(NSInteger) index withCurrentlyPlaying:(currentlyPlaying) block```
 
 ####Parameters:
 #####arrVideos:
 A mutable array of StreamingInfo instances.
 #####index:
 Index position of video which will be played after initialization.
 #####currentlyPlaying:
 This block will notify whenever video changes.
 
 `typedef void(^currentlyPlaying)(NSInteger index, SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo)`
 
 > Refer to PlaylistViewController. e.g.
 ```
 [[SlikePlayer getInstance] playVideo:self.arrData withIndex:indexPath.row withCurrentlyPlaying:^(NSInteger index, SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
 if(!progressInfo)[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
 else
 {
 NSLog(@"%@", [statusInfo getString]);
 }
 }];
 
 ```
 
 To stop a player, just use.
 
 `- (void) stopPlayer;`
 
 e.g. `[SlikePlayer getInstance] stopPlayer];`
 
 
 ###STYLING
 ####Examples
 ```
 UIImage *img = [UIImage imageNamed:@"testicon"];
 UIImage *imgResizable = [img stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
 
 UIColor *clrBackground = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
 UIColor *clrTitle = [UIColor darkGrayColor];
 UIColor *clrSubtitle = [UIColor darkGrayColor];
 UIColor *clrContent = [UIColor darkGrayColor];
 UIColor *clrActivity = [UIColor greenColor];
 
 [SlikePlayer getInstance].playerStyleBarBackground = clrBackground;
 UIFont *titleFont = [UIFont fontWithName:@"AmericanTypewriter" size:18];
 UIFont *subtitleFont = [UIFont fontWithName:@"AmericanTypewriter" size:12];
 
 [SlikePlayer getInstance].playerStyleCloseButton = img;
 [SlikePlayer getInstance].playerStylePlayButton = img;
 [SlikePlayer getInstance].playerStylePauseButton = img;
 [SlikePlayer getInstance].playerStyleReplayButton = img;
 [SlikePlayer getInstance].playerStyleReverseButton = img;
 [SlikePlayer getInstance].playerStyleForwardButton = img;
 [SlikePlayer getInstance].playerStyleBitrateButton = img;
 [SlikePlayer getInstance].playerStyleFullscreenButton = img;
 
 [SlikePlayer getInstance].playerStyleSliderMinTrackColor = [UIColor redColor];
 [SlikePlayer getInstance].playerStyleSliderMaxTrackColor = [UIColor whiteColor];
 [SlikePlayer getInstance].playerStyleSliderThumbImage = imgResizable;
 
 [SlikePlayer getInstance].playerStyleTitleFont = titleFont;
 [SlikePlayer getInstance].playerStyleDurationFont = subtitleFont;
 [SlikePlayer getInstance].playerStyleBitrateTitleFont = titleFont;
 [SlikePlayer getInstance].playerStyleBitrateSubtitleFont = subtitleFont;
 [SlikePlayer getInstance].playerStyleBitrateContentFont = subtitleFont;
 
 [SlikePlayer getInstance].playerStyleTitleColor = clrTitle;
 [SlikePlayer getInstance].playerStyleDurationColor = clrSubtitle;
 [SlikePlayer getInstance].playerStyleActivityTintColor = clrActivity;
 [SlikePlayer getInstance].playerStyleBitrateBackground = [clrBackground colorWithAlphaComponent:0.7];
 [SlikePlayer getInstance].playerStyleBitrateTitleColor = clrTitle;
 [SlikePlayer getInstance].playerStyleBitrateSubtitleColor = clrSubtitle;
 [SlikePlayer getInstance].playerStyleBitrateContentColor = clrContent;
 ```
 
 **************************************
 
 ## Author
 
 Times Internet Limited, pravin.ranjan@timesinternet.in
 
 License
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

/***
 The example demonstrate 
 1) HUD implementation. HUD is not now used by SlikePlayer
 2) Manual buttons event handling
 3) Usage of StatusInfo events.
 */
- (IBAction)clbPlayVideo:(id)sender {
    if(![SVProgressHUD isVisible]) [SVProgressHUD show];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withID:@"1_oprrpt0x" withSection:@"/videos/news" withMSId:@"56087249"];
    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    //Enable next button
    slikeConfig.isNextControl = YES;
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
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withID:nil withSection:@"/videos/news" withMSId:@"56087249"];
    
    StreamingInfo *streamingInfo = [StreamingInfo createStreamURL:@"eRDojLoCDpQ" withType:VIDEO_SOURCE_YT withTitle:@"YouTube Video" withSubTitle:@"" withDuration:0L withAds:nil];
    streamingInfo.videoSource = VIDEO_SOURCE_YT;
    
    slikeConfig.streamingInfo = streamingInfo;
    
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil) NSLog(@"%@", [statusInfo getString]);
    }];
}

- (IBAction)clbPlayKaltura:(id)sender {
    if(![SVProgressHUD isVisible]) [SVProgressHUD show];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withID:@"0_000oyfdd" withSection:@"/videos/news" withMSId:@"56087249"];
    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
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
    NSMutableArray *arr = [NSMutableArray array];
    BoxAdsInfo * info = (BoxAdsInfo *)[[BoxAdsInfo alloc] init];
    [info addPosition:0 withAdUnit:[[BoxAdsUnit alloc] initWithCategory:@"6" andAdURL:@"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator="]];
    [arr addObject:info];
    
    info = (BoxAdsInfo *)[[BoxAdsInfo alloc] init];
    [info addPosition:6 withAdUnit:[[BoxAdsUnit alloc] initWithCategory:@"6" andAdURL:@"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator="]];
    [arr addObject:info];
    
    info = (BoxAdsInfo *)[[BoxAdsInfo alloc] init];
    [info addPosition:10 withAdUnit:[[BoxAdsUnit alloc] initWithCategory:@"6" andAdURL:@"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator="]];
    [arr addObject:info];
    
    info = (BoxAdsInfo *)[[BoxAdsInfo alloc] init];
    [info addPosition:-1 withAdUnit:[[BoxAdsUnit alloc] initWithCategory:@"6" andAdURL:@"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator="]];
    [arr addObject:info];
    
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withID:nil withSection:@"/videos/news" withMSId:@"56087249"];
    slikeConfig.isSkipAds = NO;
    //http://timeslive.live-s.cdn.bitgravity.com/cdn-live/_definst_/timeslive/live/timesnow.smil/playlist.m3u8
    slikeConfig.streamingInfo = [StreamingInfo createStreamURL:@"http://timesnow-lh.akamaihd.net/i/Timesnow-TIL-APP-HLS/TimesNow_1@129288/master.m3u8" withType:VIDEO_SOURCE_HLS withTitle:@"Live Streaming" withSubTitle:@"" withDuration:0L withAds:arr];
    
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:arr withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
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
