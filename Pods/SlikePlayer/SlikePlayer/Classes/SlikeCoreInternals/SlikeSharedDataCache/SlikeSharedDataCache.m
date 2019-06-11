//
//  SlikeSharedDataCache.m
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 23/05/18.
//

#import "SlikeSharedDataCache.h"
#import "SlikeAdsQueue.h"
#import "SlikeBitratesModel.h"
#import "StreamingInfo.h"

@interface SlikeSharedDataCache() {
}

@property (strong, nonatomic) NSString *baseURLString;
@property (strong, nonatomic) NSString *analyticsBaseURLString;
@property (strong, nonatomic) NSData *slikeConfigData;
@property (assign, nonatomic) NSInteger nTotalVideoPlayedDuration;
@property (strong, nonatomic) SlikeAdsQueue *adPrefetchQueue;
@property (strong, nonatomic) NSMutableArray *bitratesArray;
@property (assign, nonatomic) NSInteger bitarteType;
@property (assign, nonatomic) NSInteger currentPlaylistIndex;
@property (strong, nonatomic) NSMutableDictionary *cacahedStreams;
@property (strong, nonatomic) NSString *tileImageURLString;
@end

@implementation SlikeSharedDataCache

+ (instancetype)sharedCacheManager {
    
    static dispatch_once_t onceToken;
    static SlikeSharedDataCache *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _baseURLString = @"http://slike.indiatimes.com/";
        _analyticsBaseURLString = @"http://slike.indiatimes.com/";
        _pfid = @"";
        _ts = @"";
        _interval = @"0";
        _bitarteType =  -1;
        _bitratesArray = [[NSMutableArray alloc]init];
        _currentStreamBitrate = SlikeMediaBitrateNone;
        self.adCleanupTime = 8000L;
        _cacahedStreams = [[NSMutableDictionary alloc]init];
        _isGDPREnable =  false;
        _cssId =  @"";
        
        _tileImageURLString = @"http://imgslike.akamaized.net/";
    }
    
    return self;
}


/**
 Slike Base Url
 @return - base Url
 */
- (NSString *)slikeBaseUrlString {
    return _baseURLString;
}

/**
 Slike Analytics String
 @return - Analytics Url
 */
- (NSString *)slikeAnalyticsBaseURLString {
    return _analyticsBaseURLString;
}


/**
 Update the Base Url String
 @param updatedUrlString - Updated URL String
 */
- (void)updateSlikeBaseUrl:(NSString *)updatedUrlString {
    if (updatedUrlString !=nil && ![updatedUrlString isEqualToString:@""]) {
        self.baseURLString = updatedUrlString;
        [[SlikeNetworkManager defaultManager] updateAnalyticURLs];
    }
}

/**
 Update the Analytics Url
 @param updatedUrlString - Updated Analytics Url
 */
- (void)updateSlikeAnalyticsBaseUrl:(NSString *)updatedUrlString {
    if (updatedUrlString !=nil && ![updatedUrlString isEqualToString:@""]) {
        self.analyticsBaseURLString = updatedUrlString;
        [[SlikeNetworkManager defaultManager] updateAnalyticURLs];
    }
}

/**
 Cache the slike config data
 @param configData - Config Data
 */
- (void)cacheSlikeConfigData:(NSData *)configData {
    self.slikeConfigData = [[NSData alloc]initWithData:configData];
}

- (NSData *)cachedSlikeConfigData {
    return self.slikeConfigData;
}

- (void)resetSlikeConfigData {
    self.slikeConfigData =nil;
}


/**
 Get the liveId from the Dictonary
 @param currentStreamId - CUrrenr
 @return - Mapped Id
 */
-(NSString *)mappedLiveStreamId:(NSString*)currentStreamId {
    
    NSMutableDictionary *dict =  [NSMutableDictionary dictionary];
    //Time Now
    [dict setObject:@"1x13qpaggu" forKey:@"times-now"];
    [dict setObject:@"1x13qpaggu" forKey:@"timesnow"];
    [dict setObject:@"1x13qpaggu" forKey:@"tnow1"];
    [dict setObject:@"1x13qpaggu" forKey:@"tnow2"];
    [dict setObject:@"1x13qpaggu" forKey:@"timesnow-bt-hd"];
    //ET NOW
    [dict setObject:@"1x13qpcggu" forKey:@"et-now"];
    [dict setObject:@"1x13qpcggu" forKey:@"economicstimes"];
    [dict setObject:@"1x13qpcggu" forKey:@"etnow"];
    //Zoom TV
    [dict setObject:@"1x13qpdggu" forKey:@"zoom-tv"];
    [dict setObject:@"1x13qpdggu" forKey:@"zoomtv"];
    //MB Now
    
    [dict setObject:@"1x13qpjggu" forKey:@"mb-now"];
    [dict setObject:@"1x13qpjggu" forKey:@"mirrornow"];
    [dict setObject:@"1x13qpjggu" forKey:@"mirror-now"];
    [dict setObject:@"1x13qpjggu" forKey:@"magicbricks-now"];
    
    //ET Audio
    [dict setObject:@"1x13w1wggu" forKey:@"et-now-audio"];
    //TIMES Now Audio
    [dict setObject:@"1x13w1fggu" forKey:@"times-now-audio"];
    
    if([dict objectForKey:currentStreamId]) {
        return [dict objectForKey:currentStreamId];
        
    } else {
        return @"";
    }
}

#pragma mark - TotalVideoPlayedDuration

/**
 Update the player playing  duration
 @param playerDuration - Current duration
 */
- (void)updateTotalVideoPlayedDuration:(NSInteger)playerDuration {
    _nTotalVideoPlayedDuration = playerDuration;
}

