//
//  SlikeGestureUI.m
//  Pods
//
//  Created by Sanjay Singh Rathor on 08/06/18.
//
#import <MediaPlayer/MediaPlayer.h>
#import "SlikeGestureUI.h"
#import "ISlikeGesture.h"
#import "SlikeGesture.h"
#import "SlikeVideoProgress.h"
//#import "SlikePlayerBrightnessView.h"
#import "SlikeUtilities.h"
#import "UIView+SlikeAlertViewAnimation.h"
#import "EventManager.h"
#import "NSLayoutConstraint+SSLayout.h"
#import "SlikeVolumeBrightnessView.h"
#import <objc/runtime.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface SlikeGestureUI()<ISlikeGesture> {
    
}
@property (nonatomic, weak, readwrite) UIView *gestureView;
@property (nonatomic, weak) id<ISlikePlayer>player;
@property (nonatomic, strong) SlikeGesture *gestureControl;;
//@property (nonatomic, strong) MPVolumeView *volumeView;
//@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) SlikeVideoProgress *videoProgressTip;
//@property (nonatomic, strong) SlikePlayerBrightnessView *videoBrightness;
@property (nonatomic, strong) SlikeVolumeBrightnessView *videoBrightness;
@property (nonatomic, assign) CGFloat touchBeginVoiceValue;
@property (nonatomic, assign) NSTimeInterval videoDuration;
@property (nonatomic, assign) NSTimeInterval videoCurrent;
@property (nonatomic, readwrite)BOOL isSeekEnabled;
@property (nonatomic, readwrite)BOOL isSeekStart;
@property (nonatomic, strong) UISlider *volumeViewSlider;

@property (nonatomic, readwrite)BOOL hideSeekbarUI;

@end

@implementation SlikeGestureUI

- (instancetype)initWithGestureUI:(UIView *)parentView slikePlayer:(id<ISlikePlayer>)currentPlayer withSeekEnabled:(BOOL)seekEnabled {
    
    self = [super init];
    self.gestureView = parentView;
    self.player = currentPlayer;
    _isSeekEnabled = seekEnabled;
    _gestureControl = [[SlikeGesture alloc]initWithTargetView:_gestureView withDelegate:self withSeekEnabled:seekEnabled];
    
    //Set up the gestures on the  target view
    [self _setupPanGestureViews];
    [self configureVolume];
    self.isSeekStart =  NO;
    _hideSeekbarUI = YES;
    return self;
}

/**
 Get the player's valume instance
 @return - volume instance
 */
/*- (MPVolumeView *)volumeView {
 if (!_volumeView) {
 _volumeView = [[MPVolumeView alloc] init];
 _volumeView.showsRouteButton = NO;
 _volumeView.showsVolumeSlider = NO;
 for (UIView *view in _volumeView.subviews) {
 if ([NSStringFromClass(view.class) isEqualToString:@"MPVolumeSlider"]) {
 _volumeSlider = (UISlider *)view;
 break;
 }
 }
 }
 return _volumeView;
 }*/

- (SlikeVideoProgress *)videoProgressTip {
    if (!_videoProgressTip) {
        _videoProgressTip = [[SlikeVideoProgress alloc] init];
        _videoProgressTip.layer.cornerRadius = 5.0;
        _videoProgressTip.autoresizesSubviews = YES;
        _videoProgressTip.hidden = YES;
        
    }
    return _videoProgressTip;
}

- (SlikeVolumeBrightnessView *)videoBrightness {
    if (!_videoBrightness) {
        _videoBrightness = [[SlikeVolumeBrightnessView alloc] init];
        _videoBrightness.hidden = YES;
        _videoBrightness.layer.cornerRadius = 2.0;
    }
    return _videoBrightness;
}

- (void)_setupPanGestureViews {
    [self _addProgressSubview];
    [self _addBrightnessSubview];
    
    if (!_isSeekEnabled || _hideSeekbarUI) {
        self.videoProgressTip.hidden = YES;
    }
}

