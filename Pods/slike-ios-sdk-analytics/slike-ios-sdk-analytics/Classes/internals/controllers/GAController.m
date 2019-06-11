//
//  GAController.m
//  Pods
//
//  Created by Aravind kumar on 9/27/17.
//
//

#import "GAController.h"
#import "SlikeGlobals.h"
#import "SlikeCoreShared.h"

@interface GAController ()
{
    id<GAITracker> trackerApp;
    id<GAITracker> trackerSlike;

}

@property(nonatomic,strong) NSString *gaTrackId;

@end

@implementation GAController
{

}


#pragma mark GA protocals-

-(void) setId:(NSString*)strId subId:(NSString*)strSubId Type:(AnalyticMode)type
{
if(type == AnalyticMode_GA)
{
    
self.gaTrackId = strId;
[self startGASession];
    
}
}
-(void) initializeData
    {
    }
-(id) init:(NSString*)strId subId:(NSString*)strSubId Type:(AnalyticMode)type
    {
        if (self = [super init])
        {
            [self setId:strId subId:strSubId Type:type];
        }
        return self;
        
    }
-(id) init:(id) tracker
    {
        if (self = [super init])
        {
            [self addAnalytics:tracker];

        }
        return self;
    }
-(AnalyticMode) getType
    {
        return AnalyticMode_GA;
    }
-(NSString*) getId
    {
        return self.gaTrackId;
    }
-(void)addAnalytics:(id)tracker
{
    trackerApp = tracker;
    
}
-(void)startGASession
{
    // Override point for customization after application launch.
        //GA
    
        // Optional: automatically send uncaught exceptions to Google Analytics.
        [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    
       // [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set Logger to VERBOSE for debug information.
    if(ENABLE_LOG)
    {
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    }else
    {
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
    }
    
 trackerSlike =   [[GAI sharedInstance] trackerWithTrackingId:self.gaTrackId];
    
    // Assumes a tracker has already been initialized with a property ID, otherwise
    // getDefaultTracker returns nil.
    // Enable IDFA collection.
    trackerSlike.allowIDFACollection = YES;
}

-(UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

-(void)sendEvent:(NSString*)category Action:(NSString*)action Label:(NSString*)label Value:(NSNumber*)value
    {
    
    if(action == nil || [action isEqualToString:@""])
    {
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        NSString *strClass = NSStringFromClass([vc class]);
        action =  strClass;;
        
    }
    
    if(trackerSlike)
    {
        [trackerSlike send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                                   action:action
                                                                    label:label
                                                                    value:nil] build]];
    }
    if(trackerApp)
    {
        [trackerApp send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                                   action:action
                                                                    label:label
                                                                    value:nil] build]];
}
}
-(void)addComScoreMetaDataAd:(SlikeConfig*)config adLength:(NSInteger)ad_length  adType:(NSInteger)adtype  PlayerStatus:(SlikePlayerState) state;
{
    //ComScore
}
-(void)addComScoreMetaDataVideo:(SlikeConfig*)config PlayerStatus:(SlikePlayerState) state
{
    //ComScore

}
@end
