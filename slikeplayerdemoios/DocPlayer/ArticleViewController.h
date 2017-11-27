//
//  ArticleViewController.h
//  SlikePlayer_Example
//
//  Created by Aravind kumar on 11/22/17.
//  Copyright © 2017 Times Internet Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SlikePlayer/SlikePlayer.h>
#import "PreviewViewController.h"

@interface ArticleViewController : UIViewController
{
    
}
@property(nonatomic,strong) SlikeConfig *playerConfig;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property(strong,nonatomic)PreviewViewController *secondViewController;
@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property(nonatomic,strong) NSArray *informationArray;
- (IBAction)backAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgThumb;
- (IBAction)playAction:(id)sender;

@end

