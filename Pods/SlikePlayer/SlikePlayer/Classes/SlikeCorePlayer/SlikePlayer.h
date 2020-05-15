//
//  SlikePlayer.h
//  Slike
//
//  Created by TIL on 29/11/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//
// SDK Version 2.9.5

#import <UIKit/UIKit.h>
#import "ISlikePlayer.h"
#import "SlikeGlobals.h"

@class SlikeConfig;
@class StreamingInfo;
@class StatusInfo;

@interface SlikePlayer : NSObject

/**
 Function returns class instance.
 @return - Class instance
 */
+ (instancetype)sharedSlikePlayer;

/**
 Updated Config request
 
 @param configModel client confog
 @param  block update config
 */
- (void)getUpdatedSlikeConfigInfo:(SlikeConfig *)configModel  withProgressHandler:(onConfigUpdateChange) block;

/**
 Function returns class instance.

 @param playlist - Array of SlikeConfigs
 @return - Class instance
 
 NOTE: playlist should be like @["config1","config1"...]
 
 */
+ (instancetype)sharedSlikePlayerWithPlaylist:(NSArray *)playlist;

/**
 Media will be changed automatically when previous media completes. It works only with playlist
 By Default: TRUE
 */
@property(nonatomic, assign) BOOL autoChangeNextMedia;

/**
 Player Instance
 @return - Current Player Instance
 Supported Players (GIF|MEME|YOUTUBE|HLS|FACEBOOK|DAILYMOTION)
 */
- (id<ISlikePlayer>)getAnyPlayer;

/**
  Stop the SlikePlayer. Will Release all the resources acquired by the SDK
 */
- (void)stopPlayer;

/**
 Play the video

 @param configModel -  Config file for Stream
 @param parent - Parent View
 @param stateBlock  - Player Status Block. Will notify ablut the player events
  */

- (void)playVideo:(SlikeConfig *)configModel inParentView:(UIView *)parent withProgressHandler:(onChange)stateBlock;

/**
 Play the video from the playlist.
 @param currrentIndex - Current Index
 @param parent - Parent View
 @param stateBlock - Player Status Block. Will notify ablut the player events
 
 NOTE: Before using this method, need to initialze the player with the playlist . "sharedSlikePlayerWithPlaylist: "
 */
- (void)playVideoAtIndex:(NSInteger)currrentIndex inParentView:(UIView *)parent withProgressHandler:(onChange)stateBlock;

#pragma mark - PlayList Utility Methods
/**
 Get the slike Config at Index
 @return - NILL || Valid config File
 */
- (SlikeConfig *)slikeConfigAtIndex:(NSInteger)indexPath;

/**
 Returns Next Slike Config Index
 @return - Valid Index  || -1
 */
- (NSInteger)nextSlikeConfigIndex;

/**
 Returns Previous Slike Config Index
 @return - Valid Index  || -1
 */
- (NSInteger)previousSlikeConfigIndex;

/**
 Hide controls mannulay
 */
-(void)hideControls;

@property (nonatomic, strong) id<ISlikeCast> slikeCast;
- (void)subscribeCues:(id<ICueHandler>)cueHandler;

@end



@interface SlikePlayerSettings:NSObject {
    id<ISlikeAnlytics> _slikeAnalyticsComScore;
}

/**
 Shared Instance of player class
 @return  - Shared Player instance
 */
+ (instancetype)playerSettingsInstance;

/**
 Initialise the player with Key and Device UID
 
 @param apiKey  - API key
 @param uuid - UUID (Optional)
 @param isDebug - Is debug purpose
 
 NOTE: Preferred place to initialize the SDK is in "AppDelegate Class
  [[SlikePlayerSettings playerSettingsInstance] initPlayerWithApikey:@"XXXXXX" andWithDeviceUID:nil debugMode:isDebug];

 */

- (void)initPlayerWithApikey:(NSString *)apiKey andWithDeviceUID:(NSString *)uuid debugMode:(BOOL)isDebug;

/// SlikeStrings
@property(nonatomic, strong) SlikeLanguageStrings *slikestrings;

