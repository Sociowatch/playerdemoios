//
//  SlikeMemePlayerViewController.h
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 09/04/18.
//

#import <UIKit/UIKit.h>

@interface SlikeMemePlayerViewController : UIViewController<ISlikePlayer> {
}
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@end
