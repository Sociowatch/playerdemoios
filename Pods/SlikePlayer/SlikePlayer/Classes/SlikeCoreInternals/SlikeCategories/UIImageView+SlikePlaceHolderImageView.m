//
//  UIImageView+SlikePlaceHolderImageView.m
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 23/08/18.
//

#import "UIImageView+SlikePlaceHolderImageView.h"
#import "SlikeNetworkManager.h"
#import "UIView+SlikeAlertViewAnimation.h"
#import "SlikeConfig.h"

@implementation UIImageView (SlikePlaceHolderImageView)

- (void)setPlaceHolderImage:(BOOL)isSet configModel:(SlikeConfig* )slikeConfig withPlayerView:(UIView *)playerView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(!isSet && self.hidden) {
            return;
        }
        if(slikeConfig.isAllowSlikePlaceHolder) {
            self.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1];
            
            if(isSet) {
                
                if(self.image!=nil) {
                    [self slike_fadeInTime:0.1 withCompletion:^(UIView *view) {
                        self.hidden= NO;
                        playerView.hidden = NO;
                    }];
                }
                else if([SlikeUtilities getPosterImage:slikeConfig].length>0) {
                    
                    [[SlikeNetworkManager defaultManager] getImageForURL:[NSURL URLWithString:[SlikeUtilities getPosterImage:slikeConfig]] completion:^(UIImage *image, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
                        
                        if(!error) {
                            self.hidden = NO;
                            self.image =image;
                        }
                        else {
                            
                            [self slike_fadeOutAndCompletion:^(UIView *view) {
                                self.hidden= YES;
                                playerView.hidden = NO;
                            }];
                        }
                    }];
                    
                } else {
                    
                    [self slike_fadeOutAndCompletion:^(UIView *view) {
                        self.hidden= YES;
                        playerView.hidden = NO;
                    }];
                }
            } else {
                
                if(!self.hidden) {
                    [self slike_fadeOutAndCompletion:^(UIView *view) {
                        self.hidden= YES;
                        playerView.hidden = NO;
                    }];
                }
            }
        } else {
            self.hidden= YES;
        }
    });
}

- (void)setThumbImage:(NSString *)thumbURLString {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SlikeNetworkManager defaultManager] getImageForURL:[NSURL URLWithString:thumbURLString] completion:^(UIImage *image, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
            if(!error) {
                self.image =image;
            }
        }];
    });
}
@end
