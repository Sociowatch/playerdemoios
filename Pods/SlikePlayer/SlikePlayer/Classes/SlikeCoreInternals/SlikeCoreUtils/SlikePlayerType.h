//
//  SlikePlayerType.h
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 28/05/18.
//

#ifndef SlikePlayerType_h
#define SlikePlayerType_h

#import <Foundation/Foundation.h>

typedef enum VideoPlayerType {
    VIDEO_PLAYER_YT = 0,
    VIDEO_PLAYER_DASH = 1,
    VIDEO_PLAYER_HLS = 2,
    VIDEO_PLAYER_MP4 = 3,
    VIDEO_PLAYER_DRM = 4,
    AUDIO_PLAYER_MP3 = 5,
    VIDEO_PLAYER_DM = 6,
    VIDEO_PLAYER_VUCLIP = 7,
    VIDEO_PLAYER_VEBLR = 8,
    VIDEO_PLAYER_TYPE_RUMBLE = 9,
    VIDEO_PLAYER_FB = 10,
    VIDEO_PLAYER_EMBEDDED=11,
    VIDEO_PLAYER_3GP = 12,
    VIDEO_PLAYER_WEBM = 13,
    VIDEO_PLAYER_MEME = 14,
    VIDEO_PLAYER_NOT_DEFINED =-1
    
} VideoPlayer;

typedef NS_ENUM(NSInteger, SlikePlayerType) {
    SlikePlayerTypeYoutube = 0x0,
    SlikePlayerTypeHls,
    SlikePlayerTypeMp4,
    SlikePlayerTypeGif,
    SlikePlayerTypeDailyMotion,
    SlikePlayerTypeFacebook,
    SlikePlayerTypeMeme,
    SlikePlayerTypeViuClip,
    SlikePlayerTypeEmbeded,
    SlikePlayerTypeUnknown
};

typedef NS_ENUM(NSInteger, VideoSourceType) {
    
    VIDEO_SOURCE_YT,
    VIDEO_SOURCE_DASH,
    VIDEO_SOURCE_HLS,
    VIDEO_SOURCE_MP4,
    VIDEO_SOURCE_DRM,
    AUDIO_SOURCE_MP3,
    VIDEO_SOURCE_GIF_MP4,
    VIDEO_SOURCE_DM,
    VIDEO_SOURCE_FB,
    VIDEO_SOURCE_VEBLR,
    VIDEO_SOURCE_MEME,
    VIDEO_SOURCE_VUCLIP,
    VIDEO_SOURCE_RUMBLE,
    VIDEO_SOURCE_EMBEDDED,
    VIDEO_SOURCE_3GP,
    VIDEO_SOURCE_WEBM,
    VIDEO_SOURCE_UNKNOWN
    
} ;

#endif /* SlikePlayerType_h */
