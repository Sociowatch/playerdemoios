//
//  SlikeUtilities.m
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 17/05/18.
//

#import "SlikeUtilities.h"
#import "SlikeServiceError.h"
#import "SlikeNetworkInterface.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation SlikeUtilities

/*
 Service event with associated data that needs to pass for registered plugins
 */
NSString * const SlikeEventManagerProcessEventNotification =
@"SlikeEventManagerProcessEventNotification";

/*
 Event Manager will use this for publiching the event with associated data
 */
NSString * const SlikeEventManagerPublishEventNotification =
@"SlikeEventManagerPublishEventNotification";

NSString * const SlikeEventManagerModelKey =
@"EventManagerModelKey";

/**
 Convert JSON object into plain string
 @param jsonDataObject  -
 @return - Plain String
 */
+ (NSString *)convertJsonToString:(id)jsonDataObject {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDataObject
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

/**
 Convert the dictonary to String
 @param dictonary - Source Dictonary
 @return return value description
 */

+ (NSString *)dictToJSONString:(NSDictionary *)dictonary {
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictonary
                                                       options:0
                                                         error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


/**
 Convert JSON String into Dictonary
 @param jsonString -  String represnting the Dictonary
 @return - result Dict| nil
 */
+ (NSDictionary *)jsonStringToDictionary:(NSString *)jsonString {
    if (!jsonString) {
        //Return the Empty Dictonary
        return @{};
    }
    
    NSError *error;
    NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:kNilOptions error:&error];
    return (!json ? @{} : json);
}


/**
 Convert JSON Data into Dictonary
 @param jsonData -  String represnting the Dictonary
 @return - result Dict| nil
 */
+ (NSDictionary *)jsonDataToDictionary:(NSData *)jsonData {
    if (!jsonData) {
        return @{};
    }
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    return (!json ? @{} : json);
}


/**
 Format the BandWidth String
 
 @param bandwidthSpeed - speed
 @return - Formatted String
 */
+ (NSString *)formattedBandWidth:(NSInteger)bandwidthSpeed {
    
    if(bandwidthSpeed == 0) return @"Auto";
    
    NSString *unitStr = @"kbps";
    
    if(bandwidthSpeed > 1024.0f) {
        bandwidthSpeed /= 1024.0f;
    }
    
    if(bandwidthSpeed > 1024.0f) {
        
        bandwidthSpeed /= 1024.0f;
        unitStr = @"mbps";
    }
    
    return [NSString stringWithFormat:@"%ld %@", (long)bandwidthSpeed, unitStr];
}

/**
 Format time
 
 @param elapsedSeconds - Seconds
 @return - Formatted Time
 */
+ (NSString *)formatTime:(NSInteger) elapsedSeconds {
    
    if(elapsedSeconds <= 0) return @"00:00";
    NSUInteger h = elapsedSeconds / 3600;
    NSUInteger m = (elapsedSeconds / 60) % 60;
    NSUInteger s = elapsedSeconds % 60;
    if(h > 0) return [NSString stringWithFormat:@"%lu:%02lu:%02lu", (unsigned long)h, (unsigned long)m, (unsigned long)s];
    else return [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)m, (unsigned long)s];
}

+ (void)rotateLayerInfinite:(CALayer *)layer {
    
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    rotation.duration = 0.7f; // Speed
    rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
    [layer removeAllAnimations];
    [layer addAnimation:rotation forKey:@"Spin"];
}


/**
 Show the AlertView contrller
 
 @param messageString - Message String
 @param alertTitle - Alert Title
 @param parentController - Parent Controller on which alert is need to shown
 */
+ (void)showAlert:(NSString *)messageString withTitle:(NSString *)alertTitle withController:(UIViewController *) parentController {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:messageString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
    }];
    [alert addAction:okAction];
    
    if(!parentController) {
        
        parentController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        if(parentController.presentedViewController) {
            parentController = parentController.presentedViewController;
        }
    }
    [parentController presentViewController:alert animated:YES completion:nil];
}

/**
 Parse M3U8 playlist file
 
 @param strURL  -  Url String
 @param block - Completion Block
 */
