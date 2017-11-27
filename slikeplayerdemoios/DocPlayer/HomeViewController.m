//
//  HomeViewController.m
//  DocplayerDemo
//
//  Created by Aravind kumar on 11/9/17.
//  Copyright © 2017 Aravind kumar. All rights reserved.
//

#import "HomeViewController.h"
#import "PreviewViewController.h"
#import "SecondViewController.h"
#import "SlikeNetworkManager.h"
#import "SlikeUICard.h"
#import "AppDelegate.h"

@interface HomeViewController ()

@end

@implementation HomeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINib *cellNib = [UINib nibWithNibName:@"SlikeUICard" bundle:nil];
    [_tbView registerNib:cellNib forCellReuseIdentifier:@"SlikeUICard"];
    _dataArray = [NSMutableArray array];
    [self getDataByUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getDataByUrl
{
    //https://slike.indiatimes.com/feed/demo/3812908.json
    //http://slike.indiatimes.com/feed/demo/3813443.json
    
    [[SlikeNetworkManager defaultManager] requestURL:[NSURL URLWithString:@"https://slike.indiatimes.com/feed/demo/3813443.json"] type:0 completion:^(NSData *data, NSString *localFilepath, BOOL isFromCache,NSInteger status, NSError *error) {
        if(data)
        {
            NSDictionary *jshonDict  = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingMutableContainers error:nil];
           // NSDictionary *dictStreams;
           // NSString *strURL;
            for( NSDictionary *dict in [jshonDict objectForKey:@"items"])
            {
                SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:[dict objectForKey:@"title"] withID:[dict objectForKey:@"_id"] withSection:@"/videos/news" withMSId:[dict objectForKey:@"msid"] posterImage:[dict objectForKey:@"thumb"]];
                StreamingInfo *streamingInfo = [[StreamingInfo alloc] init];
                streamingInfo.strTitle = [dict objectForKey:@"title"];
                streamingInfo.strSubtitle = @"";
                slikeConfig.isAutoPlay = YES;
                slikeConfig.isCloseControl =  NO;
                slikeConfig.isDocEnable =  YES;

                slikeConfig.isFullscreenControl =  YES;
                slikeConfig.isSkipAds = YES;
                slikeConfig.shareText = @"Hi Share this text.";                /*
                dictStreams = [dict objectForKey:@"streams"];
                strURL = [dictStreams objectForKey:@"Auto"];
                if(strURL)
                {
                    [streamingInfo updateStreamSource:strURL withBitrates:0 withFlavor:nil withSize:CGSizeZero withLabel:nil ofType:VIDEO_SOURCE_HLS];
                }
                strURL = [dictStreams objectForKey:@"144p"];
                if(strURL)
                {
                    [streamingInfo updateStreamSource:strURL withBitrates:0 withFlavor:nil withSize:CGSizeZero withLabel:nil ofType:VIDEO_SOURCE_MP4];
                }
                strURL = [dictStreams objectForKey:@"240p"];
                if(strURL)
                {
                    [streamingInfo updateStreamSource:strURL withBitrates:0 withFlavor:nil withSize:CGSizeZero withLabel:nil ofType:VIDEO_SOURCE_MP4];
                }
                streamingInfo.urlImageURL = [NSURL URLWithString:[dict objectForKey:@"thumb"]];
                streamingInfo.nDuration = [[dict objectForKey:@"duration"] floatValue];
                streamingInfo.nEndTime = 0.0;
                slikeConfig.streamingInfo = streamingInfo;
                slikeConfig.preferredVideoType = VIDEO_SOURCE_HLS;
                */
                [_dataArray addObject:slikeConfig];
            }
            if(_dataArray.count>0)
            {
                [_dataArray removeObjectAtIndex:0];
            }
            
            [_tbView reloadData];
        }
    }];
    
}

#pragma mark -
#pragma mark -Important Methods

-(void)showSecondController:(SlikeConfig*)config
{
//    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
//    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    UIStoryboard *mainStoryboard=[UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    self.secondViewController=[mainStoryboard instantiateViewControllerWithIdentifier:@"ViewController"];
    self.secondViewController.playerConfig =  config;
    UIWindow *window =     [UIApplication sharedApplication].keyWindow;
    
    //initial frame
    self.secondViewController.view.frame=CGRectMake(window.frame.size.width-50, window.frame.size.height-50, window.frame.size.width, window.frame.size.height);
    self.secondViewController.initialFirstViewFrame=self.view.frame;
    
    
    self.secondViewController.view.alpha=0;
    self.secondViewController.view.transform=CGAffineTransformMakeScale(0.2, 0.2);
    
    
    [window addSubview:self.secondViewController.view];
    self.secondViewController.onView=window;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.secondViewController.view.transform=CGAffineTransformMakeScale(1.0, 1.0);
        self.secondViewController.view.alpha=1;
        
        self.secondViewController.view.frame=CGRectMake(self.view.frame.origin.x, window.frame.origin.y, window.frame.size.width, window.frame.size.height);
    }];
    
}
- (void)removeController
{
    self.secondViewController=nil;
}


