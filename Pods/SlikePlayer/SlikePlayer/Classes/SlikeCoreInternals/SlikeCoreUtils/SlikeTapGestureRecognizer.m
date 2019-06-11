//
//  SlikeTapGestureRecognizer.m
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 30/05/18.
//

#import "SlikeTapGestureRecognizer.h"

@interface SlikeTapGestureRecognizer () <UIGestureRecognizerDelegate>

@end

@implementation SlikeTapGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    
    if (self = [super initWithTarget:target action:action]) {
        self.delegate = self;
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if([touch.view isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    return YES;
}


@end
