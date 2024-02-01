//
//  AnalyticController.m
//  Pods
//
//  Created by Aravind kumar on 5/25/17.
//
//

#import "SlikeAnalytics.h"
#import "SlikeNetworkManager.h"
#import "SlikeAnalyticInformation.h"
#import "ISlikeAnlytics.h"
#import "SlikePlayer.h"
#import "ISlikeAnlytics.h"
#import "EventManagerProtocol.h"
#import "EventManager.h"
#import "SlikePlayerConstants.h"
#import "NSDictionary+Validation.h"
#import "SlikeSharedDataCache.h"
#import "SlikeAdEvent.h"
#import "SlikePlayerEvent.h"

@interface SlikeAnalytics () <EventManagerProtocol> {
    
    NSInteger nTotalBufferDuration;
    NSInteger nTotalPlayedDuration;
    NSInteger nTotalBufferTimestamp;
    NSInteger nTotalPlayedTimestamp;
    BOOL  isPlayerFullScreen;
    NSInteger rpc;
    BOOL isPause;
    SlikePlayerState previousState;
    BOOL isUserPlay;
    NSInteger nTotalVideoPlayedDuration;
}

@property (nonatomic, weak) id<ISlikePlayer>player;
@property (nonatomic, assign) SlikeEventType eventType;
@property (nonatomic, assign) SlikePlayerState playerState;
@property(nonatomic,weak) SlikeConfig *slikeconfig;
@property(nonatomic,assign) BOOL isCompleted;
@property(nonatomic,assign) BOOL isFirstTimePlay;
@property(nonatomic,assign) BOOL resetPd;
@property(nonatomic,assign) BOOL resetAdPlayedPd;
@property(nonatomic,strong) NSString *current_rid;
@property(nonatomic, assign) NSInteger nActaulPlayedDuration;
@property(nonatomic, assign) NSInteger isPersentageDurationSended;
@property (strong, nonatomic) dispatch_queue_t queue;
@property (nonatomic, assign) NSInteger nPlayerCurrentTime;


- (void)sendData:(SlikePlayerState) status forced:(BOOL) forced withPlayer:(id<ISlikePlayer>) player config:(SlikeConfig*)configModel withCurrentPlayerTime:(NSInteger)pCurrentTime;
- (void)_addComScoreMetaDataVideo:(SlikeConfig*)config PlayerStatus:(SlikePlayerState) state;
- (void)resetAllAnalytics;

@end

@implementation SlikeAnalytics

#pragma mark - Init & Dealloc
- (void)registerAnalyticsToListenEvents {
    [[EventManager sharedEventManager]registerEvent:self];
}

- (instancetype)init {
    self = [super init];
    self.queue = dispatch_queue_create("com.slike.analytics.event.queue", DISPATCH_QUEUE_SERIAL);
    self.isPersentageDurationSended =  NO;
    return self;
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static SlikeAnalytics *shared = nil;
    dispatch_once(&onceToken, ^{
        shared = [[[self class] alloc] init];
    });
    return shared;
}

/**
 Reset the Data
 */
- (void)resetData {
    nTotalBufferDuration = 0;
    nTotalPlayedDuration = 0;
    nTotalBufferTimestamp = 0;
    nTotalPlayedTimestamp = 0;
    self.nActaulPlayedDuration = 0;
}

/**
 Reset all the alalytics data
 */
- (void)resetAllAnalytics {
    [self resetData];
    [SlikeAnalytics sharedManager].isPersentageDurationSended = NO;
    self.slikeconfig=nil;
    _isFirstTimePlay = FALSE;
    _resetPd=YES;
    self.resetAdPlayedPd=FALSE;
    _isCompleted=NO;
    nTotalBufferDuration = 0;
    nTotalPlayedDuration = 0;
    nTotalBufferTimestamp = 0;
    nTotalPlayedTimestamp = 0;
    isPlayerFullScreen=NO;
    rpc=0;
    isUserPlay=FALSE;
    nTotalVideoPlayedDuration =  0;
    [[SlikeSharedDataCache sharedCacheManager]updateTotalVideoPlayedDuration:nTotalVideoPlayedDuration];
    previousState = SL_COMPLETED;
    isPause=NO;
}


/**
 Send data to server
 
 @param status - Player Status
 @param forced - is Forecfully - Send data imediatily
 @param player - Current Player
 @param configModel -  Config Model
 */

