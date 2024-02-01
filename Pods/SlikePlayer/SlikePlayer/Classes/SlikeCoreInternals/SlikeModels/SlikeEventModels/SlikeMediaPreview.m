//
//  SlikeMediaPreview.m
//  Pods
//
//  Created by Sanjay Singh Rathor on 27/07/18.
//

#import "SlikeMediaPreview.h"

@implementation SlikeMediaPreview
- (instancetype)init {
    self = [super init];
    
    _rows = 0;
    _columns = 0;
    _thumbWidth = 0;
    _thumbHight = 0;
    _timeCounts = [[NSArray alloc]init];
    _tileImageUrls = [[NSMutableArray alloc]init];
    _thumbImages = [[NSMutableArray alloc]init];
    
    return self;
}

@end
