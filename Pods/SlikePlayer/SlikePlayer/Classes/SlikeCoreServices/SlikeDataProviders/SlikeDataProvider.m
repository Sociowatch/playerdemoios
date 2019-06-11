//
//  SlikeDataProvider.m
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 21/05/18.
//

#import "SlikeDataProvider.h"
#import "SlikeNetworkMonitor.h"
#import "SlikeServiceError.h"
#import "SlikeStringCommon.h"
#import "SlikeNetworkManager.h"
#import "SlikeUtilities.h"
#import "SlikeDataParser.h"
#import "SlikeSharedDataCache.h"
#import "SlikeNetworkInterface.h"

@implementation SlikeDataProvider

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

/**
 Creats the class instance of DataProvider
 @return - Class instance
 */

+ (instancetype)slikeDataProvider {
    return [[self alloc] init];
}

/**
 Creats the shared instance of DataProvider
 @return - Singleton class  instance
 */
+ (instancetype)sharedSlikeDataProvider {
    
    static SlikeDataProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        
    });
    return sharedInstance;
}

/**
 Download the  configuration  data from the server. SlikeConfig already contains some data for the player
 so here we need to update the the config file
 
 @param configURL  - Config Url
 @param slikeConfigModel - Model that needs to update
 @param completionHandler - Completion Handler Block
 */
- (void)downloadSlikeConfigData:(NSString *)configURL  withConfig:(SlikeConfig *)slikeConfigModel resultBlock:(SlikeDataProviderCompletionBlock)completionHandler {
    
    NSError *statusError = [self _isConfigInstanceValid:slikeConfigModel];
    if (statusError) {
        completionHandler(nil, statusError);
        return;
    }
    
    NSData *slikeConfigData = [[SlikeSharedDataCache sharedCacheManager]cachedSlikeConfigData];
    if (slikeConfigData) {
        [self _parseAndUpdateSlikeConfigModel:slikeConfigModel sourceData:slikeConfigData resultBlock:completionHandler] ;
        return;
    }
    
    SlikeDLog(@"%@", configURL);
    [[SlikeNetworkInterface sharedNetworkInteface]performGetServiceRequest:[NSURL URLWithString:configURL] withCompletionBlock:^(id responseData, NSError *error) {
        
        if(error) {
            completionHandler(nil ,SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, NO_API_RESPONSE));
            return;
        }
        
        if(responseData != nil) {
            [self _parseAndUpdateSlikeConfigModel:slikeConfigModel sourceData:responseData resultBlock:completionHandler] ;
        }
    }];
}

- (void)_parseAndUpdateSlikeConfigModel:(SlikeConfig *)slikeConfigModel sourceData:(NSData *)responseData resultBlock:(SlikeDataProviderCompletionBlock)completionHandler {
    
    SlikeDataParser * parser = [SlikeDataParser slikeDataParser];
    [parser parseAndUpdateSlikeConfig:slikeConfigModel withJson:responseData resultBlock:^(NSDictionary *configInfo, NSError *parseError) {
        
        if (parseError) {
            completionHandler(nil, parseError);
            return;
        }
        
        //Cache the Settings Data.
        [[SlikeSharedDataCache sharedCacheManager]cacheSlikeConfigData:responseData];
        //Now we have updated config file and we have also a response data. Pass this data to caller
        completionHandler(configInfo, nil);
    }];
}

/**
 Check if config  instance is valid or not
 @param slikeConfigModel - Config model
 @return - nil|error
 */
- (NSError *)_isConfigInstanceValid:(SlikeConfig *)slikeConfigModel   {
    
    if (![[SlikeNetworkMonitor sharedSlikeNetworkMonitor] isNetworkReachible]) {
        return SlikeServiceCreateError(SlikeServiceErrorNoNetworkAvailable, NO_NETWORK);
    }
    
    if(!slikeConfigModel) {
        return SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, INSUFFICIENT_INFORMATION);
    }
    else if(!slikeConfigModel && [slikeConfigModel.channel isEqualToString:@""]) {
        return SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, INSUFFICIENT_INFORMATION);
        
    }else if ([[SlikeDeviceSettings sharedSettings] getKey] == nil || [[[SlikeDeviceSettings sharedSettings] getKey] isKindOfClass:[NSNull class]] || [[[SlikeDeviceSettings sharedSettings] getKey] length] ==0) {
        
        return SlikeServiceCreateErrorWithDomain([[NSBundle mainBundle] bundleIdentifier],SlikeServiceErrorInvalidApiKey, @{NSLocalizedDescriptionKey:INVALID_API_KEY});
    }
    return nil;
}

