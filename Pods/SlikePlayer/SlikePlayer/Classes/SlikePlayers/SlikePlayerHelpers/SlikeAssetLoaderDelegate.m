//
//  SlikeAssetLoaderDelegate.m

#import "SlikeAssetLoaderDelegate.h"
#import "SlikeNetworkManager.h"
#import "SlikeSharedDataCache.h"
#import "SlikeBitratesModel.h"
#import "SlikeNetworkInterface.h"

NSString * const AVERAGE_BANDWIDTH = @"AVERAGE-BANDWIDTH";
NSString * const BANDWIDTH = @"BANDWIDTH";
NSString * const CODECS = @"CODECS";
NSString * const RESOLUTION = @"RESOLUTION";
NSString * const RESBASED_DISPLAY = @"ResBasedDisplay";
NSString * const COMPARATOR = @"comparator";
NSString * const SLKURL = @"url";
NSString * const TAG_PLAYLIST = @"#EXTM3U";
NSString * const TAG_STREAM = @"#EXT-X-STREAM-INF:";

@interface SlikeAssetLoaderDelegate() {
}

@end

@implementation SlikeAssetLoaderDelegate {
    
}

- (id)init{
    if (self = [super init]) {
        
    }
    return self;
}

//Slike Task-
#pragma resource handling----
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSString *url = loadingRequest.request.URL.absoluteString;
    if([url containsString:@".ts"]) {
        return [self handleSegmentsRequest:loadingRequest];
    } else if(loadingRequest.dataRequest) {
        return [self handlePlaylistRequest:loadingRequest];
    }
    return YES;
}

- (BOOL)handlePlaylistRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:loadingRequest.request.URL resolvingAgainstBaseURL:NO];
    
    if([urlComponents.scheme isEqualToString:@"123"]) {
        urlComponents.scheme = @"https";
        
    } else {
        urlComponents.scheme = @"http";
    }
    
    BOOL isAvailable = [[SlikeSharedDataCache sharedCacheManager] isBitratesAvailableForStream];
    NSMutableString *currentURL = [[SlikeSharedDataCache sharedCacheManager]currentStreamBitrateURL];
    
    if (isAvailable && currentURL) {
        NSData *charlieSendData = [currentURL dataUsingEncoding:NSUTF8StringEncoding];
        [loadingRequest.dataRequest respondWithData:charlieSendData];
        [loadingRequest finishLoading];
        return TRUE;
    }
    
    [[SlikeNetworkInterface sharedNetworkInteface] getHLSStreamDataString:[urlComponents string] withCompletionBlock:^BOOL(NSArray *bitratesArray, NSString *responseString, NSError *error) {
        if (error) {
            return NO;
        }
        [self parsePlaylistString:responseString baseUrl:[urlComponents string] loading:loadingRequest];
        return YES;
    }];
    
    return YES;
}


