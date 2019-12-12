//
//  SlikeAssetLoaderDelegate.h

#import <Foundation/Foundation.h>
#import "SPLM3U8PlaylistModel.h"
#import "NSString+SPLCRC32.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

/*
If status is -1 -> Not Contains
              1 -> Contains Subtitle other values may  be used for future
*/
typedef void(^PlaylistSubtitleBlock)(NSInteger status);

@interface SlikeAssetLoaderDelegate : NSObject <AVAssetResourceLoaderDelegate> {
}

@property (nonatomic, assign) BOOL isEncrypted;
@property (nonatomic, strong) SPLM3U8PlaylistModel *mainPlayListmodel;
@property (nonatomic, strong) dispatch_queue_t serialQueueAssetLoader;
@property (nonatomic, strong) NSString *baseURI;
@property (nonatomic, assign) NSInteger isDecoded;
@property (nonatomic, strong) NSArray *splitArray;
@property (nonatomic, copy)PlaylistSubtitleBlock subtitleBlock;


@end
