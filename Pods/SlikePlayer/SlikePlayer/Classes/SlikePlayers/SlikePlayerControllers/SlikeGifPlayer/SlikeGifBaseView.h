//
//  SlikeGifBaseView.h
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 08/03/18.
//

#import <UIKit/UIKit.h>

@interface SlikeGifBaseView : UIView
@property (weak, nonatomic)UIViewController *parentController;
@property (assign, nonatomic)BOOL isFullScreen;

//Remove the Observers
- (void)removeObserver;
//Notify the derived classes that the prientation has changed
- (void)playerOrientationDidChanged;
//Toggle the player orientation
- (void)toggleFullscreen:(BOOL)toggle;
@end
