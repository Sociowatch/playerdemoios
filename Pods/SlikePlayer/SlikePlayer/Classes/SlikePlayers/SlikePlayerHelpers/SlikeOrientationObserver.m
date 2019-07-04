//
//  SlikeOrientationObserver.m
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 04/06/18.
//

#import "SlikeOrientationObserver.h"
#import "SlikePlayerConstants.h"
#import "EventManager.h"

@interface SlikeOrientationObserver () {
    UIDeviceOrientation _deviceOrientation;
}

@property (nonatomic, copy, nullable) void(^rotatedCompletionBlock)(SlikeOrientationObserver *observer);

@property (nonatomic, weak) UIWindow *mainWindow;
@property (nonatomic, strong) UIWindow *fullScreenWindow;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, strong) UIView *dummyView;
@property (nonatomic, weak) UIViewController *playerParent;
@property (nonatomic, weak) UIViewController *mainParent;
@property (assign, nonatomic) UIDeviceOrientation cacheOrientation;
@property (assign, nonatomic) CGPoint iPadOriginalPoint;
@end

@implementation SlikeOrientationObserver

- (instancetype)initWithTarget:(UIViewController *)viewController {
    self = [super init];
    if ( !self ) return nil;
    
    [self _observerDeviceOrientation];
    _deviceOrientation = UIDeviceOrientationPortrait;
    _playerParent = viewController;
    _backWindowColor = [UIColor blackColor];
    _orientationType = SlikeOrientationTypeiPhone;
    
    return self;
}

- (instancetype)initWithTarget:(UIViewController *)viewController rotationCondition:(BOOL(^)(SlikeOrientationObserver *observer))rotationCondition {
    self = [self initWithTarget:viewController];
    if ( !self ) return nil;
    
    _rotationCondition = rotationCondition;
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    SlikeDLog(@"dealloc- Cleaning up SlikeOrientationObserver");
}

- (void)_observerDeviceOrientation {
    if ( ![UIDevice currentDevice].generatesDeviceOrientationNotifications ) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)_handleDeviceOrientationChange {
    if (!UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation)) {
        return;
    }
    
    switch ( [UIDevice currentDevice].orientation ) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            _deviceOrientation = [UIDevice currentDevice].orientation;
            if (_orientationType == SlikeOrientationTypeiPad) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self _updateOrentationChangeForIPad];
                });
                return;
            }
            
            {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(isPerform) object: nil];
                [self performSelector:@selector(isPerform) withObject:nil afterDelay:0.1];
            }
        }
            break;
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
            break;
    }
}

- (void)isPerform {
    
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        // force fullscreen for landscape device rotation
        if (UIDeviceOrientationIsLandscape(self->_deviceOrientation) && !self.fullScreen) {
            [self _updateiPhoneWithCurrentOrientation];
            
        } else if (UIDeviceOrientationIsPortrait(self->_deviceOrientation) && self.fullScreen) {
            [self _updateiPhoneWithCurrentOrientation];
        }
    }];
}

- (BOOL)isFullScreen {
    return self.fullScreen;
}

- (void)changePlayerSize {
    if (_orientationType == SlikeOrientationTypeiPad) {
        return;
    }
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ((orientation) == UIDeviceOrientationLandscapeLeft || (orientation) ==
        UIDeviceOrientationLandscapeRight) {
        if ( _rotationCondition ) {
            if ( !_rotationCondition(self) )
                return;
        }
        
        // force fullscreen for landscape device rotation
        if (UIDeviceOrientationIsLandscape(orientation) && ![self isFullScreen]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _updateiPhoneWithCurrentOrientation];
            });
        } else if (UIDeviceOrientationIsPortrait(orientation) && [self isFullScreen]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _updateiPhoneWithCurrentOrientation];
            });
            
        }
    }
}

- (void)_updateiPhoneWithCurrentOrientation {
    [self rotateDevice];
}

- (void)rotateDevice {
    //Need to look if app requires the iPad type orientations
    if (_orientationType == SlikeOrientationTypeiPad) {
        [self _layoutViewForIPadDevice];
    } else {
        [self _layoutViewForIPhoneDevice];
    }
}

