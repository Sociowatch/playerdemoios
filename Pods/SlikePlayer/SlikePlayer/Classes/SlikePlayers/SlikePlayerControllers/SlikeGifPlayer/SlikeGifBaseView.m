//
//  SlikeGifBaseView.m
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 08/03/18.
//

#import "SlikeGifBaseView.h"

@interface SlikeGifBaseView() {
    
    UIWindow *mainWindow, *fsWindow;
    UIViewController *mainParent;
    UIView *containerView, *dummyView;
    BOOL didUpdateFullScreen;
}

@property (assign, nonatomic)BOOL observerAdded;
@property (assign, nonatomic)UIDeviceOrientation currentOrientation;
@end

@implementation SlikeGifBaseView

- (id)initWithFrame:(CGRect)frame {
    self =  [super initWithFrame:frame];
    [self baseInit];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self baseInit];
    return self;
}

- (void)baseInit {
    
    if (!_observerAdded) {
        [self addObservers];
        _observerAdded=YES;
    }
}

/*
 Add observers to listen the notifications.
 */
- (void)addObservers {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

/*
 Device orientation did Changed.
 */
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performOrientationChange) object: nil];
    [self performOrientationChange];
}

/*
 Perform the changes on the device orientation
 */
- (void)performOrientationChange {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ((orientation) == UIDeviceOrientationFaceUp || (orientation) == UIDeviceOrientationFaceDown || (orientation) == UIDeviceOrientationUnknown || _currentOrientation == orientation) {
        return;
    }
    
    //Save the current orientation
    _currentOrientation = orientation;
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        {
            // force fullscreen for landscape device rotation
            if (UIDeviceOrientationIsLandscape(orientation) && !self.isFullScreen) {
                [weakSelf toggleFullscreen:YES];
                
            } else if (UIDeviceOrientationIsPortrait(orientation) && self.isFullScreen) {
                [weakSelf toggleFullscreen:NO];
                
            }
        }
    }];
}


- (void)toggleFullscreen:(BOOL) animate {
    //_isFullScreen = animate;
    didUpdateFullScreen = animate;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateFullScreen];
    });
    
}


- (void)updateFullScreen {
    
    BOOL animate =   didUpdateFullScreen;
    
    if(/*slikeConfig.isFullscreenControl*/1) {
        UIViewController *parent = _parentController;
        if (mainWindow == nil) {
            mainWindow = [UIApplication sharedApplication].keyWindow;
        }
        
        if (fsWindow == nil) {
            
            mainParent = parent.parentViewController;
            containerView = parent.view.superview;
            
            dummyView = [[UIView alloc] initWithFrame:parent.view.frame];
            dummyView.autoresizingMask = parent.view.autoresizingMask;
            //dummyView.backgroundColor = self.slikeConfig.fullScreenWindowColor;
            dummyView.backgroundColor = [UIColor blackColor];
            
            [parent removeFromParentViewController];
            [parent.view removeFromSuperview];
            [parent willMoveToParentViewController:nil];
            [containerView addSubview:dummyView];
            
            CGRect theFrame = [dummyView convertRect:dummyView.frame toView:mainWindow];
            
            fsWindow = [[UIWindow alloc] initWithFrame:theFrame];
            fsWindow.backgroundColor = [UIColor blackColor];
            fsWindow.windowLevel = UIWindowLevelStatusBar;
            [fsWindow makeKeyAndVisible];
            fsWindow.rootViewController = parent;
            
            parent.view.frame = fsWindow.bounds;
            _isFullScreen = YES;
            if(animate) {
                [UIView animateKeyframesWithDuration:0.1
                                               delay:0
                                             options:UIViewKeyframeAnimationOptionLayoutSubviews
                                          animations:^{
                                              self->fsWindow.frame = self->mainWindow.bounds;
                                          } completion:^(BOOL finished) {
                                              
                                              [self playerOrientationDidChanged];
                                              [self makeFullScreenModeFromParentViewController:parent];
                                              
                                          }];
            } else {
                [self playerOrientationDidChanged];
                [self makeFullScreenModeFromParentViewController:parent];
            }
            
        } else {
            
            animate = YES;
            self.isFullScreen = NO;
            [self willNormalScreenModeToParentViewController:parent];
            fsWindow.frame = mainWindow.bounds;
            CGRect theFrame = [dummyView convertRect:dummyView.frame toView:fsWindow.superview];
            if(animate) {
                [UIView animateKeyframesWithDuration:0.2
                                               delay:0
                                             options:UIViewKeyframeAnimationOptionLayoutSubviews
                                          animations:^{
                                              self->fsWindow.frame = theFrame;
                                          } completion:^(BOOL finished) {
                                              [self playerOrientationDidChanged];
                                              [self resetNormal:parent];
                                              
                                          }];
            } else {
                
                [self playerOrientationDidChanged];
                [self resetNormal:parent];
            }
            
        }
    }
}

- (void)resetNormal:(UIViewController *) parent {
    
    //Set the alpha value to 0 for both the variables
    dummyView.alpha=0;
    fsWindow.alpha=0;
    
    [parent.view removeFromSuperview];
    fsWindow.rootViewController = nil;
    
    [mainParent addChildViewController:parent];
    [containerView addSubview:parent.view];
    parent.view.frame = dummyView.frame;
    [parent didMoveToParentViewController:mainParent];
    [mainWindow makeKeyAndVisible];
    [dummyView removeFromSuperview];
    dummyView = nil;
    fsWindow = nil;
    [self didNormalScreenModeToParentViewController:parent];
}

- (void)didNormalScreenModeToParentViewController:(UIViewController*)parent {
    if (/*self.slikeConfig.autorotationMode == SlikeFullscreenAutorotationModeLandscape*/1)
        [self forceDeviceOrientation:UIInterfaceOrientationPortrait];
    //[[NSNotificationCenter defaultCenter] postNotificationName:AVPlayerOverlayVCNormalScreenNotification object:self];
}


- (void)willNormalScreenModeToParentViewController:(UIViewController*)parent {
    if (/*self.slikeConfig.autorotationMode == SlikeFullscreenAutorotationModeLandscape*/1)
        [self forceDeviceOrientation:UIInterfaceOrientationPortrait];
}

- (void)makeFullScreenModeFromParentViewController:(UIViewController*) parent {
    
    //if (self.slikeConfig.autorotationMode == SlikeFullscreenAutorotationModeLandscape) {
    {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        // force fullscreen for landscape device rotation
        [self forceDeviceOrientation:UIInterfaceOrientationUnknown];
        
        if (orientation == UIDeviceOrientationLandscapeRight) {
            [self forceDeviceOrientation:UIInterfaceOrientationLandscapeLeft];
        } else {
            [self forceDeviceOrientation:UIInterfaceOrientationUnknown];
            [self forceDeviceOrientation:UIInterfaceOrientationLandscapeRight];
        }
    }

}

- (void)forceDeviceOrientation:(UIInterfaceOrientation)orientation {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)removeObserver {
    if(!_observerAdded) return;
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    _observerAdded=NO;
}

- (void)playerOrientationDidChanged {
}

@end
