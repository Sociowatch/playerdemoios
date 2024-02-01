//
//  CPSlider.m
//  CPSlider
//

/**
 * Copyright (c) 2016 Charles Powell
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#import "CPSlider.h"

@interface CPSlider ()

@property (nonatomic) CGFloat startingX;
@property (nonatomic) float lastValue;
@property (nonatomic) NSUInteger currentSpeedPositionIndex;
@property (nonatomic) float effectiveValue;
@property (nonatomic) float verticalChangeAdjustment;
@property (nonatomic) float horizontalChangeAdjustment;
@property (nonatomic) BOOL isSliding;
// NOTE: just using self.tracking causes order-of-occurance problems, so use this isSliding method internally

@end

@implementation CPSlider

@synthesize arrMarkers;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSliderDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSliderDefaults];
    }
    return self;
}

-(void) adMarkerDoneAtIndex:(NSInteger) nIndex
{
    if(self.arrMarkers)
    {
        NSInteger nLen = [self.arrMarkers count];
        if(nLen > 0 && nIndex <= nLen)
        {
            SlikeDLog(@"Ad marker is removed at %ld", (long)nIndex);
            [self.arrMarkers replaceObjectAtIndex:nIndex withObject:[NSNumber numberWithInt:0]];
        }
    }
}

/*- (CGRect)trackRectForBounds:(CGRect)bounds {
 CGRect result = [super trackRectForBounds:bounds];
 result.size.height = 1;
 return result;
 }*/

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    float fRatio = self.frame.size.width / self.maximumValue;
    if(isnan(fRatio)) return;
    if(isinf(fRatio)) return;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(!context) return;
    CGRect theRect;
    /*CGContextSetShouldAntialias(context, NO);
     CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
     CGContextSetLineJoin(context, kCGLineJoinMiter);
     CGContextSetLineWidth(context, 0.5);
     
     CGRect theRect = self.bounds;
     theRect.size.height = 3;
     theRect.origin.y = (self.bounds.size.height - theRect.size.height) / 2;
     //theRect.origin.y += 0.25f;
     if(theRect.size.width <= 0) theRect.size.width = 1;
     if(isnan(theRect.size.width)) theRect.size.width = 1;
     CGPathRef path = CGPathCreateWithRect(theRect, NULL);
     CGMutablePathRef pathRef = CGPathCreateMutableCopy(path);
     CGPathCloseSubpath(pathRef);
     
     //CGContextAddPath(context, pathRef);
     //CGContextFillPath(context);
     
     CGContextAddPath(context, pathRef);
     CGContextStrokePath(context);
     CGPathRelease(path);
     CGPathRelease(pathRef);
     
     //Draw played section
     CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
     CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
     CGContextSetLineJoin(context, kCGLineJoinMiter);
     CGContextSetLineWidth(context, 0.5);
     
     theRect = self.bounds;
     theRect.size.height = 1;
     theRect.origin.y = (self.bounds.size.height - theRect.size.height) / 2;
     theRect.size.width = fRatio * (isnan(self.value) ? 1 : self.value);
     if(isnan(theRect.size.width)) theRect.size.width = 1;
     path = CGPathCreateWithRect(theRect, NULL);
     pathRef = CGPathCreateMutableCopy(path);
     
     CGPathCloseSubpath(pathRef);
     
     CGContextAddPath(context, pathRef);
     CGContextFillPath(context);
     
     CGContextAddPath(context, pathRef);
     CGContextStrokePath(context);
     CGPathRelease(path);
     CGPathRelease(pathRef);*/
    
    //Draw ad bars...
    if(self.arrMarkers)
    {
        theRect = self.bounds;
        theRect.size.height = 2;
        NSInteger nMid = (self.bounds.size.height - theRect.size.height) / 2;
        NSInteger nMax = nMid + theRect.size.height;
        if([self.arrMarkers count] > 0)
        {
            CGContextSetLineWidth(context, 1);
            CGContextSetRGBStrokeColor(context, 0.99f, 0.98f, 0.016f, 1.0f);
            CGContextBeginPath(context);
            NSInteger nLen = [self.arrMarkers count];
            NSInteger nIndex;
            NSInteger nSecs = 0;
            for(nIndex = 0; nIndex < nLen; nIndex++)
            {
                //fSecs = fRatio * nSecs;
                nSecs = [[self.arrMarkers objectAtIndex:nIndex] integerValue];
                if(nSecs == 0) continue;
                nSecs += 4;
                CGContextMoveToPoint(context, fRatio * nSecs, nMid);
                CGContextAddLineToPoint (context, fRatio * nSecs, nMax);
            }
            CGContextStrokePath(context);
        }
    }
}

