//
//  SlikeNetworkManager
//
//
//  Created by Pravin Ranjan on 20/12/2016.
//  Copyright (c) 2016 tapwork. All rights reserved.
//

#import "SlikeNetworkManager.h"
#import "SlikeAdsQueue.h"
#import "SlikeAdsUnit.h"
#import <AVFoundation/AVFoundation.h>
#import "SlikeStringCommon.h"
#import "NSDictionary+Validation.h"
#import "SlikeServiceError.h"
#import "SlikeUtilities.h"
#import "SlikeSharedDataCache.h"
#import "NSString+Advanced.h"

static NSString *const kDownloadCachePathname = @"SlikeDownloadCache";
const char *const kETAGExtAttributeName  = "etag";
const char *const kLastModifiedExtAttributeName  = "lastmodified";
static const double kDownloadTimeout = 10.0;
static const double kETagValidationTimeout = 1.0;
static NSCache *kImageCache = nil;
static dispatch_queue_t kDownloadGCDQueue = nil;

@interface SlikeNetworkManager () {
    
    NSString *strError, *strDataError;
    NSString *strMySSOID;
    NSDate *dtRecordedMovieTime;
    NSInteger nPlayTimeCol, nBufferTimeCol;
    NSString *strBaseURL, *strAnalyticsBaseURL;
    NSDictionary *dictConfig;
    BOOL isDebugMode;
    BOOL isHandleCookies;
    BOOL isServerUpInitHit;
    BOOL isServerUp;
}

@property (nonatomic, readonly) NSURLSession *urlSession;
@property (nonatomic, readonly) NSSet *runningURLRequests;
@property(nonatomic, strong) NSString *strExtraData;
@property(nonatomic, strong) NSString *strPrefix;
@property (nonatomic, readonly) BOOL isNetworkReachable;
@property (nonatomic, readonly) BOOL isReachableViaWiFi;
@property (nonatomic, strong, nullable) dispatch_queue_t  writerDispatchQueue;

@end

@implementation SlikeNetworkManager {
    NSURLSession *_urlSession;
    NSSet *_runningURLRequests;
    NSInteger nTotalPlayedTimestamp;
    NSInteger nTotalPlayedDuration;
    BOOL isForceSend;
}

static NSUInteger networkFetchingCount = 0;

static void TWBeginNetworkActivity() {
    networkFetchingCount++;
    if ([NSThread isMainThread]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
    }
}

- (float)getTheDeviceVolume {
    return [[AVAudioSession sharedInstance] outputVolume];
}

static void TWEndNetworkActivity() {
    
    if (networkFetchingCount > 0) {
        networkFetchingCount--;
        
        if (networkFetchingCount == 0) {
            if ([NSThread isMainThread]) [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                });
            }
        }
    }
}

#pragma mark - Init & Dealloc
+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static SlikeNetworkManager *shared = nil;
    dispatch_once(&onceToken, ^{
        shared = [[[self class] alloc] init];
    });
    
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        kImageCache = [[NSCache alloc] init];
        [kImageCache setTotalCostLimit:1000];
        _strPrefix = @"";
        isDebugMode = NO;
        strError = @"Oops! Something went wrong.";
        strDataError = @"Failed to fetch information. Please check your internet connection.";
        self.strExtraData = @"";
        
        strBaseURL =  [[SlikeSharedDataCache sharedCacheManager]slikeBaseUrlString];
        strAnalyticsBaseURL = [[SlikeSharedDataCache sharedCacheManager]slikeAnalyticsBaseURLString];
        //strAnalyticsBaseURL =  @"http://devslike.indiatimes.com:8081/";
        
        dictConfig = nil;
        isHandleCookies = NO;
        
        if (!kDownloadGCDQueue) {
            kDownloadGCDQueue = dispatch_queue_create("net.tapwork.download_gcd_queue", DISPATCH_QUEUE_CONCURRENT);
        }
        self.writerDispatchQueue = dispatch_queue_create("com.slike.data.write.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}
-(void)updateAnalyticURLs
{
    strBaseURL =  [[SlikeSharedDataCache sharedCacheManager]slikeBaseUrlString];
    strAnalyticsBaseURL = [[SlikeSharedDataCache sharedCacheManager]slikeAnalyticsBaseURLString];
    //strAnalyticsBaseURL =  @"http://devslike.indiatimes.com:8081/";
}
#pragma mark - Public methods

- (void)requestURL:(NSURL*)url type:(NetworkHTTPMethod)method completion:(void(^)(NSData *data,
                                                                                  NSString *localFilepath,
                                                                                  BOOL isFromCache,
                                                                                  NSInteger statusCode,
                                                                                  NSError *error))completion {
    if(!url) {
        completion(nil, nil, NO, 901, SlikeServiceCreateErrorWithDomain([[NSBundle mainBundle] bundleIdentifier], SlikeServiceErrorWrongConfiguration, [NSDictionary dictionaryWithObjectsAndKeys:@"Information", @"message", @"Data not available.", @"description", nil]));
        return;
    }
    
    NSData *postData = nil;
    NSString *postLength = nil;
    if(method == NetworkHTTPMethodPOST) {
        
        NSString *strURL = [url absoluteString];
        NSArray *arr = [strURL componentsSeparatedByString:@"?"];
        if(arr.count == 2)
        {
            url = [NSURL URLWithString:[arr objectAtIndex:0]];
            strURL = [arr objectAtIndex:1];
            postData = [strURL dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            postLength = [NSString stringWithFormat:@"%ld",(unsigned long)[postData length]];
            
        }
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:url
                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval:kDownloadTimeout];
    
    [request setHTTPShouldHandleCookies:isHandleCookies];
    
    switch (method) {
        case NetworkHTTPMethodGET:
            [request setHTTPMethod:@"GET"];
            break;
        case NetworkHTTPMethodPOST:
            [request setHTTPMethod:@"POST"];
            if(postData)
            {
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
                [request setHTTPBody:postData];
            }
            break;
        case NetworkHTTPMethodDELETE:
            [request setHTTPMethod:@"DELETE"];
            break;
        case NetworkHTTPMethodPUT:
            [request setHTTPMethod:@"PUT"];
            break;
        default:
            [request setHTTPMethod:@"GET"];
            break;
    }
    
    [self sendRequest:request completion:completion];
}


- (void)request:(NSURLRequest*)request completion:(void(^)(NSData *data, NSError *error))completion {
    [self sendRequest:request completion:^( NSData *data,
                                           NSString *localFilepath,
                                           BOOL isFromCache,
                                           NSInteger statusCode,
                                           NSError *error) {
        completion(data,error);
    }];
}


- (void)cancelAllRequests {
    
    if(_urlSession) {
        [_urlSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (!dataTasks || !dataTasks.count) {
                return;
            }
            for (NSURLSessionTask *task in dataTasks) {
                [task cancel];
            }
        }];
        [_urlSession invalidateAndCancel];
    }
    _urlSession = nil;
    _runningURLRequests = nil;
}

- (void)cancelAllRequestForURL:(NSURL*)url {
    
    [_urlSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        NSInteger capacity = [dataTasks count] + [uploadTasks count] + [downloadTasks count];
        NSMutableArray *tasks = [NSMutableArray arrayWithCapacity:capacity];
        [tasks addObjectsFromArray:dataTasks];
        [tasks addObjectsFromArray:uploadTasks];
        [tasks addObjectsFromArray:downloadTasks];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"originalRequest.URL = %@", url];
        [tasks filterUsingPredicate:predicate];
        for (NSURLSessionTask *task in tasks) {
            [task cancel];
        }
    }];
}

#pragma mark - Getter
- (NSURLSession *)urlSession {
    if (_urlSession) {
        return _urlSession;
    }
    _urlSession = [NSURLSession sessionWithConfiguration:
                   [NSURLSessionConfiguration defaultSessionConfiguration]];
    _urlSession.sessionDescription = @"net.tapwork.Networkmanager.nsurlsession";
    
    return _urlSession;
}

- (BOOL)isProcessingURL:(NSURL*)url {
    return ([self.runningURLRequests containsObject:url]);
}

- (void)isDownloadNecessaryForURL:(NSURL*)url completion:(void(^)(BOOL needsDownload))completion {
    
    NSString *cachedFile = [self cachedFilePathForURL:url];
    NSString *eTag = [self eTagAtCachedFilepath:cachedFile];
    NSString *lastModified = [self lastModifiedAtCachedFilepath:cachedFile];
    
    if (![self isNetworkReachable] &&
        [self hasCachedFileForURL:url]) {
        if (completion) {
            completion(NO);
        }
    } else if (![self hasCachedFileForURL:url] ||
               ![self isNetworkReachable] ||
               (!eTag && !lastModified)) {
        if (completion) {
            completion(YES);
        }
    } else {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                timeoutInterval:kETagValidationTimeout];
        if ([eTag length] > 0) {
            [request setValue:eTag forHTTPHeaderField:@"If-None-Match"];
        }
        if ([lastModified length] > 0) {
            [request setValue:lastModified forHTTPHeaderField:@"If-Modified-Since"];
        }
        [request setHTTPMethod:@"HEAD"];
        
        NSURLSession *session = self.urlSession;
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *response,
                                        NSError *error) {
                        
                        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                            NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
                            NSDictionary *header = [(NSHTTPURLResponse*)response allHeaderFields];
                            
                            if (statusCode == 304) {  // Not Modified - our cached stuff is fresh enough
                                completion(NO);
                            } else if (statusCode == 301) { // Moved Permanently HTTP Forward
                                NSURL *forwardURL = [NSURL URLWithString:header[@"Location"]];
                                [self isDownloadNecessaryForURL:forwardURL completion:completion];
                            } else if (statusCode == 200) {
                                completion(YES);
                            } else {
                                completion(NO);
                            }
                        } else {
                            completion(NO);
                        }
                        
                    }] resume];
    }
}

- (BOOL)hasCachedFileForURL:(NSURL*)url {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    return [fileManager fileExistsAtPath:[self cachedFilePathForURL:url]];
}

- (NSString *)cachedFilePathForURL:(NSURL*)url {
    NSString *md5Filename = [SlikeUtilities md5HashForString:[url absoluteString]];
    NSString *fullpath = [[self localCachePath] stringByAppendingPathComponent:md5Filename];
    
    return fullpath;
}

