//
//  SlikeGesture.h
//  Pods
//
//  Created by Sanjay Singh Rathor on 10/06/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ISlikeGesture.h"

@interface SlikeGesture : NSObject

/**
 Get the gesture events from the Target View

 @param view - Target View
 @param gestureDeleate - Delegate that will be called  to tell the listner about the changes
 @param isSeekEbnabled - YES|NO - Seeking events
 @return - Instance
 */
- (instancetype)initWithTargetView:(__weak UIView *)view withDelegate:(id<ISlikeGesture>) gestureDeleate withSeekEnabled:(BOOL) isSeekEbnabled;

/**
 Enable or desiable the gestures. By default it is anabled
 @param isEnable - TRUE|FALSE
 */
- (void)enablePanGesture:(BOOL)isEnable;

@end
