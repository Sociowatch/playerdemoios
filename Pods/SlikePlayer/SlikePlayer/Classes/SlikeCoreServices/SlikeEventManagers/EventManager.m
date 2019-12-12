//
//  EventManager.m
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 28/05/18.
//

#import "EventManager.h"
#import "EventModel.h"
#import "SlikeGlobals.h"
#import "ISlikePlayer.h"
#import "EventManagerProtocol.h"
#import "SlikePlayerConstants.h"



@interface EventManager() {
    
}
@property (strong, nonatomic) NSHashTable* observers;
@property (strong, nonatomic) dispatch_queue_t queue;
@property (copy, nonatomic) onChange callBackHandler;

@end

@implementation EventManager

- (id)init {
    self = [super init];
    if (self) {
        
        self.observers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality];
        self.queue = dispatch_queue_create("com.slike.event.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


+ (instancetype )sharedEventManager {
    
    static EventManager *sharedPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlayer = [[[self class] alloc] init];
    });
    return sharedPlayer;
}

/**
 Set the completion block that will be used for sending the PLayer events
 @param eventChangeblock - Event completion block
 */
- (void)setEventHanlderBlock:(onChange)eventChangeblock {
    _callBackHandler = eventChangeblock;
}

/**
 Register the observer
 @param observer - Instance of class
 */
- (void)registerEvent:(id)observer {
    
    dispatch_async(self.queue, ^() {
        
       BOOL result = [self.observers containsObject:observer];
        if (!result) {
           [self.observers addObject:observer];
        }
    });
}

/**
 UnRegister the observer
 @param observer - Instance of class
 */
- (void)unregisterEvent:(id)observer {
    // You can't use strong or weak pointers if the observer is already in the dealloc phase (i.e. removeObserver:
    // is called from the observer's dealloc method). It will cause a crash.
    id __unsafe_unretained unretainedObserver = observer;
    dispatch_async(self.queue, ^() {
        [self.observers removeObject:unretainedObserver];
    });
}

/**
 Is already observer in the collection
 
 @param observer - Instance of class
 @return - Instance
 */
- (BOOL)containsObserver:(id)observer {
    BOOL __block result;
    dispatch_sync(self.queue, ^() {
        result = [self.observers containsObject:observer];
    });
    return result;
}

/**
 Unregitering All the Observers
 */
- (void)unregisterAllEvents {
    dispatch_async(self.queue, ^() {
        [self.observers removeAllObjects];
    });
}

/**
 Notifying the all the registered observers
 */
- (void)notifyObservers:(SlikeEventType)eventType playerState:(SlikePlayerState)state dataPayload:(NSDictionary *) payload slikePlayer:(id<ISlikePlayer>)player {
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(self.queue, ^() {
        
        for (id observer in weakSelf.observers) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                if ([observer conformsToProtocol:@protocol(EventManagerProtocol)] && [observer respondsToSelector:@selector(update:playerState:dataPayload:slikePlayer:)]) {
                    [observer update:eventType playerState:state dataPayload:payload slikePlayer:player];
                }
            });
        }
        
        //Need to check that event needs to send the parent app also
        if (self.callBackHandler && [payload boolForKey:kSlikeADispatchEventToParentKey]) {
            [self dispatchEventToParentApp:eventType playerState:state dataPayload:payload slikePlayer:player];
        }
    });
}

/**
 Dispatching the events
 
 @param eventType - Event type
 @param state - Player State
 @param payload - Custom playload
 @param player - ISlikePlayer
 */
- (void)dispatchEvent:(SlikeEventType)eventType playerState:(SlikePlayerState)state dataPayload:(NSDictionary *)payload slikePlayer:(id<ISlikePlayer>)player {
    [self notifyObservers:eventType playerState:state dataPayload:payload slikePlayer:player];    
}

/**
 Dispatch the event to parent app also
 
 @param eventType - Event type
 @param state - Player state
 @param payload - Play load that contains the custom data
 @param player - Current Player
 */
- (void)dispatchEventToParentApp:(SlikeEventType)eventType playerState:(SlikePlayerState)state dataPayload:(NSDictionary *)payload slikePlayer:(id<ISlikePlayer>)player {
   
    dispatch_async(dispatch_get_main_queue(), ^{
        //Here we have last chance to manipulate the events before passing to parent app
        StatusInfo *progressInfo = payload[kSlikeAdStatusInfoKey];
        
        if (eventType == MEDIA) {
            if(state == SL_REPLAY) {
                self.callBackHandler(MEDIA, SL_READY, progressInfo);
            }
            else if(state == SL_MUSIC_ITEM) {
                StatusInfo *itemInfo = payload[kSlikeAudioItemInfoKey];
                self.callBackHandler(MEDIA, state, itemInfo);
            }
            else {
                self.callBackHandler(MEDIA, state, progressInfo);
            }
            
        } else if (eventType == AD) {
            self.callBackHandler(eventType, state, progressInfo);
            
        }  if (eventType == CONTROLS) {
            self.callBackHandler(eventType, state, nil);
            
        }
        
    });
}

@end
