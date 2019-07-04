//
//  StreamingInfo.m
//

#import "StreamingInfo.h"
#import "Stream.h"
#import "SlikeUtilities.h"
#import "SlikeSharedDataCache.h"

@interface StreamingInfo() {
    Stream *currentStream;
}
@property(nonatomic, strong) NSMutableDictionary *dictVideos;
@property(nonatomic, assign) VideoSourceType currentVideoSource;
@end


@implementation StreamingInfo

- (id)init {
    
    if (self = [super init]) {
        
        _isExternalPlayer =  NO;
        _strThumbe_160 = @"";
        _strTitle = @"";
        _strID = @"";
        _strSubtitle = @"";
        _strMeta = @"";
        _strChannel = @"";
        _strSS = @"";
        _strTS = @"";
        _nDuration = 0L;
        _nStartTime = 0L;
        _isLive = NO;
        _isAudio = NO;
        _adContentsArray = [[NSMutableArray alloc]init];
        _dictVideos = [NSMutableDictionary dictionary];
        _vendorName = @"slike";
        _currentPlayerType = SlikePlayerTypeUnknown;
        
        //Fill in empty MutableArray into the dictVideos see VideoSourceType count => 6
        for(NSInteger index = 0; index < 18; index++) {
            NSMutableArray *arr = [NSMutableArray array];
            [self.dictVideos setObject:arr forKey:[self getVideoSourceTypeStringByEnum:(VideoSourceType)index]];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

/**
 Create Stream Instance
 
 @param strURL - Stream Url
 @param sourceType - Video Source Type
 @param strTitle - Stream Title
 @param strSubTitle - Stream Sub Title
 @param duration - Duration of stream
 @param arrAds - Array of ads
 @return Stream Instance
 */

+ (instancetype)createStreamURL:(NSString *) strURL withType:(VideoSourceType) sourceType withTitle:(NSString *) strTitle withSubTitle:(NSString *) strSubTitle withDuration:(NSInteger) duration withAds:(NSMutableArray *) arrAds {
    
    StreamingInfo *streamingInfo = [[StreamingInfo alloc] init];
    streamingInfo.strTitle = strTitle;
    streamingInfo.strSubtitle = strSubTitle;
    streamingInfo.nDuration = duration;
    streamingInfo.adContentsArray = arrAds;
    
    if(strURL) {
        [streamingInfo updateStreamSource:strURL withBitrates:0 withFlavor:@"" withSize:CGSizeZero withLabel:@"" ofType:sourceType];
    }
    return streamingInfo;
}

/**
 Get the Current Stream Flavour
 
 @param strCurrentURL - Current Stream
 @param sourceType - Video Source Type
 @return - Flavoured Stream
 */
- (NSString *)getCurrentStreamFlavour:(NSString *) strCurrentURL forVideoType:(VideoSourceType) sourceType {
    if(!strCurrentURL || [strCurrentURL isEqualToString:@""]) {
        return @"";
    }
    NSArray *sourceArray = [self getVideosListByType:sourceType];
    if (sourceArray.count == 1) {
        Stream * stream = sourceArray.firstObject;
        return stream.strFlavor;
    }
    
    for (Stream *stream in sourceArray) {
        if([strCurrentURL isEqualToString:stream.strURL]) {
            return stream.strFlavor;
        }
    }
    return @"";
}

/**
 Get the index of current Flavour
 
 @param strCurrentURL - Current Url String
 @param sourceType - Video Source Type
 @return - Index
 */
- (NSInteger)getFlavouredStreamIndex:(NSString *)strCurrentURL forVideoType:(VideoSourceType)sourceType {
    
    if(!strCurrentURL || [strCurrentURL isEqualToString:@""]) return -1;
    NSArray *videosTypes = [self getVideosListByType:sourceType];
    if (videosTypes.count == 1) {
        return 0;
    }
    
    for (NSInteger streamIndex =0; streamIndex<videosTypes.count; streamIndex++) {
        Stream *stream = videosTypes[streamIndex];
        if([strCurrentURL isEqualToString:stream.strURL]){
            return streamIndex;
        }
    }
    
    return -1;
}


/**
 Get the Videos List for perticuler video type
 @param videoType - Current Video Type
 @return - List of Video types
 */
- (NSMutableArray *)getVideosListByType:(VideoSourceType)videoType {
    
    NSString *strType = [self getVideoSourceTypeStringByEnum:videoType];
    
    NSMutableArray *videosArray = (NSMutableArray *) [self.dictVideos objectForKey:strType];
    NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"nBitrate" ascending:YES];
    [videosArray sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
    
    if(!videosArray) {
        videosArray = [NSMutableArray array];
        [self.dictVideos setObject:videosArray forKey:strType];
    }
    
    return videosArray;
}

/**
 Update the Current Stream
 
 @param strSource - Source URL
 @param nBitrates - Bitrate
 @param strFlavor - Flavor
 @param theSize - Size
 @param strLabel -
 @param videoType - Video Type
 */
- (void)updateStreamSource:(NSString *) strSource withBitrates:(NSInteger) nBitrates withFlavor:(NSString *) strFlavor withSize:(CGSize) theSize withLabel:(NSString *)strLabel ofType:(VideoSourceType)videoType {
    
    if(!strSource) return;
    
    NSMutableArray *videosList = [self getVideosListByType:videoType];
    
    //Looking for the URL prefix and if they are missing then need to add it
    if(videoType != VIDEO_SOURCE_YT && videoType != VIDEO_SOURCE_DM && videoType != VIDEO_SOURCE_RUMBLE &&
       [strSource rangeOfString:@"http:"].location == NSNotFound &&
       [strSource rangeOfString:@"https:"].location == NSNotFound) {
        strSource = [NSString stringWithFormat:@"https:%@", strSource];
    }
    
    //Create the stream with the bitrates
    
    Stream * stream = [Stream createStream:strSource withBitrate:nBitrates withSize:theSize withFlavor:strFlavor withLabel:strLabel withSlikeSecure:videoType == VIDEO_SOURCE_SHLS ? YES : NO];
    
    //Video is HLS or the FHLS
    if((videoType == VIDEO_SOURCE_HLS || videoType == VIDEO_SOURCE_FHLS) && videosList.count == 0) {
        stream.strLabel = @"Auto";
        //Download  contents
        [self downloadHLSContents:strSource withType:videoType];
    }
    
    BOOL isReady =  NO;
    for (Stream *localStream in videosList) {
        if([localStream.strURL isEqualToString:stream.strURL]) {
            isReady =  YES;
        }
    }
    if(!isReady) {
        [videosList addObject:stream];
    }
}


/**
 Returns the constant value for each Player Type
 @return - Constant value
 */
- (NSInteger)getConstantValueForPlayerType {
    
    if([self getCurrentVideoSource]  == VIDEO_SOURCE_YT) {
        return 7;
        
    } else if([self getCurrentVideoSource]  == VIDEO_SOURCE_DM) {
        return 13;
        
    } else if([self getCurrentVideoSource]  == VIDEO_SOURCE_FB) {
        return 17;
        
    } else if([self getCurrentVideoSource]  == VIDEO_SOURCE_GIF_MP4) {
        return 18;
        
    } else if([self getCurrentVideoSource]  == VIDEO_SOURCE_VEBLR) {
        return 15;
        
    } else if([self getCurrentVideoSource]  == VIDEO_SOURCE_MEME) {
        return 19;
    }
    else if([self getCurrentVideoSource]  == VIDEO_SOURCE_RUMBLE) {
        return 16;
    }
    else {
        return 5;
    }
    
    return 0;
}

/**
 Get the current Video Source
 @return - Video Source
 */
- (VideoSourceType)getCurrentVideoSource {
    return _currentVideoSource;
}

/**
 Current Player being used
 @return getCurrentPlayer
 */
- (VideoPlayer)getCurrentPlayer {
    
    if(_currentVideoSource == VIDEO_SOURCE_YT) {
        return VIDEO_PLAYER_YT;
        
    } else if(_currentVideoSource == VIDEO_SOURCE_DASH) {
        return VIDEO_PLAYER_DASH;
        
    } else if(_currentVideoSource == VIDEO_SOURCE_HLS) {
        return VIDEO_PLAYER_HLS;
        
    } else if(_currentVideoSource == VIDEO_SOURCE_MP4) {
        return VIDEO_PLAYER_MP4;
        
    } else if(_currentVideoSource == VIDEO_SOURCE_DRM) {
        return VIDEO_PLAYER_DRM;
        
    } else if(_currentVideoSource == AUDIO_SOURCE_MP3) {
        return AUDIO_PLAYER_MP3;
        
    } else if(_currentVideoSource == VIDEO_SOURCE_DM) {
        return VIDEO_PLAYER_DM;
        
    } else if(_currentVideoSource == VIDEO_SOURCE_VUCLIP) {
        return VIDEO_PLAYER_VUCLIP;
        
    } else if(_currentVideoSource == VIDEO_SOURCE_VEBLR) {
        return VIDEO_PLAYER_VEBLR;
        
    } else if(_currentVideoSource == VIDEO_SOURCE_RUMBLE) {
        return VIDEO_PLAYER_TYPE_RUMBLE;
        
    } else if(_currentVideoSource == VIDEO_SOURCE_FB) {
        return VIDEO_PLAYER_FB;
        
    } else if(_currentVideoSource == VIDEO_SOURCE_EMBEDDED) {
        return VIDEO_PLAYER_EMBEDDED;
        
    } else if(_currentVideoSource == VIDEO_SOURCE_3GP) {
        return VIDEO_PLAYER_3GP;
        
    } else if(_currentVideoSource == VIDEO_SOURCE_WEBM) {
        return VIDEO_PLAYER_WEBM;
        
    } else if(_currentVideoSource == VIDEO_SOURCE_MEME) {
        return VIDEO_PLAYER_MEME;
        
    } else if(_currentVideoSource == VIDEO_SOURCE_GIF_MP4) {
        return VIDEO_PLAYER_MP4;
    }
    else if(_currentVideoSource == VIDEO_SOURCE_FHLS) {
        return VIDEO_PLAYER_FHLS;
    }
    else if(_currentVideoSource == VIDEO_SOURCE_SHLS) {
        return VIDEO_PLAYER_SHLS;
    }
    return VIDEO_PLAYER_NOT_DEFINED;
}


/**
 Get the string value for video source
 
 @param videoSource - Video Source
 @return -  Video Source in String
 */
- (NSString *)getVideoSourceTypeStringByEnum:(VideoSourceType)videoSource {
    
    if(videoSource == VIDEO_SOURCE_HLS) return @"hls";
    if(videoSource == VIDEO_SOURCE_DRM) return @"drm";
    if(videoSource == VIDEO_SOURCE_MP4) return @"mp4";
    if(videoSource == VIDEO_SOURCE_YT) return @"youtube";
    if(videoSource == VIDEO_SOURCE_FB) return @"facebook";
    if(videoSource == VIDEO_SOURCE_DM) return @"dailymotion";
    if(videoSource == VIDEO_SOURCE_DASH) return @"dash";
    if(videoSource == AUDIO_SOURCE_MP3) return @"mp3";
    if(videoSource == VIDEO_SOURCE_GIF_MP4) return @"gif";
    if(videoSource == VIDEO_SOURCE_VEBLR) return @"url";
    if(videoSource == VIDEO_SOURCE_RUMBLE) return @"rumble";
    if(videoSource == VIDEO_SOURCE_MEME) return @"meme";
    if(videoSource == VIDEO_SOURCE_SHLS) return @"shls";
    if(videoSource == VIDEO_SOURCE_FHLS) return @"fhls";
    
    return @"hls";
}


/**
 Has video exists
 @return - TRUE|FALSE
 */
- (BOOL)hasAnyVideo {
    
    for(NSString *str in self.dictVideos) {
        NSMutableArray *arr = [self.dictVideos objectForKey:str];
        if([arr isKindOfClass:[NSMutableArray class]]) {
            if(arr.count > 0) return YES;
        }
    }
    return NO;
}

/**
 Has video exists
 @return - TRUE|FALSE
 */
- (BOOL) hasVideo:(VideoSourceType) sourceType {
    NSString *strType = [self getVideoSourceTypeStringByEnum:sourceType];
    NSMutableArray *arr = (NSMutableArray *) [self.dictVideos objectForKey:strType];
    return arr.count > 0;
}

/**
 Has Bitartes available
 @return - TRUE|FALSE
 */
- (BOOL) hasBitratesAvailable {
    VideoSourceType videoType = _currentVideoSource;
    NSString *strType = [self getVideoSourceTypeStringByEnum:videoType];
    NSMutableArray *arr = (NSMutableArray *) [self.dictVideos objectForKey:strType];
    return arr.count > 1;
}

/**
 Has Bitartes available for video types
 @return - TRUE|FALSE
 */
- (BOOL)hasBitratesAvailable:(VideoSourceType) videoType {
    NSString *strType = [self getVideoSourceTypeStringByEnum:videoType];
    NSMutableArray *arr = (NSMutableArray *) [self.dictVideos objectForKey:strType];
    return arr.count > 1;
}

/**
 Download HLS contents.
 */
- (void)downloadHLSContents:(NSString *)str withType:(VideoSourceType)videoType{
    
    __block typeof(self) blockSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SlikeUtilities parsem3u8:str withCompletionBlock:^(id obj, NSError *error) {
            if(obj)
            {
                NSArray *videosList = [self getVideosListByType:videoType];
                
                NSMutableArray *arr = (NSMutableArray *) obj;
                NSMutableArray *arrMain =  [NSMutableArray array];
                for( NSDictionary *dict in arr) {
                    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"BANDWIDTH CONTAINS[cd] %@",[dict objectForKey:@"BANDWIDTH"]]; // name is object key name
                    NSArray *searchResults = [arrMain filteredArrayUsingPredicate:resultPredicate];
                    if(searchResults.count == 0) {
                        [arrMain addObject:dict];
                    }
                }
                
                arr =  arrMain;
                
                NSInteger nIndex, nLen = arr.count;
                NSDictionary *dict;
                NSInteger nBitrate = 0;
                NSArray *arrRes, *arrFlavors = nil;
                NSString *strRes;
                CGSize theSize;
                NSString *strLabel = @"";
                
                if(videosList.count > 0) {
                    Stream *stream = [videosList objectAtIndex:0];
                    arrFlavors = [stream.strFlavor componentsSeparatedByString:@","];
                }
                
                if(!arrFlavors) arrFlavors = @[];
                
                for(nIndex = 0; nIndex < nLen; nIndex++) {
                    
                    theSize = CGSizeZero;
                    
                    dict = [arr objectAtIndex:nIndex];
                    
                    if([dict objectForKey:@"BANDWIDTH"]) nBitrate = [[dict objectForKey:@"BANDWIDTH"] integerValue];
                    if([dict objectForKey:@"RESOLUTION"]) {
                        
                        strRes = [dict objectForKey:@"RESOLUTION"];
                        arrRes = [strRes componentsSeparatedByString:@"x"];
                        if(arrRes.count == 2) theSize = CGSizeMake([[arrRes objectAtIndex:0] integerValue], [[arrRes objectAtIndex:1] integerValue]);
                        
                    } else {
                        nBitrate = 0;
                    }
                    
                    if([[dict objectForKey:@"ResBasedDisplay"] isEqualToString:@"YES"]) {
                        strLabel = [NSString stringWithFormat:@"%ldP", (long)(NSInteger)theSize.height];
                        
                    } else {
                        strLabel = [SlikeUtilities formattedBandWidth:nBitrate];
                    }
                    
                    [blockSelf updateStreamSource:[dict objectForKey:@"url"] withBitrates:nBitrate withFlavor:arrFlavors.count > nIndex ? [arrFlavors objectAtIndex:nIndex] : @"" withSize:theSize withLabel:strLabel ofType:videoType];
                }
            }
        }];
    });
}

