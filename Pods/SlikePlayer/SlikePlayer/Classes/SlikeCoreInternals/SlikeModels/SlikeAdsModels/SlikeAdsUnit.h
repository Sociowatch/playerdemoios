//
//  SlikeAdsUnit.h
//  slikeplayerlite
//  Created by Sanjay Singh Rathor on 25/05/18.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SlikeAdProvider) {
    IMA = 1,
    COLOMBIA,
    FAN
};


@interface SlikeAdsUnit : NSObject
@property(nonatomic, strong) NSString *strAdURL;
@property(nonatomic, strong) NSString *strAdCategory;
@property(nonatomic, assign) SlikeAdProvider adProvider;

- (instancetype)initWithCategory:(NSString *) category andAdURL:(NSString *) adURL;

@end
