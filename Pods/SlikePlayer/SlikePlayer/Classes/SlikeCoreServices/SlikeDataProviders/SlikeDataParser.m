//
//  SlikeDataParser.m
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 21/05/18.
//

#import "SlikeDataParser.h"
#import "SlikeUtilities.h"
#import "SlikeServiceError.h"
#import "SlikeStringCommon.h"
#import "NSDictionary+Validation.h"
#import "SlikeAdsQueue.h"
#import "SlikeAdsUnit.h"
#import "SlikeSharedDataCache.h"
#import "SlikeUtilities.h"
#import "SlikeMediaPreview.h"

@interface SlikeDataParser() {
    
}
@property (nonatomic, strong)NSString *streamMediaId;


@end


@implementation SlikeDataParser

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

/**
 Creats the class instance of DataParser
 @return - Class instance
 */
+ (instancetype)slikeDataParser {
    return [[self alloc] init];
}

/**
 Parse the source json data & update the config file
 
 @param slikeConfigModel - Config file that needs to update
 @param jsonData  - JSON model
 @param completionBlock - Completion handler
 */

- (void)parseAndUpdateSlikeConfig:(SlikeConfig *)slikeConfigModel withJson:(NSData *)jsonData resultBlock:(void(^)(NSDictionary * configInfo, NSError* parseError))completionBlock {
    
    NSDictionary *configJsonDict = [SlikeUtilities jsonDataToDictionary:jsonData];
    NSError *validationError = [self validateConfigJsonReponse:configJsonDict];
    
    if (validationError) {
        [[SlikeSharedDataCache sharedCacheManager]resetSlikeConfigData];
        completionBlock(nil, validationError);
        return ;
    }
    
    NSDictionary *dictSettings = [configJsonDict dictionaryForKey:@"settings"];
    if (!dictSettings) {
        completionBlock(nil, SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, NO_API_RESPONSE));
        return;
    }
    [self parseSlikeSettingsData:slikeConfigModel settingsData:dictSettings];
    completionBlock(configJsonDict,nil);
}

/**
 Validate the Config Data..
 
 @param jsonInfoDict - JSON Data
 @return nil| Error
 */
- (NSError *)validateConfigJsonReponse:(NSDictionary *)jsonInfoDict {
    
    if(!ENABLE_LOG) {
        NSDictionary *dictSettings = [jsonInfoDict dictionaryForKey:@"settings"];
        if (dictSettings) {
            NSString *packageNameString = [dictSettings stringForKey:@"packageName"];
            if(!packageNameString) {
                packageNameString = @"";
            }
            
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            if(![packageNameString isEqualToString:bundleIdentifier]) {
                
                return  SlikeServiceCreateErrorWithDomain([[NSBundle mainBundle] bundleIdentifier],SlikeServiceErrorRequestDataError, @{NSLocalizedDescriptionKey:ERROR_CONTENT_DISABLE});
            }
        }
    }
    
    if([jsonInfoDict objectForKey:@"error"] || [jsonInfoDict count] == 0) {
        
        NSString * errorCode =  [jsonInfoDict stringForKey:@"error"];
        if ([errorCode isEqualToString:@"404"]) {
            return SlikeServiceCreateError(SlikeServiceErrorInvalidApiKey, INVALID_API_KEY);
        }
        
        return  SlikeServiceCreateErrorWithDomain([[NSBundle mainBundle] bundleIdentifier],SlikeServiceErrorWrongConfiguration, [NSDictionary dictionaryWithObjectsAndKeys:@"Information", @"message", UNKNOWN_ERROR, @"description", nil]);
    }
    
    NSArray *arrError = [[jsonInfoDict objectForKey:@"header"] objectForKey:@"errors"];
    
    if(arrError != nil) {
        
        NSDictionary *dictErr;
        for(dictErr in arrError) {
            
            NSString *strErr = [dictErr objectForKey:@"message"];
            if([strErr isEqualToString:@"Invalid Token"] || [strErr isEqualToString:INVALID_API_KEY]) {
                
                SlikeDLog(@"Invalid token found. Logging out from the SlikePlayer --- %@", [jsonInfoDict objectForKey:@"header"]);
                
                NSDictionary *dictHead = [jsonInfoDict objectForKey:@"header"];
                NSString *strParam = [dictHead objectForKey:@"request_params"];
                
                if(strParam != nil) {
                    if([strParam rangeOfString:@"=logout"].location != NSNotFound) {
                        return  SlikeServiceCreateErrorWithDomain([[NSBundle mainBundle] bundleIdentifier], SlikeServiceErrorInvalidApiKey,@{NSLocalizedDescriptionKey:[arrError objectAtIndex:0]});
                    }
                }
            }
        }
        return SlikeServiceCreateErrorWithDomain([[NSBundle mainBundle] bundleIdentifier],SlikeServiceErrorInvalidTokenKey, @{NSLocalizedDescriptionKey:[arrError objectAtIndex:0]});
    }
    return nil;
}