/**
 Get the Enum through the String
 
 @param strName - Source String
 @return - VideoSourceType
 */
- (VideoSourceType)getVideoSourceTypeEnumByString:(NSString *) strName {
    
    if([strName isEqualToString:@"hls"]) return VIDEO_SOURCE_HLS;
    if([strName isEqualToString:@"drm" ]) return VIDEO_SOURCE_DRM;
    if([strName isEqualToString:@"mp4" ]) return VIDEO_SOURCE_MP4;
    if([strName isEqualToString:@"youtube" ]) return VIDEO_SOURCE_YT;
    if([strName isEqualToString:@"facebook" ]) return VIDEO_SOURCE_FB;
    if([strName isEqualToString:@"dailymotion" ]) return VIDEO_SOURCE_DM;
    if([strName isEqualToString:@"dash" ]) return VIDEO_SOURCE_DASH;
    if([strName isEqualToString:@"mp3" ]) return AUDIO_SOURCE_MP3;
    if([strName isEqualToString:@"gif" ]) return VIDEO_SOURCE_GIF_MP4;
    if([strName isEqualToString:@"url" ]) return VIDEO_SOURCE_VEBLR;
    if([strName isEqualToString:@"rumble" ]) return VIDEO_SOURCE_RUMBLE;
    if([strName isEqualToString:@"meme" ]) return VIDEO_SOURCE_MEME;
    if([strName isEqualToString:@"shls" ]) return VIDEO_SOURCE_SHLS;
    if([strName isEqualToString:@"fhls" ]) return VIDEO_SOURCE_FHLS;
    
    return VIDEO_SOURCE_HLS;
}