- (void)sendData:(SlikePlayerState) status forced:(BOOL) forced withPlayer:(id<ISlikePlayer>) player config:(SlikeConfig*)configModel withCurrentPlayerTime:(NSInteger)pCurrentTime{
    
    if (configModel) {
        self.slikeconfig = configModel;
    }
    
    if(status == SL_START || status == SL_READY || status == SL_PLAY ) {
        [[SlikeDeviceSettings sharedSettings] getUserSession : self.slikeconfig];
    }
    
    if(self.resetPd) {
        isPause = YES;
        self.resetPd = NO;
    }
    
    if(self.isFirstTimePlay) {
        rpc = 0;
        self.isFirstTimePlay = NO;
    }
    
    if(status == SL_REPLAY)
    {
        [[SlikeDeviceSettings sharedSettings] setVideoRid:configModel.mediaId];
    }
    
    if(previousState == SL_COMPLETED && status == SL_ENDED && status != SL_START && status != SL_READY && previousState != SL_REPLAY) {
        return;
    }
//    if(previousState == SL_ENDED) {
//        return;
//    }
    previousState=status;
    
    SlikeDLog(@"strSS ===>>> : %@", self.slikeconfig.streamingInfo.strSS);
    
    if([self.slikeconfig.streamingInfo.strSS length] == 0) {
        self.slikeconfig.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:self.slikeconfig.mediaId];
    }
    
    NSInteger nStatus = 3;
    if(status ==  SL_READY) {
        [self resetData];
    }
    else if(self.isCompleted && status ==SL_SEEKING) {
        
        //Reset to After replay-
        nTotalBufferDuration = 0;
        nTotalPlayedDuration = 0;
        double currentTime = CACurrentMediaTime()*1000;
        nTotalBufferTimestamp = (NSInteger)currentTime;
        nTotalPlayedTimestamp = (NSInteger)currentTime;
        self.isCompleted = NO;
        //Change for replay--
        rpc++;
        self.slikeconfig.streamingInfo.strSS = @"";
        if([self.slikeconfig.streamingInfo.strSS length] == 0)
            self.slikeconfig.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:self.slikeconfig.mediaId];
        status = SL_READY;
    }
    else  if(self.isCompleted && status ==SL_REPLAY)
    {
        [self sendEvent:@"VIDEOREPLAY" Action:[self _getActionForCurrentVideoSource] Label:[self _getLabelForCurrentVideoSource]];
        
        [self sendEvent:@"VIDEOREQUEST" Action:[self _getActionForCurrentVideoSource] Label:[self _getLabelForCurrentVideoSource]];
        
        [self _addComScoreMetaDataVideo:self.slikeconfig PlayerStatus:status];
        
        nTotalBufferDuration = 0;
        nTotalPlayedDuration = 0;
        nTotalVideoPlayedDuration =  0;
        [[SlikeSharedDataCache sharedCacheManager]updateTotalVideoPlayedDuration:nTotalVideoPlayedDuration];
        
        double currentTime = CACurrentMediaTime()*1000;
        nTotalBufferTimestamp = (NSInteger)currentTime;
        nTotalPlayedTimestamp = (NSInteger)currentTime;
        self.isCompleted = NO;
        //Change for replay--
        rpc++;
        self.slikeconfig.streamingInfo.strSS = @"";
        if([self.slikeconfig.streamingInfo.strSS length] == 0)
            self.slikeconfig.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:self.slikeconfig.mediaId];
        status = SL_READY;
    }
    
    if(status == SL_FSEXIT) {
        isPlayerFullScreen = NO;
    }
    else if(status == SL_FSENTER) {
        isPlayerFullScreen = YES;
    }
    if(status == SL_VIDEO_REQUEST)
    {
        nTotalVideoPlayedDuration =  0;
        [[SlikeSharedDataCache sharedCacheManager]updateTotalVideoPlayedDuration:nTotalVideoPlayedDuration];
        [self sendEvent:@"VIDEOREQUEST" Action:[self _getActionForCurrentVideoSource] Label:[self _getLabelForCurrentVideoSource]];
        nStatus = 105;
    }
    else if(status == SL_READY)
    {
        nTotalVideoPlayedDuration =  0;
        [[SlikeSharedDataCache sharedCacheManager]updateTotalVideoPlayedDuration:nTotalVideoPlayedDuration];
        [self sendEvent:@"VIDEOREADY" Action:[self _getActionForCurrentVideoSource] Label:[self _getLabelForCurrentVideoSource]];
        nStatus = 1;
    }
    else if(status == SL_START || status == SL_LOADED)
    {
        nStatus = 2;
        nTotalVideoPlayedDuration =  0;
        [[SlikeSharedDataCache sharedCacheManager]updateTotalVideoPlayedDuration:nTotalVideoPlayedDuration];
        [self _addComScoreMetaDataVideo:self.slikeconfig PlayerStatus:status];
        if(status == SL_START)
        {
            if(_isCompleted)
                
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_MSEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self sendEvent:@"VIDEOVIEW" Action:[self _getActionForCurrentVideoSource] Label:[self _getLabelForCurrentVideoSource]];
                });
                
            }else
            {
                [self sendEvent:@"VIDEOVIEW" Action:[self _getActionForCurrentVideoSource] Label:[self _getLabelForCurrentVideoSource]];
            }
        }
    }
    else if(status == SL_PLAYING)
    {
        nStatus = 3;
        if(self.isCompleted) {
            return;
        }
    }
    else if(status == SL_VIDEOPLAYED)
    {
        nStatus = 14;
    }
    else if(status == SL_COMPLETED)
    {
        nStatus = 4;
        if(!self.isCompleted)
        {
            [self _addComScoreMetaDataVideo:self.slikeconfig PlayerStatus:status];
            [self sendEvent:@"VIDEOENDED" Action:[self _getActionForCurrentVideoSource] Label:[self _getLabelForCurrentVideoSource]];
        }else
        {
            return;
        }
        
    }
    else if(status == SL_VIDEO_COMPLETED)
    {
        nStatus = 16;
        [self sendEvent:@"VIDEOCOMPLETE" Action:[self _getActionForCurrentVideoSource] Label:[self _getLabelForCurrentVideoSource]];
        
    }
    else if(status == SL_REPLAY)
    {
        nStatus = 5;
        
    }
    else if(status == SL_PAUSE)
    {
        nStatus = 6;
        [self sendEvent:@"VIDEOPAUSE" Action:[self _getActionForCurrentVideoSource] Label:[self _getLabelForCurrentVideoSource]];
        
        [self _addComScoreMetaDataVideo:self.slikeconfig PlayerStatus:status];
    }
    else if(status == SL_SEEKED)
    {
        nStatus = 7;
        [self sendEvent:@"VIDEOSEEK" Action:[self _getActionForCurrentVideoSource] Label:[self _getLabelForCurrentVideoSource]];
        
    }
    else if(status == SL_QUALITYCHANGE)
    {
        nStatus = 8;
        [self sendEvent:@"VIDEOQUALITYCHNAGED" Action:[self _getActionForCurrentVideoSource] Label:[self _getLabelForCurrentVideoSource]];
        
    }
    else if(status == SL_BUFFERING)
    {
        nStatus = 9;
    }
    else if(status == SL_PLAY)
    {
        nStatus = 10;
        [self sendEvent:@"VIDEOPLAY" Action:[self _getActionForCurrentVideoSource] Label:[self _getLabelForCurrentVideoSource]];
        
        [self _addComScoreMetaDataVideo:self.slikeconfig PlayerStatus:status];
    }
    else if(status == SL_FSENTER)
    {
        nStatus = 11;
        [self sendEvent:@"VIDEOFULLSCREEN" Action:[self _getActionForCurrentVideoSource] Label:[self _getLabelForCurrentVideoSource]];
    }
    else if ( status == SL_FSEXIT )
    {
        nStatus = 11;
    }
    else if ( status == SL_ENDED)
    {
        nStatus = 12;
        [self _addComScoreMetaDataVideo:self.slikeconfig PlayerStatus:status];
    }
    
    BOOL isPdCalculate =  YES;
    if(nStatus == 4) {
        self.isCompleted = YES;
    }
    
    if(nStatus == 1 || nStatus == 2 || nStatus == 10 || nStatus == 8 || nStatus == 7|| isPause || nStatus == 105) {
        nTotalBufferDuration = 0;
        nTotalPlayedDuration = 0;
        double currentTime = CACurrentMediaTime()*1000;
        nTotalBufferTimestamp = (NSInteger)currentTime;
        nTotalPlayedTimestamp = (NSInteger)currentTime;
        
        if(isPause) {
            isPause=NO;
        }
        isPdCalculate =  NO;
    }
    else if(nStatus == 9)
    {
        double currentTime = CACurrentMediaTime()*1000;
        nTotalBufferDuration = (NSInteger)currentTime - nTotalBufferTimestamp;
    }
    else if(nStatus == 6)
    {
        isPause = YES;
    }
    
    double CurrentTime1 = CACurrentMediaTime()*1000;
    if(isPdCalculate) {
        nTotalPlayedDuration = (NSInteger)CurrentTime1  - nTotalPlayedTimestamp;
    }
    else {
        nTotalPlayedDuration = 0;
    }
    
    if(status != SL_LOADED) {
        
        if(!self.resetAdPlayedPd) {
            nTotalVideoPlayedDuration =  nTotalVideoPlayedDuration + nTotalPlayedDuration;
            [[SlikeSharedDataCache sharedCacheManager]updateTotalVideoPlayedDuration:nTotalVideoPlayedDuration];
        } else {
            self.resetAdPlayedPd =  NO;
        }
        
        SlikeAnalyticInformation *info = [[SlikeAnalyticInformation alloc] initWithAnalyticInformation:status isForced:forced withPlayTime:nTotalPlayedDuration withBD:nTotalBufferDuration withConfig:self.slikeconfig withReplayCount:rpc withRId: [[SlikeDeviceSettings sharedSettings] getVideoRid]];
        
        VideoSourceType currentMediaSource = [self.slikeconfig.streamingInfo getCurrentVideoSource];
        if( currentMediaSource == VIDEO_SOURCE_YT || currentMediaSource == VIDEO_SOURCE_DM || currentMediaSource == VIDEO_SOURCE_FB) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[SlikeNetworkManager defaultManager] sendAnalyticsModelDataToServer:info withPlayer:player withCurrentPlayerTime:pCurrentTime];
            });
            
        } else {
            
            //Send data to server
            dispatch_async(self.queue, ^() {
                [[SlikeNetworkManager defaultManager] sendAnalyticsModelDataToServer:info withPlayer:player withCurrentPlayerTime:pCurrentTime];
            });
        }
        
        self.nActaulPlayedDuration = self.nActaulPlayedDuration + nTotalPlayedDuration;
        
        if (self.nActaulPlayedDuration >=0 && self.slikeconfig.streamingInfo.nDuration>0 && !self.slikeconfig.streamingInfo.isLive ) {
            
            if(self.nActaulPlayedDuration*100/self.slikeconfig.streamingInfo.nDuration > 94 && !self.isPersentageDurationSended) {
                
                self.isPersentageDurationSended = YES;
                SlikeAnalyticInformation *info = [[SlikeAnalyticInformation alloc] initWithAnalyticInformation:SL_PLAYEDPERCENTAGE isForced:YES withPlayTime:nTotalPlayedDuration withBD:nTotalBufferDuration withConfig:self.slikeconfig withReplayCount:rpc withRId: [[SlikeDeviceSettings sharedSettings] getVideoRid]];
                dispatch_async(self.queue, ^() {
                    [[SlikeNetworkManager defaultManager] sendAnalyticsModelDataToServer:info withPlayer:player withCurrentPlayerTime:pCurrentTime];
                });
            }
        }
        
    }
    
    double currentMediaTime = CACurrentMediaTime()*1000;
    nTotalBufferTimestamp = (NSInteger)currentMediaTime;
    nTotalPlayedTimestamp = (NSInteger)currentMediaTime;
    
    nTotalBufferDuration = 0;
    nTotalPlayedDuration = 0;
    
    if(nStatus == 8) {
        isPause = YES;
    }
    
    if(nStatus == 7 && [self.slikeconfig.streamingInfo getCurrentVideoSource] == VIDEO_SOURCE_YT) {
        isPause = YES;
    }
}

