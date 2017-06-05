# SlikePlayer  (v0.5.8)

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

pod 'SlikePlayer', :git => 'https://bitbucket.org/times_internet/slikeplayer-ios.git', :tag => '0.5.8'

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

`-(void) initPlayerWithApikey:(NSString *) apikey andWithDeviceUID:(NSString *) uuid debugMode:(BOOL) isDebug`

#####apikey
The Slike key provided by the Slike CMS.

#####uuid
Device unique id used by the app.

#####debug mode
BOOL. The app should ensure release build should not go with debug mode as YES.

####method

 `- (void) playVideo:(SlikeConfig *) config inParent:(id) parent withAds:(NSMutableArray *) arrAds withProgressHandler:(onChange) block`

#### Parameters:

#####config:

 The media configuration file and instance of **SlikeConfig MDO**.

####SlikeConfig has following properties.

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
isFastSeekable|boolean|If property false (default), precise seeking is performed. Otherwise loose but fast seek is performed.
customControl|optional|If you want to create your own custom control, Please provide the customControl.

##### Custom Control:

Create custom control and provide this custom control to config.customControl

```
NSBundle *myBundle = [NSBundle bundleForClass:[PlayerViewController class]];
    slikeConfig.customControl = [[SlikePlayerControl alloc] initWithNibName:@"PlayerControlView" bundle:myBundle]

```

##### ISlikePlayerControl implementation

```
    -(void)viewWillEnterForeground
    {
    //  Handle playerStylePlayButton
    }
    -(void)viewWillEnterBackground
    {
      //  Handle playerStylePlayButton and seekBar
    }
    -(void) showBitrateChooser:(BOOL) flag
    {
        //Handle bit rate section
    }
    -(void) setHostPlayer:(id<ISlikePlayer>) hostPlayer
    {
        //Set the host player
    }
    -(void) setPlayerData:(SlikeConfig *)config
    {
        //set the player data as SlikeConfig
    }
    -(void) setAdsMarkers:(NSMutableArray *) arrMarkers
    {
        //self.seekBar.arrMarkers = arrMarkers;
        //TODO::
    }
    -(void) setAdMarkerDone:(NSInteger) index
    {
        //
    }
    -(void) updateFullScreen:(BOOL) isFullScreen
    {
        //Update fullscreen button.
    }
    -(void) showFullscreenButton:(BOOL) flag
    {
              //toggle to FullScreen
    }
    -(void)updatePlaybackProgress
    {
    }
    -(void) updateButtons:(SlikePlayerState) state
    {
      //Update controls as per config. This will be called very first time before video start.
    }
    -(void) show
   {
     //Use to show custom Control view
   }
   -(void) hide
   {
     //Use to hide custom Control view
   }

```

##### parent:

 Parent is the view in which the player will be added. It could be either an UIView or UIViewController or UINavigationController. If parent is nil, the player will added
 into the rootviewcontroller of the main window. For smaller view of the player, you should set a view as parent. Only view will set the player in window view.

##### arrAds:

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

`+(StreamingInfo *) createStreamURL:(NSString *) strURL withTitle:(NSString *) strTitle withSubTitle:(NSString *) strSubTitle withDuration:(NSInteger) duration withAds:(NSMutableArray *) arrAds;`

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

Refer to PlaylistViewController. e.g.

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

`e.g. [SlikePlayer getInstance] stopPlayer];`


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

##Author

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