#pragma mark - Video Progress View
- (void)_addProgressSubview {
    if ([self.videoProgressTip superview]) {
        [self.videoProgressTip removeFromSuperview];
    }
    
    [self.gestureView addSubview:self.videoProgressTip];
    [_gestureView bringSubviewToFront:_videoProgressTip];
    [self updateProgressFrames];
}

- (void)updateProgressFrames {
    /*
     self.videoProgressTip.center = self.gestureView.center;
     CGRect progressRect = _videoProgressTip.frame;
     progressRect.size = CGSizeMake(160, 60);
     self.videoProgressTip.frame = progressRect;
     [self.videoProgressTip setNeedsLayout];
     */
    
    [self.videoProgressTip activateConstraints:^{
        self.videoProgressTip.width_attr.constant = 160;
        self.videoProgressTip.height_attr.constant = 60;
        self.videoProgressTip.centerX_attr = self.gestureView.centerX_attr;
        self.videoProgressTip.centerY_attr = self.gestureView.centerY_attr;
    }];
}

#pragma mark - Video Brightness View
- (void)_addBrightnessSubview {
    if ([self.videoBrightness superview]) {
        [self.videoBrightness removeFromSuperview];
    }
    [self.gestureView addSubview:self.videoBrightness];
    [self updateBrightnessViewFrames];
}

- (void)updateBrightnessViewFrames {
    [self.videoBrightness activateConstraints:^{
        self.videoBrightness.width_attr.constant = 180;
        self.videoBrightness.height_attr.constant = 40;
        self.videoBrightness.centerX_attr = self.gestureView.centerX_attr;
        self.videoBrightness.centerY_attr = self.gestureView.centerY_attr;
    }];
}

#pragma mark - ISlikeGesture

- (void)beganPanWithDirection:(BOOL)isHorizontal {
    
    [[EventManager sharedEventManager] dispatchEvent:GESTURE playerState:SL_SHOWCONTROLS dataPayload:@{} slikePlayer:nil];
    self.videoCurrent = [self.player getPosition]/1000;
}

- (void)beganPanWithTouchPoints:(CGPoint)touchPoint {
    
    _touchBeginVoiceValue = _volumeViewSlider.value;
    /*  CGFloat currentTime = self.playerView.playerItem.currentTime.value / self.playerView.playerItem.currentTime.timescale;
     self.videoCurrent = currentTime;
     self.videoDuration = self.playerView.playerItem.duration.value / self.playerView.playerItem.duration.timescale;
     */
    
    [[EventManager sharedEventManager] dispatchEvent:GESTURE playerState:SL_HIDECONTROLS dataPayload:@{} slikePlayer:nil];
    
    self.videoCurrent = [self.player getPosition]/1000;
    self.videoDuration = [self.player getDuration]/1000 ;
    [self updateProgressFrames];
    [self updateBrightnessViewFrames];
    
    if (touchPoint.x == -1 && touchPoint.y == -1) {
        NSDictionary *seekedData = @{kSlikePreviewStartedKey:@(_videoCurrent)};
        [[EventManager sharedEventManager] dispatchEvent:GESTURE playerState:SL_MEDIA_PREVIEWS dataPayload:seekedData slikePlayer:self.player];
    } else {
        NSDictionary *seekedData = @{kSlikePreviewStopKey:@(-1)};
        [[EventManager sharedEventManager] dispatchEvent:GESTURE playerState:SL_MEDIA_PREVIEWS dataPayload:seekedData slikePlayer:self.player];
    }
}

/**
 Panning has changed for Volume
 @param verticalPosition  - Valume value
 */
- (void)changedPanOnVolumeChange:(float)verticalPosition {
    [self updateBrightnessViewFrames];
    
    // float voiceValue = _touchBeginVoiceValue - verticalPosition;
    self.volume  -= verticalPosition;
   // [self.videoBrightness updateProgress:self.volume withVolumeBrightnessType:SLVolumeBrightnessTypeVolume];
    
}

/**
 Panning has ended for Volume
 */
