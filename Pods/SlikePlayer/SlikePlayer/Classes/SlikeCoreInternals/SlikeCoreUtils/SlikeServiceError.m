//
//  SlikePlayerError.m
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 16/05/18.
//

#import "SlikeServiceError.h"

NSString * const SlikeServiceErrorDomain = @"com.til.slike";

/**
 Common method for creating the Error with predefined Error domain
 @param code - Error Code
 @param reason - Reason for the error
 @return - Error object
 */
NSError *SlikeServiceCreateError(SlikeServiceError code, NSString *reason) {
    if (!reason) {
        reason = @"";
    }
    NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey : reason, NSLocalizedDescriptionKey : reason};
    return [NSError errorWithDomain:SlikeServiceErrorDomain code:code userInfo:userInfo];
}


/**
 Common method for creating the Error with Error domain

 @param errDomain  -  Error Domain
 @param code  - Error Code
 @param userInfo User Info
 @return - Error object
 */
NSError *SlikeServiceCreateErrorWithDomain(NSString *errDomain, SlikeServiceError code, NSDictionary *userInfo) {
    if (!userInfo) {
        userInfo = @{};
    }
    if (!errDomain) {
        errDomain = SlikeServiceErrorDomain;
    }
    return [NSError errorWithDomain:errDomain code:code userInfo:userInfo];
}
