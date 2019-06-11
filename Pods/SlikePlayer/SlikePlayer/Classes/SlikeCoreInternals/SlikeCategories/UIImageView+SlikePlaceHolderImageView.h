//
//  UIImageView+SlikePlaceHolderImageView.h
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 23/08/18.
//

#import <UIKit/UIKit.h>

@class SlikeConfig;

@interface UIImageView (SlikePlaceHolderImageView)

- (void)setPlaceHolderImage:(BOOL)isSet configModel:(SlikeConfig* )slikeConfig withPlayerView:(UIView *)playerView;

@end
