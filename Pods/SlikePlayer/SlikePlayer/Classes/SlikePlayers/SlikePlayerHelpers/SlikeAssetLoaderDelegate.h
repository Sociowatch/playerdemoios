//
//  SlikeAssetLoaderDelegate.h

#import <Foundation/Foundation.h>
#import "SPLM3U8PlaylistModel.h"
#import "NSString+SPLCRC32.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface SlikeAssetLoaderDelegate : NSObject <AVAssetResourceLoaderDelegate,NSURLSessionDelegate> {
    
}
@property (nonatomic, strong) NSMutableData *movieData;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSMutableArray *pendingRequests;
@property (nonatomic,strong) NSString *cacheDir;
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) NSString *fileUrl;
+ (NSString*) preViewFoundInCacheDirectory:(NSString*) url;
@property(nonatomic,assign) BOOL isEncrypted;
@property(nonatomic,strong) SPLM3U8PlaylistModel *mainPlayListmodel;
@property (nonatomic, strong) dispatch_queue_t serialQueueAssetLoader;
@property (nonatomic,strong) NSString *baseURI;
@property(nonatomic,assign) NSInteger isDecoded;
@property(nonatomic,strong) NSArray *splitArray;
@end