- (NSString*)_getActionForCurrentVideoSource {
    
    NSString *returnString =  @"";
    if(self.slikeconfig.streamingInfo != nil)
    {
        returnString = [NSString stringWithFormat:@"%@/%@/%@/%ld",[SlikeUtilities getVideoTitle:self.slikeconfig],self.slikeconfig.streamingInfo.vendorName,self.slikeconfig.streamingInfo.isLive?@"LIVE":@"VOD",(long)self.slikeconfig.streamingInfo.nDuration];
        
    }else
    {
        returnString = [NSString stringWithFormat:@"%@/%@/%@/%ld",[SlikeUtilities getVideoTitle:self.slikeconfig],@"",@"",(long)self.slikeconfig.streamingInfo.nDuration];
        
        //        returnString = [NSString stringWithFormat:@"%@/%@/%@/%@",[SlikeUtilities getVideoTitle:self.slikeconfig],@"",@"",[SlikeUtilities formatTime:self.slikeconfig.streamingInfo.nDuration / 1000]];
    }
    return returnString;
}
- (NSString*)_getLabelForCurrentVideoSource {
    
    NSString *returnString =  @"";
    NSString * section = self.slikeconfig.section;
    
    if(section == nil || [section isEqualToString:@""])
    {
        section = self.slikeconfig.screenName;
    }
    //change later for top middle and bottom
    NSString *videoPostion =  @"";
    NSString *pageTemp =  self.slikeconfig.pageTemplate;
    pageTemp =  [pageTemp stringByReplacingOccurrencesOfString:@"/" withString:@"."];
    returnString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@",@"IOS",self.slikeconfig.business,section,pageTemp,videoPostion,self.slikeconfig.isAutoPlay?@"autoplay":@"user-gen"];
    return returnString;
}