/**
 Validate the Stream
 
 @param responseString - Validate the Stream Response String
 @return - Error If Any
 */
- (NSError *)validateStreamResponseString:(NSString *)responseString {
    
    NSString * strDataError = @"Failed to fetch information. Please check your internet connection.";
    if(responseString == nil) {
        return SlikeServiceCreateError(SlikeServiceErrorRequestDataError, strDataError);
    }
    
    if([responseString isEqualToString:@"null"] || [responseString isEqualToString:@"[]"] || responseString == nil || [responseString isEqualToString:@""] || [responseString isEqualToString:@"Invalid API Key"]) {
        
        return SlikeServiceCreateErrorWithDomain([[NSBundle mainBundle]bundleIdentifier],SlikeServiceErrorRequestDataError, @{NSLocalizedDescriptionKey:strDataError});
        
    } else if([responseString isEqualToString:INVALID_API_KEY]) {
        return SlikeServiceCreateErrorWithDomain([[NSBundle mainBundle] bundleIdentifier],SlikeServiceErrorInvalidApiKey, nil);
        
    } else if([responseString isEqualToString:@"Invalid Token"]) {
        return SlikeServiceCreateErrorWithDomain([[NSBundle mainBundle] bundleIdentifier],SlikeServiceErrorInvalidTokenKey, nil);
        
    } else if([[[responseString substringWithRange:NSMakeRange(0, 4)] lowercaseString]isEqualToString:@"down"]) {
        return SlikeServiceCreateErrorWithDomain([[NSBundle mainBundle] bundleIdentifier],SlikeServiceErrorServerDown, nil);
        
    } else if([responseString rangeOfString:@"under maintenance"].location != NSNotFound) {
        
        return SlikeServiceCreateErrorWithDomain([[NSBundle mainBundle] bundleIdentifier],SlikeServiceErrorServerUnderMentinance, nil);
        
    } else if([responseString containsString:@"error"] && responseString) {
        
        NSDictionary *streamInfoDict = [SlikeUtilities jsonStringToDictionary:responseString];
        if ([streamInfoDict stringForKey:@"error"] && streamInfoDict) {
            return SlikeServiceCreateError(SlikeServiceErrorInvalidMediaId, NO_VIDEO);
        }
    }
    
    return nil;
}


/**
 Parsing the Settings Data and updating the required values
 
 @param slikeConfigModel - Config Slike Model
 @param dictSettings - Settings Dictonary
 */
- (void)parseSlikeSettingsData:(SlikeConfig *)slikeConfigModel settingsData:(NSDictionary *)dictSettings {
    
    
    //Setting the adtimeout
    NSString *adTimeoutString = [dictSettings stringForKey:@"adtimeout"];
    if(adTimeoutString && [adTimeoutString integerValue]>0) {
        slikeConfigModel.adCleanupTime = [adTimeoutString integerValue];
        [SlikeSharedDataCache sharedCacheManager].adCleanupTime = [adTimeoutString integerValue];
    }
    
    NSString *timeoutString =  [dictSettings stringForKey:@"sessionTimeout"];
    if(timeoutString) {
        [[SlikeDeviceSettings sharedSettings] setUserSessionChangeInterval:[timeoutString integerValue]];
    }
    
    NSString *productString =  [dictSettings stringForKey:@"product"];
    if(productString){
        slikeConfigModel.product =  productString;
    }
    NSString *channelString =  [dictSettings stringForKey:@"channel"];
    if(channelString){
        slikeConfigModel.channel =  channelString;
    }
    NSString *packageNameString =  [dictSettings stringForKey:@"packageName"];
    if(packageNameString){
        slikeConfigModel.packageName =  packageNameString;
    }
    
    NSString *businessString =  [dictSettings stringForKey:@"business"];
    if(businessString){
        slikeConfigModel.business =  businessString;
    }
    
    NSString *gifIntervalString =  [dictSettings stringForKey:@"gifInterval"];
    if(gifIntervalString) {
        slikeConfigModel.gifInterval = [gifIntervalString integerValue];
    }
    
    
    NSString *analyticsUrlString = [dictSettings stringForKey:@"analytics-url"];
    if(analyticsUrlString != nil) {
        [[SlikeSharedDataCache sharedCacheManager]updateSlikeAnalyticsBaseUrl:analyticsUrlString];
    }
    
    NSString *baseUrlString = [dictSettings stringForKey:@"apibase"];
    if(baseUrlString) {
        [[SlikeSharedDataCache sharedCacheManager] updateSlikeBaseUrl:baseUrlString];
    }
    
    NSString *postRollPreFetchIntervalString =  [dictSettings stringForKey:@"postRollPreFetchInterval"];
    if(postRollPreFetchIntervalString) {
        slikeConfigModel.postRollPreFetchInterval = [postRollPreFetchIntervalString integerValue];
        
        //Value:0 - Prefecthing is desiabled for this stream
        if (slikeConfigModel.postRollPreFetchInterval ==0) {
            slikeConfigModel.adPrefetchEnable=NO;
        }
    }
    
    NSString *videoPlayedString =  [dictSettings stringForKey:@"videoPlayed"];
    if(videoPlayedString){
        slikeConfigModel.videoPlayed = [videoPlayedString integerValue];
    }
    
    NSString *adPlayedString =  [dictSettings stringForKey:@"adPlayed"];
    if(adPlayedString) {
        slikeConfigModel.adPlayed = [adPlayedString integerValue];
    }
    
    NSString *gaIdString =  [dictSettings stringForKey:@"gaId"];
    if(gaIdString) {
        slikeConfigModel.gaId =  gaIdString;
        [SlikeDeviceSettings sharedSettings].gaId = gaIdString;
    }
    
    NSString *comscoreIdString =  [dictSettings stringForKey:@"comscoreId"];
    if(comscoreIdString) {
        slikeConfigModel.cs_publisherId =  comscoreIdString;
        [SlikeDeviceSettings sharedSettings].comscoreId = comscoreIdString;
    }
    
    
    NSString *c3String =  [dictSettings stringForKey:@"c3"];
    if(c3String) {
        slikeConfigModel.c3 =  c3String;
    }
    
    NSString *capLevelString = [dictSettings stringForKey:@"capLevel"];
    if(capLevelString && [capLevelString integerValue] != 0) {
        NSString *minLevelString = [dictSettings stringForKey:@"minLevel"];
        if (minLevelString) {
            [[SlikeDeviceSettings sharedSettings] setMax_Min_CapLevel:[minLevelString integerValue] MaxLevel:[capLevelString integerValue]];
        }
    }
}

