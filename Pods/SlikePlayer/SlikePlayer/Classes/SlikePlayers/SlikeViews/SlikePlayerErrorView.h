//
//  SlikePlayerErrorView.h
//  Pods
//
//  Created by Sanjay Singh Rathor on 06/06/18.
//

#import <UIKit/UIKit.h>

@interface SlikePlayerErrorView : UIView
+ (instancetype )slikePlayerErrorView;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *messageLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *dynamicMessageLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *reloadButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *closeButton;

@property (copy, nonatomic) void (^reloadButtonBlock)(void);
@property (copy, nonatomic) void (^closeButtonBlock)(void);



/**
 Set the message in Aert

 @param errMessage - Error message that needs to display
 @param isCloseEnable - Is close button needs to be shown on the screen
 @param isReloadEnable - Is relaod button needs to be shown on the screen
 */
- (void)setErrorMessage:(NSString *)errMessage withCloseEnable:(BOOL)isCloseEnable withReloadEnable:(BOOL)isReloadEnable;

@end
