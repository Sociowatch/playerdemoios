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
            completionHandler(nil ,SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, [SlikePlayerSettings playerSettingsInstance].slikestrings.apiResponseErr));
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
        return SlikeServiceCreateError(SlikeServiceErrorNoNetworkAvailable, [SlikePlayerSettings playerSettingsInstance].slikestrings.networkErr);
    }
    
    if(!slikeConfigModel) {
        return SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, [SlikePlayerSettings playerSettingsInstance].slikestrings.missingInfoErr);
    }
    else if(!slikeConfigModel && [slikeConfigModel.channel isEqualToString:@""]) {
        return SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, [SlikePlayerSettings playerSettingsInstance].slikestrings.missingInfoErr);
        
    }else if ([[SlikeDeviceSettings sharedSettings] getKey] == nil || [[[SlikeDeviceSettings sharedSettings] getKey] isKindOfClass:[NSNull class]] || [[[SlikeDeviceSettings sharedSettings] getKey] length] ==0) {
        
        return SlikeServiceCreateErrorWithDomain([[NSBundle mainBundle] bundleIdentifier],SlikeServiceErrorInvalidApiKey, @{NSLocalizedDescriptionKey:[SlikePlayerSettings playerSettingsInstance].slikestrings.apiKeyErr});
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
                completionHandler(nil, SlikeServiceCreateError(SlikeServiceErrorNetworkConnectionLost, [SlikePlayerSettings playerSettingsInstance].slikestrings.networkErr));
            }
            else  {
                completionHandler(nil, SlikeServiceCreateError(SlikeServiceErrorInvalidMediaId, [SlikePlayerSettings playerSettingsInstance].slikestrings.videoUnAvailableErr));
            }
        } else {
            
            if(responseStreamData != nil) {
                [self _parseSlikeStreamData:responseStreamData configInfoData:configDataDict playerConfig:slikeConfigModel resultBlock:completionHandler];
            } else {
                completionHandler(nil ,SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, [SlikePlayerSettings playerSettingsInstance].slikestrings.apiResponseErr));
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
        NSString *analyticsUrlString = [dictSettings stringForKey:@"analytics-url"];
          if(analyticsUrlString != nil) {
              [[SlikeSharedDataCache sharedCacheManager]updateSlikeAnalyticsBaseUrl:analyticsUrlString];
          }
        
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
    [parser parsePrefetchedAds:responseData forAdNode:[SlikePlayerSettings playerSettingsInstance].prefetchNode resultBlock:^(id response, NSError *parseError) {
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
            completionHandler(nil, SlikeServiceCreateError(SlikeServiceErrorRequestDataError, [SlikePlayerSettings playerSettingsInstance].slikestrings.emptyResponseErr));
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
                completionHandler(nil, SlikeServiceCreateError(SlikeServiceErrorRequestDataError, [SlikePlayerSettings playerSettingsInstance].slikestrings.emptyResponseErr));
                
            } else {
                
                NSData *cachedStreamData = [[SlikeSharedDataCache sharedCacheManager]cachedStreamForMediaId:slikeConfigModel.mediaId];
                
                [self _parseSlikeStreamData:cachedStreamData configInfoData:configDataDict playerConfig:slikeConfigModel resultBlock:^(id responseObject, NSError *errExists) {
                    
                    if (errExists) {
                        completionHandler(nil, SlikeServiceCreateError(SlikeServiceErrorRequestDataError, [SlikePlayerSettings playerSettingsInstance].slikestrings.emptyResponseErr));
                    } else {
                        completionHandler(responseObject, nil);
                    }
                }];
            }
        }];
    }
}

#pragma mark -  Audio Data Provider
#pragma mark - AudioPlaylist Implementation
/**
 Download the Audio Playlist Information from the server
 
 @param slikeIds - Slike Ids... Comma Seprated Ids
 @param completionHandler - Completion handler
 */
- (void)downloadAudioPlaylist:(NSString *)slikeIds resultBlock:(SlikeDataProviderCompletionBlock)completionHandler  {
    
    NSData *slikeConfigData = [[SlikeSharedDataCache sharedCacheManager]cachedSlikeConfigData];
     if (!slikeConfigData) {
         completionHandler(nil ,SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, [SlikePlayerSettings playerSettingsInstance].slikestrings.apiResponseErr));
                   return;
     }
       
    
    NSString *strBaseURL = [[SlikeSharedDataCache sharedCacheManager]slikeBaseUrlString];
    NSString *downloadUrl = [NSString stringWithFormat:@"%@feed/playerconfig/%@/r001/%@.json", strBaseURL, @"beta", [[SlikeDeviceSettings sharedSettings] getKey]];
    
    [self _audioConfigData:downloadUrl resultBlock:^(id configDataDict, NSError *parseError) {
        
        if (parseError) {
            completionHandler(nil, parseError);
            return;
        }
        
        [self _downloadAudioListData:slikeIds resultBlock:^(NSDictionary * plalistModels, NSError *parseError) {
            
            if (parseError) {
                completionHandler(nil, parseError);
                return;
            }
            
            [self _synchronizeConfigWithPlaylist:configDataDict withPlaylistJSON:plalistModels resultBlock:completionHandler];
        }];
    }];
}