- (NSString *)localCachePath {
    
    NSURL *libcache = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    libcache = [libcache URLByAppendingPathComponent:kDownloadCachePathname];
    
    NSFileManager *filemanager = [[NSFileManager alloc] init];
    NSError *error = nil;
    BOOL isDir;
    if (![filemanager fileExistsAtPath:[libcache path] isDirectory:&isDir] ||
        !isDir) {
        [filemanager createDirectoryAtURL:libcache withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return [libcache path];
}

- (BOOL)isNetworkReachble {
    SlikeReachability *reach = [SlikeReachability reachabilityForInternetConnection];
    return ([reach currentReachabilityStatus] != NotReachable);
}

- (BOOL)isReachableViaWiFi {
    SlikeReachability *reach = [SlikeReachability reachabilityForInternetConnection];
    return ([reach currentReachabilityStatus] == ReachableViaWiFi);
}

+ (NSCache*)imageCache {
    return kImageCache;
}

- (NSError*)errorForNilURL {
    return [NSError errorWithDomain:NSURLErrorDomain
                               code:-1
                           userInfo:@{NSLocalizedFailureReasonErrorKey : @"URL must not be nil"}];
}



- (void)sendRequest:(NSURLRequest*)request completion:(void(^)(NSData *data, NSString *localFilepath,
                                                               BOOL isFromCache,
                                                               NSInteger statusCode,
                                                               NSError *error))completion {
    NSURL *url = [request URL];
    if (!url) {
        NSAssert(url, @"url must not be nil here");
        if (completion) {
            completion(nil, nil, NO, 901, [self errorForNilURL]);
        }
        
        return;
    }
    
    [self addRequestedURL:url];
    TWBeginNetworkActivity();
    
    NSURLSession *session = self.urlSession;
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *connectionError) {
                    
                    TWEndNetworkActivity();
                    NSError *resError = connectionError;
                    
                    if(!self->_urlSession) {
                        resError = SlikeServiceCreateErrorWithDomain([[NSBundle mainBundle] bundleIdentifier],SlikeServiceErrorRequestCanceled, [NSDictionary dictionaryWithObjectsAndKeys:@"Information", @"message", @"Cancelled.", @"description", nil]);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(nil,nil,NO, SlikeServiceErrorRequestCanceled, resError);
                            }
                        });
                        return;
                    }
                    
                    NSInteger statusCode = 0;
                    if ([response respondsToSelector:@selector(statusCode)]) {
                        statusCode = [(NSHTTPURLResponse*)response statusCode];
                    }
                    
                    if (statusCode >= 400) {
                        NSMutableDictionary *errorUserInfo = [NSMutableDictionary dictionary];
                        errorUserInfo[@"HTTP statuscode"] = @(statusCode);
                        if (connectionError) {
                            errorUserInfo[@"underlying error"] = connectionError;
                        }
                        
                        resError = SlikeServiceCreateErrorWithDomain(NSURLErrorDomain, statusCode, errorUserInfo);
                    }
                    
                    NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
                    if([headers objectForKey:@"geo"] && [[headers objectForKey:@"geo"] isKindOfClass:[NSString class]]) {
                        [[SlikeDeviceSettings sharedSettings] setGeoCountry:[headers objectForKey:@"geo"]];
                    }
                    
                    NSString *filepath = [self cachedFilePathForURL:url];
                    if (data) {
                        // for some strange reasons,NSDataWritingAtomic does not override in some cases
                        NSFileManager* filemanager = [[NSFileManager alloc] init];
                        [filemanager removeItemAtPath:filepath error:nil];
                        [data writeToFile:filepath options:NSDataWritingAtomic error:nil];
                        
                        NSError *readError = nil;
                        data = [NSData dataWithContentsOfFile:filepath
                                                      options:NSDataReadingMappedIfSafe
                                                        error:&readError];
                        
                        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                            NSDictionary *header = [(NSHTTPURLResponse*)response allHeaderFields];
                            NSString *etag = header[@"Etag"];
                            NSString *lastmodified = header[@"Last-Modified"];
                            if (etag) {
                                // store the eTag - we use it to check later if the content has been modified
                                [self setETag:etag forCachedFilepath:filepath];
                            } else if (lastmodified) {
                                [self setLastModified:lastmodified forCachedFilepath:filepath];
                            }
                        }
                    }
                    [self removeRequestedURL:url];
                    if (completion) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(data,filepath,NO, statusCode,resError);
                        });
                        
                    }
                }] resume];
}

#pragma mark - Private Getter

- (void)addRequestedURL:(NSURL*)url {
    @synchronized(self) {
        if (url) {
            NSMutableSet *requests = [self.runningURLRequests mutableCopy];
            [requests addObject:url];
            _runningURLRequests = [requests copy];
        }
    }
}

- (void)removeRequestedURL:(NSURL*)url {
    @synchronized(self ) {
        NSMutableSet *requests = [self.runningURLRequests mutableCopy];
        if (url && [requests containsObject:url]) {
            [requests removeObject:url];
            _runningURLRequests = [requests copy];
        }
    }
}

- (NSSet *)runningURLRequests {
    if (!_runningURLRequests) {
        _runningURLRequests = [[NSSet alloc] init];
    }
    return _runningURLRequests;
}

#pragma mark - Extended File Attributes (eTag & Last Modified)
- (BOOL)setETag:(NSString *)eTag forCachedFilepath:(NSString *)filepath {
    return [self setExtendedFileAttribute:kETAGExtAttributeName withValue:eTag forCachedFilepath:filepath];
}

- (NSString *)eTagAtCachedFilepath:(NSString *)filepath {
    return [self extendedFileAttribute:kETAGExtAttributeName cachedFilepath:filepath];
}

- (BOOL)setLastModified:(NSString *)lastModified forCachedFilepath:(NSString *)filepath {
    return [self setExtendedFileAttribute:kLastModifiedExtAttributeName withValue:lastModified forCachedFilepath:filepath];
}

- (NSString *)lastModifiedAtCachedFilepath:(NSString *)filepath {
    return [self extendedFileAttribute:kLastModifiedExtAttributeName cachedFilepath:filepath];
}

- (BOOL)setExtendedFileAttribute:(const char *)attribute withValue:(NSString *)value forCachedFilepath:(NSString *)filepath {
    const char *cfilePath = [filepath fileSystemRepresentation];
    const char *cETag = [value UTF8String];
    
    if (0 != setxattr(cfilePath, attribute, cETag, strlen(cETag), 0, XATTR_NOFOLLOW)) {
        SlikeDLog(@"could not create Extended File Attributes to file %@",filepath);
        return NO;
    }
    return YES;
}

- (NSString *)extendedFileAttribute:(const char *)attribute cachedFilepath:(NSString *)filepath {
    const char *cfilePath = [filepath fileSystemRepresentation];
    NSString *etagString = nil;
    
    // get size of needed buffer
    ssize_t bufferLength = getxattr(cfilePath, attribute, NULL, 0, 0, 0);
    
    if (bufferLength > 0) {
        // make a buffer of sufficient length
        char *buffer = malloc(bufferLength);
        getxattr(cfilePath,
                 attribute,
                 buffer,
                 255,
                 0, 0);
        
        etagString = [[NSString alloc] initWithBytes:buffer length:bufferLength encoding:NSUTF8StringEncoding];
        
        // release buffer
        free(buffer);
    }
    
    return etagString;
}

#pragma mark network methods
- (void)addDeviceInfo {
    self.strExtraData = [NSString stringWithFormat:@"&%@", [[SlikeDeviceSettings sharedSettings] deviceInfo]];
}