/**
 Download the Stream  data for perticular slike id from the server.
 
 @param streamURL  - Stream URL
 @param slikeConfigModel - Model that needs to update
 @param configDataDict -  Config Data Dictonary. downloaded from Config URL
 @param completionHandler - Completion Handler Block
 */
- (void)downloadSlikeStreamData:(NSString *)streamURL playerConfig:(SlikeConfig *)slikeConfigModel configInfoData:(NSDictionary *)configDataDict resultBlock:(SlikeDataProviderCompletionBlock) completionHandler {
    
    SlikeDLog(@"%@", streamURL);
    
    NSData *cachedStreamData = [[SlikeSharedDataCache sharedCacheManager]cachedStreamForMediaId:slikeConfigModel.mediaId];
    if (cachedStreamData) {
        [self _parseSlikeStreamData:cachedStreamData configInfoData:configDataDict playerConfig:slikeConfigModel resultBlock:completionHandler];
        return;
    }
    
    [[SlikeNetworkInterface sharedNetworkInteface]performGetServiceRequest:[NSURL URLWithString:streamURL] withCompletionBlock:^(id responseStreamData, NSError *error) {
        
        if(error) {
            
            if(![SlikeNetworkMonitor sharedSlikeNetworkMonitor]) {
                completionHandler(nil, SlikeServiceCreateError(SlikeServiceErrorNetworkConnectionLost, NETWORK_ERROR));
            }
            else  {
                completionHandler(nil, SlikeServiceCreateError(SlikeServiceErrorInvalidMediaId, NO_VIDEO));
            }
        } else {
            
            if(responseStreamData != nil) {
                [self _parseSlikeStreamData:responseStreamData configInfoData:configDataDict playerConfig:slikeConfigModel resultBlock:completionHandler];
            } else {
                completionHandler(nil ,SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, NO_API_RESPONSE));
            }
        }
    }];
}

- (void)_parseSlikeStreamData:(NSData *)streamData configInfoData:(NSDictionary *)configDataDict   playerConfig:(SlikeConfig *)slikeConfigModel resultBlock:(SlikeDataProviderCompletionBlock) completionHandler {
    
    SlikeDataParser * parser = [SlikeDataParser slikeDataParser];
    [parser parseStreamDataAndUpdateSlikeConfig:slikeConfigModel withStreamJson:streamData withConfigJson:configDataDict resultBlock:^(StreamingInfo* slikeStreamModel, NSError *parseError) {
        if (parseError) {
            completionHandler(nil, parseError);
        } else {
            completionHandler(slikeStreamModel, nil);
        }
    }];
}

/**
 Download the Config file and cache it . so that there is no need to download it again
 @param configURL - Config URL
 @param completionHandler - Completion block
 */
- (void)downloadAndCacheConfigData:(NSString *)configURL resultBlock:(SlikeDataProviderCompletionBlock)completionHandler {
    
    NSData *slikeConfigData = [[SlikeSharedDataCache sharedCacheManager]cachedSlikeConfigData];
    if (slikeConfigData != nil) {
        [self _parseAndUpdate:slikeConfigData resultBlock:completionHandler];
        return;
    }
    
    [[SlikeNetworkInterface sharedNetworkInteface]performGetServiceRequest:[NSURL URLWithString:configURL] withCompletionBlock:^(id responseData, NSError *error) {
        if(error || responseData == nil) {
            completionHandler(nil, error);
            return;
        }
        
        [self _parseAndUpdate:responseData resultBlock:completionHandler];
    }];
}


