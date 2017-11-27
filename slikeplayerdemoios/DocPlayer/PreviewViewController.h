//
//  ViewController.h
//  DocplayerDemo
//
//  Created by Aravind kumar on 11/3/17.
//  Copyright © 2017 Aravind kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SlikePlayer/SlikePlayer.h>

typedef NS_ENUM(NSUInteger, UIPanGestureRecognizerDirection) {
    UIPanGestureRecognizerDirectionUndefined,
    UIPanGestureRecognizerDirectionUp,
    UIPanGestureRecognizerDirectionDown,
    UIPanGestureRecognizerDirectionLeft,
    UIPanGestureRecognizerDirectionRight
};

@interface PreviewViewController : UIViewController<UIGestureRecognizerDelegate>
{
    BOOL isArticalPlayer;
}
@property (strong, nonatomic) IBOutlet UIView *smallGestureView;
@property (weak, nonatomic) IBOutlet UIView *viewHeaderPlayer;
@property(nonatomic)CGRect initialFirstViewFrame;
@property(nonatomic,strong) UIWindow *onView;
@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property(nonatomic,strong) SlikeConfig *playerConfig;
-(void)removeView;
-(void)expandViewOnPanFromHome;
-(void)removeViewFromStart;
@property(nonatomic,assign) BOOL isArticalShow;
-(void)articleDoc;
-(void)expandViewFromHome:(UIView*)header;
-(void)updateExpandMode:(BOOL)isExpand;
@property(nonatomic,assign) BOOL isArticalPlayerDoc;

@end