- (void)sendEvent:(NSString*)category Action:(NSString*)action Label:(NSString*)label {
    //NSLog(@"category = %@ || action = %@ || label = %@",category,action,label);
    NSArray *trackers =  [[SlikePlayerSettings playerSettingsInstance] getAnalyticsTrackers];
    if(trackers == nil) return;
    id <ISlikeAnlytics> slikeAnalytics;
    for(slikeAnalytics in trackers) {
        [slikeAnalytics sendEvent:category Action:action Label:label Value:nil];
    }
}

- (void)addComScoreMetaDataAd:(SlikeConfig*)config adLength:(NSInteger)ad_length  adType:(NSInteger)adtype  adStatus:(NSInteger) state {
    
    id <ISlikeAnlytics> slikeAnalytics = [[SlikePlayerSettings playerSettingsInstance] getComScoreAnalyticsTrackers];
    if(slikeAnalytics == nil) return;
    [slikeAnalytics addComScoreMetaDataAd:config adLength:ad_length adType:adtype adStatus:(NSInteger) state];
}

- (void)_addComScoreMetaDataVideo:(SlikeConfig*)config PlayerStatus:(SlikePlayerState) state {
    
    id <ISlikeAnlytics> slikeAnalytics = [[SlikePlayerSettings playerSettingsInstance] getComScoreAnalyticsTrackers];
    if(slikeAnalytics == nil) return;
    [slikeAnalytics addComScoreMetaDataVideo:config PlayerStatus:state];
}
#pragma mark
-(void)processVideoRequest:(SlikeConfig*)slikeConfigModel
{
    SLEventModel *eventModel = [SLEventModel createEventModel:SlikeAnalyticsTypeMedia withBehaviorEvent:SlikeUserBehaviorEventNone withPayload:nil];
    eventModel.slikeConfigModel = slikeConfigModel;
    self.eventType = MEDIA;
    self.playerState = SL_VIDEO_REQUEST;
    self.slikeconfig = eventModel.slikeConfigModel;
    [self _processAVPlayerAnalytics:eventModel];
}
-(NSString*)sendSlikePlayerAnalytics:(SlikeEventType)eventType playerState:(SlikePlayerState)state dataPayload:(SLEventModel *)eventModel withCurrentPlayerTime:(NSInteger)pCurrentTime
{
    
    if (![self isValidAnalyticsEvent:state]) {
        return  self.slikeconfig.streamingInfo.strSS;
    }
    if (!eventModel) {
        return  self.slikeconfig.streamingInfo.strSS;
    }
    self.nPlayerCurrentTime = pCurrentTime;
    self.eventType = eventType;
    self.playerState = state;
    if([eventModel.slikeConfigModel.streamingInfo.strSS length] == 0)
    {
        self.slikeconfig = eventModel.slikeConfigModel;
        self.slikeconfig.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:self.slikeconfig.mediaId];
    }
    if (eventType == MEDIA) {
        
        if (eventModel.analyticsType == SlikeAnalyticsTypeMedia) {
            [self _processAVPlayerAnalytics:eventModel];
            
        } else if (eventModel.analyticsType == SlikeAnalyticsTypeEmbed) {
            [self _processEmbededAnalytics:eventModel];
            
        } else if (eventModel.analyticsType == SlikeAnalyticsTypeGif) {
            [self _processGIFAnalytics:eventModel];
            
        } else if (eventModel.analyticsType == SlikeAnalyticsTypeMeme) {
            [self _processMemeAnalytics:eventModel];
            
        } else if (eventModel.analyticsType == SlikeAnalyticsTypeRumble) {
            [self _processRumbleAnalytics:eventModel];
        }
        
    } else if (eventType == AD && eventModel.analyticsType == SlikeAnalyticsTypeAVPlayerAd ) {
        [self _processAdAnalytics:eventModel];
    } else if (eventType == AD && eventModel.analyticsType == SlikeAnalyticsTypeRumbleAd ) {
        [self _processRumbleAdAnalytics:eventModel];
    }
    return  self.slikeconfig.streamingInfo.strSS;
}
#pragma mark - EventManagerProtocol
- (void)update:(SlikeEventType)eventType playerState:(SlikePlayerState)state dataPayload:(NSDictionary *)payload slikePlayer:(id<ISlikePlayer>)player {
    
    if (![self isValidAnalyticsEvent:state]) {
        return;
    }
    
    SLEventModel *eventModel = payload[kSlikeEventModelKey];
    if (!eventModel) {
        return;
    }
    self.eventType = eventType;
    self.playerState = state;
    self.slikeconfig = eventModel.slikeConfigModel;
    if (player && [player conformsToProtocol:@protocol(ISlikePlayer)]) {
        self.player = player;
    }
    
    if (eventType == MEDIA) {
        
        if (eventModel.analyticsType == SlikeAnalyticsTypeMedia) {
            [self _processAVPlayerAnalytics:eventModel];
            
        } else if (eventModel.analyticsType == SlikeAnalyticsTypeEmbed) {
            [self _processEmbededAnalytics:eventModel];
            
        } else if (eventModel.analyticsType == SlikeAnalyticsTypeGif) {
            [self _processGIFAnalytics:eventModel];
            
        } else if (eventModel.analyticsType == SlikeAnalyticsTypeMeme) {
            [self _processMemeAnalytics:eventModel];
            
        } else if (eventModel.analyticsType == SlikeAnalyticsTypeRumble) {
            [self _processRumbleAnalytics:eventModel];
        }
        
    } else if (eventType == AD && eventModel.analyticsType == SlikeAnalyticsTypeAVPlayerAd ) {
        [self _processAdAnalytics:eventModel];
    } else if (eventType == AD && eventModel.analyticsType == SlikeAnalyticsTypeRumbleAd ) {
        [self _processRumbleAdAnalytics:eventModel];
    }
    
}