- (void)_layoutViewForIPhoneDevice {
    
    if ( _rotationCondition ) { if ( !_rotationCondition(self) ) return; }
    {
        UIViewController *parent = _playerParent;
        
        if (_mainWindow == nil) {
            _mainWindow = [UIApplication sharedApplication].keyWindow;
        }
        
        if ( _orientationWillChange ) _orientationWillChange(self, self.isFullScreen);
        
        if (_fullScreenWindow == nil) {
            _mainParent = parent.parentViewController;
            _containerView = parent.view.superview;
            
            _dummyView = [[UIView alloc] initWithFrame:parent.view.frame];
            _dummyView.autoresizingMask = parent.view.autoresizingMask;
            _dummyView.backgroundColor = _backWindowColor;
            
            [parent removeFromParentViewController];
            [parent.view removeFromSuperview];
            [parent willMoveToParentViewController:nil];
            [_containerView addSubview:_dummyView];
            
            CGRect theFrame = [_dummyView convertRect:_dummyView.frame toView:_mainWindow];
            _fullScreenWindow = [[UIWindow alloc] initWithFrame:theFrame];
            _fullScreenWindow.backgroundColor = [UIColor clearColor];
            
            parent.view.frame = _fullScreenWindow.bounds;
            _fullScreen = YES;
            _fullScreenWindow.frame = _mainWindow.bounds;
            _fullScreenWindow.rootViewController = parent;
            _dummyView.backgroundColor = _backWindowColor;
            _fullScreenWindow.backgroundColor = _backWindowColor;
            _fullScreenWindow.windowLevel = UIWindowLevelStatusBar;
            [_fullScreenWindow makeKeyAndVisible];
            parent.view.frame = _fullScreenWindow.bounds;
            
            if ( _orientationChanged ) _orientationChanged(self, self.fullScreen);
            [self didFullScreenModeFromParentViewController:parent];
            
        } else {
            
            _fullScreen =  NO;
            [self willNormalScreenModeToParentViewController:parent];
            [self resetNormal:parent];
            
            if ( _orientationChanged ) _orientationChanged(self, self.fullScreen);
            
        }
    }
}

- (void)resetNormal:(UIViewController *) parent {
    
    [parent.view removeFromSuperview];
    _fullScreenWindow.rootViewController = nil;
    [_mainParent addChildViewController:parent];
    [_containerView addSubview:parent.view];
    parent.view.frame = _dummyView.frame;
    [parent didMoveToParentViewController:_mainParent];
    [_mainWindow makeKeyAndVisible];
    [_dummyView removeFromSuperview];
    _dummyView = nil;
    _fullScreenWindow = nil;
    _containerView = nil;
    _mainParent = nil;
    [self didNormalScreenModeToParentViewController:parent];
    
}

- (void)didFullScreenModeFromParentViewController:(UIViewController*) parent {
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    [self forceDeviceOrientation:UIInterfaceOrientationUnknown];
    if (orientation == UIDeviceOrientationLandscapeRight) {
        [self forceDeviceOrientation:UIInterfaceOrientationLandscapeLeft];
    } else {
        [self forceDeviceOrientation:UIInterfaceOrientationUnknown];
        [self forceDeviceOrientation:UIInterfaceOrientationLandscapeRight];
    }
}

- (void)willNormalScreenModeToParentViewController:(UIViewController*)parent {
    [self forceDeviceOrientation:UIInterfaceOrientationPortrait];
}

- (void)didNormalScreenModeToParentViewController:(UIViewController*)parent {
    [self forceDeviceOrientation:UIInterfaceOrientationPortrait];
}

#pragma mark - Device rotation

- (void)forceDeviceOrientation:(UIInterfaceOrientation)orientation {
    NSNumber *orientationValue = [NSNumber numberWithInteger:orientation];
    if (orientationValue) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        [[UIDevice currentDevice] setValue:orientationValue forKey:@"orientation"];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
}

- (void)cacheOrientationState {
    _cacheOrientation = _deviceOrientation;
}

#pragma mark - IPad Interface Implementation

