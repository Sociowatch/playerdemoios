//
//  JavascriptInterface.m
//  JavascriptInterface
//
//  Created by 7heaven on 16/7/14.
//  Copyright © 2016年 7heaven. All rights reserved.
//

#import "SlikeJavascriptInterface.h"
#import "objc/runtime.h"
#import "SlikeStringUtil.h"

@implementation SlikeJavascriptInterface

- (BOOL) validateInterfaceName:(NSString *) name{
    return name != nil && [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length != 0;
}

- (BOOL) checkUpcomingRequestURL:(NSURL *) url{
    
    if(url != nil && [self validateInterfaceName:self.interfaceName]){
        NSString *urlString = url.absoluteString;
        
        return [urlString hasPrefix:[[NSString stringWithFormat:@"%@://", _interfaceName] lowercaseString]];
    }
    
    return NO;
}

- (BOOL) handleInjectedJSMethod:(NSURL *) url{
    if([self checkUpcomingRequestURL:url]){
        return [self execSelectorForURL:url];
    }
    
    return NO;
}

- (BOOL) execSelectorForURL:(NSURL *) url{
    
    NSValue *selValue = [self.interfaceProvider javascriptInterfaces][url.host];
    if(selValue != nil){
        SEL targetSelector = [selValue pointerValue];
        
        if([self.interfaceProvider respondsToSelector:targetSelector]){
            
            NSMethodSignature *methodSignature = [((NSObject *) self.interfaceProvider) methodSignatureForSelector:targetSelector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setTarget:self.interfaceProvider];
            [invocation setSelector:targetSelector];
            
            NSDictionary *params = [SlikeStringUtil getUrlParams:url.absoluteString];
            if(params != nil && params.allKeys.count > 0){
                unsigned long paramCount = params.allKeys.count;
                for(int i = 0; i < paramCount; i++){
                    NSString *key = [NSString stringWithFormat:@"arg%d", i];
                    
                    NSString *value = params[key];
                    
                    if(value != nil){
                        [invocation setArgument:&value atIndex:i + 2];
                    }
                }
            }
            
            [invocation invoke];
            
            Method m = class_getInstanceMethod([self.interfaceProvider class], targetSelector);
            void *returnValue;
            
            char type[128];
            method_getReturnType(m, type, sizeof(type));
            
            NSData *dataData = [NSData dataWithBytes:type length:sizeof(type)];
            NSString *returnS = [[NSString alloc] initWithData:dataData encoding:NSUTF8StringEncoding];
            
            if (!([returnS hasPrefix:@"v"] && type[1] == '\0')) {
                [invocation getReturnValue:&returnValue];
                [self.webView evaluatingJavascriptFunction:[NSString stringWithFormat:@"%@.retValue=\"%@\";", self.interfaceName, returnValue] completion:^(NSString *message) {
                    
                }];
                
            }
            
            return YES;
        }
        
    }
    
    return NO;
}

- (void) injectJSMethod {
    NSDictionary<NSString *, NSValue *> *list = [self.interfaceProvider javascriptInterfaces];
    
    
    if([self validateInterfaceName:self.interfaceName] && list != nil && list.allKeys.count > 0){
        NSMutableString *injectString = [[NSMutableString alloc] init];
        [injectString appendString:[NSString stringWithFormat:@"window.%@ = {", self.interfaceName]];
        
        for(int i = 0; i < list.allKeys.count; i++){
            NSString *key = list.allKeys[i];
            SEL selector = [list[key] pointerValue];
            
            NSString *functionString = [self injectMethodStringForSelector:selector withJSName:key interfaceName:self.interfaceName];
            
            [injectString appendString:functionString];
            
            if(i != list.allKeys.count - 1){
                [injectString appendString:@","];
            }
        }
        
        [injectString appendString:@"};"];
        
        [self.webView evaluatingJavascriptFunction:injectString completion:^(NSString *message) {
            
        }];
    }
}

- (NSString *) injectMethodStringForSelector:(SEL) selector withJSName:(NSString *) jsName interfaceName:(NSString *) interfaceName{
    Method m = class_getInstanceMethod([_interfaceProvider class], selector);
    int paramsCount = method_getNumberOfArguments(m) - 2;
    
    NSMutableString *resultString = [[NSMutableString alloc] init];
    [resultString appendString:[NSString stringWithFormat:@"%@: function (", jsName]];
    
    NSMutableString *locationString = [[NSMutableString alloc] init];
    [locationString appendString:[NSString stringWithFormat:@"\"%@://%@", interfaceName, jsName]];
    if(paramsCount > 0) [locationString appendString:@"?"];
    [locationString appendString:@"\""];
    
    for(int i = 0; i < paramsCount; i++){
        if(i == paramsCount - 1){
            [resultString appendString:[NSString stringWithFormat:@"arg%d", i]];
            [locationString appendString:[NSString stringWithFormat:@" + \"arg%d=\" + arg%d", i, i]];
        }else{
            [resultString appendString:[NSString stringWithFormat:@"arg%d,", i]];
            [locationString appendString:[NSString stringWithFormat:@" + \"arg%d=\" + arg%d + \"&\"", i, i]];
        }
    }
    
    [resultString appendString:[NSString stringWithFormat:@"){"
                                "%@.retValue = null;"
                                "var iframe = document.createElement(\"IFRAME\");"
                                "iframe.setAttribute(\"src\", %@);"
                                "document.documentElement.appendChild(iframe);"
                                "iframe.parentNode.removeChild(iframe);"
                                "iframe = null;"
                                "var ret = %@.retValue;"
                                "if(ret){"
                                "return ret;"
                                "}}", interfaceName, [self.webView provideJS2NativeCallForMessage:locationString], interfaceName]];
    
    return resultString;
}

@end