/**
 Check if the event is valid for the analytics
 @param state - Player Event
 @return - YES|NO
 */
- (BOOL)isValidAnalyticsEvent:(SlikePlayerState)state {
    
    BOOL validEvent = YES;
    switch (state) {
        case SL_TIMELOADRANGE:
        case SL_SHARE:
        case SL_CLOSE:
        case SL_PREVIOUS:
        case SL_NEXT:
        case SL_LOADING:
        case SL_FULLSCREENCLICKED:
        case SL_HIDECONTROLS:
        case SL_SHOWCONTROLS:
        case SL_RESETCONTROLS:
        case SL_STATE_NONE:
        case SL_CONTENT_RESUME:
        case SL_CONTENT_PAUSE:
        case SL_PLAYER_DISTROYED:
        case SL_SEEKPOSTIONUPDATE:
        case SL_AD_REQUESTED:
        case SL_SET_NEXT_PLAYLIST_DATA:
        case SL_HIDE_NEXT_PLAYLIST_DATA:
            validEvent =NO;
            break;
        default:
            break;
    }
    
    return validEvent;
}


/**
 Process the avplayer Analytics
 @param eventModel - Event Model
 */
- (void)_processAVPlayerAnalytics:(SLEventModel *)eventModel  {
    //Need to discusswith sanjay sir
    
    
    BOOL isForce =  YES;
    if(self.playerState  == SL_PLAYING) {
        isForce =  NO;
    }
    
    if (self.playerState  == SL_READY && self.isCompleted) {
        self.isFirstTimePlay = YES;
        [self resetAllAnalytics];
    }
    else if (self.playerState  == SL_READY && self.isCompleted) {
        self.resetPd = YES;
        
    } else if (self.playerState  == SL_PLAY) {
        self.resetPd = YES;
    }
    else if (self.playerState  == SL_REPLAY) {
        self.resetPd = YES;
    }
    else if (self.playerState  == SL_SEEKED) {
        self.resetPd = YES;
    }
    
    if (eventModel) {
        
        if (self.playerState  == SL_PAUSE && eventModel.userBehaviorEvent != SlikeUserBehaviorEventPause) {
            self.playerState = SL_PLAYING;
        }
        
        if (self.playerState  == SL_PLAY && eventModel.userBehaviorEvent != SlikeUserBehaviorEventPlay) {
            self.playerState = SL_PLAYING;
        }
    }
    
    [self sendData:self.playerState forced:isForce withPlayer:self.player config:eventModel.slikeConfigModel withCurrentPlayerTime:self.nPlayerCurrentTime];
    
    if (eventModel) {
        if (self.playerState  == SL_PAUSE && eventModel.userBehaviorEvent == SlikeUserBehaviorEventPause) {
            self.resetPd = YES;
        }
    }
}

