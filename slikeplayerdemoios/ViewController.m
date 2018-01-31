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
#import <SlikeDeviceSettings.h>
#import <CustomAlertView.h>
#import <SVProgressHUD.h>
#import <BoxUtility.h>
#import <DMPlayerViewController.h>
#import "SlikePlayerControl.h"
#import "HomeViewController.h"

@interface ViewController ()<DMPlayerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    infoArray = [[NSArray alloc] initWithObjects: @"Play Video In Window",@"Play YouTube Video",@"Play With Navigation Controller",@"Play Live Stream",@"Play Audio",@"Play DailyMotion",@"LightWeight Player",nil];
    
    //    infoArray = [[NSArray alloc] initWithObjects: @"Play Video",@"Play Live Stream",@"Play With Navigation Controller",@"Play DailyMotion",@"Play YouTube Video",@"MultiPlayer",@"Live Event",nil];
    infoArray = [[NSArray alloc] initWithObjects: @"Play Video",@"Times Now",@"ET Now",@"Zoom TV",@"Magicbricks Now",@"Play DailyMotion",@"Play YouTube Video",@"YouTube Style",@"Play FaceBook",@"Play With Navigation Controller",nil];
    
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
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"toi" withID:@"1_oprrpt0x" withSection:@"defaUlt" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];
    slikeConfig.title = @"NBT Khabar express 26 09 2016 new";
    
    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    slikeConfig.pid = @"101";
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
        if(type == CONTROLS && name == SK_SHARE)
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
        if(type == MEDIA && name == SK_ERROR)
        {
            NSLog(@"Error while playing media: %@", statusInfo.error);
            [self showAlert:statusInfo.error];
        }
    }];
    
}

- (void)clbPlayAudio
{
    
    if(![SVProgressHUD isVisible]) [SVProgressHUD show];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"toi" withID:@"1x1pjc59u9" withSection:@"videos.news" withMSId:@"56087249" posterImage:nil];
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
        if(type == CONTROLS && name == SK_SHARE)
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
        if(type == MEDIA && name == SK_ERROR)
        {
            NSLog(@"Error while playing media: %@", statusInfo.error);
            [self showAlert:statusInfo.error];
        }
    }];
    
}


- (IBAction)clbPlayKaltura:(id)sender {
    if(![SVProgressHUD isVisible]) [SVProgressHUD show];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"NBT Khabar express 26 09 2016 new" withID:@"1ytcef9gl6" withSection:@"videos.news" withMSId:@"56087249" posterImage:nil];
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
        if(type == CONTROLS && name == SK_SHARE)
        {
            NSLog(@"Share button is tapped.");
            [self share:slikeConfig];
        }
        else if(type == CONTROLS && name == SK_CLOSE)
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
        if(type == MEDIA && name == SK_ERROR)
        {
            NSLog(@"Error while playing media: %@", statusInfo.error);
            [self showAlert:statusInfo.error];
        }
    }];
}

- (void)clbLiveStreamTimesNow
{
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"toi" withID:@"times-now" withSection:@"videos.news" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];
    slikeConfig.isSkipAds = NO;
    slikeConfig.isAutoPlay =  true;
    slikeConfig.streamingInfo.isLive = YES;
    slikeConfig.shareText =  @"Player share";
    slikeConfig.title =  @"Times Now";
    slikeConfig.isFullscreenControl = NO;
    slikeConfig.isAirPlaySkip =  NO;
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil) NSLog(@"%@", [statusInfo getString]);
        if(type == MEDIA && name == SK_ERROR)
        {
            NSLog(@"Error while playing media: %@", statusInfo.error);
        }
    }];
}