/**
 Get the Stream for the video
 
 @param videoType - Video source Type
 @param nIndex - Index
 @return - Stream
 */
- (Stream *)getStream:(VideoSourceType)videoType atIndex:(NSInteger)nIndex {
    
    NSArray *videosList = [self getVideosListByType:videoType];
    if(videosList.count == 0) return nil;
    
    Stream *stream = [videosList objectAtIndex:nIndex];
    if(stream && videoType == VIDEO_SOURCE_HLS && videosList.count <= 1) {
        [self downloadHLSContents:stream.strURL withType:videoType];
    } else  if(stream && videoType == VIDEO_SOURCE_FHLS && videosList.count <= 1) {
        [self downloadHLSContents:stream.strURL withType:videoType];
    }
    currentStream = stream;
    _currentVideoSource = videoType;
    return stream;
}


/**
 Get the Stream for the video source type
 Method will be called on the basis of user prority
 
 @param videoType - Video Source Type
 @param strBitrate - Bitrate
 @return -  Stream
 */
- (Stream *)getURL:(VideoSourceType)videoType byQuality:(NSString *) strBitrate {
    
    if([strBitrate isEqualToString:@"none"]) {
        
        NSInteger networkType = [SlikeReachability getNetworkTypeEnum];
        if(networkType == 1 || networkType == 4 || networkType == 0) {
            
            Stream *streamInfo = nil;
            NSArray *arr = [self getVideosListByType:videoType];
            if(arr.count>3) {
                streamInfo = [arr objectAtIndex:arr.count -2];
            } else {
                streamInfo = [arr lastObject];
            }
            if(streamInfo!=nil) {
                strBitrate = [NSString stringWithFormat:@"%ld",(long)streamInfo.nBitrate];;
            }
        }
    }
    Stream *stream = [self getStreamByUserAction:videoType];
    if(stream) return stream;
    SlikeDLog(@"%@",strBitrate);
    
    NSInteger nBitrate = [strBitrate integerValue];
    NSArray *videosList = [self getVideosListByType:videoType];
    NSInteger nIndex, nLen = videosList.count;
    for(nIndex = nLen - 1; nIndex >= 0; nIndex--) {
        
        stream = [videosList objectAtIndex:nIndex];
        if(nBitrate == stream.nBitrate) {
            currentStream = stream;
            _currentVideoSource = videoType;
            return stream;
        }
    }
    stream = [self getStreamByUserAction:videoType];
    return stream;
}


