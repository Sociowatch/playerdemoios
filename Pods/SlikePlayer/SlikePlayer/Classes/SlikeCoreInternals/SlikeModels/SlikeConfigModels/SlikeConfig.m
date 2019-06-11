//
//  SlikeConfig.m
//  SlikePlayer
//
//  Created by TIL on 24/01/17.
//  Copyright (c) 2017 BBDSL. All rights reserved.
//

#import "SlikeConfig.h"
#import "NSString+Advanced.h"
#import "SlikeMediaPlayerControl.h"

@implementation SlikeConfig

- (instancetype)init {
    
    if (self = [super init]){
        [self initializeData];
    }
    return self;
}

- (void)initializeData {
    
    self.isBackGrounPlayEnable =  NO;
    self.isControlDisable = NO;
    self.gca = @"";
    self.gcb = @"";
    self.errorMsg = @"";
    self.isSkipAds = NO;
    self.isDocEnable =  NO;
    self.isCromeCastDisable =  NO;
    self.section = @"";
    self.vendorID = @"_";
    self.mediaId = @"";
    self.msId = @"";
    self.title = @"";
    self.channel = @"";
    self.business =  @"";
    self.gaId =  @"";
    self.cs_publisherId = @"";
    self.c3 = @"";
    self.ssoid = @"";
    self.posterImage = @"";
    self.streamingInfo = nil;
    self.adCleanupTime = 6000L;
    self.timecode = 0;
    self.isAutoPlay = YES;
    self.autorotationMode = SlikeFullscreenAutorotationModeDefault;
    self.isFullscreenControl = YES;
    self.isCloseControl = YES;
    self.isShareControl = YES;
    self.isNextControl = NO;
    self.isPreviousControl = NO;
    self.preferredVideoType = VIDEO_SOURCE_HLS;
    self.strLatLong = @"";
    self.country = @"";
    self.state = @"";
    self.city = @"";
    self.gender =@"";
    self.age = 0L;
    self.pid =  @"_";
    self.pageSection =  @"";
    self.shareText = @"";
    self.clipStart =  0L;
    self.clipEnd =  0L;
    self.videoPlayed =  3000L;
    self.adPlayed =  2000L;
    // self.playerVolume = 0.7f;
    self.sg =  @"";
    self.screenName =  @"";
    self.fbAppId =  @"";
    self.pageTemplate =  @"";
    self.fullScreenWindowColor =  [UIColor blackColor];
    self.allowConfigCache = YES;
    self.isAllowSlikePlaceHolder = NO;
    self.resetPlayerInformation =  NO;
    self.postRollPreFetchInterval=10000;
    self.gifInterval = 5000;
    self.adPrefetchEnable = NO;
    self.isApiGDPRAnalyticEnabled = NO;
    self.appVersion = @"";
    self.description_url = @"";
    self.packageName = @"";
    self.isAutoPlayNext = FALSE;
    self.previewsDndStartTime = 10;
    self.preview = FALSE;
    self.isPrerollEnabled = ON;
    self.isPostrollEnabled = ON;
    _nextVideoTitle = @"";
    _nextVideoThumbnail = @"";
    _qualityName = @[@"Auto", @"Low", @"Medium", @"High"];
    self.ispr =  FALSE;
    _isBitrateControl = YES;
    _enableCoachMark = NO;
    self.isNoNetworkCloseControlEnable =  NO;

}

- (id)initWithTitle:(NSString *) strTitle withID:(NSString *) strMediaId withSection:(NSString *) strSection withMSId:(NSString *) strMsId posterImage:(NSString*)strPosterImage {
    
    if (self = [super init]) {
        [self initializeData];
        self.title = strTitle == nil ? @"" : strTitle;
        self.mediaId = strMediaId == nil ? @"" : strMediaId;
        self.section = strSection == nil ? @"" : strSection;
        self.msId = strMsId == nil ? @"" : strMsId;
        self.posterImage = strPosterImage == nil ? @"" : strPosterImage;
    }
    return self;
}

