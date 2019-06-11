//
//  EventModel.m
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 29/05/18.
//

#import "EventModel.h"
#import "SlikeAdEvent.h"
#import "SlikePlayerEvent.h"

NSString * const kSlikeEventModelKey    = @"EventModelKey";

@interface EventModel () {

}

@property (assign, nonatomic) SlikeUserBehaviorEvent userBehaviorEvent;
@property (assign, nonatomic) SlikeAnalyticsType analyticsType;
@end

@implementation EventModel

- (instancetype)init {
    self = [super init];
    
    _userBehaviorEvent = SlikeUserBehaviorEventNone;
    _adEventModel = [[SlikeAdEvent alloc]init];
    _playerEventModel = [[SlikePlayerEvent alloc]init];
    return self;
}

- (instancetype)initWithEventModel:(SlikeAnalyticsType)analyticsType withBehaviorEvent: (SlikeUserBehaviorEvent)behaviorEvent withPayload:(NSDictionary *)payloadDict {
    
    self = [self init];
    if (self) {
        _userBehaviorEvent = behaviorEvent;
        _analyticsType = analyticsType;
        self.payload = [[NSDictionary alloc]initWithDictionary:payloadDict];
    }
    return self;
}

+ (instancetype)createEventModel:(SlikeAnalyticsType) analyticsType withBehaviorEvent: (SlikeUserBehaviorEvent)behaviorEvent withPayload:(NSDictionary *)payloadDict  {
    
    EventModel *eventModel = [[EventModel alloc] initWithEventModel:analyticsType withBehaviorEvent:behaviorEvent withPayload:payloadDict];
    return eventModel;
}


@end