- (void)endPanOnVolumeChange {
     [[EventManager sharedEventManager] dispatchEvent:GESTURE playerState:SL_HIDECONTROLS dataPayload:@{} slikePlayer:nil];
}

/**
 Panning has changed for brightness
 @param verticalPosition  - brightness value
 */
- (void)changedPanOnBrightnessChange:(float)verticalPosition {
   
    [self updateBrightnessViewFrames];
    self.videoBrightness.hidden = NO;
    self.brightness -= verticalPosition;
    [self.videoBrightness updateProgress:self.brightness withVolumeBrightnessType:SLVolumeBrightnessTypeumeBrightness];
    [_gestureView bringSubviewToFront:_videoBrightness];
}

/**
 Panning has been ended for brightness
 */
- (void)endPanOnBrightnessChange {
    self.videoBrightness.hidden = YES;
    [[EventManager sharedEventManager] dispatchEvent:GESTURE playerState:SL_HIDECONTROLS dataPayload:@{} slikePlayer:nil];
}

/**
 Panning has changed for Seek
 @param seekDistance  -  Seek Distance
 */
- (void)changedPanOnSeek:(float)seekDistance {
    
    if (!_hideSeekbarUI) {
        if(!_isSeekStart) {
            [[EventManager sharedEventManager] dispatchEvent:GESTURE playerState:SL_SEEKING dataPayload:@{} slikePlayer:nil];
            self.isSeekStart =  YES;
        }
        [self updateProgressFrames];
    }
    
    //calculating
    NSTimeInterval videoCurrentPosition = [self _videoCurrentTimeWithTouchPoint:seekDistance];
    NSInteger currentProgress = (NSInteger)videoCurrentPosition - (NSInteger)_videoCurrent;
    
    float seekBarProgress = 0;
    if (videoCurrentPosition >_videoCurrent) {
        
        [self.videoProgressTip setProgressText:
         [NSString stringWithFormat:@"+ %ld / %@",
          labs(currentProgress),
          [SlikeUtilities formatTime:(long)videoCurrentPosition]]];
        
        seekBarProgress = (currentProgress + _videoCurrent) / _videoDuration;
        
    } else if(videoCurrentPosition < _videoCurrent) {
        if (videoCurrentPosition < 0.0) {
            currentProgress = 0;
        }
        
        seekBarProgress = (_videoCurrent - labs(currentProgress)) / _videoDuration;
        [self.videoProgressTip setProgressText:[NSString stringWithFormat:@"- %ld / %@",
                                                labs(currentProgress),
                                                [SlikeUtilities formatTime:(long)videoCurrentPosition]]];
    }
    
    if (!_hideSeekbarUI) {
        self.videoProgressTip.hidden = NO;
        [_gestureView bringSubviewToFront:_videoProgressTip];
    }
    
    NSDictionary *seekedData = @{kSlikePreviewProgressKey:@(seekBarProgress)};
    [[EventManager sharedEventManager] dispatchEvent:GESTURE playerState:SL_MEDIA_PREVIEWS dataPayload:seekedData slikePlayer:self.player];
}

/**
 Panning has ended for seek
 */
- (void)endPanOnSeek:(float)distance {
    
    if (_hideSeekbarUI) {
        NSDictionary *seekedData = @{kSlikePreviewStopKey:@([self calculateSeekDistance:distance])};
        [[EventManager sharedEventManager] dispatchEvent:GESTURE playerState:SL_MEDIA_PREVIEWS dataPayload:seekedData slikePlayer:self.player];
        
    } else {
        self.videoProgressTip.hidden = YES;
        self.videoBrightness.hidden = YES;
        self.isSeekStart =  NO;
        NSDictionary *seekedData = @{kSlikeSeekProgressKey:@([self calculateSeekDistance:distance])};
        [[EventManager sharedEventManager] dispatchEvent:GESTURE playerState:SL_SEEKED dataPayload:seekedData slikePlayer:nil];
        [self.player seekTo:[self calculateSeekDistance:distance] userSeeked:YES];
    }
}

