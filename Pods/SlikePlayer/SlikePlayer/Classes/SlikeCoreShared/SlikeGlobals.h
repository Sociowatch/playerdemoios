
/**
 Tells about the event generator module
 - MEDIA: Sorce is Player
 - AD: - Source Is Ad manager
 - CONTROLS: Source s UI Control
 - ANALYTICS: Source is Analytics
 */

typedef NS_ENUM(NSInteger, SlikeEventType) {
    MEDIA,
    AD,
    CONTROLS,
    ANALYTICS,
    ACTIVITY,
    GESTURE
};


typedef NS_ENUM (NSInteger, SlikeAdPriority) {
    ON,
    OFF
};


/**
 Ads Type -
 - SL_PRE: Will start at the begining of Stream
 - SL_MID: Will be start between the stream (Can be more then 1)
 - SL_POST: Will start after completion of Stream
 */

typedef NS_ENUM(NSInteger, SlikeAdType) {
    SL_NONE,
    SL_PRE,
    SL_POST,
    SL_MID
};

/*
 * Palyer States
 */

typedef NS_ENUM(NSInteger, SlikePlayerState ) {
    SL_READY,
    SL_LOADED,
    SL_VIDEO_REQUEST,
    SL_START,
    SL_PLAYING,
    SL_PAUSE,
    SL_BUFFERING,
    SL_SEEKING,
    SL_SEEKED,
    SL_ENDED,
    SL_COMPLETED,
    SL_VIDEO_COMPLETED,
    SL_FSENTER,
    SL_FSEXIT,
    SL_REPLAY,
    SL_PLAY,
    SL_ERROR,
    SL_QUALITYCHANGE,
    SL_SHARE,
    SL_CLOSE,
    SL_PREVIOUS,
    SL_NEXT,
    SL_LOADING,
    SL_HIDE_LOADING,
    SL_CLICKED,
    SL_SKIPPED,
    SL_Q0,
    SL_Q1,
    SL_Q2,
    SL_Q3,
    SL_VIDEOPLAYED,
    SL_PLAYEDPERCENTAGE,
    SL_TIMELOADRANGE,
    SL_QUALITYCHANGECLICKED,
    SL_FULLSCREENCLICKED,
    SL_HIDECONTROLS,
    SL_SHOWCONTROLS,
    SL_RESETCONTROLS,
    SL_STATE_NONE,
    SL_CONTENT_RESUME,
    SL_CONTENT_PAUSE,
    SL_PLAYER_DISTROYED,
    SL_AD_REQUESTED,
    SL_QUALITYCHANGED,
    SL_SEEKPOSTIONUPDATE,
    SL_SET_NEXT_PLAYLIST_DATA,
    SL_HIDE_NEXT_PLAYLIST_DATA,
    SL_MEDIA_PREVIEWS,//Will be Used show the Previews with the Pan Gesture
    SL_LIVE_STATES,
    SL_PLACEHODER_UPDATE,//AUdio Playlist Enums
    SL_MEDIA_UPDATE,
    SL_REWIND,
    SL_SEEKED_NEXT,
    SL_SEEKED_PREVIOUS,
    SL_LIST_VIEW,
    SL_MUSIC_SMALL,
    SL_MUSIC_FULL,
    SL_MUSICLIST_UPDATE,
    SL_MUSICLIST_STOP,
    SL_MUSIC_ITEM,
    SL_OFFLINE_CLICK
    
    
};

typedef NS_ENUM(NSInteger, SlikeFullscreenAutoRotationMode ) {
    SlikeFullscreenAutorotationModeDefault,
    SlikeFullscreenAutorotationModeLandscape,
};

/*
  Keys to access the data
 */
OBJC_EXTERN NSString * const kSlikeAdStatusInfoKey ;
OBJC_EXTERN NSString * const kSlikeCustomBitrateInfoKey;
OBJC_EXTERN NSString * const kSlikeConfigModelKey;
OBJC_EXTERN NSString * const kSlikeSeekProgressKey;
OBJC_EXTERN NSString * const kSlikeBufferPositionKey;
OBJC_EXTERN NSString * const kSlikeDurationKey;
OBJC_EXTERN NSString * const kSlikeCurrentPositionKey;
OBJC_EXTERN NSString * const kSlikeBufferingEndedKey;

//SL_MEDIA_PREVIEWS


/*
 * Pass the value "YES" if play|pause is done by the User Otherwise pass "NO"
 ie: Opening the some axternal activity like share, pass the NO so that player
 can decide its state after completion of activitys
 
 NOTE:  Does not passing this value means play|Pause is Auto
 */
OBJC_EXTERN NSString * const kSlikePlayPauseByUserKey;

//Media Previews. It is associated with Event Type GESTURE and State SL_MEDIA_PREVIEWS
OBJC_EXTERN NSString * const kSlikePreviewStartedKey ;
OBJC_EXTERN NSString * const kSlikePreviewProgressKey;
OBJC_EXTERN NSString * const kSlikePreviewStopKey;
