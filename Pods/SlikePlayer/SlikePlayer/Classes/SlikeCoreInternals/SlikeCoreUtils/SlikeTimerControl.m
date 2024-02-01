//
//  SlikeTimerControl.m

#import "SlikeTimerControl.h"


@interface NSTimer (SlikeTimerControl)
+ (NSTimer *)timer_timerWithTimeInterval:(NSTimeInterval)ti
                                   block:(void(^)(NSTimer *timer))block
                                 repeats:(BOOL)repeats;
@end

@implementation NSTimer (SlikeTimerControl)
+ (NSTimer *)timer_timerWithTimeInterval:(NSTimeInterval)ti
                                   block:(void(^)(NSTimer *timer))block
                                 repeats:(BOOL)repeats {
    NSTimer *timer = [NSTimer timerWithTimeInterval:ti
                                             target:self
                                           selector:@selector(timer_exeBlock:)
                                           userInfo:block
                                            repeats:repeats];
    return timer;
}

+ (void)timer_exeBlock:(NSTimer *)timer {
    void(^block)(NSTimer *timer) = timer.userInfo;
    if ( block ) block(timer);
}

@end




@interface SlikeTimerControl ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) short point;
@property (nonatomic, assign) BOOL resetState;
@property (nonatomic, assign) short tickCounter;
@end

const NSInteger kTimerCounter = 5;

@implementation SlikeTimerControl

- (instancetype)init {
    self = [super init];
    if ( self ) {
        self.interval = 1;
        self.counter = kTimerCounter;
    }
    return self;
}

- (void)setInterval:(short)interval {
    _interval = interval;
    _point = interval;
    
}

- (void)start {
    [self clear];
    
    __weak typeof(self) _self = self;
    _timer = [NSTimer timer_timerWithTimeInterval:1 block:^(NSTimer *timer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( 0 == --self.point ) {
            if ( self.executionBlock ) self.executionBlock(self);
            if ( !self.resetState ) [self clear];
            self.resetState = NO;
        }
    } repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}


- (void)repeat {
    
    [self clear];
    
    __weak typeof(self) _self = self;
    _timer = [NSTimer timer_timerWithTimeInterval:1 block:^(NSTimer *timer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        --self.counter;
        if ( self.executionBlock ) self.executionBlock(self);
        
        
    } repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

- (void)clear {
    
    _counter = kTimerCounter;
    [_timer invalidate];
    _timer = nil;
    _point = _interval;
}

- (void)reset {
    _counter = kTimerCounter;
    _point = _interval;
    _resetState = YES;
    _counter = 0;
}
@end
