//  DailymotionPlayerController.m
//
//  Created by Olivier Poitrey on 26/09/11.
//  Copyright 2011 Dailymotion. All rights reserved.

#import "DMPlayerViewController.h"
#import "SlikeInAppBrowserViewController.h"
#import "DMEventParser.h"

static NSString *const DMAPIVersion = @"3.7.8";

@interface DMPlayerViewController () <UIAlertViewDelegate>

@property (nonatomic) WKWebView *wkWebView;
@property (nonatomic, readwrite) BOOL autoplay;
@property (nonatomic, readwrite) float bufferedTime;
@property (nonatomic, readwrite) float duration;
@property (nonatomic, readwrite) BOOL seeking;
@property (nonatomic, readwrite) BOOL paused;
@property (nonatomic, readwrite) BOOL ended;
@property (nonatomic, readwrite) BOOL started;
@property (nonatomic, readwrite) NSError *error;
@property (nonatomic, assign) BOOL inited;
@property (nonatomic, strong) NSDictionary *params;

#pragma mark Open In Safari
@property (nonatomic, strong) NSURL *safariURL;
- (void)openURLInSafari:(NSURL *)URL;

//New Methods
@property (strong, nonatomic) NSString *messageHandlerEvent;
@property (strong, nonatomic) NSString *pathPrefix;
@end


@implementation DMPlayerViewController

- (void)dealloc {
    [self removeWebView];
}

- (void)removeWebView {
    if (_wkWebView) {
        [self pause];
        [_wkWebView stopLoading];
        [_wkWebView.configuration.userContentController removeScriptMessageHandlerForName:_messageHandlerEvent];
        _wkWebView.UIDelegate = nil;
        [_wkWebView removeFromSuperview];
        [_wkWebView stopLoading];
    }
}

- (void)updateWebView:(WKWebView *)webView {
    [self removeWebView];
    self.wkWebView = webView;
    if (webView) {
        webView.UIDelegate = self;
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        webView.frame = self.bounds;
        [self addSubview:webView];
    }
}

- (void)updatePlayerFrames {
    self.wkWebView.frame = self.bounds;
    [self.wkWebView reload];
}

