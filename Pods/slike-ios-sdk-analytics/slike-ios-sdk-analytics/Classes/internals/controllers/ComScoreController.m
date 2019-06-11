//
//  ComScoreController.m
//  ComScore-SCORBundle
//
//  Created by Aravind kumar on 9/29/17.
//

#import "ComScoreController.h"

//#define publisher_ID @"6036484"
//#define publisher_Secret @"db32bf9205278a4af70d41ece515f7fc"

@interface ComScoreController ()
{
    
}
@property(nonatomic,strong) NSString *publisher_ID;

@end

@implementation ComScoreController


-(void)addComScoreMetaDataAd:(SlikeConfig*)config adLength:(NSInteger)ad_length  adType:(NSInteger)adtype  PlayerStatus:(SlikePlayerState) state
{

    SCORReducedRequirementsStreamingAnalytics *streamingAnalytics = [[SCORReducedRequirementsStreamingAnalytics alloc] init];
    
    NSMutableDictionary *infoDict =  [NSMutableDictionary dictionary];
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
    [infoDict setValue:appName forKey:@"ns_ap_an"];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    [infoDict setValue:bundleIdentifier forKey:@"ns_ap_bi"];
    if(config.cs_publisherId != nil && ![config.cs_publisherId isKindOfClass:[NSNull class]])
    {
        [infoDict setValue:config.cs_publisherId forKey:@"c2"];
    }else
    {
        [infoDict setValue:@"" forKey:@"c2"];
        
    }
    if(config.c3 !=nil && ![config.c3 isKindOfClass:[NSNull class]])
    {
        [infoDict setValue:config.c3 forKey:@"c3"];
    }else
    {
        [infoDict setValue:@"" forKey:@"c3"];
    }
    [infoDict setValue:@"" forKey:@"c4"];
    [infoDict setValue:@"" forKey:@"c6"];
    if(config.mediaId !=nil && ![config.mediaId isKindOfClass:[NSNull class]])
    {
        [infoDict setValue:config.mediaId forKey:@"ns_st_ci"];
    }else
    {
        [infoDict setValue:@"" forKey:@"ns_st_ci"];
    }
    [infoDict setValue:[NSString stringWithFormat:@"%ld",(long)config.streamingInfo.nDuration] forKey:@"ns_st_cl"];
    
    [infoDict setValue:@"SlikePlayer" forKey:@"ns_st_st"];
    if(config.channel !=nil && ![config.channel isKindOfClass:[NSNull class]])
    {
    [infoDict setValue:config.channel forKey:@"ns_st_pu"];
    }else
    {
        [infoDict setValue:@"" forKey:@"ns_st_pu"];
    }
    
    if(config.streamingInfo.strTitle != nil && [config.streamingInfo.strTitle isKindOfClass:[NSString class]] &&[config.streamingInfo.strTitle length] >0)
        [infoDict setValue:config.streamingInfo.strTitle forKey:@"ns_st_pr"];
    else
        [infoDict setValue:config.title forKey:@"ns_st_pr"];
    
    [infoDict setValue:@"" forKey:@"ns_st_ep"];
    [infoDict setValue:@"" forKey:@"ns_st_sn"];
    [infoDict setValue:@"" forKey:@"ns_st_en"];
    if(config.pageSection !=nil && ![config.pageSection isKindOfClass:[NSNull class]])
    {
    [infoDict setValue:config.pageSection forKey:@"ns_st_ge"];
    }else
    {
        [infoDict setValue:@"" forKey:@"ns_st_ge"];
    }
    [infoDict setValue:@"" forKey:@"ns_st_ti"];
    [infoDict setValue:@"0" forKey:@"ns_st_ia"];
    [infoDict setValue:@"1" forKey:@"ns_st_ce"];
    [infoDict setValue:@"" forKey:@"ns_st_ddt"];
    [infoDict setValue:@"" forKey:@"ns_st_tdt"];
    
    [infoDict setValue:[NSString stringWithFormat:@"%ld",(long)ad_length] forKey:@"ns_st_cl"];
    if(state == SL_START)
    {
    
if(adtype ==  0)
{//pre
    [streamingAnalytics playVideoAdvertisementWithMetadata:infoDict andMediaType:SCORAdTypeLinearOnDemandPreRoll];

}else  if(adtype ==  -1)
{
    //post
    [streamingAnalytics playVideoAdvertisementWithMetadata:infoDict andMediaType:SCORAdTypeLinearOnDemandPostRoll];

}else
{
    [streamingAnalytics playVideoAdvertisementWithMetadata:infoDict andMediaType:SCORAdTypeLinearOnDemandMidRoll];
}
    }
if(state == SL_COMPLETED || state == SL_SKIPPED)
{
    [streamingAnalytics stop];
}
    
}
-(void)addComScoreMetaDataVideo:(SlikeConfig*)config PlayerStatus:(SlikePlayerState) state
{
    NSLog(@"Video-> %ld",(long)state);
    SCORReducedRequirementsStreamingAnalytics *streamingAnalytics = [[SCORReducedRequirementsStreamingAnalytics alloc] init];
    
    NSMutableDictionary *infoDict =  [NSMutableDictionary dictionary];
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
    [infoDict setValue:appName forKey:@"ns_ap_an"];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    [infoDict setValue:bundleIdentifier forKey:@"ns_ap_bi"];
    if(config.cs_publisherId !=nil && ![config.cs_publisherId isKindOfClass:[NSNull class]])
    {
    [infoDict setValue:config.cs_publisherId forKey:@"c2"];
    }else
    {
        [infoDict setValue:@"" forKey:@"c2"];

    }
    if(config.c3 !=nil && ![config.c3 isKindOfClass:[NSNull class]])
    {
    [infoDict setValue:config.c3 forKey:@"c3"];
    }else
    {
        [infoDict setValue:@"" forKey:@"c3"];
    }
    [infoDict setValue:@"" forKey:@"c4"];
    [infoDict setValue:@"" forKey:@"c6"];
    if(config.mediaId !=nil && ![config.mediaId isKindOfClass:[NSNull class]])
    {
        [infoDict setValue:config.mediaId forKey:@"ns_st_ci"];
    }else
    {
        [infoDict setValue:@"" forKey:@"ns_st_ci"];
    }
    [infoDict setValue:[NSString stringWithFormat:@"%ld",(long)config.streamingInfo.nDuration] forKey:@"ns_st_cl"];
    
    [infoDict setValue:@"SlikePlayer" forKey:@"ns_st_st"];
    if(config.channel !=nil && ![config.channel isKindOfClass:[NSNull class]])
    {
        [infoDict setValue:config.channel forKey:@"ns_st_pu"];
    }else
    {
        [infoDict setValue:@"" forKey:@"ns_st_pu"];
    }
    if(config.streamingInfo.strTitle != nil && [config.streamingInfo.strTitle isKindOfClass:[NSString class]] &&[config.streamingInfo.strTitle length] >0)
        [infoDict setValue:config.streamingInfo.strTitle forKey:@"ns_st_pr"];
    else
        [infoDict setValue:config.title forKey:@"ns_st_pr"];
    
    [infoDict setValue:@"" forKey:@"ns_st_ep"];
    [infoDict setValue:@"" forKey:@"ns_st_sn"];
    [infoDict setValue:@"" forKey:@"ns_st_en"];
    
    if(config.pageSection !=nil && ![config.pageSection isKindOfClass:[NSNull class]])
    {
        [infoDict setValue:config.pageSection forKey:@"ns_st_ge"];
    }else
    {
        [infoDict setValue:@"" forKey:@"ns_st_ge"];
    }
    [infoDict setValue:@"" forKey:@"ns_st_ti"];
    [infoDict setValue:@"0" forKey:@"ns_st_ia"];
    [infoDict setValue:@"1" forKey:@"ns_st_ce"];
    [infoDict setValue:@"" forKey:@"ns_st_ddt"];
    [infoDict setValue:@"" forKey:@"ns_st_tdt"];
    if(state == SL_LOADED || state == SL_START || state == SL_PLAY || state == SL_REPLAY)
    {
if(config.streamingInfo.isLive)
{
    
    [streamingAnalytics playVideoContentPartWithMetadata:infoDict andMediaType:SCORContentTypeLive];


}else
{
    if(config.streamingInfo.nDuration > 600)
    {
        [streamingAnalytics playVideoContentPartWithMetadata:infoDict andMediaType:SCORContentTypeLongFormOnDemand];
    }else
    {
    [streamingAnalytics playVideoContentPartWithMetadata:infoDict andMediaType:SCORContentTypeShortFormOnDemand];
    }
}
    }else if(state == SL_COMPLETED || state ==  SL_PAUSE)
    {
        [streamingAnalytics stop];
    }
}

-(void) setId:(NSString*)strId subId:(NSString*)strSubId Type:(AnalyticMode)type
{
    if(type == AnalyticMode_COMSCORE)
    {
        self.publisher_ID = strId;
    }
}
-(void) initializeData
{
}
-(id) init:(NSString*)strId subId:(NSString*)strSubId Type:(AnalyticMode)type
{
    if (self = [super init])
    {
        [self setId:strId subId:strSubId Type:type];
    }
    return self;
    
}
-(id) init:(id) tracker
{
    if (self = [super init])
    {
    }
    return self;
}
-(AnalyticMode) getType
{
    return AnalyticMode_COMSCORE;
}
-(NSString*) getId
{
    return self.publisher_ID;
}

-(void)sendEvent:(NSString*)category Action:(NSString*)action Label:(NSString*)label Value:(NSNumber*)value
{
    
}

@end
