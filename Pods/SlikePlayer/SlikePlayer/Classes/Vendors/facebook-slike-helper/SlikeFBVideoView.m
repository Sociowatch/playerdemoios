//
//  SlikeFBVideoView.m
//  fbPlayer
//
//  Created by Aravind kumar on 12/4/17.
//  Copyright © 2017 Aravind kumar. All rights reserved.
//

#import "SlikeFBVideoView.h"
#import "NSBundle+Slike.h"

NSString static *const kFBPlayerStateUnstartedCode = @"-1";
NSString static *const kFBPlayerStateEndedCode = @"0";
NSString static *const kFBPlayerStatePlayingCode = @"1";
NSString static *const kFBPlayerStatePausedCode = @"2";
NSString static *const kFBPlayerStateBufferingCode = @"3";
NSString static *const kFBPlayerStateCuedCode = @"5";
NSString static *const kFBPlayerStateUnknownCode = @"unknown";

// Constants representing Facebook player errors.
NSString static *const kFBPlayerErrorInvalidParamErrorCode = @"2";
NSString static *const kFBPlayerErrorHTML5ErrorCode = @"5";
NSString static *const kFBPlayerErrorVideoNotFoundErrorCode = @"100";
NSString static *const kFBPlayerErrorNotEmbeddableErrorCode = @"101";
NSString static *const kFBPlayerErrorCannotFindVideoErrorCode = @"105";
NSString static *const kFBPlayerErrorSameAsNotEmbeddableErrorCode = @"150";


NSString static *const kFBPlayerCallbackOnYouTubeIframeAPIReady = @"onFacebookIframeAPIReady";
NSString static *const kFBPlayerCallbackOnYouTubeIframeAPIFailedToLoad = @"onFacebookIframeAPIFailedToLoad";


@interface SlikeFBVideoView ()
{
    NSString *strAppID;
}
@property (nonatomic, strong) NSURL *originURL;
@property (nonatomic, weak) UIView *initialLoadingView;
@end

@implementation SlikeFBVideoView
- (void)awakeFromNib {
    [super awakeFromNib];
}
#pragma mark - Player methods

- (void)seek:(float)seekToSeconds{
    [self stringFromEvaluatingJavaScript:[NSString stringWithFormat:@"javascript:seekVideo(%f)", seekToSeconds]];
}
- (void)stop{
    [self stringFromEvaluatingJavaScript:@"javascript:stopVideo()"];
}
- (void)play{
    [self stringFromEvaluatingJavaScript:@"javascript:playVideo()"];
}

- (void)pause{
    // [self notifyDelegateOfYouTubeCallbackUrl:[NSURL URLWithString:[NSString stringWithFormat:@"fbplayer://onStateChange?data=%@", kFBPlayerStatePausedCode]]];
    [self stringFromEvaluatingJavaScript:@"javascript:pauseVideo()"];
}

- (void)mute{
    [self stringFromEvaluatingJavaScript:@"javascript:muteVideo()"];
}
-(void)playerMute:(BOOL)isMute
{
    if(isMute)
    {
        [self mute];
    }else
    {
        [self unmute];
    }
}
-(BOOL)getPlayerMuteStatus
{
    return [self isMuted];
}
- (void)unmute{
    [self stringFromEvaluatingJavaScript:@"javascript:unMuteVideo()"];
}

- (void)setVolume:(float) vol{
    [self stringFromEvaluatingJavaScript:[NSString stringWithFormat:@"javascript:setVolume(%f)", vol]];
}

- (float)getDuration{
    NSString *returnValue = [self stringFromEvaluatingJavaScript:@"javascript:console.log(getDuration())"];
    return [returnValue floatValue];
}

- (float)getVolume{
    NSString *returnValue = [self stringFromEvaluatingJavaScript:@"javascript:console.log(getVolume())"];
    return [returnValue floatValue];
}

- (BOOL)isMuted{
    NSString *returnValue = [self stringFromEvaluatingJavaScript:@"javascript:console.log(isMuted())"];
    return [returnValue boolValue];
}

- (float)getCurrentPosition{
    NSString *returnValue = [self stringFromEvaluatingJavaScript:@"javascript:console.log(getCurrentPosition())"];
    return [returnValue floatValue];
}

- (BOOL)loadWithVideoId:(nonnull NSString *)videoId withAppId:(nonnull NSString *) appId {
    strAppID = appId;
    return [self loadWithVideoId:videoId playerVars:nil];
}

- (BOOL)loadWithVideoId:(NSString *)videoId playerVars:(NSDictionary *)playerVars {
    /*if (!playerVars) {
     playerVars = @{};
     }*/
    
    NSDictionary *playerParams = @{@"app_id" : strAppID, @"video_url" : videoId, @"width" : [NSString stringWithFormat:@"%dpx", (int)self.frame.size.width], @"height" : [NSString stringWithFormat:@"%dpx", (int)self.frame.size.height]};
    
    return [self loadWithPlayerParams:playerParams];
}