/**
 Parse Stream Data & also update the Config instance
 
 @param slikeConfigModel - Slike Model
 @param streamData - Stream Data
 @param configInfoDict - Config Data
 @param completionBlock - Completion handler
 */
- (void)parseStreamDataAndUpdateSlikeConfig:(SlikeConfig *)slikeConfigModel withStreamJson:(NSData *)streamData withConfigJson:(NSDictionary *)configInfoDict resultBlock:(void(^)(StreamingInfo* slikeStreamModel, NSError* parseError))completionBlock {
    
    NSError *configValidationError = [self validateConfigJsonReponse:configInfoDict];
    if (configValidationError) {
        
        [[SlikeSharedDataCache sharedCacheManager]resetSlikeConfigData];
        completionBlock(nil, configValidationError);
        return;
    }
    
    NSString *streamInfoString = [[NSString alloc]initWithData:streamData encoding:NSUTF8StringEncoding];
    NSError *streamValidationError = [self validateStreamResponseString:streamInfoString];
    if (streamValidationError) {
        completionBlock(nil, streamValidationError);
        return;
    }
    
    NSDictionary *streamInfoDict = [SlikeUtilities jsonDataToDictionary:streamData];
    if ([streamInfoDict count] ==0) {
        completionBlock(nil, SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, NO_API_RESPONSE));
        return;
    }
    
    [self updateConfigWithSreamData:slikeConfigModel withStreamInfo:streamInfoDict withConfigInfo:configInfoDict resultBlock:completionBlock];
}


/**
 Update the Config object and also create the Stream Object
 
 @param slikeConfigModel - Slike Config Model
 @param streamDict  - Stream Dictonary
 @param configDict - Config Dictinary
 
 */
