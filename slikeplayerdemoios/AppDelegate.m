//
//  AppDelegate.m
//  slikeplayerexample
//
//  Created by TIL on 16/09/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//

#import "AppDelegate.h"
#import <SlikePlayer/SlikePlayerManager.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[SlikePlayerManager getInstance] initPlayer];
    
    //UNCOMMENT TO TEST STYLING EXAMPLES
    
    /*UIImage *img = [UIImage imageNamed:@"testicon"];
    UIImage *imgResizable = [img stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
    
    UIColor *clrBackground = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    UIColor *clrTitle = [UIColor darkGrayColor];
    UIColor *clrSubtitle = [UIColor darkGrayColor];
    UIColor *clrContent = [UIColor darkGrayColor];
    UIColor *clrActivity = [UIColor greenColor];
    
    [SlikePlayerManager getInstance].playerStyleBarBackground = clrBackground;
    UIFont *titleFont = [UIFont fontWithName:@"AmericanTypewriter" size:18];
    UIFont *subtitleFont = [UIFont fontWithName:@"AmericanTypewriter" size:12];
    
    [SlikePlayerManager getInstance].playerStyleCloseButton = img;
    [SlikePlayerManager getInstance].playerStylePlayButton = img;
    [SlikePlayerManager getInstance].playerStylePauseButton = img;
    [SlikePlayerManager getInstance].playerStyleReplayButton = img;
    [SlikePlayerManager getInstance].playerStyleReverseButton = img;
    [SlikePlayerManager getInstance].playerStyleForwardButton = img;
    [SlikePlayerManager getInstance].playerStyleBitrateButton = img;
    [SlikePlayerManager getInstance].playerStyleFullscreenButton = img;
    
    //[SlikePlayerManager getInstance].playerStyleSliderMinTrackImage = imgResizable;
    //[SlikePlayerManager getInstance].playerStyleSliderMaxTrackImage = imgResizable;
    [SlikePlayerManager getInstance].playerStyleSliderThumbImage = imgResizable;
    
    [SlikePlayerManager getInstance].playerStyleTitleFont = titleFont;
    [SlikePlayerManager getInstance].playerStyleDurationFont = subtitleFont;
    [SlikePlayerManager getInstance].playerStyleBitrateTitleFont = titleFont;
    [SlikePlayerManager getInstance].playerStyleBitrateSubtitleFont = subtitleFont;
    [SlikePlayerManager getInstance].playerStyleBitrateContentFont = subtitleFont;
    
    [SlikePlayerManager getInstance].playerStyleTitleColor = clrTitle;
    [SlikePlayerManager getInstance].playerStyleDurationColor = clrSubtitle;
    [SlikePlayerManager getInstance].playerStyleActivityTintColor = clrActivity;
    [SlikePlayerManager getInstance].playerStyleBitrateBackground = [clrBackground colorWithAlphaComponent:0.7];
    [SlikePlayerManager getInstance].playerStyleBitrateTitleColor = clrTitle;
    [SlikePlayerManager getInstance].playerStyleBitrateSubtitleColor = clrSubtitle;
    [SlikePlayerManager getInstance].playerStyleBitrateContentColor = clrContent;*/
    
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

@end
