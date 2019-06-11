//
//  EventModel.h
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 29/05/18.
//

#import <Foundation/Foundation.h>

OBJC_EXTERN NSString * const kSlikeEventModelKey;

@class SlikeConfig;
@class SlikeAdEvent;
@class SlikePlayerEvent;

typedef NS_ENUM(NSUInteger, SlikeUserBehaviorEvent) {
    
    SlikeUserBehaviorEventBirate = 0x0,
    SlikeUserBehaviorEventShare,
    SlikeUserBehaviorEventAirPlay,
    SlikeUserBehaviorEventCast,
    SlikeUserBehaviorEventClose,
    SlikeUserBehaviorEventPlay,
    SlikeUserBehaviorEventPause,
    SlikeUserBehaviorEventFullScreen,
    SlikeUserBehaviorEventSeek,
    SlikeUserBehaviorEventReplay,
    SlikeUserBehaviorEventNone
};

typedef NS_ENUM(NSUInteger, SlikeAnalyticsType) {
    SlikeAnalyticsTypeMedia = 0x0,
    SlikeAnalyticsTypeAVPlayerAd,
    SlikeAnalyticsTypeControl,
    SlikeAnalyticsTypeGif,
    SlikeAnalyticsTypeEmbed,
    SlikeAnalyticsTypeMeme,
    SlikeAnalyticsTypeInternal,
    SlikeAnalyticsTypeRumble,
    SlikeAnalyticsTypeRumbleAd,
};

@interface EventModel : NSObject

@property (strong, nonatomic)NSDictionary* payload;
@property (assign, nonatomic) BOOL isImmediateDispatch;
@property (nonatomic, weak) SlikeConfig *slikeConfigModel;
@property (nonatomic, strong) SlikeAdEvent *adEventModel;
@property (nonatomic, strong) SlikePlayerEvent *playerEventModel;

@property (assign, nonatomic, readonly) SlikeUserBehaviorEvent userBehaviorEvent;
@property (assign, nonatomic, readonly) SlikeAnalyticsType analyticsType;

+ (instancetype)createEventModel:(SlikeAnalyticsType)analyticsType withBehaviorEvent: (SlikeUserBehaviorEvent)behaviorEvent withPayload:(NSDictionary *)payloadDict;

@end