+ (void)parsem3u8:(NSString *)strURL withCompletionBlock:(SlikeNetworkManagerCompletionBlock) block {
    
    [[SlikeNetworkInterface sharedNetworkInteface] fetchPlaylistServiceRequest:[NSURL URLWithString:strURL] withCompletionBlock:^(id obj, NSError *error) {
        
        if(obj)
        {
            NSString *str = (NSString *) obj;
            
            if([str rangeOfString:@"#EXT-X-STREAM-INF"].location == NSNotFound) {
                block(nil, SlikeServiceCreateError(SlikeServiceErrorMasterPlaylistFileError, @"Not a master file."));
                return;
            }
            
            NSArray *arr = [str componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            NSArray *arrTmp, *tmp, *arrRes;
            
            NSMutableArray *arrSep = [NSMutableArray arrayWithArray:[strURL componentsSeparatedByString:@"/"]];
            [arrSep removeLastObject];
            NSString *strBaseURL = [arrSep componentsJoinedByString:@"/"];
            
            NSInteger nSize = 0, nIndex, nIndTmp, nLenTmp, nLen = arr.count;
            NSMutableArray *arrData = [NSMutableArray array];
            NSMutableDictionary *dict;
            NSString *strRes;
            BOOL isResBasedDisplay = YES;
            for(nIndex = 0; nIndex < nLen; nIndex++)
            {
                str = [arr objectAtIndex:nIndex];
                //SlikeDLog(@"The URL: %@", str);
                if([str rangeOfString:@"#EXT-X-STREAM-INF"].location != NSNotFound)
                {
                    dict = [NSMutableDictionary dictionary];
                    str = [str stringByReplacingOccurrencesOfString:@"#EXT-X-STREAM-INF:" withString:@""];
                    str = [str stringByReplacingOccurrencesOfString:@", " withString:@" # "];
                    arrTmp = [str componentsSeparatedByString:@","];
                    nLenTmp = arrTmp.count;
                    for(nIndTmp = 0; nIndTmp < nLenTmp; nIndTmp++)
                    {
                        str = [arrTmp objectAtIndex:nIndTmp];
                        tmp = [str componentsSeparatedByString:@"="];
                        if(tmp.count == 2)[dict setObject:[tmp objectAtIndex:1] forKey:[tmp objectAtIndex:0]];
                        if([[tmp objectAtIndex:0] isEqualToString:@"BANDWIDTH"])
                        {
                            if(![[tmp objectAtIndex:1] isEqualToString:@""]) nSize = [[tmp objectAtIndex:1] integerValue];
                            if(nSize > 0)
                            {
                                [dict setObject:[tmp objectAtIndex:1] forKey:[tmp objectAtIndex:0]];
                                [dict setObject:[tmp objectAtIndex:1] forKey:@"comparator"];
                            }
                        }
                        else if([[tmp objectAtIndex:0] isEqualToString:@"RESOLUTION"])
                        {
                            if(strRes != nil && [strRes isEqualToString:[tmp objectAtIndex:1]]) isResBasedDisplay = NO;
                            strRes = [tmp objectAtIndex:1];
                            [dict setObject:strRes forKey:[tmp objectAtIndex:0]];
                            arrRes = [strRes componentsSeparatedByString:@"x"];
                            if(arrRes.count > 0) [dict setObject:[arrRes objectAtIndex:1] forKey:@"comparator"];
                            else [dict setObject:@"0" forKey:@"comparator"];
                        }
                    }
                }
                else if([str rangeOfString:@"http://"].location != NSNotFound || [str rangeOfString:@"https://"].location != NSNotFound)
                {
                    [dict setObject:str forKey:@"url"];
                    if(dict.count > 0) [arrData addObject:dict];
                }
                else if([str rangeOfString:@"//"].location != NSNotFound)
                {
                    [dict setObject:[NSString stringWithFormat:@"%@//%@", [arrSep objectAtIndex:0], str] forKey:@"url"];
                    if(dict.count > 0) [arrData addObject:dict];
                }
                else if([str rangeOfString:@".m3u8"].location != NSNotFound)
                {
                    [dict setObject:[NSString stringWithFormat:@"%@/%@", strBaseURL, str] forKey:@"url"];
                    if(dict.count > 0) [arrData addObject:dict];
                }
            }
            
            if(arrData.count > 1) {
                
                for(NSMutableDictionary *dict in arrData) [dict setObject:isResBasedDisplay ? @"YES" : @"NO" forKey:@"ResBasedDisplay"];
                __block NSMutableDictionary *dict1, *dict2;
                NSArray *arr = [arrData sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    dict1 = (NSMutableDictionary *) a;
                    dict2 = (NSMutableDictionary *) b;
                    NSNumber *num1 = [NSNumber numberWithInteger:[[dict1 objectForKey:@"comparator"] integerValue]];
                    NSNumber *num2 = [NSNumber numberWithInteger:[[dict2 objectForKey:@"comparator"] integerValue]];
                    return [num1 compare:num2];
                }];
                arrData = [arr mutableCopy];
                block(arrData, nil);
            }
            else {
                block(nil, SlikeServiceCreateError(SlikeServiceErrorMasterPlaylistFileError, @"Parse error."));
            }
            
        }
        else {
            block(nil, SlikeServiceCreateError(SlikeServiceErrorNoNetworkAvailable, @"Network error."));
        }
    }];
}