- (NSString *)getVAOneTimeString:(SlikeConfig *) config withAdCall:(BOOL)isAdCall
{
    //if(![streamingInfo.strSS isEqualToString:@""]) return @"";
    long tit = (long)[SlikeDeviceSettings sharedSettings].nConfigLoadTime;
    long tis = (long)[SlikeDeviceSettings sharedSettings].nPlayerLoadTime;
    long tim = (long)[SlikeDeviceSettings sharedSettings].nManifestLoadTime;
    long tsm = (long)[SlikeDeviceSettings sharedSettings].nVideoLoadTime;
    NSString *strHa = @"";
    if(strMySSOID && ![strMySSOID isEqualToString:@""])
    {
        strHa = [NSString stringWithFormat:@"%@&ssoid=%@", strHa, strMySSOID];
    }
    StreamingInfo *streamingInfo = config.streamingInfo;
    long playerDuration = streamingInfo.nDuration;
    
    if(streamingInfo.isLive) {
        playerDuration=-1;
    }
    else if(playerDuration<0) {
        playerDuration=0;
    }
    
    NSString *strLatLong = @"";
    if(config.strLatLong && [config.strLatLong length] == 0) {
        strLatLong = [[SlikeDeviceSettings sharedSettings] getDeviceLocation];
        
    } else {
        strLatLong = config.strLatLong;
    }
    
    NSString *countyAndCity=@"";
    if(config.country && [config.country length]>0) {
        countyAndCity=[NSString stringWithFormat:@"&c=%@",config.country];
    }
    
    if(config.city && [config.city length]>0) {
        if([countyAndCity length]>0) {
            countyAndCity=[NSString stringWithFormat:@"%@&zc=%@",countyAndCity,config.city];
            
        } else {
            //countyAndCity=[NSString stringWithFormat:@"&c=%@",config.city];
        }
    }
    
    if(config.state && [config.state length]>0) {
        
        if([countyAndCity length]>0) {
            countyAndCity=[NSString stringWithFormat:@"%@&ste=%@",countyAndCity,config.state];
            
        } else {
            //countyAndCity=[NSString stringWithFormat:@"&ste=%@",config.state];
        }
    }
    
    NSString *userInformation = @"";
    if(config.age!=0) {
        userInformation = [NSString stringWithFormat:@"&ag=%ld",(long)config.age];
    }
    
    if([userInformation length]>0) {
        
        if(config.gender && config.gender!=nil && config.gender.length>0) {
            userInformation = [NSString stringWithFormat:@"%@&g=%@",userInformation,config.gender];
        }
    } else {
        
        if(config.gender && config.gender!=nil && config.gender.length>0) {
            userInformation = [NSString stringWithFormat:@"&g=%@",config.gender];
        }
    }
    
    if(isAdCall)
    {
        return [NSString stringWithFormat:@"%@&st=%ld&sr=%ld&te=%d&ce=%d&pt=%ld&stt=%ld&t=%d&tg=%@&nt=%ld%@%@&l=%@%@%@&me=%@&cdn=%@&va=%.2f&tpl=%@&av=%@", strHa, (long)streamingInfo.nStartTime, (long)[[SlikeDeviceSettings sharedSettings] getScreenResEnum], 1, [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy == NSHTTPCookieAcceptPolicyNever ? 0 : 1, (long)[streamingInfo getConstantValueForPlayerType], (long)[streamingInfo getCurrentPlayer], 0, @"", (long)[SlikeReachability getNetworkTypeEnum], [config toString], [[SlikeDeviceSettings sharedSettings] getSlikeAnalyticsCache],strLatLong,countyAndCity,userInformation,@"0",[[SlikeDeviceSettings sharedSettings] getM3U8HostName],[[SlikeDeviceSettings sharedSettings] getPlayerViewArea],config.pageTemplate,config.appVersion];
    }else
    {
        return [NSString stringWithFormat:@"%@&tit=%ld&tis=%ld&tim=%ld&tsm=%ld&du=%ld&st=%ld&sr=%ld&te=%d&ce=%d&pt=%ld&stt=%ld&t=%d&tg=%@&nt=%ld%@%@&l=%@%@%@&me=%@&cdn=%@&va=%.2f&tpl=%@&av=%@", strHa, tit, tis, tim, tsm,playerDuration, (long)streamingInfo.nStartTime, (long)[[SlikeDeviceSettings sharedSettings] getScreenResEnum], 1, [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy == NSHTTPCookieAcceptPolicyNever ? 0 : 1, (long)[streamingInfo getConstantValueForPlayerType], (long)[streamingInfo getCurrentPlayer], 0, @"", (long)[SlikeReachability getNetworkTypeEnum], [config toString], [[SlikeDeviceSettings sharedSettings] getSlikeAnalyticsCache],strLatLong,countyAndCity,userInformation,@"0",[[SlikeDeviceSettings sharedSettings] getM3U8HostName],[[SlikeDeviceSettings sharedSettings] getPlayerViewArea],config.pageTemplate,config.appVersion];
    }
}


- (NSString *) getVARegularString:(SlikeConfig *) config withAdCall:(BOOL)isAdCall
{
    
    NSInteger nBitrate = [[SlikeDeviceSettings sharedSettings] nMeasuredBitrate];
    NSInteger nBitrateEnum = [SlikeUtilities getCBR:nBitrate];
    StreamingInfo *streamingInfo = config.streamingInfo;
    
    if(config.section && config.section.length>0) {
        
        NSArray * componentData = [config.section componentsSeparatedByString:@"."];
        NSString *l1=@"";
        NSString *l2=@"";
        NSString *l3=@"";
        NSString *l4=@"";
        int i = 1;
        
        for (NSString * str in componentData) {
            
            if(i == 1) {
                l1 = str;
                
            } else if(i == 2) {
                l2 = str;
                
            } else if(i == 3) {
                l3 = str;
                
            } else {
                
                if(l4.length == 0) {
                    l4 = str;
                }else
                {
                    l4 = [NSString stringWithFormat:@"%@.%@",l4,str];
                }
            }
            i++;
        }
        if(streamingInfo.isExternalPlayer)
        {
            return [NSString stringWithFormat:@"&ss=%@&ts=%@&br=%ld&cbr=%ld&src=%ld&k=%@%@%@&ap=%d&l1=%@&l2=%@&l3=%@&l4=%@", streamingInfo.strSS, streamingInfo.strTS, (long)nBitrateEnum, (long)nBitrate,(long)[self getSrcType:streamingInfo.strID], streamingInfo.strID, streamingInfo.strMeta, [self getVAOneTimeString:config withAdCall:isAdCall],config.isAutoPlay,l1,l2,l3,l4];
        }
        return [NSString stringWithFormat:@"&ss=%@&ts=%@&br=%ld&cbr=%ld&k=%@%@%@&ap=%d&l1=%@&l2=%@&l3=%@&l4=%@", streamingInfo.strSS, streamingInfo.strTS, (long)nBitrateEnum, (long)nBitrate, streamingInfo.strID, streamingInfo.strMeta, [self getVAOneTimeString:config withAdCall:isAdCall],config.isAutoPlay,l1,l2,l3,l4];
        
    } else {
        
        if(streamingInfo.isExternalPlayer)
        {
            NSString *src = @"";
            NSArray * srcComponent = [streamingInfo.strID componentsSeparatedByString:@"."];
            if(srcComponent.count>1)
            {
                src = [srcComponent firstObject];
            }
            return [NSString stringWithFormat:@"&ss=%@&ts=%@&br=%ld&cbr=%ld&src=%ld&k=%@%@%@&ap=%d", streamingInfo.strSS, streamingInfo.strTS, (long)nBitrateEnum, (long)nBitrate,(long)[self getSrcType:streamingInfo.strID], streamingInfo.strID, streamingInfo.strMeta, [self getVAOneTimeString:config withAdCall:isAdCall],config.isAutoPlay];
        }
        return [NSString stringWithFormat:@"&ss=%@&ts=%@&br=%ld&cbr=%ld&k=%@%@%@&ap=%d", streamingInfo.strSS, streamingInfo.strTS, (long)nBitrateEnum, (long)nBitrate, streamingInfo.strID, streamingInfo.strMeta, [self getVAOneTimeString:config withAdCall:isAdCall],config.isAutoPlay];
    }
}

- (void)writeLog:(NSString*)analyticInfo Status: (NSInteger)status {
    
    //Do for 30 sec
    if(isServerUpInitHit)
        [[SlikeDeviceSettings sharedSettings] setServerPingInterval:30000];
    isServerUpInitHit = NO;
    analyticInfo = [analyticInfo stringByReplacingOccurrencesOfString:@"?"
                                                           withString:@"~~"];
    
    time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
    [self writeErrorInDocumnet:[NSString stringWithFormat:@"%@&ets=%ld",analyticInfo,unixTime*1000]];
    
    if(status ==4 || status ==12)
    {
        int r = arc4random_uniform(30);
        SlikeDLog(@"%i",r)
        [self performSelector:@selector(afterDelayHit) withObject:nil afterDelay:r];
    }
    
}

- (void) sendLogToServer:(NSString *) strLog {
    
    if(strAnalyticsBaseURL != nil && strAnalyticsBaseURL.length == 0) return;
    NSString *aUrl = [NSString stringWithFormat:@"%@devicelog?%@type=device_info%@", strAnalyticsBaseURL, self.strPrefix, self.strExtraData];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    aUrl = [aUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
    
    [[SlikeNetworkManager defaultManager] requestURL:[NSURL URLWithString:aUrl] type:NetworkHTTPMethodGET completion:^(NSData *data, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
        
        if(data != nil) {
            //NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }];
    
}



- (void)initWithApikey:(NSString *)apikey andWithDeviceUID:(NSString *)uuid debugMode:(BOOL)isDebug {
    isDebugMode = isDebug;
    [[SlikeDeviceSettings sharedSettings] setKey:apikey];
    [[SlikeDeviceSettings sharedSettings] setUniqueDeviceIdentifierAsString:uuid];
    [SlikeDeviceSettings sharedSettings].isDebugMode = isDebugMode;
}

- (void)callLoad:(NSURL *)aUrl withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock {
    SlikeDLog(@"%@", aUrl);
    [[SlikeNetworkManager defaultManager] requestURL:aUrl type:NetworkHTTPMethodGET completion:^(NSData *data, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
        
        if(data != nil) {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            completionBlock(string, nil);
            
        } else if(error) {
            if(error.code == 5555) return;
            completionBlock(nil, error);
            
        } else {
            completionBlock(nil, SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, self->strError));
            
        }
    }];
}

- (void)requestURL:(NSString *)aUrl withMethod:(NetworkHTTPMethod) method withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock {
    
    SlikeDLog(@"%@", aUrl);
    aUrl = [aUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[SlikeNetworkManager defaultManager] requestURL:[NSURL URLWithString:aUrl] type:method completion:^(NSData *data, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(data != nil){
                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                completionBlock(string, nil);
            }
            else if(error) {
                if(error.code == 5555) return;
                completionBlock(nil, error);
            }
            else {
                completionBlock(nil, SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, self->strError));
            }
        });
    }];
}

- (void)setStoredDeviceUUID:(NSString *) strUUID {
    if(strUUID && ![strUUID isEqualToString:@""]) {
        [[SlikeDeviceSettings sharedSettings] setUniqueDeviceIdentifierAsString:strUUID];
    }
    else {
        assert("Invalid provided UUID. The SDK will use own UUID.");
    }
}

- (void)setSSOID:(NSString *)strSSOID {
    strMySSOID = strSSOID;
}

- (void)setHandleCookies:(BOOL)isHandle {
    isHandleCookies  = isHandle;
}
/**
 Send the analytics data to the server. Analytics information is contained in the model
 
 @param analyticInfo - Analytics model
 @param player - Player Instance
 */
-  (void)sendAnalyticsModelDataToServer:(SlikeAnalyticInformation*)analyticInfo withPlayer:(id<ISlikePlayer>)player withCurrentPlayerTime:(NSInteger)pCurrentTime{
    
    if([SlikeSharedDataCache sharedCacheManager].isGDPREnable) return;
    
    if(ENABLE_Analytic) {
        
        NSInteger nStatus = 3;
        if(analyticInfo.state == SL_READY) nStatus = 1;
        else if(analyticInfo.state == SL_VIDEO_REQUEST) nStatus = 105;
        else if(analyticInfo.state == SL_START || analyticInfo.state == SL_LOADED) nStatus = 2;
        else if(analyticInfo.state == SL_PLAYING) nStatus = 3;
        else if(analyticInfo.state == SL_COMPLETED) nStatus = 4;
        else if(analyticInfo.state == SL_REPLAY) nStatus = 5;
        else if(analyticInfo.state == SL_PAUSE) nStatus = 6;
        else if(analyticInfo.state == SL_SEEKED) nStatus = 7;
        else if(analyticInfo.state == SL_QUALITYCHANGE) nStatus = 8;
        else if(analyticInfo.state == SL_BUFFERING) nStatus = 9;
        else if(analyticInfo.state == SL_PLAY) nStatus = 10;
        else if(analyticInfo.state == SL_FSENTER || analyticInfo.state == SL_FSEXIT) nStatus = 11;
        else if (analyticInfo.state == SL_ENDED) nStatus = 12;
        else if (analyticInfo.state == SL_VIDEOPLAYED) nStatus = 14;
        else if (analyticInfo.state == SL_PLAYEDPERCENTAGE) nStatus = 15;
        else if (analyticInfo.state == SL_VIDEO_COMPLETED) nStatus = 16;
        
        if(!analyticInfo.config && !analyticInfo.config.mediaId && [analyticInfo.config.mediaId isEqualToString:@""]) {
            return;
        }
        
        if(nStatus == 105)
        {
           // [self sendDataForVideoRequest:nStatus withConfigModel:analyticInfo.config];
            nPlayTimeCol = 0;
            nBufferTimeCol = 0;
//            return;
        }
        
        nPlayTimeCol += analyticInfo.nTotalPlayedDuration;
        nBufferTimeCol += analyticInfo.nTotalBufferDuration;
        
        if(analyticInfo.isForce == NO && analyticInfo.state != SL_COMPLETED && analyticInfo.state !=SL_PAUSE) {
            
            if(dtRecordedMovieTime == nil) {
                dtRecordedMovieTime = [NSDate date];
            }
            else {
                NSTimeInterval diff = -[dtRecordedMovieTime timeIntervalSinceNow];
                if(diff < [[SlikeDeviceSettings sharedSettings] serverPingInterval]) {
                    return;
                } else {
                    dtRecordedMovieTime = [NSDate date];
                }
            }
        }
        
        StreamingInfo *streamingInfo = analyticInfo.config.streamingInfo;
        if(!streamingInfo.strID) {
            return;
        }
        if([streamingInfo.strID isEqualToString:@""] &&  !streamingInfo.isExternalPlayer)
        {
            return;
        }else   if([streamingInfo.strID isEqualToString:@""] &&  streamingInfo.isExternalPlayer)
        {
            NSString *videoType = @"";
            if([streamingInfo hasVideo:VIDEO_SOURCE_HLS])
            {
                videoType = @"hl";
            }
            else if([streamingInfo hasVideo:VIDEO_SOURCE_DRM])
            {
                videoType = @"dr";
            }
            else if([streamingInfo hasVideo:VIDEO_SOURCE_MP4])
            {
                videoType = @"m4";
            }
            else if([streamingInfo hasVideo:VIDEO_SOURCE_YT])
            {
                videoType = @"yt";
            }
            else if([streamingInfo hasVideo:VIDEO_SOURCE_FB])
            {
                videoType = @"fb";
            }
            else if([streamingInfo hasVideo:VIDEO_SOURCE_DM])
            {
                videoType = @"dm";
            }
            else if([streamingInfo hasVideo:VIDEO_SOURCE_DASH])
            {
                videoType = @"ds";
            }
            else if([streamingInfo hasVideo:AUDIO_SOURCE_MP3])
            {
                videoType = @"m3";
            }
            else if([streamingInfo hasVideo:VIDEO_SOURCE_GIF_MP4])
            {
                videoType = @"gf";
            }
            else if([streamingInfo hasVideo:VIDEO_SOURCE_VEBLR])
            {
                videoType = @"vb";
            }
            else if([streamingInfo hasVideo:VIDEO_SOURCE_MEME])
            {
                videoType = @"rb";
            }
            else if([streamingInfo hasVideo:VIDEO_SOURCE_MEME])
            {
                videoType = @"me";
            }
            else
            {
                //unknown
                videoType = @"un";
            }
            
            NSString *mediaUrl =  [StreamingInfo slikeMediaUrl:analyticInfo.config];
            if(!mediaUrl || [mediaUrl isEqualToString:@""])
            {
                mediaUrl = analyticInfo.config.streamingInfo.mediaId;
            }
            if(!mediaUrl || [mediaUrl isEqualToString:@""])
            {
                mediaUrl = analyticInfo.config.mediaId;
            }
            if([mediaUrl hasPrefix:@"http"])
            {
                mediaUrl = [mediaUrl md5];
            }
         
            streamingInfo.strID = [NSString stringWithFormat:@"%@.%@",videoType,mediaUrl];
        }
        
        BOOL isYT = NO;
        if([streamingInfo hasVideo:VIDEO_SOURCE_YT]) isYT = YES;
        
        BOOL isDM = NO;
        if([streamingInfo hasVideo:VIDEO_SOURCE_DM]) isDM = YES;
        
        if (isDM || isYT) {
            //Do the same task when duration recived...
        } else {
            
            if(nPlayTimeCol > streamingInfo.nEndTime && !streamingInfo.isLive) {
                nPlayTimeCol = streamingInfo.nEndTime;
            }
            
            if(nPlayTimeCol >= streamingInfo.nDuration && !streamingInfo.isLive) {
                nPlayTimeCol= 0;
            }
        }
        
        {
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                //Before Send end event
                /*
                if(nStatus == 4)
                {
                    if(analyticInfo.config.isPostrollEnabled == OFF)
                    {
                        [self callSendToServer:121 withPlayer:player withConfigModel:analyticInfo.config withPD:self->nPlayTimeCol-self->nBufferTimeCol withDuration:streamingInfo.nEndTime withBufferDuration:self->nBufferTimeCol withrpc:analyticInfo.rpc with_rid:analyticInfo.rid withCurrentPlayerTime:pCurrentTime  withCompletionBlock:^(id result, NSError *error) {
                            if(result) {
                            }
                        }];
                    }
                }
                */

                
                [self callSendToServer:nStatus withPlayer:player withConfigModel:analyticInfo.config withPD:self->nPlayTimeCol-self->nBufferTimeCol withDuration:streamingInfo.nEndTime withBufferDuration:self->nBufferTimeCol withrpc:analyticInfo.rpc with_rid:analyticInfo.rid withCurrentPlayerTime:pCurrentTime  withCompletionBlock:^(id result, NSError *error) {
                    if(result)
                    {
                    }
                }];
                /*
                if(nStatus == 1)
                {
                    if(analyticInfo.config.isPrerollEnabled == OFF)
                    {
                        [self callSendToServer:120 withPlayer:player withConfigModel:analyticInfo.config withPD:self->nPlayTimeCol-self->nBufferTimeCol withDuration:streamingInfo.nEndTime withBufferDuration:self->nBufferTimeCol withrpc:analyticInfo.rpc with_rid:analyticInfo.rid withCurrentPlayerTime:pCurrentTime  withCompletionBlock:^(id result, NSError *error) {
                            if(result) {
                            }
                        }];
                    }
                }
                 */
                self->nPlayTimeCol = 0;
                self->nBufferTimeCol = 0;
            });
        }
        
        
    }
}
- (void)sendAdLogToServer:(SlikeConfig *) config withStatus:(NSInteger)nStatus withAdID:(NSString *)adID withAdCampaign:(NSString *)strID withRetryCount:(NSInteger)retryCount withMediaDuration:(NSInteger) dur withMediaPosition:(NSInteger)pos withAdDuration:(NSInteger)adDur andWithAdPosition:(NSInteger) adPos DeviceVolume:(BOOL)isOn DeviceVolumeLevel:(float)vl adMoreInformation:(NSString*)adMoreInfo adLoadError:(NSString*)errDespriction addType:(NSInteger)adt strIu:(NSString*)iu strAdResion:(NSString*)adResionType withPreFetchInfo:(BOOL)isPreFetched withPFID:(NSString*)pfid withAdProvider:(NSString*)adProvider withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock {
    
    if([SlikeSharedDataCache sharedCacheManager].isGDPREnable) return;
    
    //To do
    //Need to fixed s after colambiya
    if(strAnalyticsBaseURL != nil && strAnalyticsBaseURL.length == 0) return;
    if(!config && !config.mediaId && [config.mediaId isEqualToString:@""]) return;
    if(!strID && [strID isEqualToString:@""]) return;
    
    StreamingInfo *streamingInfo = config.streamingInfo;
    
    long atl = (long)[SlikeDeviceSettings sharedSettings].nAdLoadTime;
    long atc = (long)[SlikeDeviceSettings sharedSettings].nAdContentLoadTime;
    
    NSString *sg= config.sg;
    NSArray * pairs = [sg componentsSeparatedByString:@"&"];
    
    if(pairs.count>0) {
        sg=pairs.firstObject;
    }
    
    NSArray * componentData = [iu componentsSeparatedByString:@"/"];
    NSString *iu1=@"";
    NSString *iu2=@"";
    NSString *iu3=@"";
    
    int i = 0;
    for (NSString * str in componentData) {
        
        if(i == 3) {
            iu1 = str;
            
        } else  if(i == 4){
            iu2 = str;
            
        } else if(i>4) {
            if(iu3.length == 0) {
                iu3 = str;
            } else {
                iu3 = [NSString stringWithFormat:@"%@.%@",iu3,str];
            }
        }
        i++;
    }
    __block NSString *analyticInfo = @"";
    if(config == nil || streamingInfo == nil)
    {
        analyticInfo = [NSString stringWithFormat:@"adstats?%@vai=%@&k=%@&atl=%ld&atc=%ld&vp=%ld&adu=%ld&cp=%ld&rt=%ld&evt=%ld&ci=%@%@&m=%i&err=%@&atr=0&adt=%li&s=%@&vl=%f%@&usid=%@&sg=%@&iu1=%@&iu2=%@&iu3=%@&ha=%@&pf=%d&pfid=%@", self.strPrefix, adID, @"", atl, atc, (long)pos, (long)adDur, (long)adPos, (long)retryCount, (long)nStatus, strID, @"",isOn,errDespriction == nil ? @"" : errDespriction,(long)adt,adProvider,vl*100,adMoreInfo,[[SlikeDeviceSettings sharedSettings] getUserSession : config],@"",iu1,iu2,iu3,adResionType,isPreFetched, pfid];
        
    }else
    {
        if(streamingInfo.isExternalPlayer)
        {
            
            analyticInfo = [NSString stringWithFormat:@"adstats?%@vai=%@&src=%ld&k=%@&atl=%ld&atc=%ld&vp=%ld&adu=%ld&cp=%ld&rt=%ld&evt=%ld&ci=%@%@&m=%i&err=%@&atr=0&adt=%li&s=%@&vl=%f%@&usid=%@&sg=%@&iu1=%@&iu2=%@&iu3=%@&ha=%@&pf=%d&pfid=%@", self.strPrefix, adID,(long)[self getSrcType:streamingInfo.strID],streamingInfo.strID, atl, atc, (long)pos, (long)adDur, (long)adPos, (long)retryCount, (long)nStatus, strID, [self getVARegularString:config withAdCall:YES],isOn,errDespriction == nil ? @"" : errDespriction,(long)adt,adProvider,vl*100,adMoreInfo,[[SlikeDeviceSettings sharedSettings] getUserSession : config],sg,iu1,iu2,iu3,adResionType,isPreFetched, pfid];

        }else
        {
        analyticInfo = [NSString stringWithFormat:@"adstats?%@vai=%@&k=%@&atl=%ld&atc=%ld&vp=%ld&adu=%ld&cp=%ld&rt=%ld&evt=%ld&ci=%@%@&m=%i&err=%@&atr=0&adt=%li&s=%@&vl=%f%@&usid=%@&sg=%@&iu1=%@&iu2=%@&iu3=%@&ha=%@&pf=%d&pfid=%@", self.strPrefix, adID, streamingInfo.strID, atl, atc, (long)pos, (long)adDur, (long)adPos, (long)retryCount, (long)nStatus, strID, [self getVARegularString:config withAdCall:YES],isOn,errDespriction == nil ? @"" : errDespriction,(long)adt,adProvider,vl*100,adMoreInfo,[[SlikeDeviceSettings sharedSettings] getUserSession : config],sg,iu1,iu2,iu3,adResionType,isPreFetched, pfid];
        }
    }
    SlikeDLog(@"Ad analyticInfo_Sanajy %@",analyticInfo);
    
    analyticInfo = [analyticInfo stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    [self writeAnalyticsInDocumnet:analyticInfo];
    // logic to send server call
    nTotalPlayedDuration  = 0.0;
    
    if(nTotalPlayedTimestamp > 0) {
        double currentMediaNew = CACurrentMediaTime();
        nTotalPlayedDuration = (NSInteger)currentMediaNew  - nTotalPlayedTimestamp;
        if(nStatus == 7 || nStatus == 8) {
        }
        else
        {
            if(nTotalPlayedDuration > [[SlikeDeviceSettings sharedSettings] serverPingInterval]) {
                dispatch_async(self.writerDispatchQueue, ^{
                    [self loadAnalyticInfoFromDocToServer:config];
                    self->nTotalPlayedTimestamp = currentMediaNew;
                });
            }
        }
    } else {
        
        double currentMediaNew = CACurrentMediaTime();
        nTotalPlayedTimestamp = currentMediaNew;
        //[self loadAnalyticInfoFromDocToServer:config];
    }
}
-(void)sendDataForVideoRequest:(NSInteger)playerStatus withConfigModel:(SlikeConfig *) config
{
    if(strAnalyticsBaseURL != nil && strAnalyticsBaseURL.length == 0) return;
    
    [SlikeSharedDataCache sharedCacheManager].cssId =  [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:config.mediaId];
    
    __block  NSString *analyticInfo = [NSString stringWithFormat:@"savelogs?at=%ld&apikey=%@&css=%@&type=init&k=%@",playerStatus,[[SlikeDeviceSettings sharedSettings] getKey],[SlikeSharedDataCache sharedCacheManager].cssId  ,config.mediaId];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", strAnalyticsBaseURL,analyticInfo];
    
    [[SlikeNetworkManager defaultManager] requestURL:[NSURL URLWithString:requestUrl] type:NetworkHTTPMethodGET completion:^(NSData *data, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if(string) {
                SlikeDLog(@"string Saved Log %@",string);
            }
        });
        
    }
     ];
    
}
/**
 Send data to server
 
 @param playerStatus - Current player state
 @param player - Current Player
 @param config - Config Model
 @param playedDuration - Player played Duration
 @param duration - Duration of stream
 @param bufferDuration - Buffer duration
 @param replayCount - Reply count
 @param rid -
 @param completionBlock - Completion handler
 */