+ (instancetype)createConfigForType:(VideoSourceType)playerType mediaTitle:(NSString *)title mediaURL:(NSString *)mediaURL posterURL:(NSString *)posterURLString isAutoPlay:(BOOL)autoPlay {
    
    SlikeConfig *configModel = [[SlikeConfig alloc]init];
    configModel.title = title == nil ? @"" : title;
    if([mediaURL hasPrefix:@"http"])
    {
        configModel.mediaId = mediaURL;
        configModel.msId = @"";
    }
    configModel.posterImage = posterURLString == nil ? @"" : posterURLString;
    configModel.preferredVideoType = playerType;
    configModel.autorotationMode = SlikeFullscreenAutorotationModeLandscape;
    configModel.isAllowSlikePlaceHolder = YES;
    configModel.isAutoPlay = autoPlay;
    
    StreamingInfo *streamingInfo = [StreamingInfo createStreamURL:mediaURL withType:playerType withTitle:configModel.title withSubTitle:@"" withDuration:0.0 withAds:nil];
    streamingInfo.mediaId = configModel.mediaId;
    streamingInfo.isExternalPlayer = YES;
    configModel.streamingInfo = streamingInfo;
    return configModel;
    
}

+ (instancetype)createConfigWithMediaId:(NSString *)mediaId isAutoPlay:(BOOL)autoPlay {
    SlikeConfig *configModel = [[SlikeConfig alloc]init];
    configModel.mediaId = mediaId;
    configModel.isAutoPlay = autoPlay;
    return configModel;
}

- (id)initWithChannel:(NSString *) strChannel withID:(NSString *) strMediaId withSection:(NSString *) strSection withMSId:(NSString *) strMsId posterImage:(NSString*)strPosterImage {
    
    if (self = [super init]) {
        [self initializeData];
        
        self.channel = strChannel == nil ? @"" : strChannel;
        self.mediaId = strMediaId == nil ? @"" : strMediaId;
        self.section = strSection == nil ? @"" : strSection;
        self.msId = strMsId == nil ? @"" : strMsId;
        self.posterImage = strPosterImage == nil ? @"" : strPosterImage;
        
    }
    return self;
}

- (id)initWithInfo:(StreamingInfo *)streamInfo withSection:(NSString *) strSection withMSId:(NSString *) strMsId {
    
    if (self = [super init]) {
        [self initializeData];
        self.title = streamInfo.strTitle;
        self.channel = streamInfo.strChannel;
        self.streamingInfo = streamInfo;
        self.section = strSection == nil ? @"" : strSection;
        self.msId = strMsId == nil ? @"" : strMsId;
    }
    return self;
}

- (NSString *)toString {
    
    NSString *str = [[self.section stringByReplacingOccurrencesOfString:@"/" withString:@"."] urlEncodedString];
    if(str.length > 0 && [str hasPrefix:@"."]) str = [str substringFromIndex:1];
    if(!self.ssoid) self.ssoid = @"";
    return [NSString stringWithFormat:@"&ssoid=%@&skipAds=%@&chs=%@&section=%@&ch=%@&msid=%@&tpr=%@&tb=%@&", self.ssoid, self.isSkipAds ? @"true" : @"false", str, str, [self.channel urlEncodedString], [self.msId urlEncodedString],self.product?self.product:@"",self.business];
}

- (void)setLatitudeLongitude:(NSString*)lat Longitude:(NSString*)lng {
    if(lat!=nil && lng!=nil) {
        self.strLatLong = [NSString stringWithFormat:@"%@,%@", lat, lng];
    } else {
        self.strLatLong = @"";
    }
}

- (void)setCountry_State_City:(NSString *)countryValue State:(NSString*)stateValue City:(NSString*)cityValue {
    
    if(countryValue!=nil)
        self.country = countryValue;
    if(stateValue!=nil)
        self.state = stateValue;
    if(cityValue!=nil)
        self.city = cityValue;
    
}

- (void)setUserInformation:(NSString*)genderValue Age:(NSInteger)ageValue {
    
    if(self.gender!=nil) {
        self.gender = genderValue;
    }
    if(ageValue != 0) {
        self.age = ageValue;
    }
}

-(void)dealloc {
    SlikeDLog(@"dealloc- Cleaning up SlikeConfig");
}

- (BOOL)isMediaThumbnailsAvailable {
    if (self.streamingInfo.thumbnailsInfoModel &&  ([self.streamingInfo.thumbnailsInfoModel.tileImageUrls count]>0 || [self.streamingInfo.thumbnailsInfoModel.thumbImages count]>0) ) {
        return YES;
    }
    return NO;
}

- (void)setIsCloseControl:(BOOL)isCloseControl {
    _isCloseControl = isCloseControl;
    if (self.customControls != nil && [self.customControls isKindOfClass:[SlikeMediaPlayerControl class]]) {
        [(SlikeMediaPlayerControl*)self.customControls updatePlayerConfigControl];
    }
}

@end
