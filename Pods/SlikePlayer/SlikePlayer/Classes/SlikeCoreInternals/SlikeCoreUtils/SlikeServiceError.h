//
//  SlikeServiceError.h
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 16/05/18.
//

#import <Foundation/Foundation.h>
/**
 *  Media player error codes.
 */
typedef NS_ENUM(NSInteger, SlikeServiceError) {
    
    SlikeServiceErrorWrongConfiguration = 901,
    SlikeServiceErrorInvalidMediaId = 902,
    SlikeServiceErrorInvalidApiKey = 903,
    SlikeServiceErrorInvalidTokenKey = 904,
    SlikeServiceErrorServerDown = 905,
    SlikeServiceErrorServerUnderMentinance = 906,
    SlikeServiceErrorRequestDataError = 907,
    SlikeServiceErrorRequestCanceled = 908,
    SlikeServiceErrorMasterPlaylistFileError = 800,
    SlikeServiceErrorNetworkConnectionLost = 9999,
    SlikeServiceErrorNoNetworkAvailable = -9999,
    SlikeServiceErrorM3U8FileError = -99999,
    SlikeServiceVideoNotSupported = -999
};
/**
 *  Domain for media player errors.
 */
OBJC_EXTERN NSString * const SlikeServiceErrorDomain;
OBJC_EXTERN NSError* SlikeServiceCreateError(SlikeServiceError code, NSString* reason);
OBJC_EXTERN NSError *SlikeServiceCreateErrorWithDomain(NSString *errDomain, SlikeServiceError code, NSDictionary *userInfo);
