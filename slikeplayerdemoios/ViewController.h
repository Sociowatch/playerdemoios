//
//  ViewController.h
//  slikeplayerexample
//
//  Created by TIL on 16/09/16.
//  Copyright © 2016 BBDSL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Globals.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnPlayVideo;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayYT;
- (IBAction)clbPlayVideo:(id)sender;
- (IBAction)clbPlayYT:(id)sender;
- (IBAction)clbPlayKaltura:(id)sender;
- (IBAction)clbLiveStream:(id)sender;
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue;
@end