#pragma mark Table View-
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 1;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header;
    header= [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    header.backgroundColor =[UIColor blackColor];
    return header;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 340;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SlikeUICard *cell = [tableView dequeueReusableCellWithIdentifier:@"SlikeUICard"];
    cell.thumbImageView.backgroundColor = [UIColor blackColor];
    SlikeConfig *config = [_dataArray objectAtIndex:indexPath.row];
    cell.tiLbl.text = config.title;
    cell.despcriptionLbl.text = @"ASA 2’s included managed templates have an option to limit the per default visible product description length. ";
    cell.tiLbl.font = [UIFont systemFontOfSize:17];
    cell.despcriptionLbl.font = [UIFont systemFontOfSize:14];
    cell.infoBtn.tag =  indexPath.row;
    [cell.infoBtn addTarget:self action:@selector(moreInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    [[SlikeNetworkManager defaultManager] imageAtURL:[NSURL URLWithString:config.posterImage] completion:^(UIImage *image, NSString *localFilepath, BOOL isFromCache, NSInteger status, NSError *error) {
        cell.thumbImageView.image = image;
    }];

    cell.tiLbl.font = [UIFont systemFontOfSize:17];
    cell.despcriptionLbl.font = [UIFont systemFontOfSize:14];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SlikeConfig *config = [_dataArray objectAtIndex:indexPath.row];
    self.secondViewController = [AppDelegate getAppDelegate].previewObj;
    BOOL isSameVideo =  NO;
    if(self.secondViewController)
    {
        if([self.secondViewController.playerConfig.mediaId isEqualToString:config.mediaId])
        {
            isSameVideo =  YES;
        }else
        {
            //[self.secondViewController removeViewFromStart];
        }
    }
    
//    if(!isSameVideo)
//    {
//        [[AppDelegate getAppDelegate].previewObj.view removeFromSuperview];
//        [[SlikePlayer getInstance] stopPlayer];
//        [AppDelegate getAppDelegate].previewObj = nil;
//        [self showArticalController:config];
//    }
//    else
    
        [self showArticalControllerSameVideo:config];
    
/*
    BOOL isSameVideo =  NO;
    if(self.secondViewController)
    {
        if([self.secondViewController.playerConfig.mediaId isEqualToString:config.mediaId])
        {
            isSameVideo =  YES;
        }else
        {
        [self.secondViewController removeViewFromStart];
        }
    }
    
   if(!isSameVideo) [self showSecondController:config];
   else [self.secondViewController expandViewOnPanFromHome];
    
    */
}
-(void)showArticalController:(SlikeConfig*)config
{
    //    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    //    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    UIStoryboard *mainStoryboard=[UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    ArticleViewController *articleViewController=[mainStoryboard instantiateViewControllerWithIdentifier:@"ArticleViewController"];
    articleViewController.playerConfig =  config;
    articleViewController.secondViewController = [AppDelegate getAppDelegate].previewObj;
    [self.navigationController pushViewController:articleViewController animated:YES];

  
    
}
-(void)showArticalControllerSameVideo:(SlikeConfig*)config
{
    UIStoryboard *mainStoryboard=[UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    ArticleViewController *articleViewController=[mainStoryboard instantiateViewControllerWithIdentifier:@"ArticleViewController"];
    articleViewController.playerConfig =  config;
    articleViewController.secondViewController = [AppDelegate getAppDelegate].previewObj;
    [self.navigationController pushViewController:articleViewController animated:YES];
    
    
    
}

- (void)moreInfo:(id)sender
{
    UIButton *btn=(UIButton*)sender;
    SlikeConfig *config = [_dataArray objectAtIndex:btn.tag];
    
    UIStoryboard *mainStoryboard=[UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SecondViewController *Obj=[mainStoryboard instantiateViewControllerWithIdentifier:@"SecondViewController"];
    Obj.playerConfig =  config;
    [self.navigationController pushViewController:Obj animated:YES];
}


@end
