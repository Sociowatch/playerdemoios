//
//  SlikeMediaPreview.h
//  Pods
//
//  Created by Sanjay Singh Rathor on 27/07/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

@interface SlikeMediaPreview : NSObject
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, assign) NSInteger columns;
@property (nonatomic, assign) NSInteger thumbWidth;
@property (nonatomic, assign) NSInteger thumbHight;
@property(nonatomic, strong)  NSMutableArray *tileImageUrls;
@property (nonatomic, strong) NSArray* timeCounts;
@property (nonatomic, assign) NSInteger currentTiledIndex;
@property (nonatomic, assign) NSInteger totalTiledImages;
@property (nonatomic, strong) NSMutableArray* thumbImages;


@end
