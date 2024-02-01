//
//  SlikeDataProvider.h
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 21/05/18.
//

#import <Foundation/Foundation.h>

typedef void (^SlikeDataProviderCompletionBlock)(id _Nullable responseObject, NSError* _Nullable errExists);

@interface SlikeDataProvider : NSObject

/**
 Creats the class instance of DataProvider
 @return - Class instance
 */
+ (instancetype _Nullable)slikeDataProvider;


/**
 Creats the shared instance of DataProvider
 @return - Singleton class  instance
 */
+ (instancetype _Nullable )sharedSlikeDataProvider;


/**
 Download the  configuration  data from the server. SlikeConfig already contains some data for the player
 so here we need to update the the config file
 
 @param configURL  - Config Url
 @param slikeConfigModel - Model that needs to update
 @param completionHandler - Completion Handler Block
 */
- (void)downloadSlikeConfigData:(NSString *_Nullable)configURL  withConfig:(SlikeConfig *_Nonnull)slikeConfigModel resultBlock:(SlikeDataProviderCompletionBlock _Nullable)completionHandler;

/**
 Download the Stream  data for perticular slike id from the server.
 
 @param streamURL  - Stream URL
 @param slikeConfigModel - Model that needs to update
 @param configDataDict -  Config Data . downloaded from Config URL
 @param completionHandler - Completion Handler Block
 */

- (void)downloadSlikeStreamData:(NSString *_Nonnull)streamURL playerConfig:(SlikeConfig *_Nonnull)slikeConfigModel configInfoData:(NSDictionary *_Nonnull)configDataDict resultBlock:(SlikeDataProviderCompletionBlock _Nullable ) completionHandler;


/**
 Download the config file and cache
 @param configURL - Config url
 @param completionHandler - Completion Handler Block
 */
- (void)downloadAndCacheConfigData:(NSString *_Nonnull)configURL resultBlock:(SlikeDataProviderCompletionBlock _Nullable )completionHandler;


/**
 Download and Cache the Stream Data
 @param streamURL - Stream URL
 @param completionHandler - Completion Block 
 */
- (void)downloadAndCacheStreamData:(NSString *_Nonnull)streamURL forMediaId:(NSString *_Nonnull)mediaId resultBlock:(SlikeDataProviderCompletionBlock _Nullable ) completionHandler;

/**
 Prepare the slike config model from the cache. If we have downloaded stream data and config data .
 @param slikeConfigModel - Partial Config model that needs to update
 @param completionHandler - Completion handler
 */
- (void)prepareSlikeConfigFromCache:(SlikeConfig *_Nonnull)slikeConfigModel resultBlock:(SlikeDataProviderCompletionBlock _Nullable ) completionHandler;

#pragma mark - Audo Playlist
- (void)downloadAudioPlaylist:(NSString *_Nonnull)slikeIds resultBlock:(SlikeDataProviderCompletionBlock _Nullable )completionHandler;

- (void)createAudioConfigModel:(NSData *_Nullable)configData mediaId:(NSString * _Nonnull)mediaId slikeConfig:(SlikeConfig *_Nullable)slikeConfig streamData:(NSData *_Nullable)streamData status:(void(^_Nullable)(BOOL status))result;

@end