- (void)_parseAndUpdate:(NSData *)responseData resultBlock:(SlikeDataProviderCompletionBlock)completionHandler {
    
    SlikeDataParser * parser = [SlikeDataParser slikeDataParser];
    NSDictionary *configJsonDict = [SlikeUtilities jsonDataToDictionary:responseData];
    NSDictionary *dictSettings = [configJsonDict dictionaryForKey:@"settings"];
    if (dictSettings) {
    NSString *gaIdString =  [dictSettings stringForKey:@"gaId"];
    if(gaIdString) {
        [SlikeDeviceSettings sharedSettings].gaId = gaIdString;
    }
    NSString *comscoreIdString =  [dictSettings stringForKey:@"comscoreId"];
    if(comscoreIdString) {
        [SlikeDeviceSettings sharedSettings].comscoreId = comscoreIdString;
    }
    }
    
    NSError *validationError = [parser validateConfigJsonReponse:configJsonDict];
    if (validationError) {
        [[SlikeSharedDataCache sharedCacheManager]resetSlikeConfigData];
        completionHandler(nil, validationError);
        return ;
    }
    
    [[SlikeSharedDataCache sharedCacheManager]cacheSlikeConfigData:responseData];
    [parser parsePrefetchedAds:responseData resultBlock:^(id response, NSError *parseError) {
        if (parseError) {
            completionHandler(nil, parseError);
        } else {
            completionHandler(response, nil);
        }
    }];
}

/**
 Downlaod and cache the Stream Data
 @param streamURL - Stream URL
 @param completionHandler - Completion Block
 */
- (void)downloadAndCacheStreamData:(NSString *)streamURL forMediaId:(NSString *)mediaId resultBlock:(SlikeDataProviderCompletionBlock) completionHandler {
    
    SlikeDLog(@"%@", streamURL);
    [[SlikeNetworkInterface sharedNetworkInteface]performGetServiceRequest:[NSURL URLWithString:streamURL] withCompletionBlock:^(id responseStreamData, NSError *error) {
        
        if(error || responseStreamData ==nil) {
            completionHandler(nil, SlikeServiceCreateError(SlikeServiceErrorRequestDataError, ERR_EMPTY_RESPONSE));
        } else {
            
            SlikeDataParser * parser = [SlikeDataParser slikeDataParser];
            NSString *streamInfoString = [[NSString alloc]initWithData:responseStreamData encoding:NSUTF8StringEncoding];
            NSError *streamValidationError = [parser validateStreamResponseString:streamInfoString];
            if (streamValidationError) {
                completionHandler(nil, streamValidationError);
                return;
            }
            [[SlikeSharedDataCache sharedCacheManager]cacheStream:responseStreamData forMediaId:mediaId];
            completionHandler(responseStreamData,nil);
        }
    }];
}


- (void)prepareSlikeConfigFromCache:(SlikeConfig *)slikeConfigModel resultBlock:(SlikeDataProviderCompletionBlock) completionHandler {
    
    NSData *slikeConfigData = [[SlikeSharedDataCache sharedCacheManager]cachedSlikeConfigData];
    
    if (slikeConfigData) {
        
        [self _parseAndUpdateSlikeConfigModel:slikeConfigModel sourceData:slikeConfigData resultBlock:^(NSDictionary *configDataDict, NSError *errExists) {
            
            if (errExists) {
                completionHandler(nil, SlikeServiceCreateError(SlikeServiceErrorRequestDataError, ERR_EMPTY_RESPONSE));
                
            } else {
                
                NSData *cachedStreamData = [[SlikeSharedDataCache sharedCacheManager]cachedStreamForMediaId:slikeConfigModel.mediaId];
                
                [self _parseSlikeStreamData:cachedStreamData configInfoData:configDataDict playerConfig:slikeConfigModel resultBlock:^(id responseObject, NSError *errExists) {
                    
                    if (errExists) {
                        completionHandler(nil, SlikeServiceCreateError(SlikeServiceErrorRequestDataError, ERR_EMPTY_RESPONSE));
                    } else {
                        completionHandler(responseObject, nil);
                    }
                }];
            }
        }];
    }
}

@end
