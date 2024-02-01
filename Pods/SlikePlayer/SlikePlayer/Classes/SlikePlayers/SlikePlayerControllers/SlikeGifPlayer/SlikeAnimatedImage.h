//
//  SlikeAnimatedImage.h

#import <Foundation/Foundation.h>
@protocol SlikeAnimatedImageDebugDelegate;


//
//  An `SlikeAnimatedImage`'s job is to deliver frames in a highly performant way and works in conjunction with `SlikeAnimatedImageView`.
//  It subclasses `NSObject` and not `UIImage` because it's only an "image" in the sense that a sea lion is a lion.
//  It tries to intelligently choose the frame cache size depending on the image and memory situation with the goal to lower CPU usage for smaller ones, lower memory usage for larger ones and always deliver frames for high performant play-back.
//  Note: `posterImage`, `size`, `loopCount`, `delayTimes` and `frameCount` don't change after successful initialization.
//
@interface SlikeAnimatedImage : NSObject

@property (nonatomic, strong, readonly) UIImage *posterImage; // Guaranteed to be loaded; usually equivalent to `-imageLazilyCachedAtIndex:0`
@property (nonatomic, assign, readonly) CGSize size; // The `.posterImage`'s `.size`

@property (nonatomic, assign, readonly) NSUInteger loopCount; // 0 means repeating the animation indefinitely
@property (nonatomic, strong, readonly) NSArray *delayTimes; // Of type `NSTimeInterval` boxed in `NSNumber`s
@property (nonatomic, assign, readonly) NSUInteger frameCount; // Number of valid frames; equal to `[.delayTimes count]`

@property (nonatomic, assign, readonly) NSUInteger frameCacheSizeCurrent; // Current size of intelligently chosen buffer window; can range in the interval [1..frameCount]
@property (nonatomic, assign) NSUInteger frameCacheSizeMax; // Allow to cap the cache size; 0 means no specific limit (default)

// Intended to be called from main thread synchronously; will return immediately.
// If the result isn't cached, will return `nil`; the caller should then pause playback, not increment frame counter and keep polling.
// After an initial loading time, depending on `frameCacheSize`, frames should be available immediately from the cache.
- (UIImage *)imageLazilyCachedAtIndex:(NSUInteger)index;

// Pass either a `UIImage` or an `SlikeAnimatedImage` and get back its size
+ (CGSize)sizeForImage:(id)image;

// Designated initializer
// On success, returns a new `SlikeAnimatedImage` with all fields populated, on failure returns `nil` and an error will be logged.
- (instancetype)initWithAnimatedGIFData:(NSData *)data;

@property (nonatomic, strong, readonly) NSData *data; // The data the receiver was initialized with; read-only

#if DEBUG
// Only intended to report internal state for debugging
@property (nonatomic, weak) id<SlikeAnimatedImageDebugDelegate> debug_delegate;
#endif

@end


@interface SLWeakProxy : NSProxy

+ (instancetype)weakProxyForObject:(id)targetObject;

@end


#if DEBUG
@protocol SlikeAnimatedImageDebugDelegate <NSObject>

@optional

- (void)debug_animatedImage:(SlikeAnimatedImage *)animatedImage didUpdateCachedFrames:(NSIndexSet *)indexesOfFramesInCache;
- (void)debug_animatedImage:(SlikeAnimatedImage *)animatedImage didRequestCachedFrame:(NSUInteger)index;
- (CGFloat)debug_animatedImagePredrawingSlowdownFactor:(SlikeAnimatedImage *)animatedImage;

@end
#endif
