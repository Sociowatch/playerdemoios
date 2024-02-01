//
//  SlikeAvPlayerViewController.h
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 30/05/18.
//

#import <UIKit/UIKit.h>
#import "ISlikePlayer.h"
#import "ISlikeCast.h"
#import "ISlikeAnlytics.h"
#import "PlayerView.h"
#import "ISlikePlayer.h"

@interface SlikeAvPlayerViewController : UIViewController<ISlikePlayer> {
    
}

@property (nonatomic, strong) id<ISlikeCast> slikeCast;
@property (nonatomic, strong) id<ISlikeAnlytics> slikeAnalytics;
@property (nonatomic, strong) IBOutlet PlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;

- (void)receiveNotifications:(NSNotification *) notification;;
- (void)setVideoPlaceHolder:(BOOL)isSet;
@end