/// PreFetch Node for specific Language
@property (nonatomic, strong,readonly) NSString *prefetchNode;

/// User This method for updatevalues
-(void)resetSlikeStrings;

/**
 GDPAEnabledenable information
 
 @param isGDPREnabled value true if enable else false
 */
-(void)setGDPAEnabled:(BOOL)isGDPREnabled;


/// Node For Prectech
/// @param prefetchNode Node value for pretch , If you want to default node then pass Empty
/// @param isRemoved cancel last prefech Data
-(void)setPrefetchNode:(NSString*)prefetchNode shouldRemovedLastPrefectData:(BOOL)isRemoved;


/// set Ad Priority  array if any other wise set nil;
/// @param adPriority array [NSArray arrayWithObjects:@"SL_FAN", @"SL_IMA", nil];
/// @param isSoftCncl YES  if reset all ad pass NO
-(void)setAdPriority:(NSArray*)adPriority withSoftCancellation:(BOOL)isSoftCncl;

/**
 Add the Analytics Info
 @param slikeAnalytics -
 */
-(void)addAnalytics:(id <ISlikeAnlytics>) slikeAnalytics;

/**
 Analytics Trackers
 @return - AnalyticsTrackers
 */
- (NSArray*)getAnalyticsTrackers;

/**
 ComScore Analytics Trackers
 @return - ComScoreAnalyticsTrackers
 */
- (id<ISlikeAnlytics>)getComScoreAnalyticsTrackers;

- (void)setIdsForAnalyticsEvents:(NSString *)gaId withCS_publisherId:(NSString*)cs_publisherId;

@property(nonatomic, strong, readwrite) UIColor *playerStyleBarBackground;
@property(nonatomic, strong, readwrite) UIColor *playerStyleSliderMinTrackColor;
@property(nonatomic, strong, readwrite) UIColor *playerStyleSliderMaxTrackColor;
@property(nonatomic, strong, readwrite) UIImage *playerStyleSliderThumbImage;
@property(nonatomic, strong, readwrite) UIFont *playerStyleTitleFont;
@property(nonatomic, strong, readwrite) UIFont *playerStyleDurationFont;
@property(nonatomic, strong, readwrite) UIColor *playerStyleTitleColor;
@property(nonatomic, strong, readwrite) UIColor *playerStyleDurationColor;
@property(nonatomic, strong, readwrite) UIImage *playerStyleReverseButton;
@property(nonatomic, strong, readwrite) UIImage *playerStylePlayButton;
@property(nonatomic, strong, readwrite) UIImage *playerStylePauseButton;
@property(nonatomic, strong, readwrite) UIImage *playerStyleReplayButton;
@property(nonatomic, strong, readwrite) UIImage *playerStyleStopButton;
@property(nonatomic, strong, readwrite) UIImage *playerStyleForwardButton;
@property(nonatomic, strong, readwrite) UIImage *playerStyleBitrateButton;
@property(nonatomic, strong, readwrite) UIImage *playerStyleFullscreenButton;
@property(nonatomic, strong, readwrite) UIImage *playerStyleShareButton;
@property(nonatomic, strong, readwrite) UIImage *playerStyleCloseButton;
@property(nonatomic, strong, readwrite) UIColor *playerStyleActivityTintColor;
@property(nonatomic, strong, readwrite) UIColor *playerStyleBitrateBackground;
@property(nonatomic, strong, readwrite) UIColor *playerStyleBitrateTitleColor;
@property(nonatomic, strong, readwrite) UIColor *playerStyleBitrateSubtitleColor;
@property(nonatomic, strong, readwrite) UIColor *playerStyleBitrateContentColor;
@property(nonatomic, strong, readwrite) UIFont *playerStyleBitrateTitleFont;
@property(nonatomic, strong, readwrite) UIFont *playerStyleBitrateSubtitleFont;
@property(nonatomic, strong, readwrite) UIFont *playerStyleBitrateContentFont;

/**
 Analytic file 
 */
@property (strong, nonatomic)NSMutableArray *arrAnalyticsTrackers;

@end







