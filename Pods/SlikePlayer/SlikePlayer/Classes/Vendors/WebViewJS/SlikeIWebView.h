//
//  JavascriptInterface
#import <Foundation/Foundation.h>

@protocol SlikeIWebView <NSObject>

- (NSString *) provideJS2NativeCallForMessage:(NSString *) message;
- (NSString *) evaluatingJavascript:(NSString *) script;

@end