- (void)setupSliderDefaults
{
    self.scrubbingSpeedPositions = [NSArray arrayWithObjects:
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:50],
                                    [NSNumber numberWithInt:100],
                                    [NSNumber numberWithInt:150], nil];
    
    self.scrubbingSpeeds = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:1.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.25f],
                            [NSNumber numberWithFloat:0.1f], nil];
    
    self.effectiveValue = 0.0f;
    self.ignoreDraggingAboveSlider = YES;
    self.accelerateWhenReturning = YES;
}

#pragma mark - Custom UISlider getters/setters

- (void)setValue:(float)value animated:(BOOL)animated {
    // Catch "jump" which occurs in iOS 7 and up
    if (!self.isTracking && self.isSliding) {
        return;
    }
    if (self.isSliding) {
        // Adjust effective value
        float effectiveDifference = (value - self.lastValue) * self.currentScrubbingSpeed;
        
        self.effectiveValue += (effectiveDifference + self.verticalChangeAdjustment + self.horizontalChangeAdjustment);
        // Reset adjustments
        self.verticalChangeAdjustment = 0.0f;
        self.horizontalChangeAdjustment = 0.0f;
        
        self.lastValue = value;
        
    } else {
        // No adjustment
        self.effectiveValue = value;
    }
    
    // Either way, set use super to set true value
    float actual = MAX(MIN(value, self.maximumValue), self.minimumValue);
    
    [super setValue:actual animated:animated];
}

- (float)value {
    if (self.isSliding) {
        // If sliding, return the effective value
        return self.effectiveValue;
    } else {
        // Otherwise, the true value (grabbed via super to prevent infinite recursion)
        return [super value];
    }
}

#pragma mark - Custom getters/setters

- (void)setCurrentSpeedPositionIndex:(NSUInteger)currentSpeedPositionIndex {
    if (_currentSpeedPositionIndex == currentSpeedPositionIndex) {
        return;
    }
    
    if (currentSpeedPositionIndex == NSNotFound) {
        currentSpeedPositionIndex = self.scrubbingSpeedPositions.count-1;
    }
    _currentSpeedPositionIndex = currentSpeedPositionIndex;
    
    // Notify delegates
    if ([self.delegate respondsToSelector:@selector(slider:didChangeToSpeedIndex:whileTracking:)]) {
        [self.delegate slider:self didChangeToSpeedIndex:_currentSpeedPositionIndex whileTracking:self.isSliding];
    }
    if ([self.delegate respondsToSelector:@selector(slider:didChangeToSpeed:whileTracking:)] && _currentSpeedPositionIndex != NSNotFound) {
        [self.delegate slider:self didChangeToSpeed:[[self.scrubbingSpeeds objectAtIndex:_currentSpeedPositionIndex] floatValue] whileTracking:self.isSliding];
    }
}

- (void)setEffectiveValue:(float)effectiveValue {
    if (_effectiveValue == effectiveValue) {
        return;
    }
    
    _effectiveValue = MAX(MIN(effectiveValue, self.maximumValue), self.minimumValue);
}

