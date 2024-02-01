//
//  SlikePreviewDraggingProgressView.m
//  Pods
//
//  Created by Sanjay Singh Rathor on 26/07/18.
//

#import "SlikePreviewDraggingProgressView.h"
#import "NSBundle+Slike.h"

@implementation SlikePreviewDraggingProgressView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderWidth = 2;
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

+ (instancetype )slikePreviewDraggingProgressView {
    SlikePreviewDraggingProgressView *progressView = [[[NSBundle slikeNibsBundle] loadNibNamed:@"SlikePreviewDraggingProgressView" owner:self options:nil] lastObject];
    return progressView;
}


@end
