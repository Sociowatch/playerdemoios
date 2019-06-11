//
//  SlikeCoachmarkView
//
//  Created by Sanjay Singh on 04/06/19.
//  Copyright © 2019 Times Internet ltd. All rights reserved.
//

#import "SlikeCoachmarkView.h"
#import "NSBundle+Slike.h"

#define SlikePlayerImage(file,imageBundle)  [UIImage imageNamed:file inBundle:imageBundle compatibleWithTraitCollection:nil]

@interface SlikeCoachmarkView()

@property (strong, nonatomic)UIButton *touchButton;
@end

@implementation SlikeCoachmarkView

/**
 *  initWithView create object of SlikeCoachmarkView
 *
 *  @param view      pass the current view
 *  @param imageName name to displayed as coach mark
 *
 *  @return return value description
 */

- (instancetype) initWithView:(UIView*)view coachMarkImageName:(NSString*)imageName {
    
    self = [super init];
    if (self) {
    
        _touchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _touchButton.frame = [view bounds];
        
        self.frame = [view bounds];
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, self.bounds.origin.y, self.bounds.size.width - 30, self.bounds.size.height)];
        
    
        imageView.image = SlikePlayerImage(imageName, [NSBundle slikeImagesBundle]);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.alpha = 0.0;
        [self addSubview:imageView];
        imageView.frame = CGRectMake(15, self.bounds.origin.y, self.bounds.size.width - 30, self.bounds.size.height);
        
        
        
        
        // Capture touches
       /* UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(userDidTap:)];*/
       // [_touchButton addGestureRecognizer:tapGestureRecognizer];
        [self setBackgroundColor:[UIColor clearColor]];
        
        [view addSubview:self];
        [self addSubview:_touchButton];
        
        [_touchButton addTarget:self action:@selector(userDidTap:) forControlEvents:UIControlEventTouchUpInside];
        //[appDelegate.window addSubview:self];
        
    }
    
    return self;
}

/**
 *  Used to show the SlikeCoachmarkView
 */

-(void)showCoachMark {
    
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self->imageView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         if (self->_autoHideAfterInterval == TRUE) {
                             [self performSelector:@selector(hideCoachMark) withObject:nil afterDelay:self->_hideInterval];
                         }
                     }];
}

/**
 *  Used to hide the SlikeCoachmarkView on tap
 */

-(void)hideCoachMark {
    
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self->imageView.alpha = 0.0;
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self->imageView removeFromSuperview];
                         [self removeFromSuperview];
                         
                     }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    float offsetLeading = 15;
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    
    if (CGRectGetWidth(mainWindow.frame) > CGRectGetHeight(mainWindow.frame)) {
        if (@available(iOS 11.0, *)) {
            if (mainWindow.safeAreaInsets.bottom > 5.0) {
                offsetLeading += MAX(mainWindow.safeAreaInsets.left, mainWindow.safeAreaInsets.bottom);
            }
             imageView.frame = CGRectMake(offsetLeading, self.bounds.origin.y, self.bounds.size.width - offsetLeading*2, self.bounds.size.height);
        }
        
    } else {
         imageView.frame = CGRectMake(offsetLeading, self.bounds.origin.y, self.bounds.size.width - offsetLeading*2, self.bounds.size.height);
    }
}


#pragma mark - Touch handler

/**
 *  Detect single tap on coach view to hide 
 *
 *  @param recognizer UITapGestureRecognizer
 */

- (void)userDidTap:(UIButton *)recognizer {
    if ([self.delegate respondsToSelector:@selector(coachMarksView:didTapOnScreen:)]) {
        [self.delegate coachMarksView:self didTapOnScreen:self];
    }
}

@end