/**
 Make the URL
 
 @param strParentURL - parent URL
 @param strLocalURL - Local URL
 @return - Formatted URL String
 */
- (NSString *)makeURL:(NSString *)strParentURL withLocalURL:(NSString *) strLocalURL {
    
    if(!strLocalURL) return nil;
    if([strLocalURL isEqualToString:@""]) return nil;
    NSURL *urlLocal = [[NSURL alloc] initWithString:strLocalURL];
    if(urlLocal && urlLocal.scheme) return [urlLocal absoluteString];
    if(!strParentURL) return nil;
    NSURL *urlParent = [[NSURL alloc] initWithString:strParentURL];
    if(!urlParent) return [urlLocal absoluteString];
    if(!urlParent.scheme) return [urlLocal absoluteString];
    if([[strLocalURL substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"//"]) return [NSString stringWithFormat:@"%@:%@", urlParent.scheme, strLocalURL];
    else
        if (@available(iOS 9.0, *)) {
            urlLocal = [[NSURL alloc] initFileURLWithPath:strLocalURL relativeToURL:urlParent];
        } else {
            urlLocal = [[NSURL alloc] initWithString:strLocalURL relativeToURL:urlParent];
        }
    if(!urlLocal) return strLocalURL;
    
    return [urlLocal absoluteString];
}

+ (NSInteger)getCBR:(NSInteger)bitrate {
    
    if(bitrate < 50001) {
        return 1;// "108p";
    } else if (bitrate > 50000 && bitrate < 100000) {
        return 2;// "144p";
    } else if (bitrate > 100000 && bitrate < 200001) {
        return 3;//"180p";
    } else if (bitrate > 200000 && bitrate < 350001) {
        return 4;// "Low"; //  "240p";
    } else if (bitrate > 350000 && bitrate < 650001) {
        return 5;// "Medium"; //"360p";
    } else if (bitrate > 650000 && bitrate < 920001) {
        return 6;// "High"; //"480p";
    } else if (bitrate > 920000 && bitrate < 1620001) {
        return 7;//  "Very High"; //"720p";
    } else if (bitrate > 1620000) {
        return 8;//  "HD"; //"720p";
    }
    return 9; //Other
}

+ (NSString*)getPosterImage:(SlikeConfig *)config {
    
    NSString *posterImg = @"";
    if(config.posterImage && [config.posterImage length]>0) {
        posterImg = config.posterImage;
    } else if(config.streamingInfo.strImageURL && config.streamingInfo.strImageURL!=nil) {
        posterImg = [NSString stringWithFormat:@"%@",config.streamingInfo.strImageURL];
    }
    return posterImg;
}

+ (NSString*)getVideoTitle:(SlikeConfig*)config {
    
    if(config.title && config.title!=nil && config.title.length >0) {
        return config.title;
    } else
    {
        if(config.streamingInfo == nil) return @"";
        return config.streamingInfo.strTitle;
    }
}

+ (NSString*)getNextVideoTitle:(SlikeConfig*)config {
    if (config.nextVideoTitle && ![config.nextVideoTitle isEqualToString:@""]) {
        return config.nextVideoTitle;
    }
    return [SlikeUtilities getVideoTitle:config];
}

+ (NSString*)getNextPosterImage:(SlikeConfig*)config {
    
    if (config.nextVideoThumbnail && ![config.nextVideoThumbnail isEqualToString:@""]) {
        return config.nextVideoThumbnail;
    }
    if(config.streamingInfo && [config.streamingInfo.strThumbe_160 length]>0) {
        return  config.streamingInfo.strThumbe_160;
    }
    return [SlikeUtilities getPosterImage:config];
    
}

+ (NSString *)endcodeAndFormatString:(NSString *)encodeData {
    if (encodeData == nil || [encodeData isEqualToString:@""]) {
        return @" ";
    }
 NSString *strData = [NSString stringWithFormat:@"%@", encodeData];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    strData = [strData stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    //@Ravi and @utasav and @nialy
    NSString*  formattedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                       NULL,                                                                                                                      (CFStringRef)strData,                                                                                                                      NULL,                                                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",                                                                                                                      kCFStringEncodingUTF8 ));
#pragma clang diagnostic pop
    if(formattedString != nil && [formattedString isKindOfClass:[NSString class]])
    {
    return formattedString;
    }else return @"";
    
}

+ (NSString *)md5HashForString:(NSString *)string {
    
    const char *cStr = [string UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}


+ (UIViewController *)_topMostController:(UIViewController *)cont {
    
    UIViewController *topController = cont;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    if ([topController isKindOfClass:[UINavigationController class]]) {
        UIViewController *visible = ((UINavigationController *)topController).visibleViewController;
        if (visible) {
            topController = visible;
        }
    }
    
    return (topController != cont ? topController : nil);
}

+ (UIViewController *)topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *next = nil;
    while ((next = [self.class _topMostController:topController]) != nil) {
        topController = next;
    }
    return topController;
}


/**
 Parse M3U8 playlist file
 
 @param strURL  -  Url String
 @param completionBlock - Completion Block
 */
+ (void)parsePlaylistString:(NSString *)strURL withCompletionBlock:(SlikePlaylistCompletionBlock) completionBlock {
    
    [[SlikeNetworkInterface sharedNetworkInteface] fetchPlaylistServiceRequest:[NSURL URLWithString:strURL] withCompletionBlock:^(id obj, NSError *error) {
        
        if(obj)
        {
            NSString *str = (NSString *) obj;
            NSString *responseString = [[ NSString alloc]initWithString:str];
            
            if([str rangeOfString:@"#EXT-X-STREAM-INF"].location == NSNotFound) {
                completionBlock(nil,nil, SlikeServiceCreateError(SlikeServiceErrorMasterPlaylistFileError, @"Not a master file."));
                return;
            }
            
            NSArray *arr = [str componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            NSArray *arrTmp, *tmp, *arrRes;
            
            NSMutableArray *arrSep = [NSMutableArray arrayWithArray:[strURL componentsSeparatedByString:@"/"]];
            [arrSep removeLastObject];
            NSString *strBaseURL = [arrSep componentsJoinedByString:@"/"];
            
            NSInteger nSize = 0, nIndex, nIndTmp, nLenTmp, nLen = arr.count;
            NSMutableArray *arrData = [NSMutableArray array];
            NSMutableDictionary *dict;
            NSString *strRes;
            BOOL isResBasedDisplay = YES;
            for(nIndex = 0; nIndex < nLen; nIndex++)
            {
                str = [arr objectAtIndex:nIndex];
                //SlikeDLog(@"The URL: %@", str);
                if([str rangeOfString:@"#EXT-X-STREAM-INF"].location != NSNotFound)
                {
                    dict = [NSMutableDictionary dictionary];
                    str = [str stringByReplacingOccurrencesOfString:@"#EXT-X-STREAM-INF:" withString:@""];
                    str = [str stringByReplacingOccurrencesOfString:@", " withString:@" # "];
                    arrTmp = [str componentsSeparatedByString:@","];
                    nLenTmp = arrTmp.count;
                    for(nIndTmp = 0; nIndTmp < nLenTmp; nIndTmp++)
                    {
                        str = [arrTmp objectAtIndex:nIndTmp];
                        tmp = [str componentsSeparatedByString:@"="];
                        if(tmp.count == 2)[dict setObject:[tmp objectAtIndex:1] forKey:[tmp objectAtIndex:0]];
                        if([[tmp objectAtIndex:0] isEqualToString:@"BANDWIDTH"])
                        {
                            if(![[tmp objectAtIndex:1] isEqualToString:@""]) nSize = [[tmp objectAtIndex:1] integerValue];
                            if(nSize > 0)
                            {
                                [dict setObject:[tmp objectAtIndex:1] forKey:[tmp objectAtIndex:0]];
                                [dict setObject:[tmp objectAtIndex:1] forKey:@"comparator"];
                            }
                        }
                        else if([[tmp objectAtIndex:0] isEqualToString:@"RESOLUTION"])
                        {
                            if(strRes != nil && [strRes isEqualToString:[tmp objectAtIndex:1]]) isResBasedDisplay = NO;
                            strRes = [tmp objectAtIndex:1];
                            [dict setObject:strRes forKey:[tmp objectAtIndex:0]];
                            arrRes = [strRes componentsSeparatedByString:@"x"];
                            if(arrRes.count > 0) [dict setObject:[arrRes objectAtIndex:1] forKey:@"comparator"];
                            else [dict setObject:@"0" forKey:@"comparator"];
                        }
                    }
                }
                else if([str rangeOfString:@"http://"].location != NSNotFound || [str rangeOfString:@"https://"].location != NSNotFound)
                {
                    [dict setObject:str forKey:@"url"];
                    if(dict.count > 0) [arrData addObject:dict];
                }
                else if([str rangeOfString:@"//"].location != NSNotFound)
                {
                    [dict setObject:[NSString stringWithFormat:@"%@//%@", [arrSep objectAtIndex:0], str] forKey:@"url"];
                    if(dict.count > 0) [arrData addObject:dict];
                }
                else if([str rangeOfString:@".m3u8"].location != NSNotFound)
                {
                    [dict setObject:[NSString stringWithFormat:@"%@/%@", strBaseURL, str] forKey:@"url"];
                    if(dict.count > 0) [arrData addObject:dict];
                }
            }
            
            if(arrData.count > 1) {
                
                for(NSMutableDictionary *dict in arrData) [dict setObject:isResBasedDisplay ? @"YES" : @"NO" forKey:@"ResBasedDisplay"];
                __block NSMutableDictionary *dict1, *dict2;
                NSArray *arr = [arrData sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    dict1 = (NSMutableDictionary *) a;
                    dict2 = (NSMutableDictionary *) b;
                    NSNumber *num1 = [NSNumber numberWithInteger:[[dict1 objectForKey:@"comparator"] integerValue]];
                    NSNumber *num2 = [NSNumber numberWithInteger:[[dict2 objectForKey:@"comparator"] integerValue]];
                    return [num1 compare:num2];
                }];
                arrData = [arr mutableCopy];
                completionBlock(arrData, [[NSString alloc]initWithString:responseString], nil);
            }
            else {
                completionBlock(nil, nil, SlikeServiceCreateError(SlikeServiceErrorMasterPlaylistFileError, @"Parse error."));
            }
            
        }
        else {
            completionBlock(nil,nil, SlikeServiceCreateError(SlikeServiceErrorNoNetworkAvailable, @"Network error."));
        }
    }];
}


/**
 Find the Closest number in a sequence.
 @param collection -
 @param searchNumber - given value
 @return - Closest index
 */
+ (NSInteger)getClosestIndexWithInCollection:(NSArray *)collection forSearchValue:(NSNumber *)searchNumber {
    
    //Note: This algo will work If the collection is sorted in ascending order
    NSInteger searchIndex = MIN([collection indexOfObject: searchNumber inSortedRange:NSMakeRange(0, collection.count)
                                                  options:NSBinarySearchingFirstEqual | NSBinarySearchingInsertionIndex
                                          usingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
                                              return [obj1 compare:obj2];
                                          }], [collection count] - 1);
    
    if (searchIndex > 0) {
        
        NSInteger leftHandDiff = ABS(((NSNumber *)collection[searchIndex - 1]).integerValue - searchNumber.integerValue);
        NSInteger rightHandDiff = ABS(((NSNumber *)collection[searchIndex]).integerValue - searchNumber.integerValue);
        
        if (leftHandDiff == rightHandDiff) {
            //here you can add behaviour when your value is in the middle of range
        } else if (leftHandDiff < rightHandDiff) {
            searchIndex--;
        }
    }
    
    return searchIndex;
}

/**
 Convert the dictonary to String
 @param dictonary - Source Dictonary
 @return return value description
 */

+ (NSData *)dictToJSONSData:(NSDictionary *)dictonary {
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictonary
                                                       options:0
                                                         error:&error];
    return [[NSData alloc] initWithData:jsonData];
}


@end