/**
 Total Played Duration by the player
 @return - played Duration
 */
- (NSInteger)totalVideoPlayedDuration {
    return _nTotalVideoPlayedDuration;
}


- (void)cachePreloadedAdsContents:(SlikeAdsQueue *)adPrefetchQueue {
    self.adPrefetchQueue = adPrefetchQueue;
}

- (SlikeAdsQueue *)cachedPreloadedAdsContents {
    return _adPrefetchQueue;
}

/**
 Is Prefetch is enabled
 @return - TRUE | FALSE
 */
- (BOOL)isPrefetchAllow {
    if (self.adPrefetchQueue && [self.adPrefetchQueue.adContents count]>0) {
        return YES;
    }
    return NO;
}


- (NSInteger)prefetchedAdsCount {
    if (self.adPrefetchQueue) {
        return [self.adPrefetchQueue.adContents count];
    }
    return 0;
}

/**
 Cache the Bitrates model
 @param bitrates - Bitrate model that needs to be cache
 */
- (void)cacheBitratesModel:(NSArray *)bitrates withCurrentBitrate:(SlikeMediaBitrate) currentStreamBitrate {
    _currentStreamBitrate = currentStreamBitrate;
    [_bitratesArray removeAllObjects];
    [_bitratesArray addObjectsFromArray:bitrates];
}

/**
 Cached Bitrate model
 @return - Bitrate Model
 */
- (NSArray *)cachedBitratesModels {
    return _bitratesArray;
}

- (BOOL)isBitratesAvailableForStream {
    return [_bitratesArray count] >0 ? YES :NO ;
}

- (void)resetSlikeBitratesModel {
    [_bitratesArray removeAllObjects];
    _currentStreamBitrate = SlikeMediaBitrateNone;
}

/**
 current Stream Bitrates
 @return - StreamBitrateURL
 */
- (NSMutableString *)currentStreamBitrateURL {
    for (SlikeBitratesModel * model in _bitratesArray) {
        if (model.bitrateType == _currentStreamBitrate) {
            return model.bitrateUrl;
        }
    }
    return nil;
}

- (NSMutableString *)streamUrlForBitrateType:(SlikeMediaBitrate )bitrateType {
    for (SlikeBitratesModel * model in _bitratesArray) {
        if (model.bitrateType == bitrateType && model.isValid) {
            return model.bitrateUrl;
        }
    }
    return nil;
}

/**
 update the playlist index
 @param playlistIndex - Updated playlist index
 */
- (void)updatePlylistIndex:(NSInteger)playlistIndex {    
    _currentPlaylistIndex = playlistIndex;
}

/**
 Current Playlist Index
 @return - Current Index
 */
- (NSInteger)currentPlylistIndex {
    return _currentPlaylistIndex;
}

/**
 Cache the Stream
 @param stream - Stream
 */

/**
 Cache the Stream
 @param stream - Stream
 @param mediaId - Media Id
 */
- (void)cacheStream:(NSData *)stream forMediaId:(NSString *)mediaId {
    if (stream !=nil && [mediaId isValidString]) {
        [_cacahedStreams setObject:stream forKey:mediaId];
    }
}

/**
 Cacahed Media Stream
 
 @param mediaId - Media Id
 @return - Stream
 */

- (NSData *)cachedStreamForMediaId:(NSString *)mediaId {
    if ([mediaId isValidString]) {
        return _cacahedStreams[mediaId];
    }
    return nil;
}

/**
 Reset the cached Streams
 */
- (void)resetCachedStreams {
    [_cacahedStreams removeAllObjects];
}

- (BOOL)isStreamAlreadyCached:(NSString *)mediaId {
    if ([_cacahedStreams objectForKey:mediaId]) {
        return YES;
    }
    return NO;
}

/**
 Check whether the player has more than on vodeo streams to play
 @return -  YES  if it has next stream to play
 */
- (BOOL)isLastPlaylistItem {
    if(_cacahedPlaylist && [_cacahedPlaylist count]>0 && (_currentPlaylistIndex == [_cacahedPlaylist count]-1)) {
        return YES;
    }
    return NO;
}

- (BOOL)isPlayListVideo {
    if (_cacahedPlaylist && [_cacahedPlaylist count]>0) {
        return YES;
    }
    return NO;
}

///**
// Get the Ad Queue for PRE|POST|MID
// @param adIdentity - PRE|POST|MID
// @return - AdQueue
// */
//- (SlikeAdsQueue *)getPrefetchedAdQueueForAdType:(NSInteger)adIdentity {
//
//    for (SlikeAdsQueue *adInfo in _adPrefetchArray) {
//
//        if (adIdentity == -1) {
//            if (adInfo.startPoistion == -1 && adInfo.adType == SL_POST) {
//                SlikeDLog(@"ADS LOG: Prefetch Ad from Global Cache and AdType == POST");
//                return adInfo;
//            }
//
//        } else if (adIdentity == 0) {
//
//            if (adInfo.startPoistion == 0 && adInfo.adType == SL_PRE) {
//                SlikeDLog(@"ADS LOG: Prefetch Ad from Global Cache and AdType == PRE");
//                return adInfo;
//            }
//        }
//        else {
//            //TODO: Need to do for the Mid
//        }
//    }
//    return Nil;
//}

- (NSString *)tileImageBaseUrl {
    if (_tileImageURLString && [_tileImageURLString length]>0) {
        return _tileImageURLString;
    }
    _tileImageURLString = @"http://imgslike.akamaized.net/";
    return _tileImageURLString;
    
}
- (void)updateTileImageBaseUrl:(NSString *)tileImageURLString {
    if (tileImageURLString != nil && [tileImageURLString length]>0) {
        _tileImageURLString = tileImageURLString;
    }
}

@end
