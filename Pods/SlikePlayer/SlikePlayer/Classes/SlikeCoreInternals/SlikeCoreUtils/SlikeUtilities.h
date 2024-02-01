//
//  SlikeUtilities.h
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 17/05/18.
//

#import <Foundation/Foundation.h>
#import "SlikeNetworkManager.h"

@class SlikeConfig;

@interface SlikeUtilities : NSObject

/**
 *  Notification sent when some service needs to inform about its current Event
 */

OBJC_EXTERN NSString * const SlikeEventManagerProcessEventNotification;
OBJC_EXTERN NSString * const SlikeEventManagerPublishEventNotification;
OBJC_EXTERN NSString * const SlikeEventManagerModelKey;

/**
 Convert JSON object into plain string
 @param jsonDataObject  -
 @return - Plain String
 */
+ (NSString *)convertJsonToString:(id)jsonDataObject;

/**
 Convert the dictonary to String
 @param dictonary - Source Dictonary
 @return return value description
 */
+ (NSString *)dictToJSONString:(NSDictionary *)dictonary;

/**
 Convert JSON String into Dictonary
 @param jsonString -  String represnting the Dictonary
 @return - result Dict| nil
 */
+ (NSDictionary *)jsonStringToDictionary:(NSString *)jsonString;

/**
 Convert JSON Data into Dictonary
 @param jsonData -  String represnting the Dictonary
 @return - result Dict| nil
 */
+ (NSDictionary *)jsonDataToDictionary:(NSData *)jsonData;


/**
 Format the BandWidth String
 
 @param bandwidthSpeed - speed
 @return - Formatted String
 */
+ (NSString *)formattedBandWidth:(NSInteger)bandwidthSpeed;


/**
 Format time
 
 @param elapsedSeconds - Seconds
 @return - Formatted Time
 */
+ (NSString *)formatTime:(NSInteger) elapsedSeconds;


/**
 Rotate the Contents of Layer
 @param layer - Content Layer
 */
+ (void)rotateLayerInfinite:(CALayer *)layer;

/**
 Show the AlertView contrller
 
 @param messageString - Message String
 @param alertTitle - Alert Title
 @param parentController - Parent Controller on which alert is need to shown
 */
+ (void)showAlert:(NSString *)messageString withTitle:(NSString *)alertTitle withController:(UIViewController *) parentController;

/**
 Parse M3U8 playlist file
 
 @param strURL  -  Url String
 @param block - Completion Block
 */
+ (void)parsem3u8:(NSString *) strURL withCompletionBlock:(SlikeNetworkManagerCompletionBlock) block;

/**
 Get the CBR value
 @param bitrate - Bitrate
 @return - Current Bitrate
 */
+ (NSInteger)getCBR:(NSInteger)bitrate;

/**
 Get the poster image
 @param config - Config Model
 @return - Poster image url
 */
+ (NSString*)getPosterImage:(SlikeConfig*)config;

/**
 Get the poster image for the Next
 @param config - Config Model
 @return - Poster image url
 */
+ (NSString*)getNextPosterImage:(SlikeConfig*)config;

/**
 Get the Video Title for the Current Stream
 @param config - Config Model
 @return -  Video Title
 */
+ (NSString*)getVideoTitle:(SlikeConfig*)config;

/**
 Get the Next Video Title for the Current Stream
 @param config - Config Model
 @return -  Video Title
 */
+ (NSString*)getNextVideoTitle:(SlikeConfig*)config;

/**
 Encoding and Formating the string
 @param strData - Sourec String
 @return - Encoded String
 */
+ (NSString *)endcodeAndFormatString:(NSString *)strData;

/**
 Convert the String into MD5
 @param plainString -
 @return - Coverted String
 */
+ (NSString *)md5HashForString:(NSString *)plainString;
/**
 Get the Top View controller
 
 @return - Top View Controller
 */
+ (UIViewController *)topMostController;

/**
 Find the Closest number in a sequence.
 @param collection -
 @param searchNumber - given value
 @return - Closest index
 //Note: This algo will work If the collection is sorted in ascending order
 */
+ (NSInteger)getClosestIndexWithInCollection:(NSArray *)collection forSearchValue:(NSNumber *)searchNumber;

+ (NSData *)dictToJSONSData:(NSDictionary *)dictonary;
@end
