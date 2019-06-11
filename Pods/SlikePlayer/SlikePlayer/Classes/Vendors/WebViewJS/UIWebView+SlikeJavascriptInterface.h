//
//  UIWebView+JavascriptInterface.h
//  JavascriptInterface
//
//  Created by 7heaven on 16/7/14.
//  Copyright © 2016年 7heaven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlikeInterfaceProvider.h"
#import "SlikeJavascriptInterface.h"
#import "SlikeIWebView.h"

@interface UIWebView (SlikeJavascriptInterface) <UIWebViewDelegate, SlikeIWebView>

- (void)initializeWebKit;
- (void) addJavascriptInterface:(id<SlikeInterfaceProvider>) target forName:(NSString *) name;

@end
