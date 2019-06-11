//
//  Stream.m
//
//
#import "Stream.h"

@implementation Stream

- (id)init {
    if (self = [super init]) {
        self.strURL = @"";
        self.strFlavor = @"";
        self.strLabel = @"";   
     }
    return self;
}

+ (Stream *)createStream:(NSString *) url withBitrate:(NSInteger) bitrate withSize:(CGSize) theSize withFlavor:(NSString *) flavor withLabel:(NSString *) label {
    
    Stream *stream = [[Stream alloc] init];
    if(url) stream.strURL = url;
    stream.nBitrate = bitrate;
    stream.size = theSize;
    if(flavor) stream.strFlavor = flavor;
    if(label) stream.strLabel = label;
    return stream;
}

@end