- (void)callSendToServer:(NSInteger)playerStatus withPlayer:(id<ISlikePlayer>)player withConfigModel:(SlikeConfig *) config withPD:(NSInteger)playedDuration withDuration:(NSInteger)duration withBufferDuration:(NSInteger)bufferDuration withrpc:(NSInteger)replayCount with_rid:(NSString*)rid  withCurrentPlayerTime:(NSInteger)pCurrentTime withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock {
    
    if(strAnalyticsBaseURL != nil && strAnalyticsBaseURL.length == 0) return;
    
    StreamingInfo *streamingInfo = config.streamingInfo;
    NSInteger streamPostion =  0;
    NSInteger streamDuration = 0;
    if(player)
    {
        NSInteger streamPostion = [player getPosition];
        
        if(streamPostion < 0) {
            streamPostion = 0;
        }
        
        streamDuration = streamingInfo.nDuration;
        if([player getDuration]>0) {
            streamDuration = [player getDuration];
        }
        
        if((streamDuration - streamPostion) < 100) {
            streamPostion = streamDuration;
            NSLog (@"%ld", (long)streamPostion);
        }
        
        if(streamDuration < 0) {
            streamDuration = 0;
        }
    }else
    {
        streamPostion = pCurrentTime;
        streamDuration = duration;
        
    }
    
    float vol = [self getTheDeviceVolume];
    BOOL playerVolume = NO ;
    
    if(vol>0.0) {
        playerVolume = NO;
        
    } else {
        playerVolume = YES;
    }

    __block  NSString *analyticInfo = @"";
    BOOL isPlayerStatusForPostRollOff = NO;
    if(playerStatus == 121)
    {
        isPlayerStatusForPostRollOff = YES;
        playerStatus = 120;
    }
    if(player)
    {
        analyticInfo = [NSString stringWithFormat:@"stats?%@at=%ld&bd=%ld&pd=%ld&et=%ld&fid=%@&il=%@&ps=%@%@%@&ia=%@&ha=%i&vl=%f&m=%d&usid=%@&sn=%@&aud=0&ispr=%d", self.strPrefix, (long)playerStatus, (long)bufferDuration, (long)playedDuration, playerStatus == 4 ? (long)streamDuration : (long)streamPostion, [player getCurrentFlavour], config.streamingInfo.isLive ? @"1" : @"0", [player isFullScreen] ? @"5" : @"1",[self getVARegularString:config withAdCall:NO],streamingInfo.strMeta,streamingInfo.isAudio ? @"1" : @"0",config.isSkipAds == NO ? 1: -2, vol*100,playerVolume, [[SlikeDeviceSettings sharedSettings] getUserSession : config],config.screenName,config.ispr];
        
    }else
    {
        analyticInfo = [NSString stringWithFormat:@"stats?%@at=%ld&bd=%ld&pd=%ld&et=%ld&fid=%@&il=%@&ps=%@%@%@&ia=%@&ha=%i&vl=%f&m=%d&usid=%@&sn=%@&aud=1&ispr=%d", self.strPrefix, (long)playerStatus, (long)bufferDuration, (long)playedDuration, playerStatus == 4 ? (long)streamDuration : (long)streamPostion, @"", config.streamingInfo.isLive ? @"1" : @"0", [player isFullScreen] ? @"5" : @"1",[self getVARegularString:config withAdCall:NO],streamingInfo.strMeta,streamingInfo.isAudio ? @"1" : @"0",config.isSkipAds == NO ? 1: -2, vol*100,playerVolume, [[SlikeDeviceSettings sharedSettings] getUserSession : config],config.screenName,config.ispr];
    }
    if(config.isPrerollEnabled == OFF)
    {
        analyticInfo = [NSString stringWithFormat:@"%@&skpr=1",analyticInfo];
    }
    

    if(config.isPostrollEnabled == OFF)
    {
        analyticInfo = [NSString stringWithFormat:@"%@&skps=1",analyticInfo];
    }
    if(config.streamingInfo.isExternalPlayer)
    {
        NSCharacterSet *set = [NSCharacterSet URLFragmentAllowedCharacterSet];
        analyticInfo = [NSString stringWithFormat:@"%@&ti=%@",analyticInfo,[[SlikeUtilities getVideoTitle:config] stringByAddingPercentEncodingWithAllowedCharacters:set]];
    }
    
    if(playerStatus == 120)
    {
             if(config.isPrerollEnabled == OFF && !isPlayerStatusForPostRollOff)
             {
                 analyticInfo = [NSString stringWithFormat:@"%@&adt=1&adr=-1",analyticInfo];
             }else if(config.isPostrollEnabled == OFF && isPlayerStatusForPostRollOff)

             {
                 analyticInfo = [NSString stringWithFormat:@"%@&adt=3&adr=-1",analyticInfo];
             }
    }

  
    if(replayCount>0) {
        replayCount = 1;
        analyticInfo = [NSString stringWithFormat:@"%@&rpc=%ld",analyticInfo,(long)replayCount];
    }
    
    if(rid == nil) {
        analyticInfo = [NSString stringWithFormat:@"%@&rid=%@",analyticInfo,@""];
        
    } else {
        analyticInfo = [NSString stringWithFormat:@"%@&rid=%@",analyticInfo,rid];
    }
    if(ENABLE_LOG)
    {
    NSLog(@"Sanajay Analytics %@",analyticInfo);
    }
    if(playerStatus == 1)
    {
        if([SlikeSharedDataCache sharedCacheManager].cssId && [[SlikeSharedDataCache sharedCacheManager].cssId  length] >0)
        {
            analyticInfo = [NSString stringWithFormat:@"%@&css=%@",analyticInfo,[SlikeSharedDataCache sharedCacheManager].cssId];
        }
        NSString *aUrl = [NSString stringWithFormat:@"%@%@", strAnalyticsBaseURL,analyticInfo];
        aUrl = [aUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        //SlikeDLog(@"AURL %@" , aUrl);
        double CurrentTimeNew = CACurrentMediaTime();
        nTotalPlayedTimestamp = CurrentTimeNew;
        
        isServerUp =  YES;
        [[SlikeNetworkManager defaultManager] requestURL:[NSURL URLWithString:aUrl] type:NetworkHTTPMethodGET completion:^(NSData *data, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(statusCode !=200) {
                    [self writeAnalyticsInDocumnet:analyticInfo];
                    self->isServerUp =  NO;
                }
                else if(data != nil) {
                    
                    self->isServerUp =  YES;
                    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if(string) {
                        
                        NSDictionary *dict = [SlikeUtilities jsonStringToDictionary:string];
                        
                        if(dict) {
                            
                            if([dict objectForKey:@"body"]) {
                                dict = [dict objectForKey:@"body"];
                            }
                            SlikeDLog(@"Video %@",dict);
                            if([dict isValidDictonary]) {
                                
                                if([dict stringForKey:@"ss"]) {
                                    [self updateAnalyticsResponse:dict streamingInfo:streamingInfo configModel:config.mediaId];
                                    completionBlock(dict, nil);
                                }
                                else {
                                    
                                    if([streamingInfo.strSS length] == 0) {
                                        
                                        streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:config.mediaId];
                                        
                                        analyticInfo = [self formatAnalyticsErrorRsponse:0 playerState:playerStatus withPlayer:player withConfigModel:config withPD:playedDuration withDuration:streamDuration withBufferDuration:bufferDuration streamPostion:streamPostion streamDuration:streamDuration streamingInfo:streamingInfo playerVolume:playerVolume];
                                    }
                                    
                                    [self writeAnalyticsInDocumnet:analyticInfo];
                                }
                            }
                            else {
                                
                                if([streamingInfo.strSS length] == 0) {
                                    streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:config.mediaId];
                                    
                                    analyticInfo = [self formatAnalyticsErrorRsponse:1 playerState:playerStatus withPlayer:player withConfigModel:config withPD:playedDuration withDuration:streamDuration withBufferDuration:bufferDuration streamPostion:streamPostion streamDuration:streamDuration streamingInfo:streamingInfo playerVolume:playerVolume];
                                }
                                
                                [self writeAnalyticsInDocumnet:analyticInfo];
                            }
                        }
                        else {
                            
                            if([streamingInfo.strSS length] == 0) {
                                
                                streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:config.mediaId];
                                
                                analyticInfo = [self formatAnalyticsErrorRsponse:2 playerState:playerStatus withPlayer:player withConfigModel:config withPD:playedDuration withDuration:streamDuration withBufferDuration:bufferDuration streamPostion:streamPostion streamDuration:streamDuration streamingInfo:streamingInfo playerVolume:playerVolume];
                            }
                            
                            [self writeAnalyticsInDocumnet:analyticInfo];
                        }
                    }
                }
                else if(error && error.code != 5555) {
                    if([streamingInfo.strSS length] == 0) {
                        
                        streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:config.mediaId];
                        
                        analyticInfo = [self formatAnalyticsErrorRsponse:3 playerState:playerStatus withPlayer:player withConfigModel:config withPD:playedDuration withDuration:streamDuration withBufferDuration:bufferDuration streamPostion:streamPostion streamDuration:streamDuration streamingInfo:streamingInfo playerVolume:playerVolume];
                    }
                    
                    [self writeAnalyticsInDocumnet:analyticInfo];
                    if(error.code == 5555) return;
                    completionBlock(nil, error);
                }
                else if(error.code != 5555)
                {
                    if([streamingInfo.strSS length] == 0) {
                        
                        streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:config.mediaId];
                        
                        analyticInfo = [self formatAnalyticsErrorRsponse:4 playerState:playerStatus withPlayer:player withConfigModel:config withPD:playedDuration withDuration:streamDuration withBufferDuration:bufferDuration streamPostion:streamPostion streamDuration:streamDuration streamingInfo:streamingInfo playerVolume:playerVolume];
                    }
                    
                    [self writeAnalyticsInDocumnet:analyticInfo];
                    completionBlock(nil, SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, self->strError));
                }
            });
        }];
        
    } else {
       
        [self writeAnalyticsInDocumnet:analyticInfo];
        
        if(nTotalPlayedTimestamp > 0) {
            double CurrentTimeNew = CACurrentMediaTime();
            nTotalPlayedDuration = (NSInteger)CurrentTimeNew  - nTotalPlayedTimestamp;
            
            if(playerStatus == 4) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_MSEC), self.writerDispatchQueue, ^{
                    [self loadAnalyticInfoFromDocToServer:config];
                });
            }
            else if(nTotalPlayedDuration > [SlikeDeviceSettings sharedSettings].serverPingInterval) {
                dispatch_async(self.writerDispatchQueue, ^{
                    [self loadAnalyticInfoFromDocToServer:config];
                    self->nTotalPlayedTimestamp = CACurrentMediaTime();
                    self->nTotalPlayedDuration = 0;
                });
                
            }
            
        } else {
            dispatch_async(self.writerDispatchQueue, ^{
                double CurrentTimeNew = CACurrentMediaTime();
                self->nTotalPlayedTimestamp = CurrentTimeNew;
                [self loadAnalyticInfoFromDocToServer:config];
            });
        }
    }
}

