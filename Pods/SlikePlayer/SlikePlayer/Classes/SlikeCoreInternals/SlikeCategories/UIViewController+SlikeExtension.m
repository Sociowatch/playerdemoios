//
//  UIViewController+SlikeExtension.m
//  SlikeVideoPlayerProject

#import "UIViewController+SlikeExtension.h"

@implementation UIViewController (SlikeExtension)

#ifdef __SLIKE_ORIENTATION_WITH_VIEW_CONTROLLER__

- (BOOL)shouldAutorotate {
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
#endif

@end

@implementation UINavigationController (SlikeExtension)

#ifdef __SLIKE_ORIENTATION_WITH_VIEW_CONTROLLER__

static UIViewController *_get_top_view_controller(UINavigationController *nav) {
    UIViewController *vc = nav.topViewController;
    while (  [vc isKindOfClass:[UINavigationController class]] || [vc isKindOfClass:[UITabBarController class]] ) {
        if ( [vc isKindOfClass:[UINavigationController class]] ) vc = [(UINavigationController *)vc topViewController];
        if ( [vc isKindOfClass:[UITabBarController class]] ) vc = [(UITabBarController *)vc selectedViewController];
        if ( vc.presentedViewController ) vc = vc.presentedViewController;
    }
    return [vc childViewControllers].firstObject;
}

- (BOOL)shouldAutorotate {
    return _get_top_view_controller(self).shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return _get_top_view_controller(self).supportedInterfaceOrientations;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return _get_top_view_controller(self).preferredInterfaceOrientationForPresentation;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return _get_top_view_controller(self);
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return _get_top_view_controller(self);
}
#endif

@end

@implementation UIAlertController (SlikeExtension)
/*#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations; {
    return UIInterfaceOrientationMaskAll;
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
#endif*/
@end


