//
//  Stream.h
//

#import <Foundation/Foundation.h>

@interface Stream : NSObject

@property(nonatomic, strong) NSString *strURL;
@property(nonatomic, assign) NSInteger nBitrate;
@property(nonatomic, assign) CGSize size;
@property(nonatomic, strong) NSString *strFlavor;
@property(nonatomic, strong) NSString *strLabel;
@property(nonatomic, assign) BOOL isSecurePlayer;

+ (Stream *)createStream:(NSString *) url withBitrate:(NSInteger) bitrate withSize:(CGSize) theSize withFlavor:(NSString *) flavor withLabel:(NSString *) label withSlikeSecure:(BOOL)isSecure;

@end
