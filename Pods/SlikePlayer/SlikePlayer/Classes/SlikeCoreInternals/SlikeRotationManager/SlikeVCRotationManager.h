//
//  SlikeVCRotationManager.h

#import <UIKit/UIKit.h>
#import "SJRotationManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface SlikeVCRotationManager : NSObject<SJRotationManagerProtocol>
- (instancetype)initWithViewController:(__weak UIViewController *)atViewController;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;

/// These methods, please call in the controller at the right time
- (void)vc_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;
- (BOOL)vc_shouldAutorotate;
- (UIInterfaceOrientationMask)vc_supportedInterfaceOrientations;
- (UIInterfaceOrientation)vc_preferredInterfaceOrientationForPresentation;
@end
NS_ASSUME_NONNULL_END



/*
 
 1.viewController
 
 @interface ViewController ()
 @property (nonatomic, strong) SJVideoPlayer *player;
 @property (nonatomic, strong) SJVCRotationManager *rotationManager;
 @end
 
 - (void)viewDidLoad {
    [super viewDidLoad];
    _rotationManager = [[SJVCRotationManager alloc] initWithViewController:self];
    _player.rotationManager = _rotationManager;
 }

 
 2. viewController
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [_rotationManager vc_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (BOOL)shouldAutorotate {
    return [self.rotationManager vc_shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.rotationManager vc_supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.rotationManager vc_preferredInterfaceOrientationForPresentation];
}
*/
