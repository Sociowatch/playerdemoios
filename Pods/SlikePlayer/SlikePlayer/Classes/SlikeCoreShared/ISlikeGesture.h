//
//  ISlikeGesture.h
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 08/06/18.
//

#ifndef ISlikeGesture_h
#define ISlikeGesture_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol ISlikeGesture;

@protocol ISlikeGesture<NSObject>

- (void)beganPanWithTouchPoints:(CGPoint)touchPoint;
- (void)changedPanOnVolumeChange:(float)distance;
- (void)changedPanOnBrightnessChange:(float)distance;
- (void)changedPanOnSeek:(float)distance;
- (void)endPanOnVolumeChange;
- (void)endPanOnBrightnessChange;
- (void)endPanOnSeek:(float)distance;

@end

#endif /* ISlikeGesture_h */
