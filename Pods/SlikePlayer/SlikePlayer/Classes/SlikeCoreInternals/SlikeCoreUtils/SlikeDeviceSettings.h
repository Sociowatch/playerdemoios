//
//  SlikeDeviceSettings.h
//  SlikePlayer
//
//  Created by TIL on 10/08/12.
//  Copyright (c) 2012 TIL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "NSString+Advanced.h"

@class SlikeConfig;

@interface SlikeDeviceSettings : NSObject

+ (instancetype)sharedSettings;

@property(assign, readonly, getter = isIPhoneDevice) BOOL phoneDevice;
@property(nonatomic, strong, readonly, getter = deviceInfo) NSString *strDeviceInfo;

//Playback load times.
@property(assign) NSTimeInterval nConfigLoadTime;
@property(assign) NSTimeInterval nPlayerLoadTime;
@property(assign) NSTimeInterval nManifestLoadTime;
@property(assign) NSTimeInterval nVideoLoadTime;
@property(assign) NSTimeInterval nAdContentLoadTime;
@property(assign) NSTimeInterval nAdLoadTime;
@property(assign) NSInteger nAdSuccess;
@property(nonatomic,assign) BOOL tryHlsAds;

//Ad custom Params

/**
 Section id required to play ads
 */
@property(nonatomic, strong) NSString *section;

/**
 Vender Id (optional)
 */
@property(nonatomic, strong) NSString *vendorID;

/*
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

/**
 Ad analytic custom parametrs (optional)
 */
@property(nonatomic,strong) NSString *description_url;

/**
 App packageName, Provided by seeting api key, No need to fill.
 */
@property(nonatomic,strong) NSString *packageName;

/**
 Colombia audiance parameters use for ad analytic(optional)
 */
@property(nonatomic,strong) NSString *sg;



- (NSString*)getUserSession:(SlikeConfig *) config;

- (NSString *)getKey;

- (void)setKey:(NSString *)key;

- (NSString *)getSlikeAnalyticsCache;

- (void)setUniqueDeviceIdentifierAsString:(NSString *) strID;

- (NSString*)getDeviceLocation;

- (void)setUserSessionChangeInterval:(NSInteger) nUserSessionInterval;

- (NSInteger)getcapLevel;

- (void)setMax_Min_CapLevel:(NSInteger)minLevel MaxLevel:(NSInteger)capLevel;

- (void)setM3U8HostValue:(NSString *)strM3U8HostName;

- (NSString*)getM3U8HostName;

- (void)setVideoRid:(NSString *)ridvalue;

- (NSString*)getVideoRid;

- (NSString*)getGeoCountry;

- (void)setGeoCountry:(NSString *)geoId;

- (BOOL)isGeoAllowed:(NSString*)strGca GCB:(NSString*)strGcb;

- (NSString*)getBitrateBylabel:(SlikeConfig*)config;

- (void)setPlayerViewArea:(id)parentView;

- (float)getPlayerViewArea;

- (NSInteger)getScreenResEnum;

- (NSInteger)serverPingInterval;

- (void)setServerPingInterval:(NSInteger)serverPingInterval;

- (NSInteger)serverPlayStatus;

- (void)setServerPlayStatus:(NSInteger)serverPlayStatus;

- (NSInteger)nMeasuredBitrate;

- (void)setMeasuredBitrate:(NSInteger)measuredBitrate;

- (void)setMediaBitrate:(NSString *)bitrate;

- (void)setMediaBitrate:(NSString *)bitrate withLabel:(NSString*)bitrateLabel;

- (NSString *)savedMediaBitrate;

- (NSString *)genrateUniqueSSId:(NSString*)mediaId;

-(void)updateAdCustomParams:(SlikeConfig*)config;


- (BOOL)isPhoneX;

- (BOOL)isPhone6Plus;

- (BOOL)isPhone6;

- (BOOL)isPhone5;

- (BOOL)isPhone4;

@property (nonatomic, weak) UIViewController *playerParentViewController;
@property(nonatomic,assign) BOOL isDebugMode;
@property(nonatomic, strong) NSString *gaId;
@property(nonatomic, strong) NSString *comscoreId;

//Utility method for showing the Coachmark
- (BOOL)hasCoachMarkShown;
//Update the coachmark status
- (void)updateCoachMarkStatus:(BOOL)hasShown;

/// SDK Version or player version
- (NSString*)getSDKVersion;

/// Speed Player
-(float)getAvplayerSpeed;
@end
