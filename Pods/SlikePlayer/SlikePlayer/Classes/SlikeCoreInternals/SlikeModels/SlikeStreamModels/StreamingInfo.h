//
//  StreamingInfo.h
//
//

#import <Foundation/Foundation.h>
#import "Stream.h"
#import "SlikePlayerType.h"
#import "SlikeMediaPreview.h"

@class SlikeAdsQueue;
@class SlikeConfig;

static NSTimeInterval const  SLKMediaPlayerDefaultLiveTolerance = 30.;

typedef NS_ENUM(NSInteger, SLKMediaPlayerStreamType) {
    SLKMediaPlayerStreamTypeOthers = 0,
    SLKMediaPlayerStreamTypeLive,
    SLKMediaPlayerStreamTypeDVR
};

@interface StreamingInfo : NSObject

@property (nonatomic, assign)BOOL preRollEnabled;
@property (nonatomic, assign)BOOL midRollEnabled;
@property(nonatomic,strong) NSArray *midroll_arr;
@property (nonatomic, assign)BOOL postRollEnabled;
@property (nonatomic, strong)Stream *currentStream;

@property(nonatomic, strong) NSMutableArray<SlikeAdsQueue*> *adContentsArray;
@property (nonatomic, assign)SlikePlayerType currentPlayerType;

@property(nonatomic, strong) NSString *strTitle;
@property(nonatomic, strong) NSString *strID;
@property(nonatomic, strong) NSString *strImageURL;
@property(nonatomic, strong) NSString *strThumbe_160;
@property(nonatomic, assign) NSInteger nDuration;
@property(nonatomic, assign) NSInteger nStartTime;
@property(nonatomic, assign) NSInteger nEndTime;
@property(nonatomic, assign) BOOL isLive;
@property(nonatomic, strong) NSString *vendorName;
@property(nonatomic, strong) NSString *strChannel;
@property(nonatomic, strong) NSString *strMeta;
@property(nonatomic, strong) NSString *strSubtitle;
@property(nonatomic, assign) NSInteger nCurrentBitrate;
@property(nonatomic, strong) NSString *strSS;
@property(nonatomic, strong) NSString *strTS;
@property(nonatomic, strong) NSString *mediaId;
@property(nonatomic, assign) BOOL isAudio;
@property(nonatomic, strong) SlikeMediaPreview *thumbnailsInfoModel;
@property(nonatomic, assign) BOOL downloadingInProcess;
@property(nonatomic, assign) BOOL cachedThumbnails;
@property(nonatomic,assign) BOOL isExternalPlayer;
@property(nonatomic, strong) NSString *evtUrl ;

@property(nonatomic, assign) BOOL intl;
@property(nonatomic, strong) NSString *hurl;
@property(nonatomic, assign) SLKMediaPlayerStreamType mediaStreamType;
@property(nonatomic, assign) BOOL containsDVR;
@property(nonatomic, strong) NSString *dvrURLString;
@property(nonatomic, assign) BOOL outSideAd;

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
+ (instancetype)createStreamURL:(NSString *)strURL withType:(VideoSourceType)sourceType withTitle:(NSString *)strTitle withSubTitle:(NSString *)strSubTitle withDuration:(NSInteger)duration withAds:(NSMutableArray *)arrAds;


/**
 Get the Current Stream Flavour
 
 @param strCurrentURL - Current Stream
 @param sourceType - Video Source Type
 @return - Flavoured Stream
 */
- (NSString *)getCurrentStreamFlavour:(NSString *)strCurrentURL forVideoType:(VideoSourceType)sourceType;


/**
 Get the index of current Flavour
 
 @param strCurrentURL - Current Url String
 @param sourceType - Video Source Type
 @return - Index
 */
- (NSInteger)getFlavouredStreamIndex:(NSString *)strCurrentURL forVideoType:(VideoSourceType)sourceType;


/**
 Get the Videos List for perticuler video type
 @param videoType - Current Video Type
 @return - List of Video types
 */
- (NSMutableArray *)getVideosListByType:(VideoSourceType)videoType;


/**
 Update the Current Stream
 
 @param aSourceURL - Source URL
 @param aBitrates - Bitrate
 @param aFlavor - Flavor
 @param aSize - Size
 @param aLabel -
 @param aVideoType - Video Type
 */
- (void)updateStreamSource:(NSString *)aSourceURL withBitrates:(NSInteger)aBitrates withFlavor:(NSString *)aFlavor withSize:(CGSize)aSize withLabel:(NSString *)aLabel ofType:(VideoSourceType)aVideoType withDVR:(NSString *)dvrURL;

/**
 Returns the constant value for each Player Type
 @return - Constant value
 */
- (NSInteger)getConstantValueForPlayerType;

/**
 Get the Current Video Source
 @return - Video Source
 */
- (VideoSourceType)getCurrentVideoSource;

/**
 Get the current player being used
 @return - Current Player
 */
- (VideoPlayer)getCurrentPlayer;

/**
 Get the string value for video source
 
 @param videoSource - Video Source
 @return -  Video Source in String
 */
- (NSString *)getVideoSourceTypeStringByEnum:(VideoSourceType)videoSource;


/**
 Get the Enum through the String
 
 @param sourceString - Source String
 @return - VideoSourceType
 */
- (VideoSourceType)getVideoSourceTypeEnumByString:(NSString *)sourceString;

/**
 Get the Stream for the video source type
 
 @param videoType - Video Source Type
 @param strBitrate - Bitrate
 @return -  Stream
 */
- (Stream *) getURL:(VideoSourceType) videoType byQuality:(NSString *) strBitrate;

/**
 Set the Video Surce Type
 @param videoSource - Video Source type
 */
- (void)setVideoSoureceType:(VideoSourceType)videoSource;

/**
 Has video exists
 @return - TRUE|FALSE
 */
- (BOOL)hasAnyVideo;

/**
 Is there any media source type exists for the source type
 @param sourceType -
 @return - TRUE|FALSE
 */
- (BOOL)hasVideo:(VideoSourceType) sourceType;

/**
 Has Bitrates available for the selected media stream
 @return TRUE|FALSE
 */
- (BOOL)hasBitratesAvailable;

/**
 Has Bitrates available for the selected media stream
 @param videoType - Current media Type
 @return - TRUE|FALSE
 */
- (BOOL)hasBitratesAvailable:(VideoSourceType)videoType;

/**
 Get the Media Url
 @param slikeConfig - Slike COnfig Model
 @return - Media Url
 */
+ (NSString *)slikeMediaUrl:(SlikeConfig *)slikeConfig;

/**
 Get the stream type for selected media
 @param configModel - Config model
 @return - Stream Type
 */
- (NSString *)streamTypeForSlikeConfig:(SlikeConfig *)configModel;

/**
 Update the Media Thumbnails information
 */
- (void)downloadInitialMediaThumbnails;

- (void)getThimbnailFromTiledImage:(NSInteger)currentPosition withCompletionBlock:(void (^)(UIImage *image))completion;

- (BOOL )isSlikeStreamSecure:(SlikeConfig *)slikeConfig;

- (NSString *)dvrMediaStream:(VideoSourceType)aPreferedType;

/**
 *  Return the tolerance (in seconds) for a DVR stream to be considered being played in live conditions. If the stream
 *  playhead is located within the last `liveTolerance` seconds of the stream, it is considered to be live. The default
 *  value is 30 seconds and matches the standard iOS player controller behavior.
 */
@property (nonatomic) NSTimeInterval liveTolerance;

@end
