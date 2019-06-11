//
//  SlikeDataParser.h
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 21/05/18.
//

#import <Foundation/Foundation.h>

@class SlikeConfig;
@class StreamingInfo;

@interface SlikeDataParser : NSObject

+ (instancetype)slikeDataParser;

/**
 Parse the source json data & update the config file

 @param slikeConfigModel - Config file that needs to update
 @param jsonData  - JSON model
 @param completionBlock - Completion handler
 */
- (void)parseAndUpdateSlikeConfig:(SlikeConfig *)slikeConfigModel withJson:(NSData *)jsonData resultBlock:(void(^)(NSDictionary * configInfo, NSError* parseError))completionBlock;

/**
 Parse Stream Data & also update the Config instance

 @param slikeConfigModel - Slike Model
 @param streamData - Stream Data
 @param configDataDict - Config Data
 @param completionBlock - Completion handler
 */
- (void)parseStreamDataAndUpdateSlikeConfig:(SlikeConfig *)slikeConfigModel withStreamJson:(NSData *)streamData withConfigJson:(NSDictionary *)configDataDict resultBlock:(void(^)(StreamingInfo* slikeStreamModel, NSError* parseError))completionBlock;

- (void)parsePrefetchedAds:(NSData *)jsonData resultBlock:(void(^)(id responseInstance, NSError* parseError))completionBlock;

- (NSError *)validateConfigJsonReponse:(NSDictionary *)jsonInfoDict;
- (NSError *)validateStreamResponseString:(NSString *)responseString;

@end
