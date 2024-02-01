#import <UIKit/UIKit.h>

@protocol CPSliderDelegate;

@interface CPSlider : UISlider

@property (nonatomic, unsafe_unretained) id <CPSliderDelegate>delegate;
@property (nonatomic, strong) NSArray *scrubbingSpeedPositions;
@property (nonatomic, strong) NSArray *scrubbingSpeeds;
@property (nonatomic, strong) NSMutableArray *arrMarkers;
@property (nonatomic, readonly) float currentScrubbingSpeed;
@property (nonatomic, readonly) NSUInteger currentScrubbingSpeedPosition;

@property (nonatomic) BOOL accelerateWhenReturning;

@property (nonatomic) BOOL ignoreDraggingAboveSlider;
-(void) adMarkerDoneAtIndex:(NSInteger) nIndex;
@end


@protocol CPSliderDelegate <NSObject>

@optional
- (void)slider:(CPSlider *)slider didChangeToSpeed:(CGFloat)speed whileTracking:(BOOL)tracking;
- (void)slider:(CPSlider *)slider didChangeToSpeedIndex:(NSUInteger)index whileTracking:(BOOL)tracking;

@end
