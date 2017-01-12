//
//  NavViewController.h
//  slikeplayerexample
//
//  Created by TIL on 16/09/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *viewPlayer;
- (IBAction)clbPlayWithNav:(id)sender;
- (IBAction)clbPlayYTWithNav:(id)sender;
@end

