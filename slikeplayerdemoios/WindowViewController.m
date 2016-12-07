//
//  WindowViewController.m
//  slikeplayerexample
//
//  Created by TIL on 16/09/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//

#import "WindowViewController.h"
#import <SlikePlayer/SlikePlayerManager.h>

@interface WindowViewController ()

@end

@implementation WindowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AnalyticsSpecificInfo *analyticsSpecificInfo = [[AnalyticsSpecificInfo alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withSection:@"home:city" withCategory:@"2" withNewsID:@"8" withChannel:@"toi"];
    [[SlikePlayerManager getInstance] playVideo:@"1_oprrpt0x" withTimeCode:0L inParent:self.viewPlayer withAds:nil withAnalyticsInfo:analyticsSpecificInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
