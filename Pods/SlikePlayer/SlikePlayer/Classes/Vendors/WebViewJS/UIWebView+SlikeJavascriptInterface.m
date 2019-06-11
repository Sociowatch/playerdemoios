//
//  UIWebView+JavascriptInterface.m

#import "UIWebView+SlikeJavascriptInterface.h"
#import "objc/runtime.h"

#define SLIKE_PROPERTY_DELEGATE "_delegate"
#define SLIKE_PROPERTY_JAVASCRIPT_INTERFACE "_javascriptinterface"

@implementation UIWebView (SlikeJavascriptInterface)

- (void)initializeWebKit {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self webkit_methodSwizzle];
    });
}

- (void) webkit_methodSwizzle {
    [self webkitSwizzleSelector:@selector(setDelegate:) withTargetSelector:@selector(src_setDelegate:)];
    [self webkitSwizzleSelector:@selector(delegate) withTargetSelector:@selector(src_delegate)];
    [self webkitSwizzleSelector:@selector(initWithFrame:) withTargetSelector:@selector(src_initWithFrame:)];
    [self webkitSwizzleSelector:@selector(initWithCoder:) withTargetSelector:@selector(src_initWithCoder:)];
}

- (void)webkitSwizzleSelector:(SEL)sourceSelector withTargetSelector:(SEL)targetSelector{
    Class myclass = [self class];
    Method sourceMethod = class_getInstanceMethod(myclass, sourceSelector);
    Method targetMethod = class_getInstanceMethod(myclass, targetSelector);
    BOOL didAddMethod = class_addMethod(myclass, targetSelector, method_getImplementation(targetMethod), method_getTypeEncoding(targetMethod));
    if (didAddMethod) {
        class_replaceMethod(myclass, targetSelector, method_getImplementation(targetMethod), method_getTypeEncoding(targetMethod));
    }else{
        method_exchangeImplementations(sourceMethod, targetMethod);
    }
}

- (instancetype) src_initWithFrame:(CGRect)frame{
    if([self src_initWithFrame:frame]){
        [self setDelegate:nil];
        [self initJavascriptInterface];
    }
    
    return self;
}

- (instancetype) src_initWithCoder:(NSCoder *)aDecoder{
    if([self src_initWithCoder:aDecoder]){
        [self setDelegate:nil];
        [self initJavascriptInterface];
    }
    
    return self;
}

- (void) src_setDelegate:(id<UIWebViewDelegate>)delegate{
    
    if(delegate == nil){
        [self src_setDelegate:self];
    }else if(delegate != self){
        objc_setAssociatedObject(self, SLIKE_PROPERTY_DELEGATE, delegate, OBJC_ASSOCIATION_ASSIGN);
    }
    
    
}

- (id<UIWebViewDelegate>) src_delegate{
    return [self getSrcDelegate];
}

- (id<UIWebViewDelegate>) getSrcDelegate{
    id delegateObject = objc_getAssociatedObject(self, SLIKE_PROPERTY_DELEGATE);
    if(delegateObject != nil && [delegateObject conformsToProtocol:@protocol(UIWebViewDelegate)]){
        return (id<UIWebViewDelegate>) delegateObject;
    }
    
    return nil;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    SlikeJavascriptInterface *_javascriptInterface = [self getJavascriptInterface];
    
    id<UIWebViewDelegate> srcDelegate = [self getSrcDelegate];
    if((_javascriptInterface == nil || (_javascriptInterface != nil && ![_javascriptInterface handleInjectedJSMethod:request.URL])) &&
       srcDelegate != nil && [srcDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]){
        return [srcDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    return NO;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    SlikeJavascriptInterface *_javascriptInterface = [self getJavascriptInterface];
    if(_javascriptInterface != nil) [_javascriptInterface injectJSMethod];
    
    id<UIWebViewDelegate> srcDelegate = [self getSrcDelegate];
    if(srcDelegate != nil && [srcDelegate respondsToSelector:@selector(webViewDidStartLoad:)]){
        [srcDelegate webViewDidStartLoad:webView];
    }
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    id<UIWebViewDelegate> srcDelegate = [self getSrcDelegate];
    if(srcDelegate != nil && [srcDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]){
        [srcDelegate webViewDidFinishLoad:webView];
    }
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:( NSError *)error{
    id<UIWebViewDelegate> srcDelegate = [self getSrcDelegate];
    if(srcDelegate != nil && [srcDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]){
        [srcDelegate webView:webView didFailLoadWithError:error];
    }
    
}

- (NSString *) provideJS2NativeCallForMessage:(NSString *) message{
    return message;
}

- (NSString *) evaluatingJavascript:(NSString *)script{
    return [self stringByEvaluatingJavaScriptFromString:script];
}

- (SlikeJavascriptInterface *) getJavascriptInterface{
    return objc_getAssociatedObject(self, SLIKE_PROPERTY_JAVASCRIPT_INTERFACE);
}

- (void) initJavascriptInterface{
    SlikeJavascriptInterface *_javascriptInterface = [[SlikeJavascriptInterface alloc] init];
    
    objc_setAssociatedObject(self, SLIKE_PROPERTY_JAVASCRIPT_INTERFACE, _javascriptInterface, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) addJavascriptInterface:(id<SlikeInterfaceProvider>) target forName:(NSString *) name{
    SlikeJavascriptInterface *_javascriptInterface = [self getJavascriptInterface];
    if(_javascriptInterface != nil){
        _javascriptInterface.interfaceName = name;
        _javascriptInterface.webView = self;
        _javascriptInterface.interfaceProvider = target;
        
    }
}

@end
