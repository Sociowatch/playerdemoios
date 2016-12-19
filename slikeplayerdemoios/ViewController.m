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
 
 - (void) playVideo:(NSString *)strVideoKey withTimeCode:(NSInteger) timeCode inParent:(id) parent withAds:(NSMutableArray *) arrAds withAnalyticsInfo:(AnalyticsSpecificInfo *) analyticsSpecificInfo
 
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
 
 
 Other playback options:
 
 In case of non kaltura streams or some live stream, the StreamingInfo can be created explicitely and passed to the player.
 +(StreamingInfo *) createStreamURL:(NSString *) strURL withTitle:(NSString *) strTitle withSubTitle:(NSString *) strSubTitle withDuration:(NSInteger) duration withAds:(NSMutableArray *) arrAds withAnalyticsInfo:(AnalyticsSpecificInfo *) analyticsSpecificInfo;
 
 This method will give an instance of StreamingInfo.
 And can be used in...
 - (void) playVideoWithInfo:(StreamingInfo *)obj withTimeCode:(NSInteger) timeCode inParent:(id) parent
 
 
 For playing a playlist...
 
 Create a mutable array of StreamingInfo instances and pass it to the following method.
 
 - (void) playVideo:(NSMutableArray *)arrVideos withIndex:(NSInteger) index withCurrentlyPlaying:(currentlyPlaying) block
 Parameters:
    arrVideos: a mutable array of StreamingInfo instances.
    index: index position of video which will be played after initialization.
    currentlyPlaying: This block will notify whenever video changes.
 
 Refer to PlaylistViewController.
 e.g.
    [[SlikePlayerManager getInstance] playVideo:self.arrData withIndex:indexPath.row withCurrentlyPlaying:^(NSInteger index) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }];
 
 
 To stop a player, just use.
 - (void) stopPlayer;
 
  e.g. [SlikePlayerManager getInstance] stopPlayer];
 
 **/
#import "ViewController.h"
#import <SlikePlayer/SlikePlayerManager.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clbPlayVideo:(id)sender {
    AnalyticsSpecificInfo *analyticsSpecificInfo = [[AnalyticsSpecificInfo alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withSection:@"home:city" withCategory:@"2" withNewsID:@"8" withChannel:@"toi"];
    [[SlikePlayerManager getInstance] playVideo:@"1_oprrpt0x" withTimeCode:0L inParent:nil withAds:nil withAnalyticsInfo:analyticsSpecificInfo withProgressHandler:^(ProgressInfo *progressInfo) {
        if(progressInfo != nil) NSLog(@"%@", [progressInfo getString]);
    }];
}

/***
/////////OBSOLATE//////////
*/
- (IBAction)clbPlayYT:(id)sender {
    /*AnalyticsSpecificInfo *analyticsSpecificInfo = [[AnalyticsSpecificInfo alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withSection:@"home:city" withCategory:@"2" withNewsID:@"8" withChannel:@"toi"];
    [[SlikePlayer getInstance] playVideo:@"Y_dKkU" withTimeCode:0L inParent:nil withAds:nil withAnalyticsInfo:analyticsSpecificInfo];*/
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
    [[SlikePlayerManager getInstance] playVideo:@"1_oprrpt0x" withTimeCode:0L inParent:nil withAds:nil withAnalyticsInfo:analyticsSpecificInfo withProgressHandler:^(ProgressInfo *progressInfo) {
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
    [[SlikePlayerManager getInstance] playVideoWithInfo:[StreamingInfo createStreamURL:@"http://timesnow-lh.akamaihd.net/i/Timesnow-TIL-APP-HLS/TimesNow_1@129288/master.m3u8" withTitle:@"Live Streaming" withSubTitle:@"" withDuration:0L withAds:arr withAnalyticsInfo:analyticsSpecificInfo] withTimeCode:0L inParent:nil withProgressHandler:^(ProgressInfo *progressInfo) {
        if(progressInfo != nil) NSLog(@"%@", [progressInfo getString]);
    }];
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue
{
    [[SlikePlayerManager getInstance] stopPlayer];
}
@end