/**
 Process the Ad Analytics
 @param eventModel - Event Model
 */

-(void)sendGAAnalytics:(SLEventModel *)eventModel
{
    //    NSLog(@"returnString %@ == %@",eventModel.adEventModel.adStatusAnalytics,[self _getActionForCurrentAdSource:eventModel]);
    [self sendEvent:eventModel.adEventModel.adStatusAnalytics Action:[self _getActionForCurrentAdSource:eventModel] Label:[self _getLabelForCurrentAdSource:eventModel]];
}

/**
 Process the Ad Analytics
 @param eventModel - Event Model
 */

- (void)_processAdAnalytics:(SLEventModel *)eventModel {
    
    if([SlikeSharedDataCache sharedCacheManager].isGDPREnable) return;
    if(eventModel.adEventModel.adStatus != 3) {
        [self sendGAAnalytics:eventModel];
    }
    [self addComScoreMetaDataAd:eventModel.slikeConfigModel adLength:eventModel.adEventModel.adDuration adType:eventModel.adEventModel.slikeAdType adStatus:eventModel.adEventModel.adStatus];

    if(eventModel.adEventModel.adStatus == -1) return;
    
    [[SlikeNetworkManager defaultManager]sendAdLogToServer:eventModel.slikeConfigModel withStatus:eventModel.adEventModel.adStatus withAdID:eventModel.adEventModel.slikeAdId withAdCampaign:eventModel.adEventModel.adCampaign withRetryCount:eventModel.adEventModel.retryCount withMediaDuration:eventModel.adEventModel.mediaDuration withMediaPosition:eventModel.adEventModel.mediaPoistion withAdDuration:eventModel.adEventModel.adDuration andWithAdPosition:eventModel.adEventModel.adPosition DeviceVolume:eventModel.adEventModel.isVolumeOn DeviceVolumeLevel:eventModel.adEventModel.volumeLevel adMoreInformation:eventModel.adEventModel.adMoreInfo adLoadError:eventModel.adEventModel.errDespription addType:eventModel.adEventModel.slikeAdType strIu:eventModel.adEventModel.iu strAdResion:eventModel.adEventModel.adResgion withPreFetchInfo:eventModel.adEventModel.isAdPrefetched withPFID:eventModel.adEventModel.pfid withAdProvider:[NSString stringWithFormat:@"%ld",(long)eventModel.adEventModel.adProviderType] withCompletionBlock:nil];
}

