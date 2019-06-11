//
//  SlikeConfig.h
//  SlikePlayer
//
//  Created by TIL on 24/01/17.
//  Copyright (c) 2017 BBDSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SlikeGlobals.h"
#import "ISlikePlayerControl.h"
#import "StreamingInfo.h"

@interface SlikeConfig : NSObject

/**
 Create config With Default Values.

 @param mediaId - Slike Id & should not be empty
 @param autoPlay - Auto play Video
 @return - Config and can be update
 */
+ (instancetype)createConfigWithMediaId:(NSString *)mediaId isAutoPlay:(BOOL)autoPlay;

/**
 Create PlayerConfig for playing media
 
 @param videoTitle  - video title
 @param videoMediaId -  video media id(required)
 @param videoSection -  Ads will be served as per section (optional)
 @param videoMsId -  Slike Id to play video
 @param videoPosterURL -  posterImage is used for video place holder before playing.(optional)
 @return slikeConfig - Configuration instance
 */
- (id)initWithTitle:(NSString *)videoTitle withID:(NSString *)videoMediaId withSection:(NSString *) videoSection withMSId:(NSString *)videoMsId posterImage:(NSString*)videoPosterURL;

/**
 Create PlayerConfig for playing media
 
 @param videoChannel -  channel name. No need to be filled.(optional)
 @param videoMediaId -  video media id(required)
 @param videoSection -  Ads will be served as per section id. (optional)
 @param videoMsId  - Slike Id to play video
 @param videoPosterURL -  posterImage is used for image place holder before playing media (optional)
 @return slikeConfig - Configuration instance
 */
- (id)initWithChannel:(NSString *)videoChannel withID:(NSString *)videoMediaId withSection:(NSString *)videoSection withMSId:(NSString *)videoMsId posterImage:(NSString*)videoPosterURL;

/**
 This Method can be used to invoke the supported slike player directly without "SlikeId".
 @param playerType - Player Type that needs to be invoked.
 @param title - Media Title
 @param autoPlay - Media Should Auto Play
 @param mediaURL - Media URL String
 @param posterURLString - Poster Image URL
 @return - Config Model
 
 NOTE: For youTube pass "YoutubeId" also in mediaURL
 */
+ (instancetype)createConfigForType:(VideoSourceType)playerType mediaTitle:(NSString *)title mediaURL:(NSString *)mediaURL posterURL:(NSString *)posterURLString isAutoPlay:(BOOL)autoPlay;


/**
 Create PlayerConfig for playing media
 
 @param streamInfo - Info to play video if you want to play video from outside
 @param videoSection -  Ads will be served as per section id. (optional)
 @param videoMsId -  Slike Id to play video
 @return slikeConfig -  Configuration instance
 */
- (id)initWithInfo:(StreamingInfo *)streamInfo withSection:(NSString *)videoSection withMSId:(NSString *)videoMsId;
/**
 Making this property true means there are no force orientations.Changing the orientation will do nothing untill clicking on the full screen button. Clicking on Button will make screen Full/Normal.

 Note: It will work only if property is YES and Device type is iPad
 By Default: NO for all IOS device type
 */
@property(nonatomic,assign) BOOL orientationTypeiPad;

/**
 Section id required to play ads
 */
@property(nonatomic, strong) NSString *section;

/**
 Vender Id (optional)
 */
@property(nonatomic, strong) NSString *vendorID;

/**
 Slike Id to play media (required)
 */
@property(nonatomic, strong) NSString *mediaId;

/**
 Entity id (required)
 */
@property(nonatomic, strong) NSString *msId;

/**
 Google analytics id (optional)
 */
@property(nonatomic, strong) NSString *gaId;

/**
 ComScore publisherId (optional)
 */
@property(nonatomic, strong) NSString *cs_publisherId;

/**
 ComScore secret key (optional)
 */
@property(nonatomic, strong) NSString *c3;

/**
 Publisher name (optional)
 */
@property(nonatomic,strong) NSString *pid;

/**
 To identify the page section, required for reporting purpose. These are the unsupported or reserved characters: ~,", ', =, !, +, #, *, ~, ;, ^, (, ), <, >, [, ]
 */
@property(nonatomic,strong) NSString *pageSection;

/**
 Colombia audiance parameters use for ad analytic(optional)
 */
@property(nonatomic,strong) NSString *sg;

/**
 Geo country allowed name (optional)
 */
@property(nonatomic,strong) NSString *gca;

/**
 Geo country blocked name (optional)
 */
@property(nonatomic,strong) NSString *gcb;


/**
 This property is used for google analytics screen capture
 */
@property(nonatomic,strong) NSString *screenName;

/**
 This property is used to play Facebook videos
 */
@property(nonatomic,strong) NSString *fbAppId;

