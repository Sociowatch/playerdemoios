# SWPlayer  (v 10.1.0)

## Example

To run the example project, clone the repo by clicking [**SWPlayer demo for iOS**][aef1a7c4]

  [aef1a7c4]: https://github.com/Sociowatch/playerdemoios.git "SWPlayerDemoiOS"

## Requirements
platform: iOS 13 or greater
NSAppTransportSecurity: (For app transport security see the example's info plist file.)

## Installation

SWPlayer is available through private repo [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```

pod 'SWPlayer', :git => 'https://github.com/Sociowatch/swplayer-ios.git', :tag => '10.1.0'

```


#HOW TO INTEGRATE:
Best way to integrate, [**just clone the example repo**][65b043dc].

  [65b043dc]: https://github.com/Sociowatch/playerdemoios.git "PlayerDemoiOS"

**************************************
``` Basic Implimentation ```

SWPlayerSettings is a singleton class. To instantiate,

```
#import <SWPlayer/SWPlayer.h>
```
SWPlayer will be initialized as follows.

```
[[SWPlayerSettings playerSettingsInstance] initPlayerWithApikey:apikey andWithDeviceUID:nil debugMode:isDebug];

```

#####apikey
The SW key provided by the SW CMS.

#####uuid
Device unique id used by the app.

#####debug mode
BOOL. The app should ensure release build should not go with debug mode as YES.


####SWPlayer Property
```
@property (strong, nonatomic) SWPlayer *swPlayer;
@property (strong, nonatomic) SWConfig *swConfig;
```
####initialisation

```self.swConfig = [[SWConfig alloc] initWithChannel:@"swPlayer" withID:@"1x13srhggk" withSection:@"default" withMSId:@"56087249" posterImage:@""]
self.swPlayer = [SWPlayer sharedSWPlayer];
```
####method

 `- (void)playVideo:(SWConfig *)configModel inParentView:(UIView *)parent withProgressHandler:(onChange)stateBlock`
 

#### Parameters:

#####configModel:

 The media configuration file and instance of **SWConfig MDO**.

####SWConfig has following properties.

Property|Type|Description|Default Value
--|---|--|--
mediaId|String|Media id to be played.(required)|N/A
ssoid|String|SSO login id.(optional)|Empty
msId|String|entity id (required)|N/A
title|String|title of the media.|Empty
channel|String|channel name. No need to be filled.|N/A
section|String|Section id. Ads will be served as per section id. (required)|Empty
streamingInfo|StreamingInfo|StreamingInfo instance. Not required to fill if using mediaId. SWPlayer will take care of it.|N/A
adCleanupTime|Number|Remove pending or stucked ad within time. Default is 6000 milliseconds.| 6000 milliseconds
timecode|Number|Time in milliseconds from where media should start.|0
isSkipAds|boolean|If property true, SWPlayer does not show any ad.|NO
isAutoPlay|boolean|If property true, the media will start automatically.|YES
isFullscreenControl|boolean|If property false, the fullscreen button will not be visible.|YES
isCloseControl|boolean|If property false, the close button will be visible only in fullscreen mode. Close control sends CONTROL event as CLOSE.|YES
isShareControl|boolean|If property false, share button will not be visible. Share control sends CONTROL event as SHARE.|YES
isNextControl|boolean|If property true, next button control will be visible. Next control sends CONTROL event as SL_NEXT.|NO
isPreviousControl|boolean|If property true, previous button control will not be visible. Previous control sends CONTROL event as SL_PREVIOUS.|NO
isFastSeekable|boolean|If property false (default), precise seeking is performed. Otherwise loose but fast seek is performed.|NO
customControl|optional|If you want to create your own custom control, Please provide the customControl.|Default control added
isCromeCastEnable|boolean|If property true, SWPlayer does not show any cromecast.|NO
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

Times News Network Limited, sanjay.rathor1@timesgroup.com

License
-------

    Copyright 2023 Times News Network

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