#pragma mark - Touch handlers

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    float value = [self value];
    
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    
    CGPoint currentTouchPoint = [touch locationInView:self];
    
    CGRect thumbRect = [self thumbRectForBounds:self.bounds trackRect:trackRect value:value];
    
    if(CGRectContainsPoint(thumbRect, currentTouchPoint))
    {
        self.isSliding = YES;
        self.currentSpeedPositionIndex = 0;
        self.startingX = thumbRect.size.width - CGRectGetMaxX(thumbRect) + currentTouchPoint.x;
        self.lastValue = value;
    }
    
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.isSliding) {
        CGRect trackRect = [self trackRectForBounds:self.bounds];
        
        CGPoint currentTouchPoint = [touch locationInView:self];
        currentTouchPoint.x -= trackRect.origin.x;
        
        CGPoint previousTouchPoint = [touch previousLocationInView:self];
        CGFloat verticalDownrange = currentTouchPoint.y - CGRectGetMidY(trackRect);
        self.currentSpeedPositionIndex = [self scrubbingSpeedPositionForVerticalDownrange:verticalDownrange];
        
        // Check if the touch is returning to the slider
        float maxDownrange = [[self.scrubbingSpeedPositions lastObject] floatValue];
        if (self.accelerateWhenReturning &&
            fabs(currentTouchPoint.y) < fabs(previousTouchPoint.y) && // adjust only if touch is returning
            fabs(currentTouchPoint.y) < maxDownrange && // adjust only if it's inside the furthest slider speed position
            ![self pointInside:currentTouchPoint withEvent:nil]) // do not adjust if the touch is on the slider. Prevents jumpiness when default speed is not 1.0f
        {
            // Calculate and apply any vertical adjustment
            verticalDownrange = fabs(verticalDownrange);
            float adjustmentRatio = powf((1 - (verticalDownrange/maxDownrange)), 4);
            self.verticalChangeAdjustment = ([super value] - self.effectiveValue) * adjustmentRatio;
        }
        
        // Apply horizontal change (emulation (I think?) of standard UISlider)
        
        CGRect thumbRect = [self thumbRectForBounds:self.bounds trackRect:trackRect value:0.0f];
        
        CGFloat newValue = self.minimumValue + (self.maximumValue - self.minimumValue) * (currentTouchPoint.x - self.startingX) / (trackRect.size.width - thumbRect.size.width);
        
        [self setValue:newValue animated:NO];
        [self setNeedsLayout];
        
        // Send UIControl action
        if (self.continuous) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    // Pre-set value to effective value
    [super setValue:self.effectiveValue animated:NO];
    
    // Call super before changing isSliding to NO, to catch value change
    // in same logic used for iOS 7+ "jump" fix
    [super endTrackingWithTouch:touch withEvent:event];
    
    // Reset
    self.currentSpeedPositionIndex = 0;
    self.isSliding = NO;
}

- (void)cancelTrackingWithEvent:(nullable UIEvent *)event
{
    if(event)[super cancelTrackingWithEvent:event];
    self.currentSpeedPositionIndex = 0;
    self.isSliding = NO;
}

#pragma mark - UISlider Rect methods

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect thumbRect;
    if (self.isSliding) {
        // If sliding, use the effective value to place the thumb
        thumbRect = [super thumbRectForBounds:bounds trackRect:rect value:self.effectiveValue];
    } else {
        // Otherwise, use the true value
        thumbRect = [super thumbRectForBounds:bounds trackRect:rect value:self.value];
    }
    return thumbRect;
}

#pragma mark - Other Helpers

- (NSUInteger)scrubbingSpeedPositionForVerticalDownrange:(CGFloat)downrange {
    // Ignore negative downranges if specified
    if (self.ignoreDraggingAboveSlider) {
        downrange = MAX(downrange, 0);
    }
    
    return [self.scrubbingSpeedPositions indexOfObjectWithOptions:NSEnumerationReverse passingTest:^BOOL(NSNumber *obj, NSUInteger idx, BOOL *stop){
        if (downrange >= [obj floatValue]) {
            return YES;
        }
        return NO;
    }];
}

- (float)currentScrubbingSpeed {
    return [[self.scrubbingSpeeds objectAtIndex:self.currentSpeedPositionIndex] floatValue];
}

- (NSUInteger)currentScrubbingSpeedPosition {
    return self.currentSpeedPositionIndex;
}

@end