/**
 Error message for player
 */
@property(nonatomic,strong) NSString *errorMsg;

/**
 Preview image base Url
 */
@property(nonatomic,strong) NSString *imgBaseUrl;


/**
 Section within the app where media is to be played eg. Home/Videos
 */
@property(nonatomic,strong) NSString *pageTemplate;

/*
 Title of the media (optional)
 */
@property(nonatomic, strong) NSString *title;

/**
 Channel name (optional)
 */
@property(nonatomic, strong) NSString *channel;

/**
 Product or  Business name (optional)
 */
@property(nonatomic, strong) NSString *product;

@property(nonatomic, strong) NSString *business;

/**
 If property true, SlikePlayer cache the config data by default this property is FALSE
 */
@property(nonatomic, assign) BOOL allowConfigCache;

/**
 If property true, SlikePlayer does not show any ads by default this property is FALSE
 */
@property(nonatomic, assign) BOOL isSkipAds;

/**
 SlikePlayer disables chromecast SDK functionality by default this property is TRUE
 */
@property(nonatomic, assign) BOOL isCromeCastDisable;

/**
 This property tells whether player is currently supporting the Docing
 */
@property(nonatomic, assign) BOOL isDocEnable;

/**
 Player data reset for next and previous actions.
 */
@property(nonatomic,readwrite) BOOL resetPlayerInformation;

/**
 Enable ad prefetching. Currenlt supports only for POST Roll.
 Default : FALSE
 */
@property(nonatomic,assign) BOOL adPrefetchEnable;

/*
 * Properties for setting and getting player controlls
 */

/**
 Poster Image is used for image place holder before playing a media (optional)
 */
@property(nonatomic, strong) NSString *posterImage;

/**
 Time in milliseconds from where media should start
 */
@property(nonatomic, assign) NSInteger timecode;

/**
 If property true, the media will start automatically.
 */
@property(nonatomic, assign) BOOL isAutoPlay;

/**
 This property support autorotation of player. Default is set Portrait
 */
@property(nonatomic, assign) SlikeFullscreenAutoRotationMode autorotationMode;

/**
 If property false, fullscreen button will not be visible
 */
@property(nonatomic, assign) BOOL isFullscreenControl;

/**
 If property false, the close button will be visible only in fullscreen mode. Close control sends CONTROL event as CLOSE
 */
@property(nonatomic, assign) BOOL isCloseControl;

/**
 If property true, share button will be visible. Share control sends CONTROL event as SL_SHARE
 */
@property(nonatomic, assign) BOOL isShareControl;

/**
 If property true,  BitrateControl button will be visible. Default value is YES
 */
@property(nonatomic, assign) BOOL isBitrateControl;

/**
 If property true, next button control will be visible. Next control sends CONTROL event as SL_NEXT
 */
@property(nonatomic, assign) BOOL isNextControl;

/**
 If property true, previous button control will be visible. Previous control sends CONTROL event as SL_PREVIOUS.
 */
@property(nonatomic, assign) BOOL isPreviousControl;

/**
 PreferredVideoType, By default is VIDEO_SOURCE_HLS
 */
@property(nonatomic, assign) VideoSourceType preferredVideoType;

/**
 Player window color in full screen mode, Default value is Black Color
 */
@property(nonatomic,strong) UIColor  *fullScreenWindowColor;

/**
 If you want to create your own custom control, provide the customControl object as UIViewController
 */
@property(nonatomic, weak) UIView* customControls;

/**
 Parent app version for analytic (optional)
 */
@property(nonatomic,strong) NSString *appVersion;

/**
 Ad analytic custom parametrs (optional)
 */
@property(nonatomic,strong) NSString *description_url;

/**
 App packageName, Provided by seeting api key, No need to fill.
 */
@property(nonatomic,strong) NSString *packageName;

@property(nonatomic, assign)BOOL isGestureEnable;

/**
 Set the Placeholder image for the Video. By Default this property is NO. Client
 have to set the placeholder Image. If the property is YES then the SDDK will download and set the
 Image.
 */
@property(nonatomic,readwrite) BOOL isAllowSlikePlaceHolder;

/**
 If property is empty, share action returns callback in to application. Otherwise, iOS default share dialog will be shown (optional)
 */
@property(nonatomic,strong) NSString *shareText;

/*
 Time intervals  at which the gif event will be send to server
 */
@property(assign) NSInteger gifInterval;

/**
 Ad Prefetching time -  Seconds
 Currently supports only for POST-ROLL
 NOTE: Value should not be <10 Seconds
 Default value is 10 Seconds (Post-Roll will be pre fetched before 10 sec and will be shown once video finished).
 */
@property(nonatomic,assign) NSInteger postRollPreFetchInterval;

/**
 Time for removing pending or stuck ads. Default is 6000 milliseconds
 */