/**
 Get the Media Stream as per user choice
 
 @param videoType - Video Source type
 @return - Media Stream
 */
- (Stream*)getStreamByUserAction:(VideoSourceType)videoType {
    
    Stream * stream = nil;
    if(videoType == VIDEO_SOURCE_SHLS) {
        
        stream = [self getStream:VIDEO_SOURCE_SHLS atIndex:0];
        
        if(!stream) stream = [self getStream:VIDEO_SOURCE_FHLS atIndex:0];
        if(!stream) stream = [self getStream:VIDEO_SOURCE_HLS atIndex:0];
        if(!stream) stream = [self getStream:VIDEO_SOURCE_MP4 atIndex:0];
    }
    else if(videoType == VIDEO_SOURCE_FHLS) {
        stream = [self getStream:VIDEO_SOURCE_FHLS atIndex:0];
        
        if(!stream) stream = [self getStream:VIDEO_SOURCE_SHLS atIndex:0];
        if(!stream) stream = [self getStream:VIDEO_SOURCE_HLS atIndex:0];
        if(!stream) stream = [self getStream:VIDEO_SOURCE_MP4 atIndex:0];
    }
    else if(videoType == VIDEO_SOURCE_HLS) {
        stream = [self getStream:VIDEO_SOURCE_HLS atIndex:0];
        
        if(!stream) stream = [self getStream:VIDEO_SOURCE_SHLS atIndex:0];
        if(!stream) stream = [self getStream:VIDEO_SOURCE_FHLS atIndex:0];
        if(!stream) stream = [self getStream:VIDEO_SOURCE_MP4 atIndex:0];
    }
    else {
        stream = [self getStream:videoType atIndex:0];
    }
    return stream;
}
/**
 Set the Video Surce Type
 @param videoSource - Video Source type
 */