- (BOOL)parsePlaylistString:(NSString *)hlsContent baseUrl:(NSString *)baseUrl loading:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    //No Bitrates available . So we need to create
    __block NSMutableString * lowBitrate = [[NSMutableString alloc] initWithString:TAG_PLAYLIST];
    __block NSMutableString * mediumBitrate = [[NSMutableString alloc] initWithString:TAG_PLAYLIST];
    __block NSMutableString * highBitrate = [[NSMutableString alloc] initWithString:TAG_PLAYLIST];
    __block NSMutableString * autoBitrate = [[NSMutableString alloc] initWithString:TAG_PLAYLIST];
    
    NSMutableArray *bitratesModelArray = [[NSMutableArray alloc]init];
    
    [lowBitrate appendString:@"\n"];
    [mediumBitrate appendString:@"\n"];
    [highBitrate appendString:@"\n"];
    [autoBitrate appendString:@"\n"];
    
    NSArray *lines = [hlsContent componentsSeparatedByString:@"\n"];
    NSInteger lineIndex = 0;
    
    while (lineIndex < [lines count]) {
        
        NSString *line = [lines objectAtIndex:lineIndex];
        if ([line rangeOfString:TAG_STREAM].location == 0) {
            
            NSArray *params = [[line substringFromIndex:[TAG_STREAM length]] componentsSeparatedByString:@","];
            
            NSString *keyValueString = nil;
            long long bitrate = 0;
            long long height = 0;
        
            [autoBitrate appendString:[lines objectAtIndex:lineIndex]];
            [autoBitrate appendString:@"\n"];
            NSInteger autoIndex = lineIndex;
            ++autoIndex;
            NSString *autoStreamURL = [self streamRelativeUrl:[lines objectAtIndex:autoIndex] withBase:baseUrl];
            [autoBitrate appendFormat:@"%@\n", autoStreamURL];
            for (NSInteger itemIndex = 0; itemIndex < [params count]; itemIndex++) {
                
                keyValueString = [params objectAtIndex:itemIndex];
                if ([keyValueString rangeOfString:@"BANDWIDTH"].location != NSNotFound) {
                    bitrate = [[[keyValueString componentsSeparatedByString:@"="] objectAtIndex:1] longLongValue];
                }
                else if ([keyValueString rangeOfString:@"RESOLUTION"].location != NSNotFound) {
                    NSString *heightSting = [[keyValueString componentsSeparatedByString:@"="] objectAtIndex:1];
                    height = [[[heightSting componentsSeparatedByString:@"x"] objectAtIndex:1] longLongValue];
                }
            }
            
            bitrate = bitrate/1000;
            if (height < 360 || bitrate < 450) {
                
                [lowBitrate appendFormat:@"%@\n", [lines objectAtIndex:lineIndex]];
                lineIndex++;
                NSString *streamURL = [self streamRelativeUrl:[lines objectAtIndex:lineIndex] withBase:baseUrl];
                [lowBitrate appendFormat:@"%@\n", streamURL];
                
            } else if ((height <= 480 && height >= 360) ||
                       (bitrate <= 800 && bitrate >= 450)) {
                
                [mediumBitrate appendFormat:@"%@\n", [lines objectAtIndex:lineIndex]];
                lineIndex++;
                NSString *streamURL = [self streamRelativeUrl:[lines objectAtIndex:lineIndex] withBase:baseUrl];
                [mediumBitrate appendFormat:@"%@\n", streamURL];
                
            }
            else if (height > 480 || bitrate > 800) {
                [highBitrate appendFormat:@"%@\n", [lines objectAtIndex:lineIndex]];
                lineIndex++;
                NSString *streamURL = [self streamRelativeUrl:[lines objectAtIndex:lineIndex] withBase:baseUrl];
                [highBitrate appendFormat:@"%@\n", streamURL];
            }
        }
        lineIndex++;
    }
    
    NSInteger validationCons = 5;
    
    if ([autoBitrate length] > [TAG_PLAYLIST length]+ validationCons) {
        SlikeBitratesModel* autoBitrateModel =  [[SlikeBitratesModel alloc]init];
        autoBitrateModel.bitrateName = @"Auto";
        autoBitrateModel.bitrateUrl = autoBitrate;
        autoBitrateModel.isValid = YES;
        autoBitrateModel.bitrateType = SlikeMediaBitrateAuto;
        [bitratesModelArray addObject:autoBitrateModel];
    }
    
    if ([lowBitrate length] > [TAG_PLAYLIST length]+ validationCons) {
        SlikeBitratesModel* lowBitrateModel =  [[SlikeBitratesModel alloc]init];
        lowBitrateModel.bitrateName = @"Low";
        lowBitrateModel.bitrateUrl = lowBitrate;
        lowBitrateModel.isValid = YES;
        lowBitrateModel.bitrateType = SlikeMediaBitrateLow;
        [bitratesModelArray addObject:lowBitrateModel];
    }
    
    if ([mediumBitrate length] > [TAG_PLAYLIST length]+ validationCons) {
        SlikeBitratesModel* mediumBitrateModel =  [[SlikeBitratesModel alloc]init];
        mediumBitrateModel.bitrateName = @"Medium";
        mediumBitrateModel.bitrateUrl = mediumBitrate;
        mediumBitrateModel.isValid = YES;
        mediumBitrateModel.bitrateType = SlikeMediaBitrateMedium;
        [bitratesModelArray addObject:mediumBitrateModel];
    }
    
    if ([highBitrate length] > [TAG_PLAYLIST length]+ validationCons) {
        SlikeBitratesModel* highBitrateModel =  [[SlikeBitratesModel alloc]init];
        highBitrateModel.bitrateName = @"High";
        highBitrateModel.bitrateUrl = highBitrate;
        highBitrateModel.isValid = YES;
        highBitrateModel.bitrateType = SlikeMediaBitrateHigh;
        [bitratesModelArray addObject:highBitrateModel];
    }
    
    [[SlikeSharedDataCache sharedCacheManager]cacheBitratesModel:bitratesModelArray withCurrentBitrate:SlikeMediaBitrateAuto];
    NSData *streamData = [autoBitrate dataUsingEncoding:NSUTF8StringEncoding];
    [loadingRequest.dataRequest respondWithData:streamData];
    [loadingRequest finishLoading];
    
    return TRUE;
    
}

- (NSString *)streamRelativeUrl:(NSString *)urlString withBase:(NSString *)baseUrlString
{

    
    if ([urlString hasPrefix:@"http"] || [urlString hasPrefix:@"https"])
    {
        return urlString;
    }
        NSURL *url = [NSURL URLWithString:baseUrlString];
        url = [url URLByDeletingLastPathComponent];
        return  [[url URLByAppendingPathComponent:urlString] absoluteString];
}
- (BOOL)handleSegmentsRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSURLRequest *redirect = nil;
    redirect = [NSURLRequest requestWithURL:[NSURL URLWithString:[[[(NSURLRequest *)[loadingRequest request] URL] absoluteString] stringByReplacingOccurrencesOfString:@"123" withString:@"https"]]];
    
    // NOTE: After several hours of digging I found that you CANNOT pass HLS chunks directly
    // to the player. It would be great *if* this was possible because after we download the file
    // we could save it to disk and pass it via respondWithData thus only using one network
    // call per chunk.
    
    if (redirect) {
        [loadingRequest setRedirect:redirect];
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[redirect URL] statusCode:302 HTTPVersion:nil headerFields:nil];
        [loadingRequest setResponse:response];
        [loadingRequest finishLoading];
        
    } else {
        [loadingRequest finishLoadingWithError:[NSError errorWithDomain: NSURLErrorDomain code:400 userInfo: nil]];
    }
    
    return YES;
}

@end


