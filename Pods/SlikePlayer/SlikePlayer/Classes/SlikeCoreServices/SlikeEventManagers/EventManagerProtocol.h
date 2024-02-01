//
//  EventManagerProtocol.h
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 05/06/18.
//

#ifndef EventManagerProtocol_h
#define EventManagerProtocol_h

#import <UIKit/UIkit.h>
#import "SlikeGlobals.h"

@protocol EventManagerProtocol<NSObject>

@required
- (void)update:(SlikeEventType)eventType playerState:(SlikePlayerState)state dataPayload:(NSDictionary *) payload slikePlayer:(id<ISlikePlayer>)player;
@end
#endif /* EventManagerProtocol_h */
