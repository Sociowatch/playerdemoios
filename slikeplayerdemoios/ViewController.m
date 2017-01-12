//
//  ViewController.m
//  slikeplayerexample
//
//  Created by TIL on 19/12/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//
/**
 
 SlikePlayerManager is a singleton class and precisely do not create new instance by allocating yourself.
 
 SlikePlayerManager *myPlayer = [SlikePlayerManager getInstance];
 
 Its main methods are as follows.
 
 - (void) playVideo:(NSString *)strVideoKey withTimeCode:(NSInteger) timeCode inParent:(id) parent withAds:(NSMutableArray *) arrAds withAnalyticsInfo:(AnalyticsSpecificInfo *) analyticsSpecificInfo withProgressHandler:(progressinfohandler) block
 
 Parameters:
 strVideoKey: The kaltura video id.
 timeCode: The time code is the play start time in milliseconds.
 parent: Parent is the view in which the player will be added. It could be either an UIView or UIViewController or UINavigationController. If parent is nil, the player is added
 into the rootviewcontroller of the main window. For smaller view of the player, you should set a view as parent. Precisely, only view will set the player in window view.
 arrAds: The ads array. This should by nil until explicitely need to override the ads array of the video. It is a mutable array of BoxAdsInfo instances.
 
 NSMutableArray *arr = [NSMutableArray array];
 BoxAdsInfo * info = (BoxAdsInfo *)[[BoxAdsInfo alloc] init];
 [info addPosition:0 withAdUnit:[[BoxAdsUnit alloc] initWithCategory:@"6" andAdURL:@"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator="]];
 [arr addObject:info];
 
 This ads array will override the actual ads of the video.
 
 analyticsSpecificInfo: The analytics info is the object which needs to be filled by the SlikePlayer's owner app. This is video specific data needs for analytics purpose.
 
 e.g.
 AnalyticsSpecificInfo *analyticsSpecificInfo = [[AnalyticsSpecificInfo alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withSection:@"home:city" withCategory:@"2" withNewsID:@"8" withChannel:@"toi"];
 
 This information is optional (perhaps required by TOI apps).
 
 The progress handler is optional. If set, it will provide video update detail MDO i.e. ProgressInfo instance.
 
 
 Other playback options:
 
 In case of non kaltura streams or some live stream, the StreamingInfo can be created explicitely and passed to the player.
 +(StreamingInfo *) createStreamURL:(NSString *) strURL withTitle:(NSString *) strTitle withSubTitle:(NSString *) strSubTitle withDuration:(NSInteger) duration withAds:(NSMutableArray *) arrAds withAnalyticsInfo:(AnalyticsSpecificInfo *) analyticsSpecificInfo;
 
 This method will give an instance of StreamingInfo.
 And can be used in...
 - (void) playVideoWithInfo:(StreamingInfo *)obj withTimeCode:(NSInteger) timeCode inParent:(id) parent withProgressHandler:(progressinfohandler) block
 
 
 For playing a playlist...
 
 Create a mutable array of StreamingInfo instances and pass it to the following method.
 
 - (void) playVideo:(NSMutableArray *)arrVideos withIndex:(NSInteger) index withCurrentlyPlaying:(currentlyPlaying) block
 Parameters:
 arrVideos: a mutable array of StreamingInfo instances.
 index: index position of video which will be played after initialization.
 currentlyPlaying: This block will notify whenever video changes. It consists 2 parameters. currently playing video index and ProgressInfo of currently playing video. the info can be nil while switching to other videos or replay.
 
 Refer to PlaylistViewController.
 e.g.
 [[SlikePlayerManager getInstance] playVideo:self.arrData withIndex:indexPath.row withCurrentlyPlaying:^(NSInteger index, ProgressInfo *progressInfo) {
 if(!progressInfo)[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
 else
 {
 NSLog(@"%@", [progressInfo getString]);
 }
 }];
 
 
 To stop a player, just use.
 - (void) stopPlayer;
 
 e.g. [SlikePlayerManager getInstance] stopPlayer];
 
 
 ///STYLING e.g.
 UIImage *img = [UIImage imageNamed:@"testicon"];
 UIImage *imgResizable = [img stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
 
 UIColor *clrBackground = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
 UIColor *clrTitle = [UIColor darkGrayColor];
 UIColor *clrSubtitle = [UIColor darkGrayColor];
 UIColor *clrContent = [UIColor darkGrayColor];
 UIColor *clrActivity = [UIColor greenColor];
 
 [SlikePlayerManager getInstance].playerStyleBarBackground = clrBackground;
 UIFont *titleFont = [UIFont fontWithName:@"AmericanTypewriter" size:18];
 UIFont *subtitleFont = [UIFont fontWithName:@"AmericanTypewriter" size:12];
 
 [SlikePlayerManager getInstance].playerStyleCloseButton = img;
 [SlikePlayerManager getInstance].playerStylePlayButton = img;
 [SlikePlayerManager getInstance].playerStylePauseButton = img;
 [SlikePlayerManager getInstance].playerStyleReplayButton = img;
 [SlikePlayerManager getInstance].playerStyleReverseButton = img;
 [SlikePlayerManager getInstance].playerStyleForwardButton = img;
 [SlikePlayerManager getInstance].playerStyleBitrateButton = img;
 [SlikePlayerManager getInstance].playerStyleFullscreenButton = img;
 
 [SlikePlayerManager getInstance].playerStyleSliderMinTrackColor = [UIColor redColor];
 [SlikePlayerManager getInstance].playerStyleSliderMaxTrackColor = [UIColor whiteColor];
 [SlikePlayerManager getInstance].playerStyleSliderThumbImage = imgResizable;
 
 [SlikePlayerManager getInstance].playerStyleTitleFont = titleFont;
 [SlikePlayerManager getInstance].playerStyleDurationFont = subtitleFont;
 [SlikePlayerManager getInstance].playerStyleBitrateTitleFont = titleFont;
 [SlikePlayerManager getInstance].playerStyleBitrateSubtitleFont = subtitleFont;
 [SlikePlayerManager getInstance].playerStyleBitrateContentFont = subtitleFont;
 
 [SlikePlayerManager getInstance].playerStyleTitleColor = clrTitle;
 [SlikePlayerManager getInstance].playerStyleDurationColor = clrSubtitle;
 [SlikePlayerManager getInstance].playerStyleActivityTintColor = clrActivity;
 [SlikePlayerManager getInstance].playerStyleBitrateBackground = [clrBackground colorWithAlphaComponent:0.7];
 [SlikePlayerManager getInstance].playerStyleBitrateTitleColor = clrTitle;
 [SlikePlayerManager getInstance].playerStyleBitrateSubtitleColor = clrSubtitle;
 [SlikePlayerManager getInstance].playerStyleBitrateContentColor = clrContent;
 
 **/