- (void)updateConfigWithSreamData:(SlikeConfig *)slikeConfigModel withStreamInfo:(NSDictionary *)streamDict withConfigInfo:(NSDictionary *)configDict resultBlock:(void(^)(StreamingInfo* slikeStreamModel, NSError* parseError))completionBlock {
    
    _streamMediaId = slikeConfigModel.mediaId;
    
    NSString *analyticsUrlString = [configDict stringForKey:@"analytics-url"];
    if(analyticsUrlString != nil) {
        [[SlikeSharedDataCache sharedCacheManager]updateSlikeAnalyticsBaseUrl:analyticsUrlString];
    }
    
    NSString *baseUrlString = [configDict stringForKey:@"apibase"];
    if(baseUrlString) {
        [[SlikeSharedDataCache sharedCacheManager] updateSlikeBaseUrl:baseUrlString];
    }
    
    NSString *vendorString = [streamDict stringForKey:@"vendor"];
    if (vendorString) {
        slikeConfigModel.vendorID = vendorString;
    }
    NSString *gcaString = [streamDict stringForKey:@"gca"];
    if (gcaString) {
        slikeConfigModel.gca = gcaString;
    }
    
    NSString *gcbString = [streamDict stringForKey:@"gcb"];
    if (gcbString) {
        slikeConfigModel.gcb = gcbString;
    }
    
    NSString *errorMsgString = [streamDict stringForKey:@"errorMsg"];
    if (gcbString) {
        slikeConfigModel.errorMsg = errorMsgString;
    }
    
    NSString *actionTypeString = [streamDict stringForKey:@"at"];
    if(actionTypeString){
        if ([actionTypeString.lowercaseString  isEqualToString:@"gif"]) {
            slikeConfigModel.preferredVideoType = VIDEO_SOURCE_GIF_MP4;
        } else if ([actionTypeString.lowercaseString  isEqualToString:@"meme"]) {
            slikeConfigModel.preferredVideoType = VIDEO_SOURCE_MEME;
        }
    }
    
    __block StreamingInfo *slikeStreamModel;
    
    NSString *embedString = [streamDict stringForKey:@"embed"];
    if(embedString) {
        [self parseEmbedTypeVideoWithStreamInfo:streamDict withConfigModel:slikeConfigModel resultBlock:^(StreamingInfo *updatedStreamInfo, BOOL parseError) {
            
            if (parseError) {
                completionBlock(nil,SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, @"Video is not available"));
                return;
            } else {
                slikeStreamModel = updatedStreamInfo;
            }
        }];
        
    } else {
        
        [self parseNormalTypeVideo:streamDict withConfigModel:slikeConfigModel resultBlock:^(StreamingInfo *updatedStreamInfo, BOOL parseError)  {
            
            if (parseError) {
                completionBlock(nil,SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, @"Video is not available"));
                return;
            } else {
                slikeStreamModel = updatedStreamInfo;
            }
        }];
       
    }
    
   
    
    NSString *preEnabledString = [configDict stringForKey:@"pre"];
    if([preEnabledString isEqualToString:@"-1"] && preEnabledString) {
        slikeStreamModel.preRollEnabled = YES;
    }
    
    NSString *agMsgString = [streamDict stringForKey:@"AG"];
    if (agMsgString) {
        slikeStreamModel.vendorName = agMsgString;
    } else {
        slikeStreamModel.vendorName = [streamDict stringOrEmptyStringForKey:@"vendor_name"];
    }

    NSString *postEnabledString = [configDict stringForKey:@"post"];
    if(postEnabledString && [preEnabledString isEqualToString:@"0"]) {
        slikeStreamModel.postRollEnabled = YES;
    }
    
    //Fillin ads...
    NSArray *midPostionArray = @[];
    NSString *midPositionsString = [configDict stringForKey:@"mid"];
    if(midPositionsString ) {
        midPostionArray = [midPositionsString componentsSeparatedByString:@","];
        if ([midPostionArray count]>0) {
            slikeStreamModel.midRollEnabled = YES;
        }
    }
    
    //Setting the interval
    NSString *intervalString = [configDict stringForKey:@"interval"];
    if(intervalString) {
        NSInteger intervalValue = [intervalString integerValue];
        if(intervalValue < 1000) {
            slikeStreamModel.strID = @"";
        }
        [[SlikeDeviceSettings sharedSettings]setServerPingInterval:intervalValue];
    }
    
    NSString *metaString = [streamDict stringForKey:@"meta"];
    if(metaString) {
        slikeStreamModel.strMeta = metaString;
    }
    
    NSDictionary * adsDictonary = [configDict dictionaryForKey:@"ads"];
    if (adsDictonary && [adsDictonary count]>0) {
        [self parseAds:slikeStreamModel adsInfo:adsDictonary sectionTitle:slikeConfigModel.section midRollPostions:midPostionArray];
    }
    
    slikeConfigModel.streamingInfo = slikeStreamModel;
    slikeConfigModel.streamingInfo.nStartTime = slikeConfigModel.timecode;
    
    //Return the parsed result
    completionBlock(slikeStreamModel, nil);
}

/**
 Parse Embeded Types of videos..
 
 @param streamDict - Steam Info Dictonary
 @param completionBlock - Completion block
 */
