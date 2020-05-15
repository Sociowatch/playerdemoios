//
//  JavascriptInterface
#import <Foundation/Foundation.h>

@protocol SlikeIWebView <NSObject>

- (NSString *)provideJS2NativeCallForMessage:(NSString *) message;
- (void)evaluatingJavascriptFunction:(NSString *)script completion:(void(^)(NSString *message))completed;

@end
