//
//  SlikeBitratesView.h
//  Pods
//
//  Created by Sanjay Singh Rathor on 23/07/18.
//

#import <UIKit/UIKit.h>
@class SlikeConfig;

@interface SlikeBitratesView : UIView

+ (instancetype )slikeBitratesView;

/**
 Method for presenting the Available Bitrates
 */
- (void)presentAvailableBitratesForStream;
@property (weak, nonatomic) SlikeConfig *configModel;

@property (copy, nonatomic) void (^selectedBirateBlock)(id bitrateType);
@property (copy, nonatomic) void (^closeButtonBlock)(void);


@end
