# SlikePlayer  (v 2.5.0)

## Example

To run the example project, clone the repo by clicking [**SlikePlayer demo for iOS**][aef1a7c4]

  [aef1a7c4]: https://bitbucket.org/times_internet/slikeplayerdemoios.git "SlikePlayerDemoiOS"

## Requirements
platform: iOS 9 or greater
NSAppTransportSecurity: (For app transport security see the example's info plist file.)

## Installation

SlikePlayer is available through private repo [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```

pod 'SlikePlayer', :git => 'https://bitbucket.org/times_internet/slikeplayer-ios.git', :tag => '2.5.0'

```


#HOW TO INTEGRATE:
Best way to integrate, [**just clone the example repo**][65b043dc].

  [65b043dc]: https://bitbucket.org/times_internet/slikeplayerdemoios.git "SlikePlayerDemoiOS"

**************************************
``` Basic Implimentation ```

SlikePlayerSettings is a singleton class. To instantiate,

```
#import <SlikePlayer/SlikePlayer.h>
```
SlikePlayer will be initialized as follows.

```
[[SlikePlayerSettings playerSettingsInstance] initPlayerWithApikey:apikey andWithDeviceUID:nil debugMode:isDebug];

```

#####apikey
The Slike key provided by the Slike CMS.

#####uuid
Device unique id used by the app.

#####debug mode
BOOL. The app should ensure release build should not go with debug mode as YES.


####SlikePlayer Property
```
@property (strong, nonatomic) SlikePlayer *slikePlayer;
@property (strong, nonatomic) SlikeConfig *slikeConfig;
```
####initialisation

```self.slikeConfig = [[SlikeConfig alloc] initWithChannel:@"slike" withID:@"1x13srhggk" withSection:@"default" withMSId:@"56087249" posterImage:@""]
self.slikePlayer = [SlikePlayer sharedSlikePlayer];
```
####method

 `- (void)playVideo:(SlikeConfig *)configModel inParentView:(UIView *)parent withProgressHandler:(onChange)stateBlock`
 

#### Parameters:

#####configModel:

 The media configuration file and instance of **SlikeConfig MDO**.

####SlikeConfig has following properties.

Property|Type|Description|Default Value
--|---|--|--
mediaId|String|Media id to be played.(required)|N/A
ssoid|String|SSO login id.(optional)|Empty
msId|String|entity id (required)|N/A
title|String|title of the media.|Empty
channel|String|channel name. No need to be filled.|N/A
section|String|Section id. Ads will be served as per section id. (required)|Empty
streamingInfo|StreamingInfo|StreamingInfo instance. Not required to fill if using mediaId. SlikePlayer will take care of it.|N/A
adCleanupTime|Number|Remove pending or stucked ad within time. Default is 6000 milliseconds.| 6000 milliseconds
timecode|Number|Time in milliseconds from where media should start.|0
isSkipAds|boolean|If property true, SlikePlayer does not show any ad.|NO
isAutoPlay|boolean|If property true, the media will start automatically.|YES
isFullscreenControl|boolean|If property false, the fullscreen button will not be visible.|YES
isCloseControl|boolean|If property false, the close button will be visible only in fullscreen mode. Close control sends CONTROL event as CLOSE.|YES
isShareControl|boolean|If property false, share button will not be visible. Share control sends CONTROL event as SHARE.|YES
isNextControl|boolean|If property true, next button control will be visible. Next control sends CONTROL event as SL_NEXT.|NO
isPreviousControl|boolean|If property true, previous button control will not be visible. Previous control sends CONTROL event as SL_PREVIOUS.|NO
isFastSeekable|boolean|If property false (default), precise seeking is performed. Otherwise loose but fast seek is performed.|NO
customControl|optional|If you want to create your own custom control, Please provide the customControl.|Default control added
isCromeCastDisable|boolean|If property true, SlikePlayer does not show any cromecast.|NO
shareText|String|If property is empty, share action return callback in to application. Otherwise we will open ios default share dialog|Empty
posterImage|String|posterImage is used for video place holder before playing.|Empty
strLatLong|String|This property is used for latitude and longitude which is concatenated by ',' .|Empty
country|String|This property is used for user profile.|Empty
state|String|This property is used for user profile..|Empty
city|String|This property is used for user profile.|Empty
gender|String|This property is used for user profile.|Empty
screenName|String|This property is used for google analytic screen capture.|Empty
fbAppId|String|This property is used for FaceBook video play.|Empty
pageTemplate|String|Section within the app where media is to be played eg. Home/Videos|Empty


##### parent:

 Parent is the view in which the player will be added. It should be  an UIView. It is non nil.

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