- (NSString*)_getActionForCurrentAdSource :(SLEventModel *)eventModel
{
    
    NSString *returnString =  @"";
    NSString *adSource =  @"";
    NSString *adType =  @"";
    
    if(eventModel.adEventModel.adProviderType == 1)
    {
        adSource =  @"Google";
    }
    else if(eventModel.adEventModel.adProviderType == 3)
    {
        adSource =  @"FAN";
    }
    else
    {
        adSource =  @"3P";
    }
    
    if(eventModel.adEventModel.slikeAdType == 1)
    {
        adType =  @"pre-roll";
    }
    else if(eventModel.adEventModel.slikeAdType == 3)
    {
        adType =  @"post-roll";
    }
    else
    {
        adType =  @"mid-roll";
    }
    //{Ad title}/{Ad source-FAN/Google/3P}/{Advertizer}/{Ad type- video/banner}/{ad len}/{skippable/non-skippable}/{pre-roll/post-roll/mid-roll}/{ad-error-code}
    if(eventModel.adEventModel.errCode &&  [eventModel.adEventModel.errCode length]>0)
    {
        returnString = [NSString stringWithFormat:@"%@/%@/%@/%@/%ld/%@/%@/%@",eventModel.adEventModel.adTitle,adSource,eventModel.adEventModel.advertiserName,eventModel.adEventModel.contentType,(long)eventModel.adEventModel.adDuration,eventModel.adEventModel.isSkippable,adType,eventModel.adEventModel.errCode];
        
        
        // returnString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%ld/%@/%@",eventModel.adEventModel.adTitle,adSource,eventModel.adEventModel.advertiserName,eventModel.adEventModel.contentType,adType,(long)eventModel.adEventModel.adDuration,eventModel.adEventModel.isSkippable,eventModel.adEventModel.errCode];
        
    }else
    {
        returnString = [NSString stringWithFormat:@"%@/%@/%@/%@/%ld/%@/%@",eventModel.adEventModel.adTitle,adSource,eventModel.adEventModel.advertiserName,eventModel.adEventModel.contentType,(long)eventModel.adEventModel.adDuration,eventModel.adEventModel.isSkippable,adType];
    }
    return returnString;
}
- (NSString*)_getLabelForCurrentAdSource :(SLEventModel *)eventModel
{
    
    NSString *returnString =  @"";
    NSString * section = self.slikeconfig.section;
    
    if(section == nil || [section isEqualToString:@""])
    {
        section = self.slikeconfig.screenName;
    }
    //change later
    NSString *videoPostion =  @"";
    NSString *pageTemp =  self.slikeconfig.pageTemplate;
    pageTemp =  [pageTemp stringByReplacingOccurrencesOfString:@"/" withString:@"."];
    returnString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@",@"IOS",self.slikeconfig.business,section,pageTemp,videoPostion,self.slikeconfig.isAutoPlay?@"autoplay":@"user-gen"];
    return returnString;
}
//    {
//
//
//    NSString *returnString =  @"";
//    returnString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@",@"IOS",self.slikeconfig.section,self.slikeconfig.screenName,self.slikeconfig.pageTemplate,@"",self.slikeconfig.isAutoPlay?@"autoplay":@"user-gen"];
//    return returnString;
//}


/**
 Process the Embeded Player analytics
 @param eventModel - Event Model that contains information about the analytics
 */
- (void)_processEmbededAnalytics:(SLEventModel *)eventModel {
    
    if([SlikeSharedDataCache sharedCacheManager].isGDPREnable) return;
    
    NSString *analyticsString = [NSString stringWithFormat:@"type=%@&k=%@&ch=%@&tpr=%@&vid=%@&at=%@&rpc=%ld&src=%@&ss=%@&ts=%@&pt=%ld&stt=%ld&tb=%@%@",eventModel.playerEventModel.type, self.slikeconfig.mediaId, self.slikeconfig.channel, self.slikeconfig.product,self.slikeconfig.vendorID,eventModel.playerEventModel.eventType,(long)eventModel.playerEventModel.replayCount, self.slikeconfig.streamingInfo.vendorName, self.slikeconfig.streamingInfo.strSS, self.slikeconfig.streamingInfo.strTS, (long)[self.slikeconfig.streamingInfo getConstantValueForPlayerType], (long)[self.slikeconfig.streamingInfo getCurrentPlayer],self.slikeconfig.business,[self.slikeconfig toString]];
    
    NSString *finalRequestString = @"";
    if ([eventModel.playerEventModel.eventType isEqualToString:@"2"]) {
        finalRequestString = [NSString stringWithFormat:@"&urts=%ld&uopts=%ld",eventModel.playerEventModel.urts, eventModel.playerEventModel.uopts];
        analyticsString = [NSString stringWithFormat:@"%@%@",analyticsString,finalRequestString];
    }
    
    if(ENABLE_LOG)
    {
        //NSLog(@"analyticsString %@",analyticsString);
    }
    [self processAnalyticsRequest:analyticsString];
}