- (void)setVideoSoureceType:(VideoSourceType)videoSource {
    self.currentVideoSource = videoSource;
}

//TODO - Needs to optimize the function
- (NSString *)streamTypeForSlikeConfig:(SlikeConfig *)configModel {
    
    NSString *streamType = @"";
    if([configModel.streamingInfo getCurrentVideoSource] == VIDEO_SOURCE_YT) {
        streamType = @"youtube";
        
    } else if([configModel.streamingInfo getCurrentVideoSource] == VIDEO_SOURCE_DASH) {
        streamType = @"dash";
        
    } else if([configModel.streamingInfo getCurrentVideoSource] == VIDEO_SOURCE_HLS) {
        streamType = @"hls" ;
        
    } else if([configModel.streamingInfo getCurrentVideoSource] == VIDEO_SOURCE_MP4) {
        streamType = @"mp4";
        
    } else if([configModel.streamingInfo getCurrentVideoSource] == VIDEO_SOURCE_DRM) {
        streamType = @"drm";
        
    } else if([configModel.streamingInfo getCurrentVideoSource] == AUDIO_SOURCE_MP3) {
        streamType = @"mp3"    ;
        
    } else if([configModel.streamingInfo getCurrentVideoSource] == VIDEO_SOURCE_DM) {
        streamType = @"dailymotion"    ;
        
    } else if([configModel.streamingInfo getCurrentVideoSource] == VIDEO_SOURCE_GIF_MP4) {
        streamType = @"mp4";
        
    } else if([configModel.streamingInfo getCurrentVideoSource] == VIDEO_SOURCE_VEBLR) {
        streamType = @"url"  ;
        
    }  else if([configModel.streamingInfo getCurrentVideoSource] == VIDEO_SOURCE_RUMBLE) {
        streamType = @"rumble";
        
    } else if([configModel.streamingInfo getCurrentVideoSource] == VIDEO_SOURCE_MEME) {
        streamType = @"mime" ;
        
    } else if([configModel.streamingInfo getCurrentVideoSource] == VIDEO_SOURCE_SHLS) {
        streamType = @"shls" ;
        
    } else if([configModel.streamingInfo getCurrentVideoSource] == VIDEO_SOURCE_FHLS) {
        streamType = @"fhls" ;
    }
    
    return streamType;
}


