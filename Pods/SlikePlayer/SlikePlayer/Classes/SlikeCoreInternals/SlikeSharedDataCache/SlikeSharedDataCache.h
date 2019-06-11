//
//  SlikeSharedDataCache.h
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 23/05/18.
//

#import <Foundation/Foundation.h>

@class SlikeAdsQueue;
@class SlikeBitratesModel;

typedef NS_ENUM(NSUInteger, SlikeMediaBitrate) {
    SlikeMediaBitrateAuto = 0x0,
    SlikeMediaBitrateLow,
    SlikeMediaBitrateMedium,
    SlikeMediaBitrateHigh,
    SlikeMediaBitrateNone
};

@interface SlikeSharedDataCache : NSObject
+ (instancetype)sharedCacheManager;

@property (nonatomic, assign) SlikeMediaBitrate currentStreamBitrate;
/**
 Slike Base Url
 @return - base Url
 */
- (NSString *)slikeBaseUrlString;

/**
 Slike Analytics String
 @return - Analytics Url
 */
- (NSString *)slikeAnalyticsBaseURLString;

/**
 Update the Base Url String
 @param updatedBaseUrl - Updated URL String
 */
- (void)updateSlikeBaseUrl:(NSString *)updatedBaseUrl;

/**
 Update the Analytics Url
 @param updatedAnalyticsUrl - Updated Analytics Url
 */
- (void)updateSlikeAnalyticsBaseUrl:(NSString *)updatedAnalyticsUrl;

/**
 Cache the slike config data
 @param configData - Config Data
 */
- (void)cacheSlikeConfigData:(NSData *)configData;

/**
Cached config Data
@return - cached data
 */
- (NSData *)cachedSlikeConfigData;


/**
 Reset the Slike config Data
 */
- (void)resetSlikeConfigData;

/**
 Live Stream Id for the Stream
 @param currentStreamId  - Current id
 @return - Mapped Strem Id
 */
- (NSString *)mappedLiveStreamId:(NSString*)currentStreamId;

/**
 Update the player playing  duration
 @param playerDuration - Current duration
 */
- (void)updateTotalVideoPlayedDuration:(NSInteger)playerDuration;

/**
 Total Played Duration by the player
 @return - played Duration
 */
- (NSInteger)totalVideoPlayedDuration;

/**
 Cache Preloaded Ads Contents

 @param adPrefetchQueue - Items
 */
- (void)cachePreloadedAdsContents:(SlikeAdsQueue *)adPrefetchQueue;

/**
 Cached Preloaded Ads Contents

 @return - PreloadedAdsContents
 */
- (SlikeAdsQueue *)cachedPreloadedAdsContents;

/**
 Is Prefetch is Allow
 @return - TRUE|FALSE
 */
- (BOOL)isPrefetchAllow;
/**
 Prefetch Items Count
 @return - Count
 */
- (NSInteger)prefetchedAdsCount;
/**
 Cache the Bitrates model
 @param bitrates - Bitrate model that needs to be cache
 @param currentStreamBitrate - currentStreamBitrate
 
 */
- (void)cacheBitratesModel:(NSArray *)bitrates withCurrentBitrate:(SlikeMediaBitrate) currentStreamBitrate;
/**
 Cached Bitrate model
 @return - Bitrate Model
 */
- (NSArray *)cachedBitratesModels;
/**
 Clear Bitrate items
 */
- (void)resetSlikeBitratesModel;

/**
 Currently Bitrates
 @return - Bitrates Stream
 */
- (NSMutableString *)currentStreamBitrateURL;

/**
 Return the Stream URL for perticuler tyep bitrate
 @param bitrateType - Bitrate type
 @return - Bitrate  Stream
 */

- (NSMutableString *)streamUrlForBitrateType:(SlikeMediaBitrate )bitrateType;
/**
 Bitrates Available For the Stream
 @return - TRUE|FALSE
 */

- (BOOL)isBitratesAvailableForStream;

/**
CSS ID
 */
@property (nonatomic, strong) NSString *cssId;

/**
 Preefetch Id
 */
@property (nonatomic, strong) NSString *pfid;

/**
  ts - time segment
 */
@property (nonatomic, strong) NSString *ts;

/**
 Request time Interval
 */
@property (nonatomic, strong) NSString *interval;

/**
 Ad Clean up type
 */
@property (nonatomic, assign) NSInteger adCleanupTime;

/**
 Cached Bitrates
 */
@property (weak,  nonatomic) NSArray *cacahedPlaylist;

/**
 update the playlist index
 @param playlistIndex - Updated playlist index
 */
- (void)updatePlylistIndex:(NSInteger)playlistIndex;

/**
 Current Playlist Index
 @return - Current Index
 */
- (NSInteger)currentPlylistIndex;

/**
 Has Playlist Next Vodeo Also
 @return TRUE|FALSE
 */
- (BOOL)isLastPlaylistItem;

    
/**
 Cache the Stream
 @param stream - Stream
 @param mediaId - Media Id
 */
- (void)cacheStream:(NSData *)stream forMediaId:(NSString *)mediaId;

/**
 Cacahed Media Stream

 @param mediaId - Media Id
 @return - Stream
 */
- (NSData *)cachedStreamForMediaId:(NSString *)mediaId;

/**
 Reset the cached Streams
 */
- (void)resetCachedStreams ;

/**
 Is Stream Already Cached
 @param mediaId - Media Id
 @return -  TRUE|FALSE
 */
- (BOOL)isStreamAlreadyCached:(NSString *)mediaId;

- (BOOL)isPlayListVideo;

@property (nonatomic, assign) BOOL isGDPREnable;

@end
