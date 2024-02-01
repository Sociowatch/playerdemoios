//
//  SlikeCoachmarkView.h
//
//  Created by Sanjay Singh on 04/06/19.
//  Copyright © 2019 Times Internet ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SlikeCoachmarkViewDelegate;

@interface SlikeCoachmarkView : UIView  {
    
    //UIImageView object
    UIImageView *imageView;
}

@property (nonatomic, assign) id<SlikeCoachmarkViewDelegate> delegate;

@property (nonatomic, assign, getter=isAutoHideAfterInterval) BOOL autoHideAfterInterval;
@property (nonatomic, assign) float hideInterval;

/**
 *  initWithView create object of SlikeCoachmarkView
 *
 *  @param view      pass the current view
 *  @param imageName name to displayed as coach mark
 *
 *  @return return value description
 */
- (instancetype) initWithView:(UIView*)view coachMarkImageName:(NSString*)imageName;

/**
 *  Used to hide the SlikeCoachmarkView on tap
 */
-(void)hideCoachMark;

/**
 *  Used to show the SlikeCoachmarkView
 */
-(void)showCoachMark;

@end


@protocol SlikeCoachmarkViewDelegate <NSObject>

/**
 *  Delegate to get the signle tap on SlikeCoachmarkView
 *
 *  @param coachMarksView current SlikeCoachmarkView object
 *  @param sender         tap gesture object
 */
- (void)coachMarksView:(SlikeCoachmarkView*)coachMarksView didTapOnScreen:(id)sender;

@end