- (void)parseEmbedTypeVideoWithStreamInfo:(NSDictionary *)streamDict  withConfigModel:(SlikeConfig *)slikeConfigModel resultBlock:(void(^)(StreamingInfo * streamInfo, BOOL parseError))completionBlock {
    
    BOOL isError = NO;
    StreamingInfo *streamInfo;
    
    NSString *embedString = [streamDict stringForKey:@"embed"];
    NSArray * videoInfo = [embedString componentsSeparatedByString:@"::"];
    
    if(videoInfo.count>1) {
        
        if([videoInfo.firstObject isEqualToString:@"dm"]) {
            streamInfo = [StreamingInfo createStreamURL:[videoInfo objectAtIndex:1] withType:VIDEO_SOURCE_DM withTitle:[streamDict stringForKey:@"name" defaultValue:@""] withSubTitle:@"" withDuration:0L withAds:nil];
            streamInfo.vendorName = [streamDict stringForKey:@"pp" defaultValue:@"slike"];
            
        } else if([videoInfo.firstObject isEqualToString:@"yt"]) {
            streamInfo = [StreamingInfo createStreamURL:[videoInfo objectAtIndex:1] withType:VIDEO_SOURCE_YT withTitle:[streamDict stringForKey:@"name" defaultValue:@""] withSubTitle:@"" withDuration:0L withAds:nil];
            streamInfo.vendorName = [streamDict stringForKey:@"pp" defaultValue:@"slike"];
            
        } else if([videoInfo.firstObject isEqualToString:@"url"] || [videoInfo.firstObject isEqualToString:@"ru"]) {
            
            if ([videoInfo.firstObject isEqualToString:@"url"]) {
                streamInfo = [StreamingInfo createStreamURL:[videoInfo objectAtIndex:1] withType:VIDEO_SOURCE_VEBLR withTitle:[streamDict stringForKey:@"name" defaultValue:@""] withSubTitle:@"" withDuration:0L withAds:nil];
            } else {
                streamInfo = [StreamingInfo createStreamURL:[videoInfo objectAtIndex:1] withType:VIDEO_SOURCE_RUMBLE withTitle:[streamDict stringForKey:@"name" defaultValue:@""] withSubTitle:@"" withDuration:0L withAds:nil];
            }
            
        }
        else {
            isError = YES;
        }
    }
    
    NSString *idString = [streamDict stringForKey:@"_id"];
    if (idString) {
        streamInfo.strID = idString;
    }
    
    NSString * nameString = [streamDict stringForKey:@"name"];
    if (nameString) {
        streamInfo.strTitle = nameString;
    }
    
    NSString *durationmsString = [streamDict stringForKey:@"durationms"];
    NSString *durationString = [streamDict stringForKey:@"duration"];
    
    if(durationmsString) {
        streamInfo.nDuration = [durationmsString integerValue];
    }
    else if(durationString) {
        streamInfo.nDuration = [durationString integerValue] * 1000;
    }
    
    //Update the Thumbnail Image URL
    [self updateThumbImageUrl:streamInfo withConfigModel:slikeConfigModel streamInfo:streamDict];
    completionBlock(streamInfo, isError);
    return;
}

/**
 Parse normal Type of Videos
 
 @param streamDict -  Stream Info Dictonary
 @param completionBlock - Completion Block
 */
- (void)parseNormalTypeVideo:(NSDictionary *)streamDict withConfigModel:(SlikeConfig *)slikeConfigModel resultBlock:(void(^)(StreamingInfo * streamInfo, BOOL parseError))completionBlock {
    
    BOOL isError = NO;
    StreamingInfo *streamInfo = [[StreamingInfo alloc] init];
    [streamInfo setVideoSoureceType:VIDEO_SOURCE_HLS];
    
    NSString * idString = [streamDict stringForKey:@"_id"];
    if (idString) {
        streamInfo.strID = idString;
    }
    
    NSString * nameString = [streamDict stringForKey:@"name"];
    if (nameString) {
        streamInfo.strTitle = nameString;
    }
    
    /*NSString * imageString = [streamDict stringForKey:@"image"];
     if(imageString) {
     if([imageString rangeOfString:@"http:"].location != NSNotFound || [imageString rangeOfString:@"https:"].location != NSNotFound) {
     streamInfo.strImageURL = [NSURL URLWithString:imageString];
     
     } else {
     streamInfo.strImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https:%@",imageString]];
     }
     }*/
    [self updateThumbImageUrl:streamInfo withConfigModel:slikeConfigModel streamInfo:streamDict];
    if (slikeConfigModel.preview) {
        NSDictionary *thumbsDictonary = [streamDict dictionaryForKey:@"imagereel"];
        if (thumbsDictonary) {
            [self _parseThumbnailsPreviews:thumbsDictonary withStream:streamInfo];
        } else {
            slikeConfigModel.preview = FALSE;
        }
    }
    NSString *agMsgString = [streamDict stringForKey:@"AG"];
    if (agMsgString) {
        streamInfo.vendorName = agMsgString;
    } else {
        streamInfo.vendorName = [streamDict stringOrEmptyStringForKey:@"vendor_name"];
    }
    NSString *durationmsString = [streamDict stringForKey:@"durationms"];
    NSString *durationString = [streamDict stringForKey:@"duration"];
    
    if(durationmsString) {
        streamInfo.nDuration = [durationmsString integerValue];
    } else if (durationString) {
        streamInfo.nDuration = [durationString integerValue] * 1000;
    }
    
    BOOL isThirdPartyVideo = NO;
    NSString *audioOnlyString = [streamDict stringForKey:@"audioOnly"];
    if (audioOnlyString) {
        streamInfo.isAudio = [audioOnlyString integerValue] ? YES : NO;
    }
    
    NSString *isLiveString = [streamDict stringForKey:@"isLive"];
    if (isLiveString) {
        streamInfo.isLive = [isLiveString integerValue] ? YES : NO;
    }
    
    NSArray *arrFlavors = [streamDict arrayForKey:@"flavors"];
    if(arrFlavors && !isThirdPartyVideo) {
        isError = [self parseFlavours:arrFlavors withStream:streamInfo];
        completionBlock(streamInfo, isError);
    }
    else {
        isError = YES;
        SlikeDLog(@"%d", isError);
    }
    
    isError = ![streamInfo hasAnyVideo];
    completionBlock( streamInfo, isError);
    return ;
}