/**
 Update the analytics response
 
 @param dict - Response dictonary
 @param streamingInfo - Streaming info
 @param mediaId - Midea Id
 */
- (void)updateAnalyticsResponse:(NSDictionary *)dict streamingInfo:(StreamingInfo *)streamingInfo configModel:(NSString *)mediaId   {
    
    if([dict stringForKey:@"ss"]){
        streamingInfo.strSS = [dict stringForKey:@"ss"];
    }
    else if([streamingInfo.strSS length] == 0) {
        streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:mediaId];
    }
    if([dict stringForKey:@"ts"]){
        streamingInfo.strTS = [dict stringForKey:@"ts"];
    }
    if([dict stringForKey:@"interval"]) {
        [[SlikeDeviceSettings sharedSettings] setServerPingInterval:[[dict stringForKey:@"interval"] integerValue]];
        
        if([dict objectForKey:@"playstat"]) {
            [[SlikeDeviceSettings sharedSettings] setServerPlayStatus:[[dict stringForKey:@"playstat"] integerValue]];
        }
    }
}

- (NSString *)formatAnalyticsErrorRsponse:(NSInteger)responseCode  playerState:(NSInteger)playerStatus withPlayer:(id<ISlikePlayer>)player withConfigModel:(SlikeConfig *) config withPD:(NSInteger)playedDuration withDuration:(NSInteger)duration withBufferDuration:(NSInteger)bufferDuration streamPostion:(NSInteger) streamPostion streamDuration:(NSInteger) streamDuration streamingInfo:(StreamingInfo *)streamingInfo playerVolume:(BOOL) playerVolume {
    
    float vol = [self getTheDeviceVolume];
    
    NSString *analyticInfo = @"";
    
    if (responseCode ==0) {
        
        analyticInfo = [NSString stringWithFormat:@"stats?%@at=%ld&bd=%ld&pd=%ld&et=%ld&fid=%@&il=%@&ps=%@%@%@&ia=%@&ha=%i&vl=%f&du=%ld&m=%d&usid=%@&ispr=%d", self.strPrefix, (long)playerStatus, (long)bufferDuration, (long)playedDuration, playerStatus == 4? (long)streamDuration : (long)streamPostion, [player getCurrentFlavour], config.streamingInfo.isLive ? @"1" : @"0", [player isFullScreen] ? @"5" : @"1",[self getVARegularString:config withAdCall:NO],streamingInfo.strMeta,streamingInfo.isAudio ? @"1" : @"0",config.isSkipAds == NO ? 1: -2,vol*100,(long)streamDuration,playerVolume,[[SlikeDeviceSettings sharedSettings] getUserSession : config],config.ispr];
        
    } else if (responseCode == 1) {
        
        analyticInfo = [NSString stringWithFormat:@"stats?%@at=%ld&bd=%ld&pd=%ld&et=%ld&fid=%@&il=%@&ps=%@%@%@&ia=%@&ha=%i&vl=%f&m=%d&usid=%@&ispr=%d", self.strPrefix, (long)playerStatus, (long)bufferDuration, (long)playedDuration, playerStatus == 4 ? (long)streamDuration : (long)streamPostion, [player getCurrentFlavour], config.streamingInfo.isLive ? @"1" : @"0", [player isFullScreen] ? @"5" : @"1",[self getVARegularString:config withAdCall:NO],streamingInfo.strMeta,streamingInfo.isAudio ? @"1" : @"0",config.isSkipAds == NO ? 1: -2,vol*100,playerVolume,[[SlikeDeviceSettings sharedSettings] getUserSession : config],config.ispr];
        
    } else if (responseCode == 2) {
        
        analyticInfo = [NSString stringWithFormat:@"stats?%@at=%ld&bd=%ld&pd=%ld&et=%ld&fid=%@&il=%@&ps=%@%@%@&ia=%@&ha=%i&vl=%f&m=%d&usid=%@&ispr=%d", self.strPrefix, (long)playerStatus, (long)bufferDuration, (long)playedDuration, playerStatus == 4 ? (long)streamDuration : (long)streamPostion, [player getCurrentFlavour], config.streamingInfo.isLive ? @"1" : @"0", [player isFullScreen] ? @"5" : @"1",[self getVARegularString:config withAdCall:NO],streamingInfo.strMeta,streamingInfo.isAudio ? @"1" : @"0",config.isSkipAds == NO ? 1: -2,vol*100,playerVolume,[[SlikeDeviceSettings sharedSettings] getUserSession : config],config.ispr];
        
    } else if (responseCode ==3) {
        
        analyticInfo = [NSString stringWithFormat:@"stats?%@at=%ld&bd=%ld&pd=%ld&et=%ld&fid=%@&il=%@&ps=%@%@%@&ia=%@&ha=%i&vl=%f&m=%d&usid=%@&ispr=%d", self.strPrefix, (long)playerStatus, (long)bufferDuration, (long)playedDuration, playerStatus == 4 ? (long)streamDuration : (long)streamPostion, [player getCurrentFlavour], config.streamingInfo.isLive ? @"1" : @"0", [player isFullScreen] ? @"5" : @"1",[self getVARegularString:config withAdCall:NO],streamingInfo.strMeta,streamingInfo.isAudio ? @"1" : @"0",config.isSkipAds == NO ? 1: -2,vol*100,playerVolume,[[SlikeDeviceSettings sharedSettings] getUserSession : config],config.ispr];
        
    } else if (responseCode ==4) {
        
        analyticInfo = [NSString stringWithFormat:@"stats?%@at=%ld&bd=%ld&pd=%ld&et=%ld&fid=%@&il=%@&ps=%@%@%@&ia=%@&ha=%i&vl=%f&m=%d&usid=%@&ispr=%d", self.strPrefix, (long)playerStatus, (long)bufferDuration, (long)playedDuration, playerStatus == 4 ? (long)streamDuration : (long)streamPostion, [player getCurrentFlavour], config.streamingInfo.isLive ? @"1" : @"0", [player isFullScreen] ? @"5" : @"1",[self getVARegularString:config withAdCall:NO],streamingInfo.strMeta,streamingInfo.isAudio ? @"1" : @"0",config.isSkipAds == NO ? 1: -2,vol*100,playerVolume,[[SlikeDeviceSettings sharedSettings] getUserSession : config],config.ispr];
    }
    if(config.isPrerollEnabled == OFF)
    {
        analyticInfo = [NSString stringWithFormat:@"%@&skpr=1",analyticInfo];
    }
    
    if(config.isPostrollEnabled == OFF)
    {
        analyticInfo = [NSString stringWithFormat:@"%@&skps=1",analyticInfo];
    }
    
    return analyticInfo;
}


