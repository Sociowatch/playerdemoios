//
//  AppDelegate.m
//  slikeplayerexample
//
//  Created by TIL on 16/09/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//

#import "AppDelegate.h"
#import <SlikePlayer/SlikePlayer.h>
// IMPORTANT!!! replace with you api key
#define apikey @"test"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    BOOL isDebug = NO;
#ifdef DEBUG
    isDebug = YES;
#endif
//    [[SlikePlayer getInstance] initPlayerWithApikey:@"toiiphonefe6b17700fa1d800a8c4b8851" andWithDeviceUID:nil debugMode:isDebug];
    

    [[SlikePlayer getInstance] initPlayerWithApikey:apikey andWithDeviceUID:nil debugMode:isDebug];

    //UNCOMMENT TO TEST STYLING EXAMPLES
    
    /*UIImage *img = [UIImage imageNamed:@"testicon"];
    UIImage *imgResizable = [img stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
    
    UIColor *clrBackground = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    UIColor *clrTitle = [UIColor darkGrayColor];
    UIColor *clrSubtitle = [UIColor darkGrayColor];
    UIColor *clrContent = [UIColor darkGrayColor];
    UIColor *clrActivity = [UIColor greenColor];
    
    [SlikePlayer getInstance].playerStyleBarBackground = clrBackground;
    UIFont *titleFont = [UIFont fontWithName:@"AmericanTypewriter" size:18];
    UIFont *subtitleFont = [UIFont fontWithName:@"AmericanTypewriter" size:12];
    
    [SlikePlayer getInstance].playerStyleCloseButton = img;
    [SlikePlayer getInstance].playerStylePlayButton = img;
    [SlikePlayer getInstance].playerStylePauseButton = img;
    [SlikePlayer getInstance].playerStyleReplayButton = img;
    [SlikePlayer getInstance].playerStyleReverseButton = img;
    [SlikePlayer getInstance].playerStyleForwardButton = img;
    [SlikePlayer getInstance].playerStyleBitrateButton = img;
    [SlikePlayer getInstance].playerStyleFullscreenButton = img;
    
    [SlikePlayer getInstance].playerStyleSliderMinTrackColor = [UIColor redColor];
    [SlikePlayer getInstance].playerStyleSliderMaxTrackColor = [UIColor whiteColor];
    [SlikePlayer getInstance].playerStyleSliderThumbImage = imgResizable;
    
    [SlikePlayer getInstance].playerStyleTitleFont = titleFont;
    [SlikePlayer getInstance].playerStyleDurationFont = subtitleFont;
    [SlikePlayer getInstance].playerStyleBitrateTitleFont = titleFont;
    [SlikePlayer getInstance].playerStyleBitrateSubtitleFont = subtitleFont;
    [SlikePlayer getInstance].playerStyleBitrateContentFont = subtitleFont;
    
    [SlikePlayer getInstance].playerStyleTitleColor = clrTitle;
    [SlikePlayer getInstance].playerStyleDurationColor = clrSubtitle;
    [SlikePlayer getInstance].playerStyleActivityTintColor = clrActivity;
    [SlikePlayer getInstance].playerStyleBitrateBackground = [clrBackground colorWithAlphaComponent:0.7];
    [SlikePlayer getInstance].playerStyleBitrateTitleColor = clrTitle;
    [SlikePlayer getInstance].playerStyleBitrateSubtitleColor = clrSubtitle;
    [SlikePlayer getInstance].playerStyleBitrateContentColor = clrContent;*/
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
// Expects the URL of the scheme e.g. "fb://"
- (BOOL)schemeAvailable:(NSString *)scheme {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:scheme];
    return [application canOpenURL:URL];
}
- (void)openScheme:(NSString *)scheme {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:scheme];
    [application openURL:URL options:@{} completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"Opened %@",scheme);
        }
    }];
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // Display text
    UIAlertView *alertView;
    NSString *text = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    alertView = [[UIAlertView alloc] initWithTitle:@"Text" message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    return YES;
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"%@u",url);
    return NO;
}

@end