- (BOOL)parseFlavours:(NSArray *)arrFlavors withStream:(StreamingInfo *)streamInfo {
    
    NSInteger itemIndex, flavoursCount = arrFlavors.count;
    if(flavoursCount == 0) {
        return YES;
    }
    else {
        
        NSInteger bitrate = 0;
        CGSize theSize;
        NSString *strLabel;
        
        for(itemIndex = 0; itemIndex < flavoursCount; itemIndex++) {
            NSDictionary *dict = [arrFlavors objectAtIndex:itemIndex];
            if(dict)
            {
                if(![dict objectForKey:@"url"]) continue;
                
                if([dict stringForKey:@"bitrate"]) {
                    bitrate = [[dict stringForKey:@"bitrate"] integerValue];
                    strLabel = [SlikeUtilities formattedBandWidth:bitrate];
                } else {
                    bitrate = 0;
                }
                
                if([dict stringForKey:@"height"]) {
                    theSize = CGSizeMake([[dict stringForKey:@"width"] floatValue], [[dict stringForKey:@"height"] floatValue]);
                    if(theSize.height > 0)strLabel = [NSString stringWithFormat:@"%@P", [dict stringForKey:@"height"]];
                }
                else {
                    theSize = CGSizeZero;
                }
                
                [streamInfo updateStreamSource:[dict stringForKey:@"url"] withBitrates:bitrate withFlavor:[dict stringForKey:@"flavor"] withSize:theSize withLabel:strLabel ofType:[streamInfo getVideoSourceTypeEnumByString:[dict stringForKey:@"type"]]];
            }
        }
    }
    return NO;
}


/**
 Update the THUMB Image URL
 
 @param streamInfo - Stream Info
 @param streamDict - Stream Dictonary
 */
- (void)updateThumbImageUrl:(StreamingInfo *)streamInfo withConfigModel:(SlikeConfig *)slikeConfigModel streamInfo:(NSDictionary *)streamDict {
    
    //Set the Poster Image
    NSString * strURL = @"";
    NSString * imageURLString = [streamDict stringForKey:@"image"];
    if(imageURLString) {
        strURL = imageURLString;
    }
    streamInfo.strImageURL =  [self formattedImageUrl:strURL];
    //Set the Thumnail Image
    NSString * thumbURLString = [streamDict stringForKey:@"thumb"];
    if(thumbURLString !=nil && ![thumbURLString isEqualToString:@""]) {
        streamInfo.strThumbe_160 =  [self formattedImageUrl:thumbURLString];
    } else {
        streamInfo.strThumbe_160 = streamInfo.strImageURL;
    }
}

- (NSString *)formattedImageUrl:(NSString *)strURL {
    
    NSString *formattedUrl = @"";
    if([strURL rangeOfString:@"http://"].location != NSNotFound || [strURL rangeOfString:@"https://"].location != NSNotFound) {
        formattedUrl = [NSString stringWithFormat:@"%@",strURL];
        
    } else {
        if ([strURL hasPrefix:@"//"]) {
            formattedUrl = [NSString stringWithFormat:@"https:%@",strURL];
        } else {
            formattedUrl = [NSString stringWithFormat:@"https:// %@",strURL];
        }
    }
    return formattedUrl;
}

/**
 Parse the Ads from the response JSON
 
 @param streamInfo -  Stream Info
 @param adsInfoDictonary -  Dictonary containg the Ads Information
 @param sectionName  - sectionName
 @param midPostionArray - Mid postions for the mid rolls ads
 */
