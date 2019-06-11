//
//  SlikeNetworkMonitor.h
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 21/05/18.
//

#import <Foundation/Foundation.h>

@interface SlikeNetworkMonitor : NSObject

+ (instancetype)sharedSlikeNetworkMonitor;
- (BOOL)isNetworkReachible;

@end
