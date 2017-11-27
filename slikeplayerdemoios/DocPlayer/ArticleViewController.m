//
//  ArticleViewController.m
//  SlikePlayer_Example
//
//  Created by Aravind kumar on 11/22/17.
//  Copyright © 2017 Times Internet Limited. All rights reserved.
//

#import "ArticleViewController.h"
#import "AppDelegate.h"
#import "SlikeNetworkManager.h"

@interface ArticleViewController ()

@end

@implementation ArticleViewController
- (void)viewDidLoad {
    [super viewDidLoad];
  
    [[SlikeNetworkManager defaultManager] imageAtURL:[NSURL URLWithString:self.playerConfig.posterImage] completion:^(UIImage *image, NSString *localFilepath, BOOL isFromCache, NSInteger status, NSError *error) {
        _imgThumb.image = image;
    }];
    if([[AppDelegate getAppDelegate].previewObj.playerConfig.mediaId isEqualToString:self.playerConfig.mediaId]  || [AppDelegate getAppDelegate].previewObj == nil)
    {
       [self backToTop];
        [[[SlikePlayer getInstance] getAnyPlayer] play:NO];
    }

    // Do any additional setup after loading the view.
   // NSLog(@"%@",self.secondViewController);
    self.secondViewController = [AppDelegate getAppDelegate].previewObj;
    if([[AppDelegate getAppDelegate].previewObj.playerConfig.mediaId isEqualToString:self.playerConfig.mediaId] || [AppDelegate getAppDelegate].previewObj == nil)
    {
    //[self addPlayerHeader];
    }
    self.playerView.clipsToBounds =  YES;
    self.informationArray =  [NSArray arrayWithObjects:@"A very nice song by Lata Mangeshkar. I really love the lyrics. Leena looks the best here",@"Presenting Mile Ho Tum reprise version sung by Neha Kakkar & Tony Kakkar from the movie Fever.",@"A very nice song by Lata Mangeshkar. I really love the lyrics. Leena looks the best here",@"Presenting Mile Ho Tum reprise version sung by Neha Kakkar & Tony Kakkar from the movie Fever.",@"A very nice song by Lata Mangeshkar. I really love the lyrics. Leena looks the best here",@"Presenting Mile Ho Tum reprise version sung by Neha Kakkar & Tony Kakkar from the movie Fever.",@"A very nice song by Lata Mangeshkar. I really love the lyrics. Leena looks the best here",@"A very nice song by Lata Mangeshkar. I really love the lyrics. Leena looks the best here",@"Presenting Mile Ho Tum reprise version sung by Neha Kakkar & Tony Kakkar from the movie Fever.",@"A very nice song by Lata Mangeshkar. I really love the lyrics. Leena looks the best here",@"Presenting Mile Ho Tum reprise version sung by Neha Kakkar & Tony Kakkar from the movie Fever.",@"A very nice song by Lata Mangeshkar. I really love the lyrics. Leena looks the best here",@"Presenting Mile Ho Tum reprise version sung by Neha Kakkar & Tony Kakkar from the movie Fever.",@"A very nice song by Lata Mangeshkar. I really love the lyrics. Leena looks the best here", nil];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addPlayerHeader
{
        //    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        //    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    if(!self.secondViewController)
    {
        UIStoryboard *mainStoryboard=[UIStoryboard storyboardWithName:@"Main" bundle: nil];
    self.secondViewController=[mainStoryboard instantiateViewControllerWithIdentifier:@"ViewController"];
        [AppDelegate getAppDelegate].previewObj =  self.secondViewController;

    }else
    {
      if([self.secondViewController.playerConfig.mediaId isEqualToString:self.playerConfig.mediaId])
      {
         
      }
        self.secondViewController.isArticalShow =  YES;
        [self backToTop];
        [[[SlikePlayer getInstance] getAnyPlayer] play:NO];
        
    }
    self.secondViewController.isArticalShow =  YES;

    self.secondViewController.playerConfig =  self.playerConfig;
    
    
    
    UIWindow *window =     [UIApplication sharedApplication].keyWindow;

    
        self.secondViewController.view.alpha=1;
        
        self.secondViewController.view.frame=CGRectMake(self.view.frame.origin.x, window.frame.origin.y, window.frame.size.width, window.frame.size.height);
  
        self.secondViewController.playerConfig =  self.playerConfig;

    self.secondViewController.view.clipsToBounds =  YES;
    [self.playerView addSubview:self.secondViewController.view];
    [self.secondViewController.view bringSubviewToFront:self.playerView];
    
    
  //  [self backToTop];
}

#pragma mark Table View-
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.informationArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header;
    header= [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 240)];
    header.backgroundColor =[UIColor clearColor];
    //self.playerView.backgroundColor = [UIColor redColor];
   
    return header;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"infoCell";
    
    
    UITableViewCell *cell;
    cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
    infoLbl.numberOfLines = 3;
    infoLbl.text =[self.informationArray objectAtIndex:indexPath.row];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
/////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)activeScrollView
{
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   // NSLog(@"%f",scrollView.contentOffset.y);
    
   
        if(scrollView.contentOffset.y > 230)
        {
           // NSLog(@"Up");
            if(self.secondViewController.isArticalShow)
            {
            [self.secondViewController updateExpandMode:NO];

            [self.secondViewController articleDoc];
                if( [[[SlikePlayer getInstance] getAnyPlayer] getControl] && self.playerConfig.isDocEnable)
                {
                    [[[[SlikePlayer getInstance] getAnyPlayer] getControl] updateDocBtn:YES];
                }
            }
        }else
        {
           // NSLog(@"Down");
            [self backToTop];

        }
    

}
-(void)backToTop
{
    if([[AppDelegate getAppDelegate].previewObj.playerConfig.mediaId isEqualToString:self.playerConfig.mediaId])
    {
    if(self.secondViewController)
    {
        if(!self.secondViewController.isArticalShow)
        {
        self.secondViewController.isArticalShow = YES;
        [self.secondViewController updateExpandMode:YES];
        [self.secondViewController expandViewFromHome:self.playerView];
        [self.tbView reloadData];
            if( [[[SlikePlayer getInstance] getAnyPlayer] getControl] && self.playerConfig.isDocEnable)
            {
                [[[[SlikePlayer getInstance] getAnyPlayer] getControl] updateDocBtn:NO];
            }
        }
    }
    }
}
- (IBAction)backAction:(id)sender
{
   // [self.secondViewController articleDoc];
    if(self.secondViewController.isArticalShow)
    {
        [AppDelegate getAppDelegate].previewObj = self.secondViewController;

        [self.secondViewController articleDoc];

//    [[SlikePlayer getInstance]  stopPlayer];
//
//    self.secondViewController = nil;
//        [AppDelegate getAppDelegate].previewObj = self.secondViewController;
  
  }else
    {
        [AppDelegate getAppDelegate].previewObj = self.secondViewController;

    }
    [self.navigationController popViewControllerAnimated:YES];

}
- (IBAction)playAction:(id)sender
{
    /*
    if([[AppDelegate getAppDelegate].previewObj.playerConfig.mediaId isEqualToString:self.playerConfig.mediaId])
    {
        [self backToTop];

    }else
    {
        */
    [[AppDelegate getAppDelegate].previewObj.view removeFromSuperview];
            [[SlikePlayer getInstance] stopPlayer];
            [AppDelegate getAppDelegate].previewObj = nil;
    self.secondViewController= nil;
    [self backToTop];
    [self addPlayerHeader];
   // }
    
}
@end
