//
//  SlikeBitratesModel.h
//  Pods
//
//  Created by Sanjay Singh Rathor on 19/07/18.
//

#import <Foundation/Foundation.h>
#import "SlikeSharedDataCache.h"

@interface SlikeBitratesModel : NSObject
@property (nonatomic, assign) SlikeMediaBitrate bitrateType;
@property (nonatomic, strong) NSMutableString *bitrateUrl;
@property (nonatomic, strong) NSString *bitrateName;
@property (nonatomic, assign) BOOL isValid;

@end