- (void)_layoutViewForIPadDevice {
    
    if ( _rotationCondition ) { if ( !_rotationCondition(self) ) return; }
    
    UIViewController *parent = _playerParent;
    if (_mainWindow == nil) {
        _mainWindow = [UIApplication sharedApplication].keyWindow;
    }
    
    if ( _orientationWillChange ) _orientationWillChange(self, self.isFullScreen);
    if (!_backWindowColor) {
        _backWindowColor = [UIColor blackColor];
    }
    
    if (self.fullScreenWindow == nil) {

        self.mainParent = parent.parentViewController;
        self.containerView = parent.view.superview;
        
        self.dummyView = [[UIView alloc] initWithFrame:parent.view.frame];
        _dummyView.autoresizingMask = parent.view.autoresizingMask;
        _dummyView.backgroundColor = _backWindowColor;
        
        [parent removeFromParentViewController];
        [parent.view removeFromSuperview];
        [parent willMoveToParentViewController:nil];
        [_containerView addSubview:_dummyView];
        
        CGRect theFrame = [_dummyView convertRect:_dummyView.frame toView:_mainWindow];
        self.fullScreenWindow = [[UIWindow alloc] initWithFrame:theFrame];
        _fullScreenWindow.backgroundColor = [UIColor clearColor];
        
        _fullScreenWindow.windowLevel = UIWindowLevelNormal;
        [_fullScreenWindow makeKeyAndVisible];
        _fullScreenWindow.rootViewController = parent;
        parent.view.frame = _fullScreenWindow.bounds;
        _dummyView.backgroundColor = _backWindowColor;
        _fullScreenWindow.backgroundColor = _backWindowColor;
        
        _iPadOriginalPoint = [_playerParent.view convertPoint:_fullScreenWindow.frame.origin toView:parent.view];
        
        _fullScreen = YES;
        __weak typeof(self) _self = self;
        [UIView animateKeyframesWithDuration:0.3
                                       delay:0
                                     options:UIViewKeyframeAnimationOptionLayoutSubviews
                                  animations:^{
                                      _self.fullScreenWindow.frame = _self.mainWindow.bounds;
                                  } completion:^(BOOL finished) {
                                      
                                      [_self _forceIPadWindowOrentation];
                                      if ( _self.orientationChanged ) _self.orientationChanged(_self, _self.fullScreen);
                                  }];
        
    } else {
        
        _fullScreen =  NO;
        __weak typeof(self) _self = self;
        [self animatedNormalScreenWithDuration:0.3 animation:^(UIViewController *parent) {
            _self.fullScreenWindow.frame = _self.dummyView.frame;

            if ( _self.orientationChanged ) _self.orientationChanged(self, _self.fullScreen);
        } completion:^(BOOL finished) {
            
            
        }];
    }
}

- (void)animatedNormalScreenWithDuration:(CGFloat)duration animation:(void (^)(UIViewController *parent))animation completion:(void(^)(BOOL finished))completion {
    __weak typeof(self) _self = self;
    UIViewController *parent = _playerParent;
    _fullScreenWindow.frame = _mainWindow.bounds;
    /*[UIView animateWithDuration:duration delay:0 options:(UIViewAnimationOptionTransitionCrossDissolve) animations:^{
     if (animation)
     animation(_self.mainParent);
     
     } completion:^(BOOL finished) {
     [_self _resetiPadNormal:parent];
     }];*/
    [UIView animateKeyframesWithDuration:duration
                                   delay:0        options:UIViewKeyframeAnimationOptionLayoutSubviews
                              animations:^{
                                  if (animation)
                                      animation(_self.mainParent);
                                  _self.iPadOriginalPoint = [_self.containerView convertPoint:_self.fullScreenWindow.frame.origin toView:parent.view];
                                  
                                  _self.fullScreenWindow.frame = CGRectMake(_self.iPadOriginalPoint.x, _self.iPadOriginalPoint.y, parent.view.frame.size.width, parent.view.frame.size.height);
                              }
                              completion:^(BOOL finished) {
                                  if (completion) {
                                      completion(finished);
                                      [_self _resetiPadNormal:parent];
                                  }
                              }];
}


- (void)_resetiPadNormal:(UIViewController *) parent {
    
    __weak typeof(self) _self = self;
    _dummyView.alpha = 0.0;
    [UIView animateWithDuration:0.0 animations:^(void){
        parent.view.alpha = 0;
        [parent.view removeFromSuperview];
        [_self.mainParent addChildViewController:parent];
        [_self.containerView addSubview:parent.view];
        parent.view.frame = _self.dummyView.frame;
        [parent didMoveToParentViewController:_self.mainParent];
        [_self.mainWindow makeKeyAndVisible];
        [_self.dummyView removeFromSuperview];
        
        [_self.mainParent.view sendSubviewToBack:_self.containerView];
        [_self.containerView bringSubviewToFront:parent.view];
        parent.view.alpha = 1;
        
        _self.dummyView = nil;
        _self.fullScreenWindow = nil;
        _self.containerView = nil;
        _self.mainParent = nil;
        _self.fullScreenWindow.rootViewController = nil;
  
    }];
   
    
}

- (void)_forceIPadWindowOrentation {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
}

- (void)_updateOrentationChangeForIPad {
    
    
    if ( _rotationCondition ) {
        if ( !_rotationCondition(self) )
            return;
    }
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsValidInterfaceOrientation(orientation)) {
        [self _forceIPadDeviceOrientation:orientation];
        [UIViewController attemptRotationToDeviceOrientation];
    }
}
- (void)_forceIPadDeviceOrientation:(UIDeviceOrientation)orientation {
    NSNumber *orientationValue = [NSNumber numberWithInteger:orientation];
    if (orientationValue) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        [[UIDevice currentDevice] setValue:orientationValue forKey:@"orientation"];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
}
@end