- (void)clbLiveStreamEtNow
{
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"toi" withID:@"et-now" withSection:@"videos.news" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];
    slikeConfig.isSkipAds = NO;
    slikeConfig.isAutoPlay =  true;
    slikeConfig.streamingInfo.isLive = YES;
    slikeConfig.shareText =  @"Player share";
    slikeConfig.title =  @"Times Now";
    slikeConfig.isFullscreenControl = NO;
    slikeConfig.isAirPlaySkip =  NO;
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil) NSLog(@"%@", [statusInfo getString]);
        if(type == MEDIA && name == SK_ERROR)
        {
            NSLog(@"Error while playing media: %@", statusInfo.error);
        }
    }];
}
- (void)clbLiveStreamZoomTv
{
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"toi" withID:@"zoom-tv" withSection:@"videos.news" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];
    slikeConfig.isSkipAds = NO;
    slikeConfig.isAutoPlay =  true;
    slikeConfig.streamingInfo.isLive = YES;
    slikeConfig.shareText =  @"Player share";
    slikeConfig.title =  @"Times Now";
    slikeConfig.isFullscreenControl = NO;
    slikeConfig.isAirPlaySkip =  NO;
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil) NSLog(@"%@", [statusInfo getString]);
        if(type == MEDIA && name == SK_ERROR)
        {
            NSLog(@"Error while playing media: %@", statusInfo.error);
        }
    }];
}
- (void)clbLiveStreamMb_Now
{
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"toi" withID:@"mb-now" withSection:@"videos.news" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];
    slikeConfig.isSkipAds = NO;
    slikeConfig.isAutoPlay =  true;
    slikeConfig.streamingInfo.isLive = YES;
    slikeConfig.shareText =  @"Player share";
    slikeConfig.title =  @"Times Now";
    slikeConfig.isFullscreenControl = NO;
    slikeConfig.isAirPlaySkip =  NO;
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil) NSLog(@"%@", [statusInfo getString]);
        if(type == MEDIA && name == SK_ERROR)
        {
            NSLog(@"Error while playing media: %@", statusInfo.error);
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
     
     if(![[SlikeDeviceSettings sharedSettings] isIPhoneDevice])
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
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"toi" withID:@"1x1wxpa9ou" withSection:@"default" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];
    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    //Enable next button
    slikeConfig.isNextControl = NO;
    slikeConfig.preferredVideoType = VIDEO_SOURCE_DM;
    slikeConfig.isSkipAds = YES;
    slikeConfig.title = @"Daily Motion";
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
-(void)testYTOutSide
{
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withID:@"eRDojLoCDpQ" withSection:@"/Entertainment/videos" withMSId:@"4724967" posterImage:nil];
    StreamingInfo *streamingInfo = [StreamingInfo createStreamURL:@"eRDojLoCDpQ" withType:VIDEO_SOURCE_YT withTitle:@"YouTube Video" withSubTitle:@"" withDuration:0L withAds:nil];
    slikeConfig.streamingInfo = streamingInfo;
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil)
        {
            NSLog(@"%ld", (long)type);
            
            NSLog(@"%@", [statusInfo getString]);
            NSLog(@"%ld", (long)name);
            
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
    [self testYTOutSide];
}
//{
//
//
////    if(![SVProgressHUD isVisible]) [SVProgressHUD show];
//    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"toi" withID:@"1x1pms59u9" withSection:@"default" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];
//    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
//    slikeConfig.title = @"Test Video";
//    //Enable next button
//    slikeConfig.isNextControl = NO;
//    slikeConfig.preferredVideoType = VIDEO_SOURCE_YT;
//    slikeConfig.isSkipAds = YES;
//
//
//    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
//        if(statusInfo != nil)
//        {
//            NSLog(@"%ld", (long)type);
//
//            NSLog(@"%@", [statusInfo getString]);
//            NSLog(@"%ld", (long)name);
//
//            //Getting ads events...
//            if(type == AD && statusInfo.adStatusInfo)
//            {
//                AdStatusInfo *info = statusInfo.adStatusInfo;
//                /****See Globals.h for ads events ****/
//                NSLog(@"Ads information, ## %@", [info getString]);
//            }
//
//        }
//    }];
//
//}

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
        UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
        infoLbl.text = [infoArray objectAtIndex:indexPath.row];
        infoLbl.textColor = [UIColor colorWithRed:41/255.0 green:132/255.0 blue:140/255.0 alpha:1];
        
    }
    else if(indexPath.row == 3)
    {
        UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
        infoLbl.text = [infoArray objectAtIndex:indexPath.row];
        infoLbl.textColor = [UIColor colorWithRed:142.0/255.0 green:109.0/255.0 blue:4.0/255.0 alpha:1];
        
    }
    else if(indexPath.row == 4)
    {
        UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
        infoLbl.text = [infoArray objectAtIndex:indexPath.row];
        infoLbl.textColor = [UIColor colorWithRed:0/255.0 green:119/255.0 blue:0/255.0 alpha:1];
        
        
    }
    else if(indexPath.row == 5)
    {
        //        cell = [self.tbView dequeueReusableCellWithIdentifier:@"infoCellLightWait"];
        UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
        infoLbl.text = [infoArray objectAtIndex:indexPath.row];
        infoLbl.textColor = [UIColor colorWithRed:210/255.0 green:10/255.0 blue:6/255.0 alpha:1];
        
    }
    else if(indexPath.row == 6)
    {
        UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
        infoLbl.text = [infoArray objectAtIndex:indexPath.row];
        infoLbl.textColor = [UIColor colorWithRed:0/255.0 green:119/255.0 blue:0/255.0 alpha:1];
        
    }
    else
    {
        cell = [self.tbView dequeueReusableCellWithIdentifier:@"infoCellNavigation"];
        UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
        infoLbl.text = [infoArray objectAtIndex:indexPath.row];
        infoLbl.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1];
        
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0)
    {
        //Window Call from xib
    }
    else if(indexPath.row == 1)
    {
        [self clbLiveStreamTimesNow];
        
    }
    else if(indexPath.row == 2)
    {
        [self clbLiveStreamEtNow];
        
    }
    else if(indexPath.row == 3)
    {
        [self clbLiveStreamZoomTv];
        
    }
    else if(indexPath.row == 4)
    {
        [self clbLiveStreamMb_Now];
        
    }
    
    else if(indexPath.row == 5)
    {
        [self clbPlayDailyMotion];
    }
    else if(indexPath.row == 6)
    {
        [self testYT];
    }
    else if (indexPath.row == 7)
    {
        //Play Light Wait
        [self youTubeStyle];
    }
    else if (indexPath.row == 8)
    {
        //Play FB
        [self playFBVideo];
    }
    else if (indexPath.row == 9)
    {
        //Play Light Wait
        [self playLiveEvent];
    }
    else
    {
        //Navigation
    }
}
-(void)playFBVideo
{
    
    
    //    if(![SVProgressHUD isVisible]) [SVProgressHUD show];
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithChannel:@"mensxp" withID:@"2205183029507967" withSection:@"default" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];
    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    slikeConfig.title = @"Test Video";
    //Enable next button
    slikeConfig.isNextControl = NO;
    slikeConfig.preferredVideoType = VIDEO_SOURCE_FB;
    slikeConfig.isSkipAds = YES;
    slikeConfig.fbAppId =  @"121697241177107";
    StreamingInfo *streamingInfo = [StreamingInfo createStreamURL:@"https://www.facebook.com/IndiaDekhoOfficial/videos/502619860105163/" withType:VIDEO_SOURCE_FB withTitle:@"FB Videos" withSubTitle:@"" withDuration:0.0 withAds:nil];
    slikeConfig.streamingInfo =streamingInfo;
    
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(statusInfo != nil)
        {
            NSLog(@"%ld", (long)type);
            
            NSLog(@"%@", [statusInfo getString]);
            NSLog(@"%ld", (long)name);
            
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
-(void)youTubeStyle
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    HomeViewController *OBJ=   [mainStoryboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    [self.navigationController pushViewController:OBJ animated:YES];
}
-(void)playLiveEvent
{
    //1x1ernjg96@567613/master.m3u8
    
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"Live Event" withID:@"1x1e8m3g9z" withSection:@"videos.entertainment" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];
    //    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"NBT Khabar express 26 09 2016 new" withID:@"1_oprrpt0x" withSection:@"videos.news" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];
    
    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    slikeConfig.channel = @"toi";
    slikeConfig.isCloseControl = NO;
    slikeConfig.isSkipAds =  YES;
    slikeConfig.isAutoPlay = YES;
    slikeConfig.isFullscreenControl  = YES;
    slikeConfig.isShareControl =  YES;
    slikeConfig.isFullscreenControl =  YES;
    
    //
    [slikeConfig setLatitudeLongitude:@"26.539345" Longitude:@"80.487820"];
    [slikeConfig setCountry_State_City:@"IN" State:@"UP" City:@"Unnao"];
    [slikeConfig setUserInformation:@"Male" Age:28];
    //
    
    slikeConfig.pid = @"102";
    slikeConfig.shareText =  @"";
    //    slikeConfig.shareText =  @"";
    //    slikeConfig.clipStart = 2000;
    //    slikeConfig.clipEnd = 40000;
    //  slikeConfig.playerVolume = 1.0;
    //slikeConfig.timecode =  20000;
    slikeConfig.autorotationMode = SlikeFullscreenAutorotationModeLandscape;
    slikeConfig.sg = @"5ps,5tp,6pd,434,359,80t,6hp,41j,7gn,5vy,7dr,2vv,5tu,7gh,5tq,8tf,5o6,5ua,446,8k6,47b,5jf,8ro,5w0,2xi,437,8iq,2vy,8sq,9nf,7h3,8k7,44h,58k,8k8,44n,7h1,2vk,8sm,6hs,8sj,47v,9ij,30b,761,75x,5ub,7l6,9mo,9n5,5tv,5vz,5jc,2xr,9i6,2vh,2vb,9hk,2x6,7gm,8sn,5ww,8sf,8rq,2xc,8rs,5o2,80s,8rk,5ag,43b,5je,5to,5uj,6vh,7h6,5ul,30s,5jd,5bz,35i,8rj,7di,75y,9hx,aib,9i3,33d,8gw,47z,8tc,ai9,8kd,8t3,8ss,8so,6pc,8t8,8s9&HDL=&ARC1=&fic=0&SCP=0&Hyp1=&article=&SCN=Default&Tmpl=Default&Tmpl_SCN=Default_Default&SubSCN=&PGT=&BL=0";
    slikeConfig.screenName = @"WindowViewController";
    
    [[SlikePlayer getInstance] playVideo:slikeConfig inParent:nil withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        if(type == AD)
        {
            NSLog(@"nnjdfnjnjen %ld", statusInfo.adStatusInfo.state);
            
        }
        if(statusInfo != nil)
        {
            //            NSLog(@"%@", [statusInfo getString]);
            //            NSLog(@"%ld", (long)type);
            //            NSLog(@"%ld", (long)type);
            //
        }
        
        if(type == MEDIA && name == SK_ERROR)
        {
            NSLog(@"Error while playing media: %@", statusInfo.error);
            [self showAlert:statusInfo.error];
        }
    }];
}

@end