- (void)parseAds:(StreamingInfo *)streamInfo adsInfo:(NSDictionary *)adsInfoDictonary sectionTitle:(NSString *)sectionName midRollPostions:(NSArray *)midPostionArray {
    
    NSMutableDictionary * adsDictonary = [[NSMutableDictionary alloc]initWithDictionary:adsInfoDictonary];
    NSDictionary *adsResponseDict = [self leafObjectForKeyedSubscript:sectionName withRootDict:adsDictonary];
    
    if (adsResponseDict !=nil) {
        
        if([adsResponseDict objectForKey:@"pre"]) {
            
            SlikeAdsQueue *adInfo = [[SlikeAdsQueue alloc] init];
            adInfo.adType = SL_PRE;
            NSArray *preRollsArray = [adsResponseDict arrayForKey:@"pre"];
            
            if (preRollsArray && [preRollsArray count]>0) {
                
                for (NSInteger index=0; index<[preRollsArray count];) {
                    
                    NSString *adId = preRollsArray[index];
                    NSString *adURL = preRollsArray[index+1];
                    SlikeAdProvider provider = IMA;
                    if ([adURL hasPrefix:@"FAN"]) {
                        NSArray *itemsArray = [adURL componentsSeparatedByString:@"::"];
                        if ([itemsArray count]==2) {
                            provider = FAN;
                            adURL = itemsArray[1];
                        }
                    }
                    SlikeAdsUnit *adUnit = [[SlikeAdsUnit alloc] initWithCategory:adId andAdURL:adURL];
                    adUnit.adProvider = provider;
                    [adInfo addPosition:0 withAdUnit:adUnit];
                    
                    index = index+2;
                }
            }
            
            if(adInfo.adContents > 0) {
                [streamInfo.adContentsArray addObject:adInfo];
            }
        }
        
        if([adsResponseDict objectForKey:@"post"]) {
            
            SlikeAdsQueue *adInfo = [[SlikeAdsQueue alloc] init];
            adInfo.adType = SL_POST;
            NSArray *postRollsArray = [adsResponseDict arrayForKey:@"post"];
            if (postRollsArray && [postRollsArray count]>0) {
                
                for (NSInteger index=0; index<[postRollsArray count];) {
                    
                    NSString *adId = postRollsArray[index];
                    NSString *adURL = postRollsArray[index+1];
                    SlikeAdProvider provider = IMA;
                    if ([adURL hasPrefix:@"FAN"]) {
                        NSArray *itemsArray = [adURL componentsSeparatedByString:@"::"];
                        if ([itemsArray count]==2) {
                            provider = FAN;
                            adURL = itemsArray[1];
                        }
                    }
                    SlikeAdsUnit *adUnit = [[SlikeAdsUnit alloc] initWithCategory:adId andAdURL:adURL];
                    adUnit.adProvider = provider;
                    [adInfo addPosition:-1 withAdUnit:adUnit];
                    index = index+2;
                }
            }
            if(adInfo.adContents > 0) {
                [streamInfo.adContentsArray addObject:adInfo];
            }
        }
        
        if([adsResponseDict objectForKey:@"mid"] && midPostionArray.count>0) {
            
            for(NSString* strPostion in midPostionArray) {
                
                SlikeAdsQueue *adInfo = [[SlikeAdsQueue alloc] init];
                adInfo.adType = SL_MID;
                NSArray *midRollsArray = [adsResponseDict arrayForKey:@"mid"];
                if (midRollsArray && [midRollsArray count]==2) {
                    [adInfo addPosition:[strPostion intValue] withAdUnit:[[SlikeAdsUnit alloc] initWithCategory:[midRollsArray objectAtIndex:0] andAdURL:[midRollsArray objectAtIndex:1]]];
                }
                if(adInfo.adContents > 0) {
                    [streamInfo.adContentsArray addObject:adInfo];
                }
            }
        }
    }
}


- (id)leafObjectForKeyedSubscript:(NSString *)key withRootDict:(NSMutableDictionary *)rootDictionary {
    
    if (![key respondsToSelector: @selector(componentsSeparatedByString:)]) {
        return nil;
    }
    // Use slashes rather than periods since we're not really doing KVC
    NSArray *splitKeys = [key componentsSeparatedByString: @"."];
    NSMutableDictionary *dict = [self innerDictionaryForSplitKey: splitKeys withRootDict:rootDictionary];
    
    id leafKey = [splitKeys lastObject];
    id result = dict[leafKey];
    
    if (![result isKindOfClass:[NSDictionary class]] && result !=nil) {
        return rootDictionary[@"default"];
    }
    
    if (result !=nil) {
        
        if (result[@"pre"] !=nil || result[@"post"] !=nil) {
            return result;
        }
        if (result[@"default"] !=nil) {
            return result[@"default"];
        }
    }
    
    id leafKeyFirst = [splitKeys firstObject];
    id resultFirst = rootDictionary[leafKeyFirst];
    
    if (resultFirst !=nil) {
        
        if (resultFirst[@"pre"] !=nil || resultFirst[@"post"] !=nil) {
            return resultFirst;
        }
        
        if (resultFirst[@"default"] !=nil) {
            return resultFirst[@"default"];
        }
        
        if (resultFirst[@"default"] !=nil) {
            return resultFirst[@"default"];
        }
    }
    
    result = rootDictionary[@"default"];
    return result;
}

- (NSMutableDictionary *)innerDictionaryForSplitKey:(NSArray *)splitKey withRootDict:(NSMutableDictionary *)rootDictionary {
    
    NSMutableDictionary *interim = rootDictionary;
    for (int i = 0; i < splitKey.count - 1; i++) {
        id key = [splitKey objectAtIndex: i];
        NSMutableDictionary *next = interim[key];
        if (next == nil || (NSNull*)next == [NSNull null]) {
            next = [NSMutableDictionary dictionary];
            interim[key] = next;
        }
        interim = next;
    }
    return interim;
}

