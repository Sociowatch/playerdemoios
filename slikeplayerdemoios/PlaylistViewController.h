//
//  PlaylistViewController.h
//  slikeplayerexample
//
//  Created by TIL on 18/10/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) NSMutableArray *arrData;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

