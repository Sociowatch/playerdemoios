//
//  SlikeNetworkInterface.h
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 29/05/18.
//

#import <Foundation/Foundation.h>

@interface SlikeNetworkInterface : NSObject

+ (instancetype)sharedNetworkInteface;

- (void)performGetServiceRequest:(NSURL *)requestURL withCompletionBlock:(SlikeNetworkManagerCompletionBlock)completionBlock;

- (void)fetchPlaylistServiceRequest:(NSURL *)requestURL withCompletionBlock:(SlikeNetworkManagerCompletionBlock)completionBlock;

- (void)getHLSStreamDataString:(NSString *)strURL withCompletionBlock:(SlikePlaylistCompletionBlock) completionBlock;

@end