/**
 Process the Embeded Player analytics
 @param eventModel - Event Model that contains information about the analytics
 */
- (void)_processGIFAnalytics:(SLEventModel *)eventModel {
    
    if([SlikeSharedDataCache sharedCacheManager].isGDPREnable) return;
    
    NSString *analyticsString = [NSString stringWithFormat:@"type=%@&k=%@&ch=%@&tpr=%@&vid=%@&at=%@&pd=%ld&ss=%@&du=%ld&ts=%@&pt=%ld&stt=%ld&tb=%@%@", eventModel.playerEventModel.type, self.slikeconfig.mediaId, self.slikeconfig.channel,self.slikeconfig.product,self.slikeconfig.vendorID,eventModel.playerEventModel.eventType, eventModel.playerEventModel.playerPosition,self.slikeconfig.streamingInfo.strSS, (long)eventModel.playerEventModel.playerDuration, self.slikeconfig.streamingInfo.strTS, (long)eventModel.playerEventModel.playerType, (long)eventModel.playerEventModel.currentPlayer,self.slikeconfig.business,[self.slikeconfig toString]];
    
    [self processAnalyticsRequest:analyticsString];
    
}

/**
 Process the meme Player analytics
 @param eventModel - Event Model that contains information about the analytics
 */
- (void)_processMemeAnalytics:(SLEventModel *)eventModel {
    
    if([SlikeSharedDataCache sharedCacheManager].isGDPREnable) return;
    
    NSString *analyticsString = [NSString stringWithFormat:@"type=%@&k=%@&ch=%@&tpr=%@&vid=%@&at=%@&ss=%@&ts=%@&pt=%ld&stt=%ld&tb=%@%@",eventModel.playerEventModel.type, self.slikeconfig.mediaId, self.slikeconfig.channel,self.slikeconfig.product,self.slikeconfig.vendorID,
                                 eventModel.playerEventModel.eventType, self.slikeconfig.streamingInfo.strSS, self.slikeconfig.streamingInfo.strTS, (long)eventModel.playerEventModel.playerType, (long)eventModel.playerEventModel.currentPlayer,self.slikeconfig.business,[self.slikeconfig toString]];
    
    SlikeDLog(@"%@",analyticsString);
    
    [self processAnalyticsRequest:analyticsString];
}

/**
 Send the request to the server and Process the result
 @param urlRequest - Requested URL
 */
- (void)processAnalyticsRequest:(NSString *)urlRequest {
    
    if([SlikeSharedDataCache sharedCacheManager].isGDPREnable) return;
    
    [[SlikeNetworkManager defaultManager]sendEmbededPlayerAnalyticsToServer:urlRequest withCompletionBlock:^(id obj, NSError *error) {
        
        NSString *responseString = (NSString *)obj;
        NSDictionary *dict = [SlikeUtilities jsonStringToDictionary:responseString];
        if([dict isValidDictonary]) {
            
            NSDictionary *responseDict = [dict dictionaryForKey:@"body"];
            if (responseDict) {
                NSString *sessionString = [responseDict stringForKey:@"ss"];
                if (sessionString) {
                    self.slikeconfig.streamingInfo.strSS = sessionString;
                } else {
                    
                    self.slikeconfig.streamingInfo.strSS = [[SlikeDeviceSettings sharedSettings] genrateUniqueSSId:self.slikeconfig.mediaId];
                    self.slikeconfig.streamingInfo.strSS = self.slikeconfig.streamingInfo.strSS;
                }
                self.slikeconfig.streamingInfo.strTS = [responseDict stringForKey:@"ts"];
            }
        }
    }];
}

/**
 Process the Rumble Ads Analytics
 @param eventModel - Event Model
 */
- (void)_processRumbleAdAnalytics:(SLEventModel *)eventModel {
    SlikeDLog(@"_processRumbleAdAnalytics");
}

/**
 Process the meme Player analytics
 @param eventModel - Event Model that contains information about the analytics
 */
- (void)_processRumbleAnalytics:(SLEventModel *)eventModel {
    
    SlikeDLog(@"_processRumbleAnalytics - %ld", (long)eventModel.playerEventModel.playerState);
    if([SlikeSharedDataCache sharedCacheManager].isGDPREnable) return;
    [self _processEmbededAnalytics:eventModel];
}

@end
