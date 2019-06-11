//
//  SlikeTapGestureRecognizer.h
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 30/05/18.
//

#import <UIKit/UIKit.h>

@protocol SlikeTapGestureRecognizerDelegate <NSObject>
- (void)passEventToParent;
@end

@interface SlikeTapGestureRecognizer : UITapGestureRecognizer
@property(assign, nonatomic)id <SlikeTapGestureRecognizerDelegate>gestureDelegate;
@end