/**
 Get the video current time based in Touch Points
 @param distance - Progress diatance
 @return - Updated value
 */
- (NSTimeInterval)_videoCurrentTimeWithTouchPoint:(float)distance {
    
    float videoCurrentTime = _videoCurrent + 90 * distance;
    if (videoCurrentTime > _videoDuration) {
        videoCurrentTime = _videoDuration;
    } else if (videoCurrentTime < 0){
        videoCurrentTime = 0.0f;
    }
    return videoCurrentTime;
}

/**
 Get the Video Current time based in Touch Points
 @param distance -  Touch Location
 @return - Estimated time of the player
 */
- (float)calculateSeekDistance:(float)distance {
    
    float _maxValueForSeek = 90;
    long maxDuration = (_videoDuration <= _maxValueForSeek ? _videoDuration : _maxValueForSeek);
    float seekDuration = maxDuration * (distance /  [UIScreen mainScreen].bounds.size.width);
    float totalSeekTime = (seekDuration + _videoCurrent);
    if (totalSeekTime > _videoDuration) {
        totalSeekTime = _videoDuration;
    }else if (totalSeekTime < 0){
        totalSeekTime = 0.0f;
    }
    return totalSeekTime;
}


/**
 Release the Acquired resources
 */
- (void)releaseResources {
    
    if (self.gestureControl) {
        self.gestureControl = nil;
    }
    
    /*if (self.volumeSlider && [self.volumeView superview]) {
     [self.volumeView removeFromSuperview];
     self.volumeView = nil;
     }*/
    
    if (self.videoProgressTip && [self.videoProgressTip superview]) {
        [self.videoProgressTip removeFromSuperview];
        self.videoProgressTip = nil;
    }
    
    if (_videoBrightness && [_videoBrightness superview]) {
        [_videoBrightness removeFromSuperview];
        _videoBrightness = nil;
    }
}

- (void)dealloc {
    [self releaseResources];
    SlikeDLog(@"dealloc- Cleaning up SlikeGestureUI");
}

/**
 Listen the Gesture events
 @param isListeningRequired - YES|NO
 */
- (void)listenForGestureEvents:(BOOL)isListeningRequired {
    [_gestureControl enablePanGesture:isListeningRequired];
}


/// Get system volume
- (void)configureVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    self.volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            self.volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    // Apps using this category don't mute when the phone's mute button is turned on, but play sound when the phone is silent
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (float)volume {
    CGFloat volume = self.volumeViewSlider.value;
    if (volume == 0) {
        volume = [[AVAudioSession sharedInstance] outputVolume];
    }
    return volume;
}

- (BOOL)isMuted {
    return self.volume == 0;
}

- (float)lastVolumeValue {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setVolume:(float)volume {
    if (volume < 0) {
        volume = 0;
    }
    if (volume > 1) {
        volume = 1;
    }
    objc_setAssociatedObject(self, @selector(volume), @(volume), OBJC_ASSOCIATION_ASSIGN);
    self.volumeViewSlider.value = volume;
}

- (void)setMuted:(BOOL)muted {
    if (muted) {
        self.lastVolumeValue = self.volumeViewSlider.value;
        self.volumeViewSlider.value = 0;
    } else {
        self.volumeViewSlider.value = self.lastVolumeValue;
    }
}
- (void)setLastVolumeValue:(float)lastVolumeValue {
    objc_setAssociatedObject(self, @selector(lastVolumeValue), @(lastVolumeValue), OBJC_ASSOCIATION_ASSIGN);
}

- (void)setBrightness:(float)brightness {
    if (brightness <= 0) {
        brightness = 0;
    } else if (brightness >= 1) {
        brightness = 1;
    }
    objc_setAssociatedObject(self, @selector(brightness), @(brightness), OBJC_ASSOCIATION_ASSIGN);
    [UIScreen mainScreen].brightness = brightness;
}
- (float)brightness {
    return [UIScreen mainScreen].brightness;
}

@end