- (void)writeErrorInDocumnet:(NSString*)errorText {
    
    __block NSString *errorString = [NSString stringWithFormat:@"%@", errorText];
    dispatch_async(self.writerDispatchQueue, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *documentTXTPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",@"error_info"]];
        NSString *savedString = errorString;
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:documentTXTPath];
        if(myHandle == nil) {
            [[NSFileManager defaultManager] createFileAtPath:documentTXTPath contents:nil attributes:nil];
            myHandle = [NSFileHandle fileHandleForWritingAtPath:documentTXTPath];
            
        } else {
            savedString=[NSString stringWithFormat:@"\n%@",errorString];
        }
        
        [myHandle seekToEndOfFile];
        [myHandle writeData:[savedString dataUsingEncoding:NSUTF8StringEncoding]];
        [myHandle closeFile];
    });
}

- (NSString*)readErrorFromDocumnt {
    
    NSString *content=@"";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",@"error_info"]];
    content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    return content;
}

- (void)sendErrorLogToServerUp {
    
    //Check Server Ping Status-
    [self serverPingStatus:SL_COMPLETED withCompletionBlock:^(id obj, NSError *error) {
        NSString * string =  (NSString*)obj;
        
        if(string) {
            NSDictionary *dict = [SlikeUtilities jsonStringToDictionary:string];
            SlikeDLog(@"hahaha %@",dict);
            
            if(dict != (id)[NSNull null]) {
                if([dict objectForKey:@"body"]) dict = [dict objectForKey:@"body"];
                
                if(dict && [dict objectForKey:@"status"] && [[dict objectForKey:@"status"] intValue] == 1) {
                    NSString *errorInformation = [self readErrorFromDocumnt];
                    SlikeDLog(@"errorInformation-> %@",errorInformation);
                    
                    if(errorInformation && errorInformation!=nil && ![errorInformation isKindOfClass:[NSNull class]]) {
                        
                        errorInformation = [errorInformation stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                        errorInformation = [errorInformation stringByReplacingOccurrencesOfString:@"&&" withString:@"`"];
                        errorInformation = [errorInformation stringByReplacingOccurrencesOfString:@"&" withString:@"`"];
                        
                        if(self->strAnalyticsBaseURL != nil && self->strAnalyticsBaseURL.length == 0) return;
                        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        
                        NSString*  webString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(                                                                                                                      NULL,(CFStringRef)errorInformation,                                              NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",                                         kCFStringEncodingUTF8 ));
                        
                        NSString *aUrl = [NSString stringWithFormat:@"%@multistats?%@", self->strAnalyticsBaseURL,webString];
                        NSString* webStringURL = [aUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
                        
                        NSURL* url = [NSURL URLWithString:webStringURL];
                        [self removeFileFromLocal];
                        SlikeDLog(@"urlurlurlurlurl-> %@",url);
                        
                        [[SlikeNetworkManager defaultManager] requestURL:url type:NetworkHTTPMethodPOST completion:^(NSData *data, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
                            
                            if(data != nil) {
                                
                                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                if(string) {
                                    
                                    NSDictionary *dict = [SlikeUtilities jsonStringToDictionary:string];
                                    
                                    if(dict)
                                    {
                                        SlikeDLog(@"==> SS = %@",dict);
                                    }
                                    else {
                                        [self writeErrorInDocumnet:errorInformation];
                                    }
                                    
                                } else {
                                    [self writeErrorInDocumnet:errorInformation];
                                }
                            } else if(error) {
                                [self writeErrorInDocumnet:errorInformation];
                                if(error.code == 5555) return;
                            }
                            else {
                                [self writeErrorInDocumnet:errorInformation];
                            }
                        }];
                    }else
                    {
                        SlikeDLog(@"Data not found");
                    }
                }
                else
                {
                    //Server is not up--
                }
            }
        }
    }];
    
}

- (void)loadAnalyticInfoFromDocToServer:(SlikeConfig *)configModel {
    
    if(strAnalyticsBaseURL == nil || [strAnalyticsBaseURL length] == 0 ) return;
    
    nTotalPlayedTimestamp = CACurrentMediaTime();
    
    if(isServerUp) {
        
        __block  NSString *strData = [self readAnalyticsFromDocumnt];
        
        if([strData isValidString]) {
            
            NSString *aUrl = [NSString stringWithFormat:@"%@multistats?%@", strAnalyticsBaseURL,[SlikeUtilities endcodeAndFormatString:strData]];
            NSString* webStringURL = [aUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSURL* url = [NSURL URLWithString:webStringURL];
            
            [self removeAnalyticFileFromLocal];
            if(ENABLE_LOG)
            {
            NSLog(@"urlurlurlurlurl-> %@",url);
            }
            [[SlikeNetworkManager defaultManager] requestURL:url type:NetworkHTTPMethodPOST completion:^(NSData *data, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
                
                SlikeDLog(@"status code -> %ld",(long)statusCode);
                if(statusCode != 200) {
                    [self writeAnalyticsInDocumnet:strData];
                    self->isServerUp = NO;
                } else {
                    
                    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSDictionary *jsondict = [SlikeUtilities jsonStringToDictionary:string];
                    
                    if([jsondict dictionaryForKey:@"body"]) {
                        NSDictionary *dict = [jsondict dictionaryForKey:@"body"];
                        if ([dict isValidDictonary]) {
                            
                            SlikeDLog(@"Video %@",dict);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [self updateTsAndSsParameters:dict configModel:configModel];
                                self->isServerUp = YES;
                            });
                        }
                    }
                }
                
            }];
        }
    } else {
        
        [self serverPingStatus:1 withCompletionBlock:^(id obj, NSError *error) {
            NSString * string =  (NSString*)obj;
            if(string) {
                NSDictionary *dict = [SlikeUtilities jsonStringToDictionary:string];
                SlikeDLog(@"Video %@",dict);
                if(dict != (id)[NSNull null])
                {
                    if([dict objectForKey:@"body"]) dict = [dict objectForKey:@"body"];
                    if(dict && [dict objectForKey:@"status"] && [[dict objectForKey:@"status"] intValue] == 1) {
                        dispatch_async(self.writerDispatchQueue, ^{
                            self->isServerUp =  YES;
                            [self loadAnalyticInfoFromDocToServer:configModel];
                        });
                        
                    }
                }
            }
        }];
    }
}

/**
 Update the TS and SS parameters
 
 @param dict - Source Dictonary
 @param configModel - COnfig Model
 */
- (void)updateTsAndSsParameters:(NSDictionary *)dict configModel:(SlikeConfig *)configModel  {
    
    if([dict isValidDictonary] && configModel !=nil && ![configModel isKindOfClass:[NSNull class]]) {
        
        StreamingInfo *streamingInfo = configModel.streamingInfo;
        if(![streamingInfo isKindOfClass:[NSNull class]])
        {
            if([dict stringForKey:@"ss"]) {
                
                if([dict stringForKey:@"ss"]) {
                    streamingInfo.strSS = [dict stringForKey:@"ss"];
                }
                else if([streamingInfo.strSS length] == 0) {
                    streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:configModel.mediaId];
                }
                
                if([dict stringForKey:@"ts"]) {
                    streamingInfo.strTS = [dict stringForKey:@"ts"];
                }
                
                if([dict stringForKey:@"interval"]) {
                    
                    [[SlikeDeviceSettings sharedSettings] setServerPingInterval:[[dict stringForKey:@"interval"] integerValue]];
                    
                    if([dict stringForKey:@"playstat"]) {
                        [[SlikeDeviceSettings sharedSettings] setServerPlayStatus:[[dict stringForKey:@"playstat"] integerValue]];
                    }
                }
            }
        }
    }
}

#pragma mark - Gif and Vebr analytics
- (void)sendEmbededPlayerAnalyticsToServer:(NSString *)analyticInfo  withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock {
    
    NSString *baseUrl = strAnalyticsBaseURL;
    NSString *analyticInfoString = [NSString stringWithFormat:@"savelogs?%@%@", analyticInfo, [[SlikeDeviceSettings sharedSettings] getSlikeAnalyticsCache]];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",baseUrl, analyticInfoString];
    
    SlikeDLog(@"EMBEDED PLAYER- Analytics - %@ ", requestUrl);
    
    [[SlikeNetworkManager defaultManager] requestURL:[NSURL URLWithString:requestUrl] type:NetworkHTTPMethodGET completion:^(NSData *data, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
        if(statusCode !=200) {
            completionBlock(nil, SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, self->strError));
        }
        else if(data != nil) {
            
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if(string) {
                
                completionBlock(string, nil);
            }
        }
        else if(error && error.code != 5555) {
            completionBlock(nil, error);
        }
        else if(error.code != 5555) {
            completionBlock(nil, SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, self->strError));
        }
    }];
}


