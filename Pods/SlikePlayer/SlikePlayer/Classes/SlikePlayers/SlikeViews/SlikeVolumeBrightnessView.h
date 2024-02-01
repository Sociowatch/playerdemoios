
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SLVolumeBrightnessType) {
    SLVolumeBrightnessTypeVolume,       // volume
    SLVolumeBrightnessTypeumeBrightness // brightness
};

@interface SlikeVolumeBrightnessView : UIView

@property (nonatomic, assign, readonly) SLVolumeBrightnessType volumeBrightnessType;

- (void)updateProgress:(CGFloat)progress withVolumeBrightnessType:(SLVolumeBrightnessType)volumeBrightnessType;

@end