#pragma mark - Prefetch Functionaliy
- (void)parsePrefetchedAds:(NSData *)jsonData resultBlock:(void(^)(id responseInstance, NSError* parseError))completionBlock {
    
    NSDictionary *configJsonDict = [SlikeUtilities jsonDataToDictionary:jsonData];
    NSDictionary *configDict = [configJsonDict dictionaryForKey:@"settings"];
    if (!configDict) {
        completionBlock(nil, SlikeServiceCreateError(SlikeServiceErrorRequestDataError, @"Setting data missing"));
        return;
    }
    
    NSDictionary * adsDictonary = [configJsonDict dictionaryForKey:@"ads"];
    if (!adsDictonary) {
        completionBlock(nil, SlikeServiceCreateError(SlikeServiceErrorRequestDataError, @"Ads data missing"));
        return;
    }
    
    SlikeAdsQueue *prefetchAdQueue =  [self _parsePrefetchAds:adsDictonary];
    if (prefetchAdQueue.adContents> 0) {
        
        NSString *adTimeoutString = [configDict stringForKey:@"adtimeout"];
        if(adTimeoutString && [adTimeoutString integerValue]>0) {
            [SlikeSharedDataCache sharedCacheManager].adCleanupTime = [adTimeoutString integerValue];
        }
        
        [[SlikeSharedDataCache sharedCacheManager]cachePreloadedAdsContents:prefetchAdQueue];
        completionBlock(prefetchAdQueue, nil);
        return;
    }
    
    completionBlock(nil, SlikeServiceCreateError(SlikeServiceErrorRequestDataError, @"Ads data missing"));
}

/**
 Parse the Ads from the response JSON
 @param adsInfoDictonary -  Dictonary containg the Ads Information
 */
- (SlikeAdsQueue *)_parsePrefetchAds:(NSDictionary *)adsInfoDictonary {
    
    NSDictionary *adsResponseDict = [adsInfoDictonary dictionaryForKey:@"_prefetch"];
    if (adsResponseDict !=nil) {
        
        //Here pre=> It  is used only for the precahing purpose. Don't confuse with tag name 'pre'
        //Note: Need to change from Array t
        NSArray *preRollsArray = [adsResponseDict arrayForKey:@"pre"];
        if(preRollsArray && [preRollsArray count]>0) {
            SlikeAdsQueue *prefetchAdQueue = [[SlikeAdsQueue alloc] init];
            prefetchAdQueue.adType = SL_PRE;
            
            for (NSInteger index=0; index<[preRollsArray count];) {
                
                NSString *adId = preRollsArray[index];
                NSString *adURL = preRollsArray[index+1];
                SlikeAdProvider provider = IMA;
                if ([adURL hasPrefix:@"FAN"]) {
                    NSArray *itemsArray = [adURL componentsSeparatedByString:@"::"];
                    if ([itemsArray count]==2) {
                        provider = FAN;
                        adURL = itemsArray[1];
                    }
                }
                SlikeAdsUnit *adUnit = [[SlikeAdsUnit alloc] initWithCategory:adId andAdURL:adURL];
                adUnit.adProvider = provider;
                [prefetchAdQueue addPosition:0 withAdUnit:adUnit];
                
                index = index+2;
            }
            return prefetchAdQueue;
        }
    }
    
    return nil;
}

/**
 Parse the
 
 @param streamPreviewDict - Dictonary
 @param streamInfo - Streaming info
 */
-(void)_parseThumbnailsPreviews:(NSDictionary *)streamPreviewDict withStream:(StreamingInfo *) streamInfo {
    
    NSInteger rows = [streamPreviewDict integerForKeyString:@"rc"];
    NSInteger columns = [streamPreviewDict integerForKeyString:@"rr"];
    NSInteger thumbWidth = [streamPreviewDict integerForKeyString:@"tw"];
    NSInteger thumbHight = [streamPreviewDict integerForKeyString:@"th"];
    NSArray *totalCount = [streamPreviewDict arrayForKey:@"tc"];
    
    if (!totalCount || [totalCount count]==0) {
        return;
    }
    //rows=6;
    SlikeMediaPreview *mediaThumbnails = [[SlikeMediaPreview alloc]init];
    mediaThumbnails.rows = rows;
    mediaThumbnails.columns = columns;
    mediaThumbnails.thumbWidth = thumbWidth;
    mediaThumbnails.thumbHight = thumbHight;
    mediaThumbnails.timeCounts = [[NSArray alloc]initWithArray:totalCount];
    mediaThumbnails.currentTiledIndex = 0;
    
    float totalItems = [totalCount count];
    float tiledImages = ceil((float)(totalItems/(rows*columns)));
    mediaThumbnails.totalTiledImages = tiledImages ;
    
    streamInfo.thumbnailsInfoModel = mediaThumbnails;
    streamInfo.cachedThumbnails=YES;
    //Store the Media Id . so that we can use it for future
    streamInfo.mediaId = _streamMediaId;
}

@end