- (BOOL)loadWithPlayerParams:(NSDictionary *)additionalPlayerParams {
    self.originURL = [NSURL URLWithString:@"https://facebook.com"];
    if(additionalPlayerParams == nil) return NO;
    // Remove the existing webView to reset any state
    [self.webView removeFromSuperview];
    _webView = [self createNewWebView];
    [self addSubview:self.webView];
    
    NSError *error = nil;
    //old
    //    NSString *path = [[NSBundle bundleForClass:[SlikeFBVideoView class]] pathForResource:@"facebook-slike-helper"
    //                                                                              ofType:@"html"
    //                                                                         inDirectory:@"ui"];
    
    
    NSBundle *nibBundle = [NSBundle slikeNibsBundle];
    NSString * path = [nibBundle pathForResource:@"facebook-slike-helper" ofType:@"html"];
    
    
    // but in framework bundle
    if (!path) {
        path = [[[self class] frameworkBundle] pathForResource:@"facebook-slike-helper"
                                                        ofType:@"html"
                                                   inDirectory:@"ui"];
    }
    
    NSString *embedHTMLTemplate =
    [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        SlikeDLog(@"Received error rendering template: %@", error);
        return NO;
    }
    NSString *key;
    NSString *value;
    for(key in additionalPlayerParams) {
        value = [additionalPlayerParams objectForKey:key];
        key = [NSString stringWithFormat:@"{%@}", key];
        embedHTMLTemplate = [embedHTMLTemplate stringByReplacingOccurrencesOfString:key withString:value];
    }
    
    [self.webView loadHTMLString:embedHTMLTemplate baseURL: self.originURL];
    [self.webView setDelegate:self];
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.mediaPlaybackRequiresUserAction = NO;
    [self.webView setOpaque:YES];
    self.webView.backgroundColor = [UIColor clearColor];
    
    if ([self.delegate respondsToSelector:@selector(playerViewPreferredInitialLoadingView:)]) {
        UIView *initialLoadingView = [self.delegate playerViewPreferredInitialLoadingView:self];
        if (initialLoadingView) {
            initialLoadingView.frame = self.bounds;
            initialLoadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self addSubview:initialLoadingView];
            self.initialLoadingView = initialLoadingView;
        }
    }
    
    return YES;
}

- (void)setWebView:(UIWebView *)webView {
    _webView = webView;
}

- (UIWebView *)createNewWebView {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.bounds];
    webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    webView.scrollView.scrollEnabled = NO;
    webView.scrollView.bounces = NO;
    
    webView.opaque = YES;
    webView.backgroundColor = [UIColor clearColor];
    if ([self.delegate respondsToSelector:@selector(playerViewPreferredWebViewBackgroundColor:)]) {
        webView.backgroundColor = [self.delegate playerViewPreferredWebViewBackgroundColor:self];
        if (webView.backgroundColor == [UIColor clearColor]) {
            webView.opaque = NO;
        }
    }
    
    return webView;
}

- (void)removeWebView {
    [self.webView removeFromSuperview];
    self.webView = nil;
}

- (NSString *)stringFromVideoIdArray:(NSArray *)videoIds {
    NSMutableArray *formattedVideoIds = [[NSMutableArray alloc] init];
    
    for (id unformattedId in videoIds) {
        [formattedVideoIds addObject:[NSString stringWithFormat:@"'%@'", unformattedId]];
    }
    
    return [NSString stringWithFormat:@"[%@]", [formattedVideoIds componentsJoinedByString:@", "]];
}

- (NSString *)stringFromEvaluatingJavaScript:(NSString *)jsToExecute {
    return [self.webView stringByEvaluatingJavaScriptFromString:jsToExecute];
}

- (NSString *)stringForJSBoolean:(BOOL)boolValue {
    return boolValue ? @"true" : @"false";
}

#pragma --
#pragma mark UIWebviewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([request.URL.scheme isEqual:@"fbplayer"]) {
        [self notifyDelegateOfYouTubeCallbackUrl:request.URL];
        return NO;
        
    } else {
        if ([self.delegate respondsToSelector:@selector(playerViewDidBecomeReady:)]) {
            [self.delegate playerViewDidBecomeReady:self];
        }
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [self.delegate playerView:self receivedError:kFBPlayerErrorUnknown];
    
    if (self.initialLoadingView) {
        [self.initialLoadingView removeFromSuperview];
        
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    float time = [self getDuration];
    [self.delegate playerView:self didPlayTime:time];
}
+ (NSBundle *)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"Assets.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}
#pragma mark - Private methods

/**
 * Private method to handle "navigation" to a callback URL of the format
 * fbplayer://action?data=someData
 * This is how the UIWebView communicates with the containing Objective-C code.
 * Side effects of this method are that it calls methods on this class's delegate.
 *
 * @param url A URL of the format ytplayer://action?data=value.
 */
- (void)notifyDelegateOfYouTubeCallbackUrl: (NSURL *) url {
    NSString *action = url.host;
    FBPlayerState state = kFBPlayerStateUnknown;
    if([action isEqualToString:@"error"])
    {
        if ([self.delegate respondsToSelector:@selector(playerView:receivedError:)])
        {
            [self.delegate playerView:self receivedError:kFBPlayerErrorUnknown];
            return;
        }
    }
    if ([self.delegate respondsToSelector:@selector(playerView:didChangeToState:)])
    {
        if([action isEqualToString:@"startedPlaying"])
        {
            state = kFBPlayerStatePlaying;
            //float duration =    [self getDuration];
        }
        if([action isEqualToString:@"startedBuffering"])
        {
            state = kFBPlayerStateBuffering;
        }
        if([action isEqualToString:@"paused"])
        {
            state = kFBPlayerStatePaused;
        }
        if([action isEqualToString:@"finishedPlaying"])
        {
            state = kFBPlayerStateEnded;
        }
        
        if([action isEqualToString:@"finishedBuffering"])
        {
            state = kFBPlayerStateEnded;
        }
        [self.delegate playerView:self didChangeToState:state];
        
    }
    
}


@end
