//
//  PlaylistViewController.m
//  slikeplayerexample
//
//  Created by TIL on 18/10/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//

#import "PlaylistViewController.h"
#import <SlikePlayerManager.h>
#import <SlikeNetworkManager.h>
#import <SBJson.h>
#import <SVProgressHUD.h>
#import <StreamingInfo.h>
#import "Haneke.h"

@interface PlaylistViewController ()

@end

@implementation PlaylistViewController

@synthesize arrData;
@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrData = [NSMutableArray array];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData
{
    if(self.arrData.count > 0) [self.arrData removeAllObjects];
    [[SlikeNetworkManager defaultManager] requestURL:[NSURL URLWithString:@"https://uat.boxtv.com/slike/streamlist"] type:NetworkHTTPMethodGET completion:^(NSData *data, NSString *localFilepath, BOOL isFromCache, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
        });
        
        if(data != nil)
        {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if(string)
            {
                NSArray *arr = (NSArray *) string.JSONValue;
                if(arr)
                {
                    NSInteger nIndex, nLen = arr.count;
                    NSDictionary *dict;
                    StreamingInfo *streamingInfo;
                    AnalyticsSpecificInfo *analyticsSpecificInfo;
                    for(nIndex = 0; nIndex < nLen; nIndex++)
                    {
                        dict = [arr objectAtIndex:nIndex];
                        if(!dict) continue;
                        analyticsSpecificInfo = [[AnalyticsSpecificInfo alloc] initWithTitle:@"Cauvery-protests-Dont-blindly-believe-messages-on-social-media-say-Bengaluru-Police" withSection:@"home:city" withCategory:@"2" withNewsID:@"8" withChannel:@"toi"];
                        streamingInfo = [StreamingInfo createStreamURL:nil withType:VIDEO_SOURCE_HLS withTitle:[dict objectForKey:@"name"] withSubTitle:@"" withDuration:[[dict objectForKey:@"duration"] integerValue] withAds:nil withAnalyticsInfo:analyticsSpecificInfo];
                        streamingInfo.strID = [dict objectForKey:@"id"];
                        streamingInfo.urlImageURL = [NSURL URLWithString:[dict objectForKey:@"image"]];
                        [self.arrData addObject:streamingInfo];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            }
        }
        else
        {
            SlikeDLog(@"Ooops! Some error is occurred.");
        }
    }];
}

/**
 getFormattedDuration:function(durationInSec)
	{
 var hr = durationInSec > 3600 ? Math.floor(durationInSec / 3600) : 0;
 durationInSec = durationInSec > 3600 ? (durationInSec % 3600) : durationInSec;
 var min = durationInSec > 60 ? Math.floor(durationInSec / 60) : 0;
 durationInSec = durationInSec > 60 ? (durationInSec % 60) : durationInSec;
 var str = "";
 if(hr != 0)
 {
 if(hr <= 9) str += "0" + hr + " hr ";
 else str += hr + " hr ";
 }
 if(min <= 9) str += "0" + min + " min ";
 else str += min + " min ";
 
 if(hr == 0)
 {
 if(durationInSec <= 9) str += "0" + durationInSec + " sec ";
 else str += durationInSec + " sec ";
 }
 return str;
	}
 */

-(NSString *) getFormattedTime:(NSInteger) durationInSec
{
    NSInteger hr = durationInSec > 3600 ? floorf(durationInSec / 3600) : 0;
    durationInSec = durationInSec > 3600 ? (durationInSec % 3600) : durationInSec;
    NSInteger min = durationInSec > 60 ? floorf(durationInSec / 60) : 0;
    durationInSec = durationInSec > 60 ? (durationInSec % 60) : durationInSec;
    NSString *str = @"";
    if(hr != 0) str = [NSString stringWithFormat:@"%@%@%ld hr ", str, hr <= 9 ? @"0" : @"", (long) hr];
    str = [NSString stringWithFormat:@"%@%@%ld min ", str, min <= 9 ? @"0" : @"", (long) min];
    if(hr == 0) str = [NSString stringWithFormat:@"%@%@%ld sec ", str, durationInSec <= 9 ? @"0" : @"", (long) durationInSec];
    return str;
}

#pragma --
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrData count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"playlistcell"];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"playlistcell"];
        //cell.textLabel.font = [cell.textLabel.font fontWithSize:16];
        //cell.detailTextLabel.font = [cell.detailTextLabel.font fontWithSize:14];
    }
    if(CGRectEqualToRect(cell.imageView.frame, CGRectZero))
    {
        CGRect theFrame = cell.imageView.frame;
        theFrame.size.width = 96;
        theFrame.size.height = 55;
        cell.imageView.frame = theFrame;
    }
    StreamingInfo *info = [self.arrData objectAtIndex:indexPath.row];
    cell.textLabel.text = info.strTitle;
    cell.detailTextLabel.text = [self getFormattedTime:info.nDuration / 1000];
    
    if(info.urlImageURL)
    {
        [cell.imageView hnk_setImageFromURL:info.urlImageURL placeholder:nil success:^(UIImage *image) {
            cell.imageView.image = image;
            [cell setNeedsLayout];
        } failure:^(NSError *error) {
            cell.imageView.image = nil;
        }];
    }
    
    return cell;
}

#pragma --
#pragma mark UITableViewDataDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[SlikePlayerManager getInstance] playVideo:self.arrData withIndex:indexPath.row withCurrentlyPlaying:^(NSInteger index, ProgressInfo *progressInfo) {
        if(!progressInfo)[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        else
        {
            NSLog(@"%@", [progressInfo getString]);
        }
    }];
}

@end
