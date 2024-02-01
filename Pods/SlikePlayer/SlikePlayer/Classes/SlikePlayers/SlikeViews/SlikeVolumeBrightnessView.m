//
//  SlikeVolumeBrightnessView.m
#import "SlikeVolumeBrightnessView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSBundle+Slike.h"

@interface SlikeVolumeBrightnessView ()

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, assign) SLVolumeBrightnessType volumeBrightnessType;
@property (nonatomic, strong) MPVolumeView *volumeView;

@end

#define SlikePlayerImage(file,imageBundle)  [UIImage imageNamed:file inBundle:imageBundle compatibleWithTraitCollection:nil]

@implementation SlikeVolumeBrightnessView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        [self addSubview:self.iconImageView];
        [self addSubview:self.progressView];
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        [self configureVolume];
        [self hideTipView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(volumeChanged:)
                                                     name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [self.volumeView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.frame.size.width;
    CGFloat min_view_h = self.frame.size.height;
    CGFloat margin = 10;
    
    min_x = margin;
    min_w = 25;
    min_h = min_w;
    min_y = (min_view_h-min_h)/2;
    self.iconImageView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = CGRectGetMaxX(self.iconImageView.frame) + margin;
    min_h = 2;
    min_y = (min_view_h-min_h)/2;
    min_w = min_view_w - min_x - margin;
    self.progressView.frame = CGRectMake(min_x, min_y, min_w, min_h);
}

- (void)volumeChanged:(NSNotification *)notification {
    float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];    
     [self updateProgress:volume withVolumeBrightnessType:SLVolumeBrightnessTypeVolume];
}

- (void)hideTipView {
    self.hidden = YES;
}

- (void)configureVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    volumeView.frame = CGRectMake(-1000, -1000, 100, 100);
    [[UIApplication sharedApplication].keyWindow addSubview:volumeView];
    self.volumeView = volumeView;
}

- (void)updateProgress:(CGFloat)progress withVolumeBrightnessType:(SLVolumeBrightnessType)volumeBrightnessType {
    
    NSBundle *imageBundle = [NSBundle slikeImagesBundle];
    
    if (progress >= 1) {
        progress = 1;
    } else if (progress <= 0) {
        progress = 0;
    }
    
    if (volumeBrightnessType == SLVolumeBrightnessTypeVolume ) {
       NSString* progressStr = [NSString stringWithFormat:@"%.2f", progress];
        progress = [progressStr floatValue];
        if (self.progressView.progress == progress) {
            return;
        }
        self.progressView.progress = progress;
    } else {
        self.progressView.progress = progress;
    }
        
        
    
    self.volumeBrightnessType = volumeBrightnessType;
    if (volumeBrightnessType == SLVolumeBrightnessTypeVolume && progress == 0) {
        self.iconImageView.image = SlikePlayerImage(@"SLPlayer_muted", imageBundle) ;
    }
    self.hidden = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTipView) object:nil];
    [self performSelector:@selector(hideTipView) withObject:nil afterDelay:1.0];
}

- (void)setVolumeBrightnessType:(SLVolumeBrightnessType)volumeBrightnessType {
    _volumeBrightnessType = volumeBrightnessType;
    
    NSBundle *imageBundle = [NSBundle slikeImagesBundle];
    if (volumeBrightnessType == SLVolumeBrightnessTypeVolume) {
        self.iconImageView.image = SlikePlayerImage(@"SLPlayer_volume", imageBundle);
    } else {
        self.iconImageView.image = SlikePlayerImage(@"SLPlayer_brightness", imageBundle);
    }
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressTintColor = [UIColor whiteColor];
        _progressView.trackTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];;
    }
    return _progressView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
    }
    return _iconImageView;
}

@end