- (void)setup {
    // See https://developer.dailymotion.com/player#player-parameters for available parameters
    _params = @{};
    
    _autoplay = [self.params[@"autoplay"] boolValue];
    _currentTime = 0;
    _bufferedTime = 0;
    _duration = NAN;
    _seeking = NO;
    _error = nil;
    _started = NO;
    _ended = NO;
    _muted = NO;
    _volume = 1;
    _paused = true;
    _fullscreen = NO;
    _webBaseURLString = @"http://www.dailymotion.com";
    _autoOpenExternalURLs = NO;
    
    //New
    _messageHandlerEvent = @"triggerEvent";
    _pathPrefix  = @"/embed/";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (id)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (id)initWithParams:(NSDictionary *)params {
    if (self = [self init]) {
        _params = params;
    }
    return self;
}

- (id)initWithVideo:(NSString *)video params:(NSDictionary *)params {
    if (self = [self initWithParams:params]) {
        [self load:video];
    }
    return self;
}

- (id)initWithVideo:(NSString *)aVideo {
    return [self initWithVideo:aVideo params:nil];
}

- (void)initPlayerWithVideo:(NSString *)video {
    if (self.inited) return;
    self.inited = YES;
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = true;
    configuration.requiresUserActionForMediaPlayback = false;
    configuration.allowsAirPlayForMediaPlayback = true;
    configuration.allowsPictureInPictureMediaPlayback = NO;
    WKPreferences *preferences = [[WKPreferences alloc]init];
    preferences.javaScriptCanOpenWindowsAutomatically = true;
    configuration.preferences = preferences;
    configuration.userContentController = [self newContentController];
    
    WKWebView *webview = [[WKWebView alloc] initWithFrame:self.frame configuration:configuration];
    webview.navigationDelegate = self;
    webview.UIDelegate = self;
    
    // Remote white default background
    webview.opaque = NO;
    webview.backgroundColor = [UIColor clearColor];
    
    if ([self.params[@"fullscreen-state"] isEqualToString:@"fullscreen"]) {
        _fullscreen = YES;
    }
    // Hack: prevent vertical bouncing
    for (id subview in webview.subviews) {
        if ([[subview class] isSubclassOfClass:[UIScrollView class]]) {
            ((UIScrollView *)subview).bounces = NO;
            ((UIScrollView *)subview).scrollEnabled = NO;
        }
    }
    
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@/embed/video/%@?api=location&objc_sdk_version=%@&api=nativeBridge&webkit-playsinline=1", self.webBaseURLString, video, DMAPIVersion];
    
    for (NSString *param in [self.params keyEnumerator]) {
        id value = self.params[param];
        if ([value isKindOfClass:NSString.class]) {
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        [url appendFormat:@"&%@=%@", param, value];
#pragma clang diagnostic pop
    }
    
    NSString *appName = NSBundle.mainBundle.bundleIdentifier;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [url appendFormat:@"&app=%@", [appName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
#pragma clang diagnostic pop
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [self updateWebView:webview];
}

- (void)setFullscreen:(BOOL)newFullscreen {
    [self notifyPlayerApi:@"fullscreen" arg:newFullscreen ? @"1" : @"0" completion:^{
        self->_fullscreen = newFullscreen;
    }];
    
}

- (void)setCurrentTime:(float)newTime {
    [self notifyPlayerApi:@"seek" arg:[NSString stringWithFormat:@"%f", newTime] completion:^{
        self->_currentTime = newTime;
    }];
    
}

- (void)play {
    [self api:@"play"];
}

- (void)togglePlay {
    [self api:@"toggle-play"];
}

- (void)pause {
    [self api:@"pause"];
}

- (void)notifyFullscreenChange {
    [self api:@"notifyFullscreenChanged"];
}

- (void)load:(NSString *)aVideo {
    if (!aVideo) {
        SlikeDLog(@"Called DMPlayerViewController load: with a nil video id");
        return;
    }
    if (self.inited) {
        [self loadPlayer:aVideo];
    }
    else {
        [self initPlayerWithVideo:aVideo];
    }
}

- (void)loadPlayer:(NSString *)videoId {
    NSMutableArray *builder = [[NSMutableArray alloc]init];
    NSString *loadStr = [NSString stringWithFormat:@"player.load('%@'", videoId];
    [builder addObject:loadStr];
    if (self.params && [self.params count]>0) {
        [builder addObject:@", "];
        [builder addObject:_params];
    }
    [builder addObject:@")"];
    NSString *jsonStrig =  [builder componentsJoinedByString:@""];
    [_wkWebView evaluateJavaScript:jsonStrig completionHandler:^(id message, NSError * _Nullable error) {
        
    }];
}

- (void)loadVideo:(NSString *)videoId withParams:(NSDictionary *)params {
    self.params = params;
    [self load:videoId];
}

- (void)notifyPlayerApi:(NSString *)method arg:(NSString *)arg completion:(void(^)(void))completed {
    if (!self.inited) return;
    if (!method) return;
    
    NSString *warnMessage = [self APIReadyWarnMessageForMethod:method];
    if (!self.started && warnMessage) {
    }
    NSString *jsArg = arg ? [NSString stringWithFormat:@"\"%@\"", [arg stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]] : @"null";
    [_wkWebView evaluateJavaScript:[NSString stringWithFormat:@"player.api(%@, %@)", method, jsArg] completionHandler:^(id message, NSError * _Nullable error) {
        completed();
    }];
}

- (void)api:(NSString *)method {
    [self notifyPlayerApi:method arg:nil completion:^{
        
    }];
}

- (NSString *) APIReadyWarnMessageForMethod:(NSString *)method {
    NSString * param = @{
        @"play"         : @"autoplay",
        @"toggle-play"  : @"autoplay",
        @"seek"         : @"start",
        @"quality"      : @"quality",
        @"muted"        : @"muted",
        @"toggle-muted" : @"muted",
        @"0"            :@"controls",
        @"0"            :@"sharing-enable",
        @"0"            :@"ui-logo",
        @"0"            :@"ui-start-screen-info",
        @"1"            :@"endscreen-enable",
    }[method];
    
    SlikeDLog(@"%@",param);
    
    if (param) {
        return [NSString stringWithFormat:@"Warning [DMPlayerViewController]: \n"
                "\tCalling `%@` method right after `apiready` event is not recommended.\n"
                "\tAre you sure you don\'t want to use the `%@` parameter instead?\n"
                "\tFor more information, see: https://developer.dailymotion.com/player#player-parameters", method, param];
    }
    else {
        return nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Open In Safari
- (void)openURLInSafari:(NSURL *)URL {
    if(_isDMExternalLinkHandle) {
    if (self.autoOpenExternalURLs) {
        [[UIApplication sharedApplication] openURL:URL];
    }
    else {
        self.safariURL = URL;
        if ([self.delegate respondsToSelector:@selector(dailymotionAddOpen:)]) {
            [self.delegate dailymotionAddOpen:URL];
        }
    }
    }
}

#pragma mark - WebKit Methods
- (WKUserContentController *)newContentController {
    WKUserContentController *controller= [[WKUserContentController alloc]init];
    NSString *source = [self eventHandler];
    [controller addUserScript:[[WKUserScript alloc]initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:false]];
    [controller addScriptMessageHandler:[[Trampoline alloc]initWithDelegate:self] name:_messageHandlerEvent];
    return controller;
}

- (NSString *)eventHandler {
    NSMutableString *source = [NSMutableString string];
    [source appendString:@"window.dmpNativeBridge = {"];
    [source appendString:@"triggerEvent: function(data) {"];
    
    NSString *formatStr = [NSString stringWithFormat:@"window.webkit.messageHandlers.%@.postMessage(decodeURIComponent(data));", _messageHandlerEvent];
    [source appendString:formatStr];
    [source appendString:@"}};"];
    return source;
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    if (navigationAction.request.URL) {
        [self openURLInSafari:navigationAction.request.URL];
    }
    return nil;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSURL * url = navigationAction.request.URL;
    WKNavigationType navigationType =  navigationAction.navigationType;
    if (url != nil && navigationType == WKNavigationTypeLinkActivated) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    if(![url.absoluteString containsString:_pathPrefix]) {
        NSURLComponents *components = [[NSURLComponents alloc]initWithURL:url resolvingAgainstBaseURL:FALSE];
        if ([components.scheme isEqualToString:@"http"] || [components.scheme isEqualToString:@"https"] ){
            [self openURLInSafari:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if(self.delegate) {
    [self.delegate dailymotionPlayer:self didFailToInitializeWithError:error];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if(self.delegate) {
    [self.delegate dailymotionPlayer:self didFailToInitializeWithError:error];
    }
}

#pragma mark - WKNavigationDelegate
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    {
        NSDictionary *events =[DMEventParser parseEvent:message.body];
        if ([events count] ==0) {
            return;
        }
        [self parseMessageBody:events[@"event"] dataDict:events];
    }
}

- (void)parseMessageBody:(NSString *)eventName dataDict:(NSDictionary *)data {
    
    if ([eventName length] > 0 && eventName) {
        
        if ([eventName isEqualToString:@"timeupdate"]) {
            [self willChangeValueForKey:@"currentTime"];
            _currentTime = [data[@"time"] floatValue];
            [self didChangeValueForKey:@"currentTime"];
        }
        else if ([eventName isEqualToString:@"progress"]) {
            self.bufferedTime = [data[@"time"] floatValue];
        }
        else if ([eventName isEqualToString:@"durationchange"]) {
            self.duration = [data[@"duration"] floatValue];
        }
        else if ([eventName isEqualToString:@"fullscreenchange"]) {
            [self willChangeValueForKey:@"fullscreen"];
            _fullscreen = [data[@"fullscreen"] boolValue];
            [self didChangeValueForKey:@"fullscreen"];
        }
        else if ([eventName isEqualToString:@"volumechange"]) {
            self.volume = [data[@"volume"] floatValue];
        }
        else if ([eventName isEqualToString:@"play"] || [eventName isEqualToString:@"playing"]) {
            self.paused = NO;
        }
        else if ([eventName isEqualToString:@"start"]) {
            self.started = YES;
        }
        else if ([eventName isEqualToString:@"end"]) {
            self.ended = YES;
        }
        else if ([eventName isEqualToString:@"end"] || [eventName isEqualToString:@"pause"]) {
            self.paused = YES;
        }
        else if ([eventName isEqualToString:@"seeking"]) {
            self.seeking = YES;
            _currentTime = [data[@"time"] floatValue];
        }
        else if ([eventName isEqualToString:@"seeked"]) {
            self.seeking = NO;
            _currentTime = [data[@"time"] floatValue];
        }
        else if ([eventName isEqualToString:@"apiready"]) {
            [self play];
        }
        else if ([eventName isEqualToString:@"error"]) {
            NSDictionary *userInfo =
            @{
                @"code" : @([data[@"code"] intValue]) ?: @0,
                @"title" : data[@"title"] ?: @"",
                @"message" : data[@"message"] ?: @"",
                NSLocalizedDescriptionKey : data[@"message"] ?: @"",
            };
            self.error = [NSError errorWithDomain:@"DailymotionPlayer"
                                             code:[data[@"code"] integerValue]
                                         userInfo:userInfo];
        }
        
        if ([self.delegate respondsToSelector:@selector(dailymotionPlayer:didReceiveEvent:)]) {
            [self.delegate dailymotionPlayer:self didReceiveEvent:eventName];
        }
    }
}
@end

@implementation Trampoline
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate {
    self = [super init];
    self.delegate = delegate;
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
}
@end

