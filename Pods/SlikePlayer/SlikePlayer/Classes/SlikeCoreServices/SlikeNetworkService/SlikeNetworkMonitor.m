//
//  SlikeNetworkMonitor.m
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 21/05/18.
//

#import "SlikeNetworkMonitor.h"

@interface SlikeNetworkMonitor() {
    
}
@property (strong, nonatomic) SlikeReachability *reachability;
@end

@implementation SlikeNetworkMonitor

- (id)init {
    if (self = [super init]) {
        self.reachability = [SlikeReachability reachabilityForInternetConnection];
        [_reachability startNotifier];
    }
    return self;
}


/**
 Creats the shared instance of DataProvider
 @return - Singleton class  instance
 */
+ (instancetype)sharedSlikeNetworkMonitor {
    
    static SlikeNetworkMonitor *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        
    });
    return sharedInstance;
}

- (BOOL)isNetworkReachible {
    
    if ([[SlikeReachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        return NO;
    }
    return  YES;
//    [[SlikeReachability reachabilityForInternetConnection] currentReachabilityStatus]
//
//    if ([_reachability currentReachabilityStatus]  == NotReachable) {
//        return NO;
//    }
//    return  YES;
}

@end
