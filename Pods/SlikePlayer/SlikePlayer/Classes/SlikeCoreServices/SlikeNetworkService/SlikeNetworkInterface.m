//
//  SlikeNetworkInterface.m
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 29/05/18.
//

#import "SlikeNetworkInterface.h"
#import "SlikeNetworkManager.h"
#import "SlikeServiceError.h"

@implementation SlikeNetworkInterface

+ (instancetype)sharedNetworkInteface {
    
    static dispatch_once_t onceToken;
    static SlikeNetworkInterface *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)performGetServiceRequest:(NSURL *)requestURL withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock {
    
    [[SlikeNetworkManager defaultManager] requestURL:requestURL type:NetworkHTTPMethodGET completion:^(NSData *responseStreamData, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
        completionBlock(responseStreamData, error);
    }];
}

- (void)fetchPlaylistServiceRequest:(NSURL *)requestURL withCompletionBlock:(SlikeNetworkManagerCompletionBlock) completionBlock {
    
    [[SlikeNetworkManager defaultManager] callLoad:requestURL withCompletionBlock:^(id responseStreamData, NSError *error) {
        completionBlock(responseStreamData, error);
    }];
}

- (void)getHLSStreamDataString:(NSString *)strURL withCompletionBlock:(SlikePlaylistCompletionBlock) completionBlock {
    
    [self fetchPlaylistServiceRequest:[NSURL URLWithString:strURL] withCompletionBlock:^(id obj, NSError *error) {
        if (error) {
            completionBlock(nil,nil, SlikeServiceCreateError(SlikeServiceErrorNoNetworkAvailable, @"Network error."));
            return ;
        }
        
        if ([obj isValidString]) {
            completionBlock(nil, [[NSString alloc]initWithString:obj], nil);
        } else {
            completionBlock(nil, nil, SlikeServiceCreateError(SlikeServiceErrorMasterPlaylistFileError, @"Parse error."));
        }
    }];
}


@end
