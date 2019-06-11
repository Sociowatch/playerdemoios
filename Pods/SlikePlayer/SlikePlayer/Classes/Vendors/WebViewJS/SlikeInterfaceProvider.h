//
//  InterfaceProvider.h
//  JavascriptInterface
#import <Foundation/Foundation.h>

@protocol SlikeInterfaceProvider <NSObject>
- (NSDictionary<NSString *, NSValue *> *) javascriptInterfaces;

@end
