//
//  slikeCustomUIViewController.h
//  TOI
//
//  Created by Aravind kumar on 1/11/18.
//  Copyright © 2018 Times Internet Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SlikePlayer/SlikePlayer.h>
#import "ASValueTrackingSlider.h"

@interface slikeCustomUIViewController : UIViewController<ISlikePlayerControl,UIGestureRecognizerDelegate,UIGestureRecognizerDelegate>
{
    SlikePlayerState status;

}
@property (nonatomic, strong) SlikeConfig *slikeConfig;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *repeatBtn;


@property (weak, nonatomic) IBOutlet UIView *topControlView;

@property (weak, nonatomic) IBOutlet UIImageView *topImageView;

@property (weak, nonatomic) IBOutlet UIButton *resolutionBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (weak, nonatomic) IBOutlet UIView *bottomViewControl;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *videoSlider;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenBtn;
@property (nonatomic, assign, getter=isDragged) BOOL  dragged;



@property (weak, nonatomic) IBOutlet UILabel                 *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel                 *totalTimeLabel;


@end
