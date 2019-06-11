//
//  SlikeAdPlateformEvents.h
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 23/06/18.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class SlikeAdsUnit;
/**
 *  Different event types sent by the IMAAdsManager to its delegate.
 */
typedef NS_ENUM(NSInteger, SlikeAdEventType){
    
    kSlikeAdEventContentLoaded = 0x0,
    kSlikeAdEventTimeout,
    kSlikeAdEventLoaded,
    kSlikeAdEventReady,
    kSlikeAdEventStarted,
    kSlikeAdEventProgress,
    kSlikeAdEventCompleted,
    kSlikeAdEventCliked,
    kSlikeAdEventQ1,
    kSlikeAdEventMid,
    kSlikeAdEventQ3,
    kSlikeAdEventPause,
    kSlikeAdEventResume,
    kSlikeAdEventSkipped,
    kSlikeAdEventPauseContent,
    kSlikeAdEventResumeContent,
    kSlikeAdEventLoadingError,
    kSlikeAdEventPlayingError,
    kSlikeAdEventError,
    kSlikeAdEventUpdateData,
    kSlikeAdEventNone
};

@protocol SlikeAdPlateformEvents<NSObject>
- (void)slikeAdEventDidReceiveAdEvent:(SlikeAdEventType)adEvent withPayload:(NSDictionary *)payload;
@end