#import "ViewController.h"
#import <SlikePlayerManager.h>
#import <ISlikePlayer.h>

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
 3) Usage of ProgressInfo events.
 */
- (IBAction)clbPlayVideo:(id)sender {
    if(![SVProgressHUD isVisible]) [SVProgressHUD show];
    
    AnalyticsSpecificInfo *analyticsSpecificInfo = [[AnalyticsSpecificInfo alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withSection:@"home:city" withCategory:@"2" withNewsID:@"8" withChannel:@"toi"];
    [[SlikePlayerManager getInstance] playVideo:@"1_oprrpt0x" withTimeCode:0L inParent:nil withAds:nil withAnalyticsInfo:analyticsSpecificInfo withProgressHandler:^(ProgressInfo *progressInfo) {
        if(progressInfo != nil)
        {
            NSLog(@"%@", [progressInfo getString]);
            
            //Getting ads events...
            if(progressInfo.adsProgressInfo)
            {
                AdsProgressInfo *info = progressInfo.adsProgressInfo;
                /****See Globals.h for ads events ****/
                /**
                 #define kSlikeAdInit 0
                 #define kSlikeAdStart 1
                 #define kSlikeAdFailure 2
                 #define kSlikeAdProgress 3
                 #define kSlikeAdQuartile1 4
                 #define kSlikeAdQuartile2 5
                 #define kSlikeAdQuartile3 6
                 #define kSlikeAdComplete 7
                 #define kSlikeAdSkip 8
                 #define kSlikeAdClick 9
                 **/
                NSLog(@"Ads information, ## %@", [info getString]);
            }
            
            /**
             Track the ready event to handle button events.
             */
            if(progressInfo.status == kSlikeAnalyticsInit)
            {
                if([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
                
                id<ISlikePlayer> player = [[SlikePlayerManager getInstance] getAnyPlayer];
                player.autorotationMode = AVPlayerFullscreenAutorotationLandscapeMode;
                //Enable previous button
                [player handlePreviousButtonManually:YES];
                //Enable next button
                [player handleNextButtonManually:YES];
                //Add button event. In need share button event only, no need to enable/disable previous or next button.
                [player setButtonEventDelegate:^(NSInteger buttontype) {
                    NSLog(@"%ld", (long)buttontype);
                    if(buttontype == kButtonEventPrevious) NSLog(@"Previous button is tapped.");
                    else if(buttontype == kButtonEventNext)
                    {
                        NSLog(@"Next button is tapped.");
                        [self clbPlayKaltura:nil];
                    }
                    else if(buttontype == kButtonEventActivity)
                    {
                        NSLog(@"Share button is tapped.");
                        [self share:analyticsSpecificInfo];
                    }
                    else if(buttontype == kButtonEventClose)
                    {
                        NSLog(@"Close button is tapped.");
                    }
                    else if(buttontype == kButtonEventHideHUD) //HUD events
                    {
                        if([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
                    }
                    else if(buttontype == kButtonEventShowHUD) //HUD events
                    {
                        if(![SVProgressHUD isVisible]) [SVProgressHUD show];
                    }
                }];
            }
        }
        else
        {
            if([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
        }
    }];
}

- (IBAction)clbPlayYT:(id)sender {
    AnalyticsSpecificInfo *analyticsSpecificInfo = [[AnalyticsSpecificInfo alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withSection:@"home:city" withCategory:@"2" withNewsID:@"8" withChannel:@"toi"];
    
    StreamingInfo *streamingInfo = [StreamingInfo createStreamURL:@"eRDojLoCDpQ" withType:VIDEO_SOURCE_YT withTitle:@"YouTube Video" withSubTitle:@"" withDuration:0L withAds:nil withAnalyticsInfo:analyticsSpecificInfo];
    streamingInfo.videoSource = VIDEO_SOURCE_YT;
    
    [[SlikePlayerManager getInstance] playVideoWithInfo:streamingInfo withTimeCode:0 inParent:nil withProgressHandler:^(ProgressInfo *progressInfo) {
        if(progressInfo != nil) NSLog(@"%@", [progressInfo getString]);
    }];
    
    /*[[SlikePlayerManager getInstance] playVideo:@"Y_dKkU" withTimeCode:0L inParent:nil withAds:nil withAnalyticsInfo:analyticsSpecificInfo withProgressHandler:^(ProgressInfo *progressInfo) {
        if(progressInfo != nil) NSLog(@"%@", [progressInfo getString]);
    }];*/
}

- (IBAction)clbPlayKaltura:(id)sender {
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
    AnalyticsSpecificInfo *analyticsSpecificInfo = [[AnalyticsSpecificInfo alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withSection:@"home:city" withCategory:@"2" withNewsID:@"8" withChannel:@"toi"];
    [[SlikePlayerManager getInstance] playVideo:@"0_000oyfdd" withTimeCode:0L inParent:nil withAds:nil withAnalyticsInfo:analyticsSpecificInfo withProgressHandler:^(ProgressInfo *progressInfo) {
        if(progressInfo != nil) NSLog(@"%@", [progressInfo getString]);
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
    
    AnalyticsSpecificInfo *analyticsSpecificInfo = [[AnalyticsSpecificInfo alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withSection:@"home:city" withCategory:@"2" withNewsID:@"8" withChannel:@"toi"];
    [[SlikePlayerManager getInstance] playVideoWithInfo:[StreamingInfo createStreamURL:@"http://timesnow-lh.akamaihd.net/i/Timesnow-TIL-APP-HLS/TimesNow_1@129288/master.m3u8" withType:VIDEO_SOURCE_HLS withTitle:@"Live Streaming" withSubTitle:@"" withDuration:0L withAds:arr withAnalyticsInfo:analyticsSpecificInfo] withTimeCode:0L inParent:nil withProgressHandler:^(ProgressInfo *progressInfo) {
        if(progressInfo != nil) NSLog(@"%@", [progressInfo getString]);
    }];
    //[[SlikePlayerManager getInstance] playVideoWithInfo:[StreamingInfo createStreamURL:@"https://tungsten.aaplimg.com/VOD/bipbop_adv_fmp4_example/master.m3u8" withTitle:@"Live Streaming" withSubTitle:@"" withDuration:0L withAds:nil] withTimeCode:0L inParent:nil];
}

-(void) share:(AnalyticsSpecificInfo *) info
{
    NSMutableArray *sharingItems = [NSMutableArray array];
    [sharingItems addObject:info.strTitle];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue
{
    [[SlikePlayerManager getInstance] stopPlayer];
}
@end
