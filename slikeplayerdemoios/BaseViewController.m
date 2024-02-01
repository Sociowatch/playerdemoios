//
//  BaseViewController.m
//  slikeplayerdemoios
//
//  Created by Aravind Kumar on 30/10/19.
//  Copyright © 2019 BBDSL. All rights reserved.
//

#import "BaseViewController.h"
#import "DemoViewController.h"
#import "SlikeConfigViewController.h"
#import "SlikePlaylistViewController.h"
#import "SlikeMusicListViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)startSlikePlayer:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    DemoViewController *controller=   [mainStoryboard instantiateViewControllerWithIdentifier:@"DemoViewController"];
    controller.playType =  0;
    [self.navigationController pushViewController:controller animated:YES];

}
- (IBAction)startSlikeYoutube:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    DemoViewController *controller=   [mainStoryboard instantiateViewControllerWithIdentifier:@"DemoViewController"];
    controller.playType =  1;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)directYoutubePlay:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    DemoViewController *controller=   [mainStoryboard instantiateViewControllerWithIdentifier:@"DemoViewController"];
    controller.playType =  2;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)fbAction:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    DemoViewController *controller=   [mainStoryboard instantiateViewControllerWithIdentifier:@"DemoViewController"];
    controller.playType =  4;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)audioPlayerDidClicked:(id)sender {
        
    SlikeMusicListViewController *audioPlayer = [[SlikeMusicListViewController alloc]initWithNibName:@"SlikeMusicListViewController" bundle:nil];
    [self.navigationController pushViewController:audioPlayer animated:YES];
}
- (IBAction)configAction:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SlikeConfigViewController *controller=   [mainStoryboard instantiateViewControllerWithIdentifier:@"SlikeConfigViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
