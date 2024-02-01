//
//  SlikeGesture.m
//  Pods
//
//  Created by Sanjay Singh Rathor on 10/06/18.
//

#import "SlikeGesture.h"
#import "ISlikeGesture.h"

//Enum for the PanGesture to the Player
typedef NS_ENUM(NSUInteger, SlikeControlType) {
    SlikeControlTypeProgress,
    SlikeControlTypeVoice,
    SlikeControlTypeLight,
    SlikeControlTypeNone = 999
};

@interface SlikeGesture() <UIGestureRecognizerDelegate>

@property (nonatomic, weak, readwrite) UIView *targetView;
@property (weak, nonatomic) id<ISlikeGesture> gestureDeleate;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGR;
@property (nonatomic, assign) BOOL isSeekEnabled;

@property (nonatomic, assign) CGPoint touchBeginPoint;
@property (nonatomic, assign) BOOL moved;
@property (nonatomic, assign) BOOL controlHasJudged;
@property (nonatomic, assign) SlikeControlType controlType;
@end


@implementation SlikeGesture

@synthesize panGR = _panGR;

- (instancetype)initWithTargetView:(__weak UIView *)view withDelegate:(id<ISlikeGesture>)gestureDeleate withSeekEnabled:(BOOL)isSeekEbnabled {
    
    self = [super init];
    if ( !self ) return nil;
    
    _targetView = view;
    _gestureDeleate = gestureDeleate;
    _isSeekEnabled = isSeekEbnabled;
    
    [self _addGestureToControlView];
    return self;
}

- (void)_addGestureToControlView {
    [_targetView addGestureRecognizer:self.panGR];
}

- (UIPanGestureRecognizer *)panGR {
    if ( _panGR ) return _panGR;
    _panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _panGR.delegate = self;
    _panGR.delaysTouchesBegan = YES;
    return _panGR;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) return NO;
    if ([touch.view isKindOfClass:[UISlider class]]) return NO;
    
    return YES;
}

/**
 Handle the Gesture on the player view
 @param pan -  Pan Gesture Recognizer
 */
- (void)handlePan:(UIPanGestureRecognizer *)pan {
    
    CGPoint touchPoint = [pan locationInView:pan.view];
    CGPoint velocity = [pan velocityInView:pan.view];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _touchBeginPoint = touchPoint;
        _moved = NO;
        _controlHasJudged = NO;
        
        CGFloat x = fabs(velocity.x);
        CGFloat y = fabs(velocity.y);
        if (x > y) {
            touchPoint.x = -1;
            touchPoint.y = -1;
            
            if ([self.gestureDeleate respondsToSelector:@selector(beganPanWithTouchPoints:)]) {
                [self.gestureDeleate beganPanWithTouchPoints:touchPoint];
            }

            SlikeDLog(@"Direction: => Horizental");
        } else {
            SlikeDLog(@"Direction: => Virtical");
            if ([self.gestureDeleate respondsToSelector:@selector(beganPanWithTouchPoints:)]) {
                [self.gestureDeleate beganPanWithTouchPoints:touchPoint];
            }
            
        }
        
    }
    
    if (pan.state == UIGestureRecognizerStateChanged) {
        if (fabs(touchPoint.x - _touchBeginPoint.x) < 0 && fabs(touchPoint.y - _touchBeginPoint.y) < 0) {
            return;
        }
        _moved = YES;
        if (!_controlHasJudged) {
            float tan = fabs(touchPoint.y - _touchBeginPoint.y) / fabs(touchPoint.x - _touchBeginPoint.x);
            
            if (tan < 1 / sqrt(3)) { // Sliding angle is less than 30 degrees.
                _controlType = SlikeControlTypeProgress;
                _controlHasJudged = YES;
            } else if (tan > sqrt(3)) { // Sliding angle is greater than 60 degrees
                
                if (_touchBeginPoint.x < pan.view.frame.size.width / 2) { // The left side of the screen controls the brightness.
                    
                    _controlType = SlikeControlTypeLight;
                } else { // The right side of the screen controls the volume.
                    
                      _controlType = SlikeControlTypeVoice;
                }
                _controlHasJudged = YES;
            } else {
                _controlType = SlikeControlTypeNone;
                return;
            }
        }
        
        if (_controlType == SlikeControlTypeProgress) {
            
            float videoSeekDistance = ((touchPoint.x - _touchBeginPoint.x) / [UIScreen mainScreen].bounds.size.width);
            
            if ([self.gestureDeleate respondsToSelector:@selector(changedPanOnSeek:)] && _isSeekEnabled) {
                [self.gestureDeleate changedPanOnSeek:videoSeekDistance];
            }
            
        } else if (_controlType == SlikeControlTypeVoice) {
            
            //float distanceVoiceValue = ((touchPoint.y - _touchBeginPoint.y) / [UIScreen mainScreen].bounds.size.height);
            float verticalPosition = (velocity.y) / 10000;

            if ([self.gestureDeleate respondsToSelector:@selector(changedPanOnVolumeChange:)]) {
                [self.gestureDeleate changedPanOnVolumeChange:verticalPosition];
            }
        } else if (_controlType == SlikeControlTypeLight) {
            
            //float verticalPosition = ((touchPoint.y - _touchBeginPoint.y) / 10000);
            float verticalPosition = (velocity.y) / 10000;
            if ([self.gestureDeleate respondsToSelector:@selector(changedPanOnBrightnessChange:)]) {
                [self.gestureDeleate changedPanOnBrightnessChange:verticalPosition];
            }
            
        } else if (_controlType == SlikeControlTypeNone) {
            //TODO:
        }
    }
    
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        
        _controlHasJudged = NO;
        if (_moved && _controlType == SlikeControlTypeProgress) {
            
            if ([self.gestureDeleate respondsToSelector:@selector(endPanOnSeek:)] && _isSeekEnabled) {
                [self.gestureDeleate endPanOnSeek:(touchPoint.x - _touchBeginPoint.x)];
            }
        } else if (_moved && _controlType == SlikeControlTypeLight) {
            
            if ([self.gestureDeleate respondsToSelector:@selector(endPanOnBrightnessChange)]) {
                [self.gestureDeleate endPanOnBrightnessChange];
            }
        }
        else if (_moved && _controlType == SlikeControlTypeVoice) {
            
            if ([self.gestureDeleate respondsToSelector:@selector(endPanOnVolumeChange)]) {
                [self.gestureDeleate endPanOnVolumeChange];
            }
        }
    }
}

/**
 Enable/Desiable the Gesture
 @param isEnable - TRUE|FALSE
 */
- (void)enablePanGesture:(BOOL)isEnable {
    if (self.panGR) {
        _panGR.enabled = isEnable;
    }
}
@end
