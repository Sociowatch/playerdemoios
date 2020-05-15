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

@interface SlikeFBVideoView () {
    NSString *strAppID;
}

@property (nonatomic, strong) NSURL *originURL;
@property (nonatomic, weak) UIView *initialLoadingView;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) BOOL isMuted;
@property (nonatomic, assign) float position;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation SlikeFBVideoView

- (void)createTimer {
    [self stopTimer];
    if(self.timer == nil) {
        self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        [runner addTimer:self.timer forMode: NSDefaultRunLoopMode];
    }
}

- (void)stopTimer {
    if(self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerCallback:(NSTimer *) timer {
    if(!self) return;
    
    [self stringFromEvaluatingJavaScript:@"javascript:console.log(getCurrentPosition())" completion:^(NSString *message) {
        self.position = [message floatValue];
    }];
    
    [self stringFromEvaluatingJavaScript:@"javascript:console.log(getDuration())" completion:^(NSString *message) {
        self.duration = [message floatValue];
    }];

}

- (void)awakeFromNib {
    [super awakeFromNib];
    _duration = 0;
    _volume = 0;
    _isMuted = false;
    _position = 0;
}
#pragma mark - Player methods

- (void)seek:(float)seekToSeconds{
    [self stringFromEvaluatingJavaScript:[NSString stringWithFormat:@"javascript:seekVideo(%f)", seekToSeconds] completion:^(NSString *message) {
        
    }];
}
- (void)stop{
    [self stringFromEvaluatingJavaScript:@"javascript:stopVideo()" completion:^(NSString *message) {
        
    }];
}
- (void)play{
    [self stringFromEvaluatingJavaScript:@"javascript:playVideo()" completion:^(NSString *message) {
        
    }];
}

- (void)pause{
    // [self notifyDelegateOfYouTubeCallbackUrl:[NSURL URLWithString:[NSString stringWithFormat:@"fbplayer://onStateChange?data=%@", kFBPlayerStatePausedCode]]];
    [self stringFromEvaluatingJavaScript:@"javascript:pauseVideo()" completion:^(NSString *message) {
        
    }];
}

- (void)mute{
    [self stringFromEvaluatingJavaScript:@"javascript:muteVideo()" completion:^(NSString *message) {
        
    }];
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
- (void)unmute {
    [self stringFromEvaluatingJavaScript:@"javascript:unMuteVideo()" completion:^(NSString *message) {
        
    }];
}

- (void)setVolume:(float)vol {
    [self stringFromEvaluatingJavaScript:[NSString stringWithFormat:@"javascript:setVolume(%f)", vol] completion:^(NSString *message) {
    }];
}

- (float)getDuration {
    [self stringFromEvaluatingJavaScript:@"javascript:console.log(getDuration())" completion:^(NSString *message) {
        self.duration = [message floatValue];
    }];
    return _duration;
}

- (float)getVolume {
    [self stringFromEvaluatingJavaScript:@"javascript:console.log(getVolume())" completion:^(NSString *message) {
        self->_volume =  [message floatValue];
    }];
    return _volume;
}

- (BOOL)isMuted {
    [self stringFromEvaluatingJavaScript:@"javascript:console.log(isMuted())" completion:^(NSString *message) {
        self.isMuted = [message boolValue];
    }];
    return _isMuted;
}

- (float)getCurrentPosition {
    [self stringFromEvaluatingJavaScript:@"javascript:console.log(getCurrentPosition())" completion:^(NSString *message) {
        self.position = [message floatValue];
    }];
    return _position;
}

- (BOOL)loadWithVideoId:(nonnull NSString *)videoId withAppId:(nonnull NSString *) appId {
    strAppID = appId;
    if(!strAppID || [strAppID isEqualToString:@""]) {
        strAppID = @"258750801975729";
    }
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
    [self.webView setUIDelegate:self];
    [self.webView setNavigationDelegate:self];
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

- (void)setWebView:(WKWebView *)webView {
    _webView = webView;
}

- (WKWebView *)createNewWebView {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = true;
    configuration.requiresUserActionForMediaPlayback = false;
    configuration.allowsAirPlayForMediaPlayback = true;
    configuration.allowsPictureInPictureMediaPlayback = NO;
    WKWebView *playerWebView = [[WKWebView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height) configuration:configuration];
    playerWebView.opaque = NO;
    playerWebView.backgroundColor = [UIColor clearColor];
    
    // Hack: prevent vertical bouncing
    for (id subview in playerWebView.subviews) {
        if ([[subview class] isSubclassOfClass:[UIScrollView class]]) {
            ((UIScrollView *)subview).bounces = NO;
            ((UIScrollView *)subview).scrollEnabled = NO;
        }
    }
    playerWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    playerWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    playerWebView.scrollView.scrollEnabled = NO;
    playerWebView.scrollView.bounces = NO;
    
    if ([self.delegate respondsToSelector:@selector(playerViewPreferredWebViewBackgroundColor:)]) {
        playerWebView.backgroundColor = [self.delegate playerViewPreferredWebViewBackgroundColor:self];
        if (playerWebView.backgroundColor == [UIColor clearColor]) {
            playerWebView.opaque = NO;
        }
    }
    
    return playerWebView;
}

- (void)removeWebView {
    [self.webView removeFromSuperview];
    self.webView.UIDelegate = nil;
    self.webView.navigationDelegate = nil;
    self.webView = nil;
}

- (NSString *)stringFromVideoIdArray:(NSArray *)videoIds {
    NSMutableArray *formattedVideoIds = [[NSMutableArray alloc] init];
    for (id unformattedId in videoIds) {
        [formattedVideoIds addObject:[NSString stringWithFormat:@"'%@'", unformattedId]];
    }
    
    return [NSString stringWithFormat:@"[%@]", [formattedVideoIds componentsJoinedByString:@", "]];
}

- (void)stringFromEvaluatingJavaScript:(NSString *)jsToExecute completion:(void(^)(NSString *message))completed {
    [self.webView evaluateJavaScript:jsToExecute completionHandler:^(NSString *message, NSError * _Nullable error) {
        completed(message);
    }];
}

- (NSString *)stringForJSBoolean:(BOOL)boolValue {
    return boolValue ? @"true" : @"false";
}

#pragma --
#pragma mark WKWebviewDelegates

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    if ([navigationAction.request.URL.scheme isEqual:@"fbplayer"]) {
        [self notifyDelegateOfYouTubeCallbackUrl:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
        
    } else {
        if ([self.delegate respondsToSelector:@selector(playerViewDidBecomeReady:)]) {
            [self.delegate playerViewDidBecomeReady:self];
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.delegate playerView:self receivedError:kFBPlayerErrorUnknown];
    if (self.initialLoadingView) {
        [self.initialLoadingView removeFromSuperview];
        
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
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
 * This is how the WKWebView communicates with the containing Objective-C code.
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

- (void)dealloc {
    [self stopTimer];
}
@end
