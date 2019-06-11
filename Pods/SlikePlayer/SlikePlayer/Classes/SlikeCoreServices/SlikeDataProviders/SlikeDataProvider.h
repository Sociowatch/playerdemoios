//
//  SlikeDataProvider.h
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 21/05/18.
//

#import <Foundation/Foundation.h>

typedef void (^SlikeDataProviderCompletionBlock)(id responseObject, NSError* errExists);

@interface SlikeDataProvider : NSObject

/**
 Creats the class instance of DataProvider
 @return - Class instance
 */
+ (instancetype)slikeDataProvider;


/**
 Creats the shared instance of DataProvider
 @return - Singleton class  instance
 */
+ (instancetype)sharedSlikeDataProvider;


/**
 Download the  configuration  data from the server. SlikeConfig already contains some data for the player
 so here we need to update the the config file
 
 @param configURL  - Config Url
 @param slikeConfigModel - Model that needs to update
 @param completionHandler - Completion Handler Block
 */
- (void)downloadSlikeConfigData:(NSString *)configURL  withConfig:(SlikeConfig *)slikeConfigModel resultBlock:(SlikeDataProviderCompletionBlock)completionHandler;

/**
 Download the Stream  data for perticular slike id from the server.
 
 @param streamURL  - Stream URL
 @param slikeConfigModel - Model that needs to update
 @param configDataDict -  Config Data . downloaded from Config URL
 @param completionHandler - Completion Handler Block
 */

- (void)downloadSlikeStreamData:(NSString *)streamURL playerConfig:(SlikeConfig *)slikeConfigModel configInfoData:(NSDictionary *)configDataDict resultBlock:(SlikeDataProviderCompletionBlock) completionHandler;


/**
 Download the config file and cache
 @param configURL - Config url
 @param completionHandler - Completion Handler Block
 */
- (void)downloadAndCacheConfigData:(NSString *)configURL resultBlock:(SlikeDataProviderCompletionBlock)completionHandler;


/**
 Download and Cache the Stream Data
 @param streamURL - Stream URL
 @param completionHandler - Completion Block 
 */
- (void)downloadAndCacheStreamData:(NSString *)streamURL forMediaId:(NSString *)mediaId resultBlock:(SlikeDataProviderCompletionBlock) completionHandler;

/**
 Prepare the slike config model from the cache. If we have downloaded stream data and config data .
 @param slikeConfigModel - Partial Config model that needs to update
 @param completionHandler - Completion handler
 */
- (void)prepareSlikeConfigFromCache:(SlikeConfig *)slikeConfigModel resultBlock:(SlikeDataProviderCompletionBlock) completionHandler;
@end