#pragma mark-  Directory Path

- (void)writeAnalyticsInDocumnet:(NSString*)analyticSrcString {
    
    __block NSString *analyticString = [NSString stringWithFormat:@"%@", analyticSrcString];
    dispatch_async(self.writerDispatchQueue, ^{
        analyticString = [analyticString stringByReplacingOccurrencesOfString:@"?"
                                                                   withString:@"~~"];
        time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
        analyticString =  [NSString stringWithFormat:@"%@&ets=%ld",analyticString, unixTime*1000];
        
        if([analyticString isValidString] && analyticString) {
            
            @synchronized(self) {
                NSString *documentTXTPath = [self directoryPathForAnalytics];
                NSString *savedString = analyticString;
                NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:documentTXTPath];
                if(myHandle == nil) {
                    [[NSFileManager defaultManager] createFileAtPath:documentTXTPath contents:nil attributes:nil];
                    myHandle = [NSFileHandle fileHandleForWritingAtPath:documentTXTPath];
                } else {
                    savedString = [NSString stringWithFormat:@"\n%@",savedString];
                }
                [myHandle seekToEndOfFile];
                
                @try {
                    [myHandle writeData:[savedString dataUsingEncoding:NSUTF8StringEncoding]];
                }
                @catch (NSException *e) {
                }
                [myHandle closeFile];
                
            }
        }
    });
}

