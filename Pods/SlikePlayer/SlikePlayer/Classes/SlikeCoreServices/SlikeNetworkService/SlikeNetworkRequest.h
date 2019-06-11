//
//  SlikeNetworkRequest.h
//  Pods
//
//  Created by Christian Menschel on 16/02/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NetworkHTTPMethod) {
    NetworkHTTPMethodGET = 0,
    NetworkHTTPMethodPOST,
    NetworkHTTPMethodDELETE,
    NetworkHTTPMethodPUT
};

@interface SlikeNetworkRequest : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) NetworkHTTPMethod type;

@end