/**
 Current Media Url
 
 @param slikeConfig - Confif Model
 @return - Media URL
 */
+ (NSString *)slikeMediaUrl:(SlikeConfig *)slikeConfig {
    
    VideoSourceType preferedType = slikeConfig.preferredVideoType;
    
    NSString *mediaURL = nil;
    //Get the Video as per  user preference
    if(preferedType == VIDEO_SOURCE_SHLS ||
       preferedType == VIDEO_SOURCE_FHLS ||
       preferedType == VIDEO_SOURCE_HLS ||
       preferedType == VIDEO_SOURCE_MP4) {
        
        mediaURL = [slikeConfig.streamingInfo getURL:preferedType byQuality:@""].strURL;
        if(mediaURL != nil && mediaURL.length > 0) {
            return mediaURL;
        }
    }
    
    //We did not find the stream URL. So need look on the Priority basis
    return [[self class] lookForStreamOnPriorityBasis:slikeConfig];
}

- (BOOL )isSlikeStreamSecure:(SlikeConfig *)slikeConfig {
    
    VideoSourceType preferedType = slikeConfig.preferredVideoType;
   Stream *stream = [slikeConfig.streamingInfo getStreamByUserAction:preferedType];
    return stream.isSecurePlayer;
}

//May be used as public method to get the stream URL 
+ (NSString *)lookForStreamOnPriorityBasis:(SlikeConfig *)slikeConfig {
    
    NSString *mediaURL = nil;
    mediaURL = [slikeConfig.streamingInfo getURL:VIDEO_SOURCE_SHLS byQuality:@""].strURL;
    if(mediaURL != nil && mediaURL.length >0) {
        return mediaURL;
    }
    
    mediaURL = [slikeConfig.streamingInfo getURL:VIDEO_SOURCE_FHLS byQuality:@""].strURL;
    if(mediaURL !=nil && mediaURL.length >0) {
        return mediaURL;
    }
    
    mediaURL = [slikeConfig.streamingInfo getURL:VIDEO_SOURCE_HLS byQuality:@""].strURL;
    if(mediaURL!=nil && mediaURL.length >0) {
        return mediaURL;
    }
    
    mediaURL = [slikeConfig.streamingInfo getURL:VIDEO_SOURCE_MP4 byQuality:@""].strURL;
    if(mediaURL!=nil && mediaURL.length >0) {
        return mediaURL;
    }
    
    mediaURL = [slikeConfig.streamingInfo getURL:AUDIO_SOURCE_MP3 byQuality:@""].strURL;
    if(mediaURL!=nil && mediaURL.length >0) {
        return mediaURL;
    }
    
    mediaURL = [slikeConfig.streamingInfo getURL:VIDEO_SOURCE_DASH byQuality:@""].strURL;
    if(mediaURL!=nil && mediaURL.length >0) {
        return mediaURL;
    }
    
    return mediaURL;
}

