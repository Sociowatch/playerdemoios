//
//  SlikeNetworkManager
//
//
//  Created by Pravin Ranjan on 20/12/2016.
//  Copyright (c) 2016 tapwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <sys/xattr.h>
#import "SlikeNetworkRequest.h"
#import "StreamingInfo.h"
#import "SlikeConfig.h"
#import "ISlikePlayer.h"
#import "SlikeAnalyticInformation.h"

typedef void (^SlikeNetworkManagerCompletionBlock)(id obj, NSError *error);
typedef BOOL (^SlikePlaylistCompletionBlock)(NSArray *responseArray, NSString *responseString, NSError *error);



@protocol BoxNetworkEngineDelegate <NSObject>
-(void) handleInvalidToken;
-(void) handleInvalidAPIKey;
@end

@interface SlikeNetworkManager : NSObject {
    
}
/// The default network manager's singleton instance
/// NetworkManager can be used also as non singleton with [[NetworkManager alloc] init]
+ (instancetype)defaultManager;

/// The default image cache with NSURL & UImage (key, value) pair
+ (NSCache *)imageCache;

/// Simple async download with disk caching -
/// there will be no download if we are offline or
/// the data on server side hasn't been modified (HTTP 304)
/// Image download - uses disk and memory caching - returns the image immediately if the image is in cache
- (UIImage *)getImageForURL:(NSURL *)url
             completion:(void(^)(UIImage *image,
                                 NSString *localFilepath,
                                 BOOL isFromCache,
                                 NSInteger statusCode,
                                 NSError *error))completion;

/// Request from URL with specific HTTP method - does not use caching
- (void)requestURL:(NSURL*)url
              type:(NetworkHTTPMethod)HTTPMethod
        completion:(void(^)(NSData *data,
                            NSString *localFilepath,
                            BOOL isFromCache,
                            NSInteger statusCode,
                            NSError *error))completion;

/// Request with NSURLRequest - does not use caching
- (void)request:(NSURLRequest*)request
     completion:(void(^)(NSData *data,
                         NSError *error))completion;

/// Check current process for an URL
/// @param url The URL to check if it is processing
/// @return YES if URL is currently requested or in download progress
- (BOOL)isProcessingURL:(NSURL *)url;

/// Checks if we already have a cached file on disk for the URL
/// @param url The URL to check if there is a local representation
/// @return YES If there is local representation
- (BOOL)hasCachedFileForURL:(NSURL *)url;

/// Gives a local representation for the real URL
/// @param url The URL for the local representation
/// @return A cached filepath for the full URL - nil if nothing is cached
- (NSString *)cachedFilePathForURL:(NSURL *)url;

/// Cancels all outstanding tasks and then invalidates the session object.
- (void)cancelAllRequests;

/// Cancels all tasks for the given URL.
/// @param url All requests with this URL will be canceled
- (void)cancelAllRequestForURL:(NSURL*)url;

//-(void) sendLogToServer:(NSString *) strLog;

//Send ad logs to the server.
//@param SlikeConfig instance. @see SlikeConfig

//@param adID, NSString Ad ID return by the vast.
//@param strID, NSString Ad category id return by the Ads unit. @see SlikeAdsUnit.
//@param retryCount NSInteger If ad loading is failed and retried.
//@param dur NSInteger Video content duration in milliseconds.
//@param pos NSInteger Video content current position in milliseconds.
//@param adDur NSInteger Ad video duration in milliseconds.
//@param adPos NSInteger Ad video current position in milliseconds.
//@param isPreFetched BOOL Ad video PreFetched information.
//@param SlikeNetworkManagerCompletionBlock, @see SlikeNetworkManagerCompletionBlock
- (void)sendAdLogToServer:(SlikeConfig *) config withStatus:(NSInteger)nStatus withAdID:(NSString *)adID withAdCampaign:(NSString *)strID withRetryCount:(NSInteger)retryCount withMediaDuration:(NSInteger) dur withMediaPosition:(NSInteger)pos withAdDuration:(NSInteger)adDur andWithAdPosition:(NSInteger) adPos DeviceVolume:(BOOL)isOn DeviceVolumeLevel:(float)vl adMoreInformation:(NSString*)adMoreInfo adLoadError:(NSString*)errDespriction addType:(NSInteger)adt strIu:(NSString*)iu strAdResion:(NSString*)adResionType withPreFetchInfo:(BOOL)isPreFetched withPFID:(NSString*)pfid withAdProvider:(NSString*)adProvider withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock;


//Initialize with apikey and device unique id.
//@param apikey NSString api key
//@param uuid NSString device unique id.
//@param debugMode BOOL.
-(void) initWithApikey:(NSString *) apikey andWithDeviceUID:(NSString *) uuid debugMode:(BOOL) isDebug;

//Load any URL
//@param aUrl NSString URL
//@param SlikeNetworkManagerCompletionBlock, @see SlikeNetworkManagerCompletionBlock
- (void)callLoad:(NSURL *) aUrl withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock;

//Load any URL
//@param aUrl NSString URL
//@param method
//@param SlikeNetworkManagerCompletionBlock, @see SlikeNetworkManagerCompletionBlock
-(void) requestURL:(NSString *) aUrl withMethod:(NetworkHTTPMethod) method withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock;

//Set device UUID
//@param strUUID as String. If not passed, the UUID will be generated and could differ from the main app UUID.
- (void)setStoredDeviceUUID:(NSString *) strUUID;

//Set SSOID
//@param strSSOID as String. Pass nil if no ssoid, otherwise pass the actual ssoid provided from TIL sso login.
- (void)setSSOID:(NSString *) strSSOID;
- (void)setHandleCookies:(BOOL)isHandle;
- (void)sendErrorLogToServerUp;

//Log to server With Mod
-(void)sendAnalyticsModelDataToServer:(SlikeAnalyticInformation*)analyticInfo withPlayer:(id<ISlikePlayer>) player withCurrentPlayerTime:(NSInteger)pCurrentTime;

//Check Server Status for analytic log.
-(void)serverPingStatus :(NSInteger) status withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock;

//Send the gif analytics to server
//-(void) sendGifAnalyticsToServer:(NSInteger) status withPlayer:(id<ISlikePlayer>) player  withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock;
-(void) sendEmbededPlayerAnalyticsToServer:(NSString *) analyticInfo  withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock;
-(void)updateAnalyticURLs;

- (void)sendPreFetchAnalyticLog:(NSString *)analyticInfo  withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock;

@end