@property(nonatomic, assign) NSInteger adCleanupTime;

/**
 Start point of a clip in the video
 */
@property(nonatomic, assign) NSInteger clipStart;

/**
 End point of a clip in the video
 */
@property(nonatomic, assign) NSInteger clipEnd;

/**
 Playback duration after which a video is considered as played. Default value 2000 miliseconds
 */
@property(nonatomic, assign) NSInteger videoPlayed;

/**
 Playback duration after which an ad is considered as played. Default value 2000 miliseconds
 */
@property(nonatomic, assign) NSInteger adPlayed;

/*
 * Setting the properties - Location releated
 */

/**
 This property is used for latitude and longitude which is concatenated by ',' (optional)
 */
@property(nonatomic,strong) NSString *strLatLong;

/**
 Country name. This property is used for user profile (Optional)
 */
@property(nonatomic,strong) NSString *country;

/**
 State name. This property is used for user profile (Optional)
 */
@property(nonatomic,strong) NSString *state;

/**
 City name. This property is used for user profile (Optional)
 */
@property(nonatomic,strong) NSString *city;

/**
 Gender value. This property is used for user profile (Optional)
 */
@property(nonatomic,strong) NSString *gender;

/**
 Age value. This property is used for user profile (Optional)
 */
@property(nonatomic,assign) NSInteger age;

/**
 SSO login id (optional)
 */
@property(nonatomic, strong) NSString *ssoid;

/**
 This is used to set latitude and longitude (optional)
 
 @param lat user lattitude
 @param lng user longitude
 */
-(void)setLatitudeLongitude:(NSString*)lat Longitude:(NSString*)lng;

/**
 This is used to set county, state and city (optional)
 
 @param countryValue county name
 @param stateValue state name
 @param cityValue city name
 */
-(void)setCountry_State_City:(NSString *)countryValue State:(NSString*)stateValue City:(NSString*)cityValue;

/**
 This is used to set gender and age (optional)
 
 @param genderValue User Gender
 @param ageValue User Age
 */
-(void)setUserInformation:(NSString*)genderValue Age:(NSInteger)ageValue;

/**
 StreamingInfo -  Can be provided from parent App Also. Contains stream related info(optional)
 */
@property(nonatomic, strong) StreamingInfo *streamingInfo;

/**
 GDPR Data, Internally fill this data.
 */
@property(nonatomic,readwrite) BOOL isApiGDPRAnalyticEnabled;

/**
 @return player data information according to configuration
 */
-(NSString *) toString;

/**
 Start time for downloading the Media thumbnails.
 Default: When buffering time becomes 10 Seconds
 */
@property(nonatomic, assign) NSInteger previewsDndStartTime;

/**
 Show the Video previws while sliding the video through the SeekBar
 Default: FALSE
 */
@property(nonatomic, readwrite) BOOL preview;

/**
 This Flag is used with the Playlist . Making this value TRUE will auto move to next Playlist item
 Default : FALSE
 */
@property(nonatomic, readwrite) BOOL isAutoPlayNext;

/**
 Utility method :
 If media Thumnails Avalibale for the Stream.
 @return YES - Thumbnails Exists | NO - Thumbnails does not Exists
 */
- (BOOL)isMediaThumbnailsAvailable;

/**
 Enable the Preroll and Post roll. These properties will not work if isSkipAds = YES
 Default: AUTO (Will Work on the basis of configuration)
 */
@property (nonatomic, assign) SlikeAdPriority isPrerollEnabled;
@property (nonatomic, assign) SlikeAdPriority isPostrollEnabled;


/**
 * Title of next video (for playlist)
 */
@property (nonatomic, strong) NSString *nextVideoTitle;
/**
 * Thumbnail URL of next video (for playlist).
 */
@property (nonatomic, strong) NSString *nextVideoThumbnail;

/**
 *  Title for bitrates. You can change the label name. You can change the names only not the count of array.
    Default: @[@"Auto", @"Low", @"Medium", @"High"];
 */
@property(nonatomic, strong) NSArray *qualityName;

/**
 Set flag Yes, If you want to disable control
 */
@property(nonatomic,assign) BOOL isControlDisable;

/**
  Set flag YES, to background play support. This property is used only for mp3 background play
 */
@property(nonatomic,assign) BOOL isBackGrounPlayEnable;

/**
 if user is prime user, Assign this value is YES, Default value is FALSE
 */
@property(nonatomic,assign) BOOL ispr;

/**
 enableCoachMark, Default value is NO
 
 */
@property(nonatomic,assign) BOOL enableCoachMark;
/**
 isNoNetworkCloseCloseControl Default value is YES.
*/
@property(nonatomic, assign) BOOL isNoNetworkCloseControlEnable;

@end