/**
 Start downloading the media Thumnails from the server
 */
- (void)downloadInitialMediaThumbnails  {
    
    if (self.mediaId.length <6) {
        return;
    }
    
    [self.thumbnailsInfoModel.tileImageUrls removeAllObjects];
    [self.thumbnailsInfoModel.thumbImages removeAllObjects];
    
    if (_cachedThumbnails) {
        //Need to use the cache methods for showing the thumnails
        [self downloadTileImageAndUpdateModel:[self crateTiledImageUrlString: self.thumbnailsInfoModel.currentTiledIndex]];
        
    } else {
        [self downloadAndCacheTiledImage:[self crateTiledImageUrlString: self.thumbnailsInfoModel.currentTiledIndex]];
    }
}
/**
 Update the media thumbnails
 */
- (void)updateMediaThumbnails {
    
    if (self.thumbnailsInfoModel.currentTiledIndex < self.thumbnailsInfoModel.totalTiledImages ) {
        
        if (_cachedThumbnails) {
            [self downloadTileImageAndUpdateModel:[self crateTiledImageUrlString: self.thumbnailsInfoModel.currentTiledIndex]];
        } else {
            [self downloadAndCacheTiledImage:[self crateTiledImageUrlString: self.thumbnailsInfoModel.currentTiledIndex]];
        }
    }
}
/**
 Get the thumbnails from the tiled image
 @param thumbPosition - Current position for which the thumbnails needs to downlaod
 
 */
- (void)getThimbnailFromTiledImage:(NSInteger)thumbPosition withCompletionBlock:(void (^)(UIImage *image))completion {
    
    if (_cachedThumbnails) {
        if (thumbPosition < [self.thumbnailsInfoModel.thumbImages count]) {
            completion (self.thumbnailsInfoModel.thumbImages[thumbPosition]);
        } else {
            completion(nil);
        }
        return;
    }
    
    float tiledImageIndex =  ceil(thumbPosition/(self.thumbnailsInfoModel.rows * self.thumbnailsInfoModel.columns));
    NSString *tileImageUrlString = [self crateTiledImageUrlString: tiledImageIndex];
    
    [[SlikeNetworkManager defaultManager] getImageForURL:[NSURL URLWithString:tileImageUrlString] completion:^(UIImage *image, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
        if(!error) {
            
            float rowPosition =  ceil(thumbPosition/8);
            float colPosition =   (thumbPosition % 8);
            
            NSInteger virticalOffset = rowPosition * self.thumbnailsInfoModel.thumbHight;
            NSInteger horizentialOffset = colPosition * self.thumbnailsInfoModel.thumbWidth;
            CGRect rect = CGRectMake(horizentialOffset, virticalOffset, self.thumbnailsInfoModel.thumbWidth, self.thumbnailsInfoModel.thumbHight);
            CGImageRef cImage = CGImageCreateWithImageInRect([image CGImage],  rect);
            if (cImage) {
                
                UIImage *image = [[UIImage alloc] initWithCGImage:cImage];
                completion(image);
                CGImageRelease(cImage);
                
            } else {
                completion(nil);
            }
        }
    }];
    
}

