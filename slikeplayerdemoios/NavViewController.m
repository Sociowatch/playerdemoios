//
//  NavViewController.m
//  slikeplayerexample
//
//  Created by TIL on 16/09/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//

#import "NavViewController.h"
#import <SlikePlayer/SlikePlayerManager.h>

@interface NavViewController ()

@end

@implementation NavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clbPlayWithNav:(id)sender
{
    AnalyticsSpecificInfo *analyticsSpecificInfo = [[AnalyticsSpecificInfo alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withSection:@"home:city" withCategory:@"2" withNewsID:@"8" withChannel:@"toi"];
    [[SlikePlayerManager getInstance] playVideo:@"1_oprrpt0x" withTimeCode:0L inParent:nil withAds:nil withAnalyticsInfo:analyticsSpecificInfo];
}
- (IBAction)clbPlayYTWithNav:(id)sender
{
    /*AnalyticsSpecificInfo *analyticsSpecificInfo = [[AnalyticsSpecificInfo alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withSection:@"home:city" withCategory:@"2" withNewsID:@"8" withChannel:@"toi"];
    [[SlikePlayer getInstance] playVideo:@"Y_dKkU" withTimeCode:0L inParent:nil withAds:nil withAnalyticsInfo:analyticsSpecificInfo];*/
}

@end
