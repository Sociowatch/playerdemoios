//
//  EventManager.h
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 28/05/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>
#import "SlikeGlobals.h"
#import "ISlikePlayer.h"

@interface EventManager : NSObject

- (instancetype) init __attribute__((unavailable("init not available")));
+ (instancetype )sharedEventManager;

/**
 Register the observer
 @param observer - Instance of class
 */
- (void)registerEvent:(id)observer;

/**
 UnRegister the observer
 @param observer - Instance of class
 */
- (void)unregisterEvent:(id)observer;

/**
 Unregitering All the Observers
 */
- (void)unregisterAllEvents;

/**
 Dispatching the events
 
 @param eventType - Event type
 @param state - Player State
 @param payload - Custom playload
 @param player - ISlikePlayer
 */
- (void)dispatchEvent:(SlikeEventType)eventType playerState:(SlikePlayerState)state dataPayload:(NSDictionary *) payload slikePlayer:(id<ISlikePlayer>)player;


/**
 Event handler block that can be used to notify  parent app about the events
 @param eventChangeblock - Event handler block
 */
- (void)setEventHanlderBlock:(onChange)eventChangeblock;


@end