/**
 Get the tiled image from the repository memory|cache|network
 @param tileImageUrlStr - Tile image url
 */
- (void)downloadAndCacheTiledImage:(NSString *)tileImageUrlStr {
    [[SlikeNetworkManager defaultManager] getImageForURL:[NSURL URLWithString:tileImageUrlStr] completion:^(UIImage *image, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
        if(!error) {
            [self.thumbnailsInfoModel.tileImageUrls addObject:tileImageUrlStr];
            self.thumbnailsInfoModel.currentTiledIndex++;
            [self updateMediaThumbnails];
        }
    }];
}

/**
 Download and store the thumnails into respostory
 @param tileImageUrlStr - Tile image url
 */
- (void)downloadTileImageAndUpdateModel:(NSString *)tileImageUrlStr {
    
    [[SlikeNetworkManager defaultManager] getImageForURL:[NSURL URLWithString:tileImageUrlStr] completion:^(UIImage *image, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
        
        //dispatch_async(dispatch_get_main_queue(), ^{
            
            if(!error) {
                
                NSMutableArray *previewsImage = [[NSMutableArray alloc]init];
                CGFloat width = self.thumbnailsInfoModel.thumbWidth;
                CGFloat height = self.thumbnailsInfoModel.thumbHight;
                
                CGFloat xPos = 0.0, yPos = 0.0;
                for (int yIndex = 0; yIndex < self.thumbnailsInfoModel.rows ; yIndex++) {
                    xPos = 0.0;
                    
                    for (int xIndex = 0; xIndex < self.thumbnailsInfoModel.columns; xIndex++) {
                        CGRect rect = CGRectMake(xPos, yPos, width, height);
                        CGImageRef cImage = CGImageCreateWithImageInRect([image CGImage],  rect);
                        if (cImage) {
                            CGFloat compressionQuality = 0.6;
                            UIImage *dImage = [[UIImage alloc] initWithCGImage:cImage];
                            NSData *imageData = UIImageJPEGRepresentation(dImage,compressionQuality);
                            if (imageData) {
                                UIImage *compressedImage = [UIImage imageWithData:imageData];
                                if (compressedImage) {
                                    [previewsImage addObject:compressedImage];
                                }
                            }
                            
                            CGImageRelease(cImage);
                        }
                        xPos += width;
                    }
                    yPos += height;
                }
                //Add all the thumb images into model
                [self.thumbnailsInfoModel.thumbImages addObjectsFromArray:previewsImage];
                self.thumbnailsInfoModel.currentTiledIndex++;
                [self updateMediaThumbnails];
            } else {
                
                if ([self.thumbnailsInfoModel.thumbImages count] ==0) {
                    self.downloadingInProcess = NO;
                }
            }
       // });
    }];
}

/**
 Create the Url for the tiled imaage
 @param tiledIndex - Index for which Url needs to create
 @return - tiled image url
 */
- (NSString *)crateTiledImageUrlString:(NSInteger)tiledIndex {
    
    NSRange range = NSMakeRange(2,2);
    NSString * middlePath = [self.mediaId substringWithRange:range];
    NSRange rangeNext = NSMakeRange(4,2);
    NSString * lastPath = [self.mediaId substringWithRange:rangeNext];
    
    NSString *tiledImageUrl = [[SlikeSharedDataCache sharedCacheManager]tileImageBaseUrl];
    
    return  [NSString stringWithFormat:@"%@%@/%@/%@/sprite/imagestile-%ld.jpg", tiledImageUrl, middlePath, lastPath,self.mediaId, (long)tiledIndex];
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    if ([self.thumbnailsInfoModel.thumbImages count]>0) {
        [self.thumbnailsInfoModel.thumbImages removeAllObjects];
        [[SlikeNetworkManager imageCache]removeAllObjects];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
