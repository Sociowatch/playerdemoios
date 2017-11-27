//
//  HomeViewController.h
//  DocplayerDemo
//
//  Created by Aravind kumar on 11/9/17.
//  Copyright © 2017 Aravind kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreviewViewController.h"
#import "ArticleViewController.h"

@interface HomeViewController : UIViewController
{
    
}
@property(strong,nonatomic)PreviewViewController *secondViewController;

@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property(nonatomic,strong) NSMutableArray *dataArray;

@end
