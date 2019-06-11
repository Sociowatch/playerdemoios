
//  JavascriptInterface.h
//  JavascriptInterface
#import <Foundation/Foundation.h>
#import "SlikeIWebView.h"
#import "SlikeInterfaceProvider.h"

@interface SlikeJavascriptInterface : NSObject

@property (unsafe_unretained, nonatomic) id<SlikeIWebView> webView;
@property (unsafe_unretained, nonatomic) id<SlikeInterfaceProvider> interfaceProvider;

@property (strong, nonatomic) NSString *interfaceName;
- (void) injectJSMethod;
- (BOOL) checkUpcomingRequestURL:(NSURL *) url;
- (BOOL) handleInjectedJSMethod:(NSURL *) url;

@end
