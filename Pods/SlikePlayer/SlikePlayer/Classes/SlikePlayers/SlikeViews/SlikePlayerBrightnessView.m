//
//  SlikeBrightnessView.m
//  Pods-SlikePlayer_Example
//
//  Created by Sanjay Singh Rathor on 07/02/18.
//

#import "SlikePlayerBrightnessView.h"
#import "NSBundle+Slike.h"

static CGFloat _currentBrightness;

@interface SlikePlayerBrightnessView ()
@property (nonatomic, strong) UIImageView *brightnessImageView;
@property (nonatomic, strong) UILabel *brightnessLabel;
@end

@implementation SlikePlayerBrightnessView

+ (void)initialize {
    _currentBrightness = [UIScreen mainScreen].brightness;
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brightnessDidChange) name:UIScreenBrightnessDidChangeNotification object:nil];
}

- (void)brightnessDidChange {
    //[UIScreen mainScreen].brightness
}

- (UIImageView *)brightnessImageView {
    if (!_brightnessImageView) {
        _brightnessImageView = [[UIImageView alloc] init];
        _brightnessImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_brightnessImageView setImage:[UIImage imageNamed:@"player_brightness" inBundle:[NSBundle slikeImagesBundle] compatibleWithTraitCollection:nil]];
    }

    return _brightnessImageView;
}

- (UILabel *)brightnessLabel {

    if (!_brightnessLabel) {
        _brightnessLabel = [[UILabel alloc]init];
        _brightnessLabel.font = [UIFont boldSystemFontOfSize:22];
        _brightnessLabel.textColor = [UIColor whiteColor];
        _brightnessLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _brightnessLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        //__weak typeof(self) weakSelf = self;

        self.brightnessImageView.translatesAutoresizingMaskIntoConstraints=NO;
        [self addSubview:self.brightnessImageView];

        NSLayoutConstraint *imageWidth = [NSLayoutConstraint constraintWithItem:self.brightnessImageView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:24];

        NSLayoutConstraint *imageHeight = [NSLayoutConstraint constraintWithItem:self.brightnessImageView
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:24];


        NSLayoutConstraint *imageLeft = [NSLayoutConstraint constraintWithItem:self.brightnessImageView
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1
                                                                      constant:20];

        NSLayoutConstraint *imageCenter = [NSLayoutConstraint constraintWithItem:self.brightnessImageView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1
                                                                        constant:0];

        [self addConstraint:imageWidth];
        [self addConstraint:imageHeight];
        [self addConstraint:imageCenter];
        [self addConstraint:imageLeft];


        self.brightnessLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self addSubview:self.brightnessLabel];
        NSLayoutConstraint *rightMargin = [NSLayoutConstraint constraintWithItem:self.brightnessLabel
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1
                                                                        constant:10];

        NSLayoutConstraint *leftMargin = [NSLayoutConstraint constraintWithItem:self.brightnessLabel
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:54];

        NSLayoutConstraint *labelCenter = [NSLayoutConstraint constraintWithItem:self.brightnessLabel
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1
                                                                        constant:0];

        [self addConstraint:leftMargin];
        [self addConstraint:rightMargin];
        [self addConstraint:labelCenter];


    }
    return self;
}

- (void)setBrightnessImage:(UIImage *)image {
    self.brightnessImageView.image = image;
}

- (void)setBrightness:(float)brightness {
    if (brightness<=0) {
        brightness=  0.01;
    }
    NSString *brightnessStr = [NSString stringWithFormat:@"%.2f", brightness];
    self.brightnessLabel.text = [NSString stringWithFormat:@"%ld %s", (NSInteger) (brightnessStr.floatValue*100), "%"];
}


@end