- (NSString*)readAnalyticsFromDocumnt {
    
    NSString *content=@"";
    NSString *filePath = [self directoryPathForAnalytics];
    content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    return content;
}

- (NSString *)directoryPathForAnalytics {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",@"slike_analytic_info"]];
    
    return filePath;
}

- (void)removeAnalyticFileFromLocal {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self directoryPathForAnalytics];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (!success) {
        SlikeDLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

- (void)removeFileFromLocal {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentTXTPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",@"error_info"]];    NSError *error;
    [fileManager removeItemAtPath:documentTXTPath error:&error];
}

/**
 Check the server Ping status
 
 @param status - Status
 @param completionBlock - COmpletion block
 */
- (void)serverPingStatus :(NSInteger) status withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock {
    
    NSString *aUrl = [NSString stringWithFormat:@"%@%@", strAnalyticsBaseURL,@"check"];
     aUrl = [aUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [[SlikeNetworkManager defaultManager] requestURL:[NSURL URLWithString:aUrl] type:NetworkHTTPMethodGET completion:^(NSData *data, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
        
        if (statusCode == 200) {
            
            NSMutableDictionary * dict =  [NSMutableDictionary dictionary];
            NSDictionary *statusInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"status", nil];
            [dict setObject:statusInfo forKey:@"body"];
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                               options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                                 error:&error];
            
            if (! jsonData) {
                SlikeDLog(@"Got an error: %@", error);
            } else {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSString *responseString = jsonString;
                completionBlock(responseString, nil);
                return ;
                
            }
        }
        else if(data != nil) {
            
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            completionBlock(responseString, nil);
            return ;
        }
        else if(error) {
            SlikeDLog(@"Error: %@",error.description);
            SlikeDLog(@"Error: %ld",(long)error.code);
            completionBlock(@"", error);
            return ;
        }
        else {
            
            self->isServerUpInitHit = NO;
            completionBlock(@"", error);
            return ;
        }
    }];
}


-(void)afterDelayHit {
    [[SlikeNetworkManager defaultManager]  sendErrorLogToServerUp];
}
#pragma marck Prectch Ad analyic
- (void)sendPreFetchAnalyticLog:(NSString *)analyticInfo  withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock {
    
    NSString *baseUrl = strAnalyticsBaseURL;
    NSString *analyticInfoString = [NSString stringWithFormat:@"adstats?%@%@", analyticInfo, [[SlikeDeviceSettings sharedSettings] getSlikeAnalyticsCache]];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",baseUrl, analyticInfoString];
    if(ENABLE_LOG)
    {
        NSLog(@"Sanajay_Ad_Log  Pre %@",analyticInfoString);
    }
    
    [[SlikeNetworkManager defaultManager] requestURL:[NSURL URLWithString:requestUrl] type:NetworkHTTPMethodGET completion:^(NSData *data, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(statusCode !=200) {
                completionBlock(nil, SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, self->strError));
            }
            else if(data != nil) {
                
                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if(string) {
                    
                    SlikeDLog(@"Prefetch/ad response  - %@ ", string);
                    //[self writeAnalyticsInDocumnet:analyticInfo];
                    completionBlock(string, nil);
                }
            }
            else if(error && error.code != 5555) {
                completionBlock(nil, error);
            }
            else if(error.code != 5555) {
                completionBlock(nil, SlikeServiceCreateError(SlikeServiceErrorWrongConfiguration, self->strError));
            }
        });
        
    }];
}


#pragma mark - Downlaod the Images
- (UIImage*)getImageForURL:(NSURL*)url completion:(void(^)( UIImage *image,
                                                           NSString *localFilepath,
                                                           BOOL isFromCache,
                                                           NSInteger statusCode,
                                                           NSError *error))completion {
    if (!url) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil, YES, 901, [self errorForNilURL]);
            });
        }
        
        return nil;
    }
    
    if ([url isKindOfClass:[NSURL class]] &&
        [[[self class] imageCache] objectForKey:url]) {
        // there is already an image in our cache so return this image
        // Download not necessary
        // we also call the completion block
        UIImage * image = [[[self class] imageCache] objectForKey:url];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image,nil,YES,image != nil ? 200 : 404, nil);
            });
        }
        return image;
    }
    
    if ([self hasCachedFileForURL:url]) {
        
        dispatch_async(kDownloadGCDQueue, ^{
            
            NSString *filepath = [self cachedFilePathForURL:url];
            NSError *error = nil;
            NSData *data = [NSData dataWithContentsOfFile:filepath options:NSDataReadingMappedIfSafe error:&error];
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                [[[self class] imageCache] setObject:image forKey:url];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(image, filepath, YES, error == nil ? 200 : 404, error);
                    
                    [self isDownloadNecessaryForURL:url completion:^(BOOL needsDownload) {
                        if (needsDownload) {
                            [self requestImageAtURL:url completion:completion];
                        }
                    }];
                }
            });
        });
    } else {
        [self requestImageAtURL:url completion:completion];
    }
    
    return nil;
}

- (void)requestImageAtURL:(NSURL*)url  completion:(void(^)(UIImage *image,
                                                           NSString *localFilepath,
                                                           BOOL isFromCache,
                                                           NSInteger statusCode,
                                                           NSError *error))completion {
    
    [self requestURLProtocolCachePolicy:url type:NetworkHTTPMethodGET completion:^(NSData *data, NSString *localFilepath, BOOL
                                                                                   isFromCache, NSInteger statusCode, NSError *error) {
        dispatch_async(kDownloadGCDQueue, ^{
            
            UIImage *image = nil;
            if (url && data) {
                
                image = [UIImage imageWithData:data];
                if (image.size.width < 2 || image.size.height < 2) {
                    image = nil;
                }
                
                if (image) {
                    [[[self class] imageCache] setObject:image forKey:url];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(image, localFilepath, isFromCache, statusCode, error);
                }
            });
        });
    }];
}

- (void)requestURLProtocolCachePolicy:(NSURL*)url type:(NetworkHTTPMethod)method completion:(void(^)(NSData *data,
                                                                                                     NSString *localFilepath,
                                                                                                     BOOL isFromCache,
                                                                                                     NSInteger statusCode,
                                                                                                     NSError *error))completion {
    if(!url) {
        completion(nil, nil, NO, 901, SlikeServiceCreateErrorWithDomain([[NSBundle mainBundle] bundleIdentifier], SlikeServiceErrorWrongConfiguration, [NSDictionary dictionaryWithObjectsAndKeys:@"Information", @"message", @"Data not available.", @"description", nil]));
        return;
    }
    
    NSData *postData = nil;
    NSString *postLength = nil;
    if(method == NetworkHTTPMethodPOST) {
        
        NSString *strURL = [url absoluteString];
        NSArray *arr = [strURL componentsSeparatedByString:@"?"];
        if(arr.count == 2)
        {
            url = [NSURL URLWithString:[arr objectAtIndex:0]];
            strURL = [arr objectAtIndex:1];
            postData = [strURL dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            postLength = [NSString stringWithFormat:@"%ld",(unsigned long)[postData length]];
            
        }
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:url
                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval:kDownloadTimeout];
    
    [request setHTTPShouldHandleCookies:isHandleCookies];
    
    switch (method) {
        case NetworkHTTPMethodGET:
            [request setHTTPMethod:@"GET"];
            break;
        case NetworkHTTPMethodPOST:
            [request setHTTPMethod:@"POST"];
            if(postData)
            {
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
                [request setHTTPBody:postData];
            }
            break;
        case NetworkHTTPMethodDELETE:
            [request setHTTPMethod:@"DELETE"];
            break;
        case NetworkHTTPMethodPUT:
            [request setHTTPMethod:@"PUT"];
            break;
        default:
            [request setHTTPMethod:@"GET"];
            break;
    }
    
    [self sendRequest:request completion:completion];
}
-(NSInteger)getSrcType:(NSString*)streamId
{
    //v=  src value
    NSInteger v = -1;
    NSString *src = @"";
    NSArray * srcComponent = [streamId componentsSeparatedByString:@"."];
    if(srcComponent.count>1)
    {
        src = [srcComponent firstObject];
    }
    if(src !=nil && [src length]>0)
    {
        if([src isEqualToString:@"hl"])
        {
        }else  if([src isEqualToString:@"dr"])
        {
        }
        else  if([src isEqualToString:@"m4"])
        {
        }
        else  if([src isEqualToString:@"yt"])
        {
            v =  1;
        }
        else  if([src isEqualToString:@"vb"])
        {
            v =  4;
        }
        else  if([src isEqualToString:@"fb"])
        {
        }
        else  if([src isEqualToString:@"dm"])
        {
            v =  6;
        }
        else  if([src isEqualToString:@"ds"])
        {
        }
        else  if([src isEqualToString:@"m3"])
        {

        }else  if([src isEqualToString:@"gf"])
        {
        }
        else  if([src isEqualToString:@"me"])
        {
        }
        else  if([src isEqualToString:@"un"])
        {
        }
    }
    return v;
}
@end
