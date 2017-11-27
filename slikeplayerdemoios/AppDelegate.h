//
//  AppDelegate.h
//  slikeplayerexample
//
//  Created by TIL on 16/09/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreviewViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    
}
+ (AppDelegate *)getAppDelegate;

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,strong) PreviewViewController *previewObj;


@end