- (void)_synchronizeConfigWithPlaylist:(NSDictionary *)configDataDict withPlaylistJSON:(NSDictionary *)playlistDataDict resultBlock:(SlikeDataProviderCompletionBlock)completionHandler {
    
    //Enumerate the Audio Items
    NSMutableArray *configsArray = [[NSMutableArray alloc]init];
    [playlistDataDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull mediaId, id  _Nonnull streamInfo, BOOL * _Nonnull stop) {
        
        // here need to add into cache
        SlikeConfig *slikeConfig = [[SlikeConfig alloc]init];
        slikeConfig.mediaId = mediaId;
        
        //need to cache it into global cache to make this for stream model
        NSData *streamData = [SlikeUtilities dictToJSONSData:streamInfo];
        NSData *configData = [SlikeUtilities dictToJSONSData:configDataDict];
        
        [self createAudioConfigModel:configData mediaId:mediaId slikeConfig:slikeConfig streamData:streamData status:nil];
        [configsArray addObject:slikeConfig];
        
    }];
    
    completionHandler(configsArray, nil);
}

- (void)createAudioConfigModel:(NSData *)configData mediaId:(NSString * _Nonnull)mediaId slikeConfig:(SlikeConfig *)slikeConfig streamData:(NSData *)streamData status:(void(^)(BOOL status))result  {
    
    if (!slikeConfig || !streamData || !configData) {
        if (result) {
            result(FALSE);
        }
        return;
    }
    
    [self _updateConfigModelWithConfigData:slikeConfig withConfigData:configData associatedStream:streamData resultBlock:^(StreamingInfo* slikeStreamModel, NSError *parseError) {
        
        if (!parseError) {
            [[SlikeSharedDataCache sharedCacheManager]cacheStream:streamData forMediaId:mediaId];
            [[SlikeSharedDataCache sharedCacheManager]cacheAudioConfigStream:slikeConfig forMediaId:mediaId];
            if (result) {
                result(TRUE);
            }
        } else {
            if (result) {
                result(FALSE);
            }
        }
    }];
}

- (void)_updateConfigModelWithConfigData:(SlikeConfig *)configModel withConfigData:(NSData *)configData associatedStream:(NSData *)streamData resultBlock:(SlikeDataProviderCompletionBlock)completionHandler {
    
    SlikeDataParser * parser = [SlikeDataParser slikeDataParser];
    [parser parseAndUpdateSlikeConfig:configModel withJson:configData resultBlock:^(NSDictionary *configDataDict, NSError *parseError) {
        if (parseError) {
            completionHandler(nil, parseError);
            return;
        }
        
        [parser parseStreamDataAndUpdateSlikeConfig:configModel withStreamJson:streamData withConfigJson:configDataDict resultBlock:^(StreamingInfo* slikeStreamModel, NSError *parseError) {
            
            if (parseError) {
                completionHandler(nil, parseError);
            } else {
                completionHandler(slikeStreamModel, nil);
            }
        }];
    }];
}

/**
 Get the Audio playlist data from the server
 
 @param playlistSuffix - Playlist Suffix
 @param completionBlock - Completion Block
 */

- (void)_downloadAudioListData:(NSString *)playlistSuffix resultBlock:(void(^)(id plalistModelsJSON, NSError* errExists))completionBlock {
    
    NSString *strBaseURL =  [[SlikeSharedDataCache sharedCacheManager]slikeBaseUrlString];
    
    NSString *playlistURL = [NSString stringWithFormat:@"%@feed/playlist?sids=%@", strBaseURL,playlistSuffix];
    [[SlikeNetworkInterface sharedNetworkInteface]performGetServiceRequest:[NSURL URLWithString:playlistURL] withCompletionBlock:^(id responseData, NSError *error) {
        
        if(!error && responseData) {
            NSDictionary *playlistJsonDict = [SlikeUtilities jsonDataToDictionary:responseData];
            completionBlock(playlistJsonDict, nil);
            
        } else {
            completionBlock(nil ,SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, [SlikePlayerSettings playerSettingsInstance].slikestrings.apiResponseErr));
        }
    }];
}

/**
 Get the configuration data for the audio.
 
 @param configURL - Configuration URL
 @param completionHandler - Completion handler
 */
- (void)_audioConfigData:(NSString *)configURL  resultBlock:(SlikeDataProviderCompletionBlock)completionHandler {
    
    NSData *slikeConfigData = [[SlikeSharedDataCache sharedCacheManager]cachedSlikeConfigData];
    
    if (slikeConfigData) {
        NSDictionary *configJsonDict = [SlikeUtilities jsonDataToDictionary:slikeConfigData];
        completionHandler(configJsonDict ,nil);
        return;
    }
    
    [[SlikeNetworkInterface sharedNetworkInteface]performGetServiceRequest:[NSURL URLWithString:configURL] withCompletionBlock:^(id responseData, NSError *error) {
        if(!error && responseData) {
            
            NSDictionary *configJsonDict = [SlikeUtilities jsonDataToDictionary:slikeConfigData];
            completionHandler(configJsonDict ,nil);
            
            SlikeDataParser * parser = [SlikeDataParser slikeDataParser];
            NSError *validationError = [parser validateConfigJsonReponse:configJsonDict];
            
            if (validationError) {
                [[SlikeSharedDataCache sharedCacheManager]resetSlikeConfigData];
                completionHandler(nil, validationError);
                return ;
            }
            
            [[SlikeSharedDataCache sharedCacheManager]cacheSlikeConfigData:responseData];
            completionHandler(configJsonDict, nil);
        } else {
            completionHandler(nil ,SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, [SlikePlayerSettings playerSettingsInstance].slikestrings.apiResponseErr));
        }
    }];
}

@end
