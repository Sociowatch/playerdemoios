# SlikePlayer Demo (iOS)  (v0.0.1)

## Example

To run the example project, clone this repo i.e. https://bitbucket.org/times_internet/slikeplayerdemoandroid.git.


## Requirements
platform: iOS 8 or greater
NSAppTransportSecurity: (For app transport security see the example's info plist file.)
Dependencies:
1 'GoogleAnalytics-iOS-SDK', '~> 3.12'
2 'google-cast-sdk', '~> 3.3'
3 'GoogleAds-IMA-iOS-SDK-For-AdMob', '~> 3.3.1'

## Installation

SlikePlayer is available through private repo [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SlikePlayer', :git => 'https://pravin_ranjan@bitbucket.org/times_internet/slikeplayer-ios.git', :tag => '0.0.1'
```

#HOW TO INTEGRATE:
Best way to integrate, just clone the example repo.

**************************************
SlikePlayerManager is a singleton class and precisely do not create new instance by allocating yourself.
 
 SlikePlayerManager *myPlayer = [SlikePlayerManager getInstance];
 
 If you'll need to initiate Google Analytics, initiate with following method.
 
 -(void) initPlayerWithGATrackID:(id<GAITracker>) gaTracker
 
 Above method must be called only once.
 
  e.g. SlikePlayerManager *myPlayer = [SlikePlayerManager getInstance] initPlayerWithGATrackID: myTracker];
 
 
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
**************************************


## Author

Times Internet Limited, pravin.ranjan@timesinternet.in

## License

TODO (Under consideration)