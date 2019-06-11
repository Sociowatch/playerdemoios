
#import "SlikeVideoProgress.h"

@interface SlikeVideoProgress ()
@property (nonatomic, strong) UILabel *tipLabel;
@end

@implementation SlikeVideoProgress

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.font = [UIFont boldSystemFontOfSize:22];
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.tipLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self addSubview:self.tipLabel];
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        NSLayoutConstraint *centerLabelX = [NSLayoutConstraint constraintWithItem:self.tipLabel
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                  constant:0];

        NSLayoutConstraint *centerLabelY = [NSLayoutConstraint constraintWithItem:self.tipLabel
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                  constant:0];

        [self addConstraint:centerLabelX];
        [self addConstraint:centerLabelY];
    }
    return self;
}

- (void)setProgressText:(NSString *)text {
    if (!text) {
        text = @"";
    }
    self.tipLabel.text = text;
}

@end
